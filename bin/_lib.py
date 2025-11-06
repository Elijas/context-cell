#!/usr/bin/env python3
"""Shared helpers for the Agent Checkpoints Framework Toolchain (acft).

This module centralises the filesystem discovery logic, checkpoint parsing,
event emission, and high-level data structures the CLI commands rely on.
The intent mirrors the framework philosophy from the specification:
keep the contract explicit, make rooted paths unambiguous, and ensure
automation shares the same primitives as humans.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import getpass
import json
import os
import re
import subprocess
import textwrap
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple


ISO_TIMESTAMP_RE = re.compile(
    r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"
    r"(?:\.\d+)?"  # optional fractional seconds
    r"(?:Z|[+-]\d{2}:\d{2})$"
)

CHECKPOINT_NAME_RE = re.compile(r"^(?P<branch>[a-z0-9_]+)_v(?P<version>\d+)_(?P<step>\d{2})$")


class AcftError(Exception):
    """Base exception for ACFT-related failures."""


class PathResolutionError(AcftError):
    """Raised when rooted path expansion fails."""


class CheckpointFormatError(AcftError):
    """Raised when `CHECKPOINT.md` cannot be parsed as expected."""


def utcnow_iso() -> str:
    """Return a UTC ISO-8601 timestamp compatible with event schema."""
    return (
        _dt.datetime.utcnow()
        .replace(tzinfo=_dt.timezone.utc)
        .isoformat()
        .replace("+00:00", "Z")
    )


def ensure_relative(path: Path, root: Optional[Path]) -> Optional[Path]:
    """Return `path` relative to `root` if possible, otherwise `None`."""
    if root is None:
        return None
    try:
        return path.relative_to(root)
    except ValueError:
        return None


def _load_optional_file(path: Path) -> Optional[str]:
    if not path or not path.exists():
        return None
    return path.read_text(encoding="utf-8")


def _strip_bom(text: str) -> str:
    return text.lstrip("\ufeff")


def _detect_sections(body: str) -> Tuple[Dict[str, str], List[str]]:
    """Parse Markdown sections (# HEADER) into a dict preserving order."""
    sections: Dict[str, str] = {}
    order: List[str] = []
    current_name: Optional[str] = None
    current_lines: List[str] = []
    fence_active = False

    for line in body.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("```"):
            fence_active = not fence_active
            current_lines.append(line)
            continue
        if not fence_active and stripped.startswith("# "):
            if current_name is not None:
                sections[current_name] = "\n".join(current_lines).strip()
                current_lines = []
            current_name = stripped[2:].strip()
            order.append(current_name)
        else:
            current_lines.append(line)

    if current_name is not None:
        sections[current_name] = "\n".join(current_lines).strip()

    return sections, order


def _parse_yaml_frontmatter(text: str) -> Tuple[Dict[str, Any], List[str]]:
    """
    Parse a simple YAML frontmatter block into a dictionary.

    This lightweight parser intentionally covers the narrow subset of YAML we
    use in checkpoints (scalars and flat lists). When PyYAML is available the
    implementation falls back to it for extra resilience.
    """

    fm: Dict[str, Any] = {}
    order: List[str] = []
    block = text.strip()
    if not block:
        return fm, order

    try:  # Prefer PyYAML when installed.
        import yaml  # type: ignore

        data = yaml.safe_load(block) or {}
        if isinstance(data, dict):
            fm = dict(data)
            order = list(fm.keys())
            return fm, order

    except Exception:  # pragma: no cover - fallback for portability
        pass

    current_key: Optional[str] = None
    current_list: Optional[List[Any]] = None
    for raw_line in block.splitlines():
        line = raw_line.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        if line.startswith("  -") and current_key:
            # we only support single indentation level for lists
            value = line.split("-", 1)[1].strip()
            if current_list is None:
                current_list = []
            current_list.append(_parse_scalar(value))
            fm[current_key] = list(current_list)
            continue

        if ":" in line:
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip()
            order.append(key)
            current_key = key
            if not value:
                current_list = []
                fm[key] = current_list
            else:
                current_list = None
                fm[key] = _parse_scalar(value)
        else:
            raise CheckpointFormatError(f"Invalid frontmatter line: {line}")

    return fm, order


def _parse_scalar(token: str) -> Any:
    lowered = token.lower()
    if lowered in {"true", "false"}:
        return lowered == "true"
    if lowered in {"null", "none"}:
        return None
    if re.fullmatch(r"-?\d+", token):
        try:
            return int(token)
        except ValueError:
            pass
    if re.fullmatch(r"-?\d+\.\d+", token):
        try:
            return float(token)
        except ValueError:
            pass
    if (token.startswith("'") and token.endswith("'")) or (
        token.startswith('"') and token.endswith('"')
    ):
        return token[1:-1]

    if token.startswith("[") and token.endswith("]"):
        items = []
        inner = token[1:-1].strip()
        if inner:
            for part in inner.split(","):
                items.append(_parse_scalar(part.strip()))
        return items
    return token


def _dump_simple_yaml(data: Dict[str, Any], order: List[str]) -> str:
    """Serialise a dict back into YAML respecting the original key order."""
    lines: List[str] = []
    keys = order or list(data.keys())
    seen = set()
    for key in keys:
        if key not in data or key in seen:
            continue
        value = data[key]
        lines.extend(_format_yaml_entry(key, value))
        seen.add(key)
    for key, value in data.items():
        if key in seen:
            continue
        lines.extend(_format_yaml_entry(key, value))
    return "\n".join(lines)


def _format_yaml_entry(key: str, value: Any) -> List[str]:
    if isinstance(value, list):
        lines = [f"{key}:"]
        for item in value:
            lines.append(f"  - {_format_yaml_scalar(item)}")
        if len(value) == 0:
            lines.append("  -")
        return lines
    return [f"{key}: {_format_yaml_scalar(value)}"]


def _format_yaml_scalar(value: Any) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if value is None:
        return ""
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value)
    if re.search(r"[\s:#]", text):
        return json.dumps(text)
    return text


@dataclass
class LogEntry:
    timestamp: Optional[_dt.datetime]
    raw_timestamp: Optional[str]
    message: str


@dataclass
class ManifestLedgerEntry:
    name: str
    path: str
    purpose: str


@dataclass
class Checkpoint:
    path: Path
    context: "AcftContext"
    frontmatter: Dict[str, Any] = field(default_factory=dict)
    frontmatter_order: List[str] = field(default_factory=list)
    sections: Dict[str, str] = field(default_factory=dict)
    section_order: List[str] = field(default_factory=list)

    @property
    def name(self) -> str:
        return self.path.name

    @property
    def checkpoint_md(self) -> Path:
        return self.path / "CHECKPOINT.md"

    def load(self) -> None:
        if not self.checkpoint_md.exists():
            raise CheckpointFormatError(
                f"{self.checkpoint_md} does not exist for checkpoint {self.path}"
            )
        content = _strip_bom(self.checkpoint_md.read_text(encoding="utf-8"))
        if not content.startswith("---"):
            raise CheckpointFormatError(
                f"{self.checkpoint_md} missing YAML frontmatter delimiter"
            )
        parts = content.split("\n", 2)
        frontmatter_end = content.find("\n---", 3)
        if frontmatter_end == -1:
            raise CheckpointFormatError(
                f"{self.checkpoint_md} missing closing YAML delimiter"
            )
        frontmatter_block = content[3:frontmatter_end]
        remaining = content[frontmatter_end + 4 :].lstrip("\n")

        fm, order = _parse_yaml_frontmatter(frontmatter_block)
        self.frontmatter = fm
        self.frontmatter_order = order

        sections, section_order = _detect_sections(remaining)
        self.sections = sections
        self.section_order = section_order

    def write_frontmatter(self) -> None:
        if not self.checkpoint_md.exists():
            raise CheckpointFormatError("Cannot write frontmatter: CHECKPOINT.md missing")
        original = self.checkpoint_md.read_text(encoding="utf-8")
        if not original.startswith("---"):
            raise CheckpointFormatError(
                "Cannot write frontmatter: missing YAML delimiter"
            )
        closing = original.find("\n---", 3)
        if closing == -1:
            raise CheckpointFormatError(
                "Cannot write frontmatter: missing closing YAML delimiter"
            )
        payload = original[closing + 4 :]
        rendered = _dump_simple_yaml(self.frontmatter, self.frontmatter_order)
        new_content = f"---\n{rendered}\n---\n{payload.lstrip()}"
        self.checkpoint_md.write_text(new_content, encoding="utf-8")

    def append_log_entry(self, message: str, timestamp: Optional[str] = None) -> None:
        ts = timestamp or utcnow_iso()
        section = self.sections.get("LOG", "")
        entry = f"- {ts} - {message}".rstrip()
        if section:
            section = section.rstrip() + "\n" + entry + "\n"
        else:
            section = entry + "\n"
        self.sections["LOG"] = section.strip() + "\n"
        self._rewrite_section("LOG")

    def _rewrite_section(self, name: str) -> None:
        if name not in self.section_order:
            self.section_order.append(name)
        # Reconstruct the markdown file from sections, preserving order.
        parts = ["---", _dump_simple_yaml(self.frontmatter, self.frontmatter_order), "---", ""]
        for section_name in self.section_order:
            body = self.sections.get(section_name, "").rstrip()
            parts.append(f"# {section_name}")
            if body:
                parts.append(body)
            parts.append("")  # Blank line between sections.
        payload = "\n".join(parts).rstrip() + "\n"
        self.checkpoint_md.write_text(payload, encoding="utf-8")

    def manifest_ledger(self) -> List[ManifestLedgerEntry]:
        manifest = self.sections.get("MANIFEST", "")
        if not manifest:
            return []
        entries: List[ManifestLedgerEntry] = []
        lines = manifest.splitlines()
        inside = False
        for line in lines:
            if line.strip().upper().startswith("## MANIFEST LEDGER"):
                inside = True
                continue
            if inside and line.startswith("## "):
                break
            if inside:
                line_stripped = line.strip()
                if not line_stripped or line_stripped.startswith(">"):
                    continue
                if line_stripped.startswith("- "):
                    line_stripped = line_stripped[2:].strip()
                parts = [part.strip() for part in line_stripped.split("->")]
                # Example format: Deliverable -> ::THIS/ARTIFACTS/foo -> Intent
                if len(parts) >= 2:
                    name = parts[0]
                    path_part = parts[1]
                    purpose = " -> ".join(parts[2:]) if len(parts) > 2 else ""
                    entries.append(ManifestLedgerEntry(name=name, path=path_part, purpose=purpose))
        return entries

    def log_entries(self) -> List[LogEntry]:
        section = self.sections.get("LOG", "")
        if not section.strip():
            return []
        entries: List[LogEntry] = []
        for line in section.splitlines():
            line = line.strip()
            if not line or not line.startswith("-"):
                continue
            match = re.match(r"^- ([^ ]+) - (.*)$", line)
            if not match:
                continue
            raw_timestamp = match.group(1)
            message = match.group(2).strip()
            ts: Optional[_dt.datetime] = None
            if ISO_TIMESTAMP_RE.match(raw_timestamp):
                try:
                    ts = _dt.datetime.fromisoformat(
                        raw_timestamp.replace("Z", "+00:00")
                    )
                except ValueError:
                    ts = None
            entries.append(LogEntry(timestamp=ts, raw_timestamp=raw_timestamp, message=message))
        return entries

    def first_status_sentence(self) -> str:
        status = self.sections.get("STATUS", "").strip()
        if not status:
            return ""
        sentence = status.split(".")[0].strip()
        return sentence


class AcftContext:
    """Resolve project/work roots and rooted path helpers."""

    def __init__(self, project_root: Optional[Path], work_root: Optional[Path], checkpoint_root: Optional[Path], acft_root: Path):
        self.project_root = project_root
        self.work_root = work_root
        self.checkpoint_root = checkpoint_root
        self.acft_root = acft_root

    @classmethod
    def discover(cls, start: Optional[Path] = None) -> "AcftContext":
        start = start or cls._symlink_aware_cwd()
        script_dir = Path(__file__).resolve().parent
        acft_root = script_dir.parent
        project_root = cls._search_upwards(
            start,
            markers=["checkpoints_project.toml"],
        )
        work_root = cls._search_upwards(
            start,
            markers=["checkpoints_work.toml"],
            stop=project_root,
        )
        checkpoint_root = cls._find_checkpoint_root(start, stop_at=work_root)
        return cls(project_root=project_root, work_root=work_root, checkpoint_root=checkpoint_root, acft_root=acft_root)

    @staticmethod
    def _symlink_aware_cwd() -> Path:
        """Return a cwd path that preserves shell-presented symlinks when safe."""
        cwd = Path.cwd()
        env_pwd = os.environ.get("PWD")
        if env_pwd:
            try:
                pwd_path = Path(env_pwd)
                if pwd_path.exists() and pwd_path.resolve() == cwd:
                    return pwd_path
            except (OSError, RuntimeError):
                pass
        return cwd

    @staticmethod
    def _search_upwards(
        start: Path, markers: Iterable[str], fallback: Optional[Path] = None, stop: Optional[Path] = None
    ) -> Optional[Path]:
        current = start
        stop_resolved = stop.resolve() if stop else None
        markers = list(markers)
        while True:
            for marker in markers:
                if (current / marker).exists():
                    return current
            if stop_resolved and current.resolve() == stop_resolved:
                break
            if current == current.parent:
                break
            current = current.parent
        return fallback

    @staticmethod
    def _find_checkpoint_root(start: Path, stop_at: Optional[Path] = None) -> Optional[Path]:
        current = start
        stop_real = stop_at.resolve() if stop_at else None
        while True:
            if (current / "CHECKPOINT.md").exists():
                return current
            try:
                current_real = current.resolve()
            except FileNotFoundError:
                current_real = None
            if stop_real and current_real == stop_real:
                break
            if current == current.parent:
                break
            current = current.parent
        return None

    # ------------------------------------------------------------------ Path utils
    def expand(self, raw: str, *, resolve_symlinks: bool = False) -> Path:
        def _normalized(path: Path) -> Path:
            # `normpath` collapses "." and ".." without following symlinks.
            return Path(os.path.normpath(str(path)))

        if raw.startswith("::PROJECT"):
            if not self.project_root:
                raise PathResolutionError("Cannot expand ::PROJECT: no checkpoints_project.toml found in ancestor directories")
            tail = raw[len("::PROJECT") :].lstrip("/")
            candidate = self.project_root / tail
            return candidate.resolve() if resolve_symlinks else _normalized(candidate)
        if raw.startswith("::WORK"):
            if not self.work_root:
                raise PathResolutionError("Cannot expand ::WORK: no checkpoints_work.toml found in ancestor directories")
            tail = raw[len("::WORK") :].lstrip("/")
            candidate = self.work_root / tail
            return candidate.resolve() if resolve_symlinks else _normalized(candidate)
        if raw.startswith("::THIS"):
            if not self.checkpoint_root:
                raise PathResolutionError("Cannot expand ::THIS: no CHECKPOINT.md found in current or ancestor directories")
            tail = raw[len("::THIS") :].lstrip("/")
            candidate = self.checkpoint_root / tail
            return candidate.resolve() if resolve_symlinks else _normalized(candidate)
        if raw.startswith("::"):
            raise PathResolutionError(f"Unknown rooted prefix in path: {raw}")
        candidate = Path(raw).expanduser()
        if not candidate.is_absolute():
            candidate = Path.cwd() / candidate
        return candidate.resolve() if resolve_symlinks else _normalized(candidate)

    def to_rooted(self, target: Path) -> str:
        target = target.resolve()
        rel_work = ensure_relative(target, self.work_root)
        if rel_work is not None:
            return f"::WORK/{rel_work.as_posix()}"
        rel_project = ensure_relative(target, self.project_root)
        if rel_project is not None:
            return f"::PROJECT/{rel_project.as_posix()}"
        return str(target)

    def checkpoint_from_arg(self, value: Optional[str]) -> Checkpoint:
        raw = value or "::THIS"
        path = self.expand(raw)
        if path.is_file():
            if path.name.upper() == "CHECKPOINT.MD":
                path = path.parent
            else:
                raise PathResolutionError(f"Checkpoint argument must resolve to a directory: {raw}")
        if not (path / "CHECKPOINT.md").exists():
            raise PathResolutionError(f"No CHECKPOINT.md found at {path}")
        checkpoint = Checkpoint(path=path, context=self)
        checkpoint.load()
        return checkpoint

    def scan_checkpoints(self) -> List[Checkpoint]:
        if not self.work_root:
            raise AcftError("Cannot scan checkpoints: no checkpoints_work.toml found in ancestor directories")
        checkpoints: List[Checkpoint] = []
        for candidate in sorted(self.work_root.glob("*")):
            if candidate.is_dir() and (candidate / "CHECKPOINT.md").exists():
                cp = Checkpoint(path=candidate, context=self)
                try:
                    cp.load()
                except CheckpointFormatError:
                    continue
                checkpoints.append(cp)
        return checkpoints


def read_manifest_commands(manifest_text: str, section_filter: Optional[str] = None) -> List[Tuple[str, str]]:
    """
    Extract harness commands from the MANIFEST section.

    Returns a list of (section_name, command) tuples. Harness commands are
    sourced from fenced code blocks (```sh / ```bash) or bullet lists
    beginning with backticks. The parser prefers subheadings that include
    the word "Harness".
    """
    commands: List[Tuple[str, str]] = []
    current_heading = "MANIFEST"
    include_block = section_filter is None
    lines = manifest_text.splitlines()
    fence_active = False
    fence_lang = ""
    buffer: List[str] = []

    def flush_buffer():
        nonlocal buffer, current_heading
        if not buffer:
            return
        text = "\n".join(buffer).strip()
        for line in text.splitlines():
            command = line.strip()
            if not command:
                continue
            commands.append((current_heading, command))
        buffer = []

    for line in lines:
        heading_match = re.match(r"^(#+)\s+(.*)", line.strip())
        if heading_match:
            flush_buffer()
            level = heading_match.group(1)
            title = heading_match.group(2).strip()
            current_heading = title.upper()
            include_block = (
                section_filter is None
                or current_heading == section_filter.upper()
                or section_filter.lower() in current_heading.lower()
            )
            fence_active = False
            fence_lang = ""
            continue
        if line.strip().startswith("```"):
            if not fence_active:
                fence_active = True
                fence_lang = line.strip().lstrip("`")
                buffer = []
            else:
                fence_active = False
                if include_block and fence_lang.lower() in {"sh", "shell", "bash"}:
                    flush_buffer()
                buffer = []
                fence_lang = ""
            continue
        if fence_active:
            if include_block:
                buffer.append(line)
            continue
        if include_block and line.strip().startswith("- "):
            token = line.strip()[2:].strip()
            if token.startswith("`") and token.endswith("`"):
                commands.append((current_heading, token[1:-1]))
    return commands


def render_table(rows: List[Dict[str, str]], headers: List[str]) -> str:
    """Render a simple fixed-width table for terminal display."""
    if not rows:
        return ""
    widths = {header: len(header) for header in headers}
    for row in rows:
        for header in headers:
            widths[header] = max(widths[header], len(row.get(header, "")))
    header_line = " | ".join(header.ljust(widths[header]) for header in headers)
    separator = "-+-".join("-" * widths[header] for header in headers)
    body = [
        " | ".join(row.get(header, "").ljust(widths[header]) for header in headers)
        for row in rows
    ]
    return "\n".join([header_line, separator] + body)


def slugify_section(value: str) -> str:
    return re.sub(r"[^A-Z0-9]+", "_", value.upper()).strip("_")


def run_subprocess(command: List[str], **kwargs: Any) -> subprocess.CompletedProcess:
    try:
        return subprocess.run(command, check=True, text=True, capture_output=True, **kwargs)
    except subprocess.CalledProcessError as exc:  # pragma: no cover - pass-through
        raise AcftError(f"Command {' '.join(command)} failed: {exc.stderr or exc.stdout}") from exc


def build_checkpoint_template(
    name: str,
    delegate_of: Optional[str] = None,
    tags: Optional[List[str]] = None,
) -> str:
    """Generate the initial contents of `CHECKPOINT.md`."""
    metadata: Dict[str, Any] = {
        "VALID": False,
        "LIFECYCLE": "active",
        "SIGNAL": "pending",
    }
    if delegate_of:
        metadata["DELEGATE_OF"] = delegate_of
    if tags:
        metadata["TAGS"] = tags

    frontmatter = _dump_simple_yaml(metadata, ["VALID", "LIFECYCLE", "SIGNAL", "DELEGATE_OF", "TAGS"])
    body = textwrap.dedent(
        f"""
        # STATUS
        - Context recap: TODO
        - Success criteria: TODO
        - Exit criteria: TODO

        # HARNESS
        Summarise the current state, key deliverables, and risks. Cite rooted paths (e.g. ::THIS/ARTIFACTS/...).

        # CONTEXT
        Document the reasoning, evidence, and alternatives considered. Link to upstream/downstream checkpoints.

        # MANIFEST
        ## MANIFEST LEDGER
        - Placeholder -> ::THIS/ARTIFACTS/stub -> Replace once deliverables exist.

        ## Harness
        ```sh
        # add verification commands here
        ```

        ## Dependencies
        ### CHECKPOINT DEPENDENCIES
        - Owner ::WORK/example_v1_01 (active, VALID: false)

        ### SYSTEM DEPENDENCIES
        - Dependency name - status / risk

        # LOG
        """
    ).strip("\n")
    return f"---\n{frontmatter}\n---\n{body}\n"


class EventEmitter:
    def __init__(self, context: AcftContext):
        self.context = context
        self.actor = os.environ.get("ACFT_ACTOR") or getpass.getuser()
        if not self.context.work_root:
            raise AcftError("Cannot initialize event emitter: no checkpoints_work.toml found in ancestor directories")
        self.log_path = (self.context.work_root / "checkpoints_events.log").resolve()

    def emit(self, event_type: str, checkpoint: Optional[Checkpoint], payload: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        payload = payload or {}
        event: Dict[str, Any] = {
            "TYPE": event_type,
            "ACTOR": self.actor,
            "TIMESTAMP": utcnow_iso(),
            "PAYLOAD": payload,
        }
        if checkpoint is not None:
            event["CHECKPOINT_PATH"] = self.context.to_rooted(checkpoint.path)
        line = json.dumps(event, sort_keys=True)
        print(line)
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        try:
            with self.log_path.open("a", encoding="utf-8") as fh:
                fh.write(line + "\n")
        except OSError as exc:
            raise AcftError(f"Failed to append event log at {self.log_path}: {exc}") from exc
        return event


def checkpoint_name_parts(name: str) -> Optional[Dict[str, str]]:
    match = CHECKPOINT_NAME_RE.match(name)
    if not match:
        return None
    data = match.groupdict()
    data["version"] = int(data["version"])
    data["step"] = int(data["step"])
    return data


def relative_duration_to_seconds(value: str) -> int:
    """
    Convert a relative duration token (e.g., "-10m") to seconds.

    Supported suffixes: s, m, h, d. The leading sign must be '-'.
    """
    if not value.startswith("-") or len(value) < 3:
        raise ValueError("Relative durations must look like -10m / -2h / -1d")
    number = value[1:-1]
    unit = value[-1]
    amount = int(number)
    multiplier = {"s": 1, "m": 60, "h": 3600, "d": 86400}.get(unit)
    if multiplier is None:
        raise ValueError(f"Unsupported duration unit {unit!r}")
    return amount * multiplier


def parse_iso_timestamp(value: str) -> _dt.datetime:
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    return _dt.datetime.fromisoformat(value)


def validate_section_order(section_order: List[str]) -> Tuple[List[str], List[str]]:
    required = ["STATUS", "HARNESS", "CONTEXT", "MANIFEST", "LOG"]
    errors: List[str] = []
    warnings: List[str] = []
    if section_order[: len(required)] != required:
        errors.append(
            "Sections must start with STATUS, HARNESS, CONTEXT, MANIFEST, LOG (in that order)."
        )
    missing = [name for name in required if name not in section_order]
    if missing:
        errors.append(f"Missing required sections: {', '.join(missing)}")
    return errors, warnings


def detect_unrooted_paths(text: str) -> List[str]:
    patterns = [
        r"\.\./",
        r"\./ARTIFACTS",
        r"\sARTIFACTS/",
    ]
    matches: List[str] = []
    for pattern in patterns:
        matches.extend(re.findall(pattern, text))
    return matches


def find_latest_checkpoint(checkpoints: List[Checkpoint], branch: str, version: int) -> Optional[Checkpoint]:
    related = [
        cp
        for cp in checkpoints
        if (parts := checkpoint_name_parts(cp.name))
        and parts["branch"] == branch
        and parts["version"] == version
    ]
    related.sort(key=lambda cp: checkpoint_name_parts(cp.name)["step"])
    return related[-1] if related else None
