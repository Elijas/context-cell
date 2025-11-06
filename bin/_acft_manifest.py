from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Sequence

from _lib import (
    AcftContext,
    Checkpoint,
    EventEmitter,
    checkpoint_name_parts,
    detect_unrooted_paths,
    read_manifest_commands,
    render_table,
)


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "manifest",
        help="Sweep for failure catalogue issues and optionally emit MANIFEST_UPDATED.",
    )
    parser.add_argument("path", nargs="?", default="::THIS", help="Rooted path (default ::THIS).")
    parser.add_argument(
        "--mode",
        choices=["quick", "full"],
        default="quick",
        help="Quick = target only; full = walk descendants.",
    )
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    parser.add_argument(
        "--emit",
        action="store_true",
        help="Emit MANIFEST_UPDATED event with aggregated severity.",
    )
    parser.set_defaults(handler=run)


@dataclass
class FailureCheck:
    key: str
    description: str
    severity: str
    detector: Any  # Callable[[Checkpoint, AcftContext, Sequence[Checkpoint]], Optional[str]]


def failure_checks() -> List[FailureCheck]:
    return [
        FailureCheck(
            key="missing_harness",
            description="MANIFEST lacks documented harness commands or LOG evidence.",
            severity="error",
            detector=check_missing_harness,
        ),
        FailureCheck(
            key="stale_contract",
            description="STATUS/HARNESS still contain TODOs while frontmatter reports VALID: true.",
            severity="warning",
            detector=check_stale_contract,
        ),
        FailureCheck(
            key="missing_manifest_ledger",
            description="VALID: true without a populated MANIFEST LEDGER using ::THIS/ARTIFACTS paths.",
            severity="error",
            detector=check_missing_manifest_ledger,
        ),
        FailureCheck(
            key="unrooted_references",
            description="Detected bare or relative paths inside CHECKPOINT.md.",
            severity="warning",
            detector=check_unrooted_references,
        ),
        FailureCheck(
            key="relative_path_bleed",
            description="Detected relative path bleed (../) to sibling checkpoints.",
            severity="warning",
            detector=check_relative_path_bleed,
        ),
        FailureCheck(
            key="timeline_gaps",
            description="LOG missing entries or lacks orientation note.",
            severity="warning",
            detector=check_timeline_gaps,
        ),
        FailureCheck(
            key="orphaned_successors",
            description="DELEGATE_OF references missing or successors not cross-linked.",
            severity="error",
            detector=check_orphaned_successors,
        ),
        FailureCheck(
            key="version_drift",
            description="Multiple active checkpoints share the same branch+version.",
            severity="error",
            detector=check_version_drift,
        ),
        FailureCheck(
            key="scope_shock",
            description="Scope change detected without cited directive.",
            severity="warning",
            detector=check_scope_shock,
        ),
        FailureCheck(
            key="history_drift",
            description="STATUS lacks a context recap for successors.",
            severity="warning",
            detector=check_history_drift,
        ),
        FailureCheck(
            key="dependency_fog",
            description="Dependencies section missing statuses or rooted links.",
            severity="warning",
            detector=check_dependency_fog,
        ),
        FailureCheck(
            key="goal_fog",
            description="Missing explicit success or exit criteria.",
            severity="warning",
            detector=check_goal_fog,
        ),
        FailureCheck(
            key="validation_theater",
            description="VALID: true without concrete harness execution evidence.",
            severity="error",
            detector=check_validation_theater,
        ),
    ]


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    target = ctx.checkpoint_from_arg(args.path)
    all_checkpoints = ctx.scan_checkpoints()
    checkpoints: List[Checkpoint]

    if args.mode == "full":
        checkpoints = all_checkpoints
    else:
        checkpoints = [target]

    issues: List[Dict[str, Any]] = []
    checks = failure_checks()
    for checkpoint in checkpoints:
        for check in checks:
            message = check.detector(checkpoint, ctx, all_checkpoints)
            if message:
                issues.append(
                    {
                        "checkpoint": ctx.to_rooted(checkpoint.path),
                        "failure": check.key,
                        "severity": check.severity,
                        "detail": message,
                    }
                )

    result = {"issues": issues, "mode": args.mode, "count": len(issues)}

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"Manifest sweep ({args.mode})")
        if not issues:
            print("No failure catalogue issues detected.")
        else:
            table = render_table(
                [
                    {
                        "CHECKPOINT": item["checkpoint"],
                        "FAILURE": item["failure"],
                        "SEVERITY": item["severity"],
                    }
                    for item in issues
                ],
                ["CHECKPOINT", "FAILURE", "SEVERITY"],
            )
            print(table)
            print()
            for item in issues:
                print(
                    f"- {item['checkpoint']} :: {item['failure']} :: {item['detail']}"
                )

    if args.emit:
        severity = "info"
        if any(item["severity"] == "error" for item in issues):
            severity = "error"
        elif any(item["severity"] == "warning" for item in issues):
            severity = "warning"
        emitter = EventEmitter(ctx)
        emitter.emit(
            "MANIFEST_UPDATED",
            target,
            payload={
                "MODE": args.mode,
                "ISSUES": issues,
                "SEVERITY": severity,
            },
        )

    return 0 if not issues else 1


# Failure catalogue heuristics -------------------------------------------------


def check_missing_harness(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    manifest = checkpoint.sections.get("MANIFEST", "")
    commands = read_manifest_commands(manifest)
    if commands:
        return None
    log_entries = checkpoint.log_entries()
    if any("harness" in entry.message.lower() for entry in log_entries):
        return None
    return "MANIFEST does not record executable harness commands and LOG lacks harness evidence."


def check_stale_contract(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    if not checkpoint.frontmatter.get("VALID"):
        return None
    status = checkpoint.sections.get("STATUS", "").lower()
    harness = checkpoint.sections.get("HARNESS", "").lower()
    manifest = checkpoint.sections.get("MANIFEST", "").lower()
    stale_tokens = {"todo", "tbd", "pending", "stub"}
    if any(token in status for token in stale_tokens) or any(
        token in harness for token in stale_tokens
    ):
        return "VALID: true but STATUS/HARNESS still contain TODO placeholders."
    if "placeholder" in manifest:
        return "MANIFEST LEDGER still marked as placeholder while VALID: true."
    return None


def check_missing_manifest_ledger(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    if not checkpoint.frontmatter.get("VALID"):
        return None
    ledger = checkpoint.manifest_ledger()
    if not ledger:
        return "No MANIFEST LEDGER entries found."
    missing_rooted = [
        entry.path for entry in ledger if not entry.path.startswith("::THIS/ARTIFACTS")
    ]
    if missing_rooted:
        return (
            "Ledger entries must reference ::THIS/ARTIFACTS paths (found "
            + ", ".join(missing_rooted)
            + ")."
        )
    return None


def check_unrooted_references(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    text = checkpoint.checkpoint_md.read_text(encoding="utf-8")
    matches = detect_unrooted_paths(text)
    if matches:
        return "Found unrooted references like " + ", ".join(sorted(set(matches)))
    return None


def check_relative_path_bleed(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    text = checkpoint.checkpoint_md.read_text(encoding="utf-8")
    if "../" in text:
        return "Found '../' references that risk leaking relative paths."
    return None


def check_timeline_gaps(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    entries = checkpoint.log_entries()
    if not entries:
        return "# LOG is empty."
    first = entries[0]
    if not first.message or "created" not in first.message.lower():
        return "No orienting LOG entry recorded."
    return None


def check_orphaned_successors(
    checkpoint: Checkpoint, ctx: AcftContext, checkpoints: Sequence[Checkpoint]
) -> Optional[str]:
    delegate_of = checkpoint.frontmatter.get("DELEGATE_OF")
    if isinstance(delegate_of, str):
        try:
            delegate_path = ctx.expand(delegate_of)
        except Exception:
            return f"DELEGATE_OF references unknown path: {delegate_of}"
        if not (delegate_path / "CHECKPOINT.md").exists():
            return f"DELEGATE_OF target missing CHECKPOINT.md: {delegate_of}"
    parts = checkpoint_name_parts(checkpoint.name)
    if not parts or checkpoint.frontmatter.get("LIFECYCLE") != "active":
        return None
    conflicts = [
        cp
        for cp in checkpoints
        if cp.path != checkpoint.path
        and checkpoint_name_parts(cp.name)
        and checkpoint_name_parts(cp.name)["branch"] == parts["branch"]
        and checkpoint_name_parts(cp.name)["version"] == parts["version"]
        and cp.frontmatter.get("LIFECYCLE") == "active"
    ]
    if conflicts:
        names = ", ".join(cp.name for cp in conflicts)
        return f"Branch {parts['branch']} v{parts['version']} has multiple active checkpoints: {names}"
    return None


def check_version_drift(
    checkpoint: Checkpoint, ctx: AcftContext, checkpoints: Sequence[Checkpoint]
) -> Optional[str]:
    parts = checkpoint_name_parts(checkpoint.name)
    if not parts:
        return None
    related = [
        cp
        for cp in checkpoints
        if checkpoint_name_parts(cp.name)
        and checkpoint_name_parts(cp.name)["branch"] == parts["branch"]
        and checkpoint_name_parts(cp.name)["version"] == parts["version"]
    ]
    active = [cp for cp in related if cp.frontmatter.get("LIFECYCLE") == "active"]
    if len(active) > 1:
        names = ", ".join(cp.name for cp in active if cp.path != checkpoint.path)
        return f"Multiple active checkpoints share {parts['branch']} v{parts['version']}: {names}"
    return None


def check_scope_shock(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    for entry in checkpoint.log_entries():
        if "scope" in entry.message.lower() and "::" not in entry.message:
            return "Scope change mentioned in LOG without rooted directive reference."
    return None


def check_history_drift(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    if "Context recap" not in checkpoint.sections.get("STATUS", ""):
        return "STATUS missing 'Context recap' bullet."
    return None


def check_dependency_fog(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    manifest = checkpoint.sections.get("MANIFEST", "")
    if "## Dependencies" not in manifest:
        return None
    dependencies = []
    capture = False
    for line in manifest.splitlines():
        if line.strip().startswith("## MANIFEST LEDGER"):
            capture = False
        if line.strip().startswith("## Dependencies"):
            capture = True
            continue
        if line.startswith("## ") and capture:
            continue
        if capture and line.strip().startswith("- "):
            dependencies.append(line.strip()[2:])
    if not dependencies:
        return "Dependencies heading present but no items documented."
    missing_status = [
        dep for dep in dependencies if "(" not in dep and "VALID" not in dep.upper()
    ]
    if missing_status:
        return "Dependencies missing status annotations: " + ", ".join(missing_status)
    if any("::" not in dep for dep in dependencies):
        return "Dependencies should use rooted paths (::THIS/ or ::WORK/)."
    return None


def check_goal_fog(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    status = checkpoint.sections.get("STATUS", "")
    if "Success criteria" not in status or "Exit criteria" not in status:
        return "STATUS must capture success and exit criteria."
    return None


def check_validation_theater(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    if not checkpoint.frontmatter.get("VALID"):
        return None
    manifest = checkpoint.sections.get("MANIFEST", "").lower()
    if "placeholder" in manifest or "# add verification commands here" in manifest:
        return "MANIFEST still contains placeholder harness after VALID: true."
    log_entries = checkpoint.log_entries()
    if not any("harness" in entry.message.lower() for entry in log_entries):
        return "No LOG entry referencing harness execution despite VALID: true."
    return None
