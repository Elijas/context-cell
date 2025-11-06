import json
import os
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional


ACFT_BIN = Path(__file__).resolve().parent.parent / "acft"


def _write(path: Path, contents: str) -> None:
    path.write_text(contents, encoding="utf-8")


@dataclass
class CommandResult:
    stdout: str
    stderr: str
    returncode: int


class ProjectBuilder:
    """
    Construct a throwaway project/work hierarchy in /tmp that mirrors the
    expectations of AcftContext.
    """

    def __init__(self) -> None:
        self._tmpdir = Path(tempfile.mkdtemp(prefix="acft_tests_")).resolve()
        self.project_root = self._tmpdir / "project"
        self.work_root = self.project_root / "work"
        self.spec_root = self.project_root / "spec"

        self.project_root.mkdir(parents=True, exist_ok=True)
        self.work_root.mkdir(parents=True, exist_ok=True)
        self.spec_root.mkdir(parents=True, exist_ok=True)

        _write(self.project_root / "checkpoints_project.toml", "project = true\n")
        _write(self.work_root / "checkpoints_work.toml", "work = true\n")

        _write(self.spec_root / "FRAMEWORK_SPEC.md", "# Test Harness Manual\n")
        _write(self.spec_root / "FRAMEWORK_FOUNDATION.md", "# Test Foundation Notes\n")
        _write(self.spec_root / "SYSTEM_PROMPT.md", "# Test Prompt\n")

    def cleanup(self) -> None:
        shutil.rmtree(self._tmpdir, ignore_errors=True)

    # ------------------------------------------------------------------ helpers
    def run_acft(
        self,
        args: List[str],
        *,
        cwd: Optional[Path] = None,
        env: Optional[Dict[str, str]] = None,
        check: bool = True,
    ) -> CommandResult:
        command = [str(ACFT_BIN)] + args
        run_env = os.environ.copy()
        run_env.setdefault("ACFT_ACTOR", "acft-test")
        if env:
            run_env.update(env)
        completed = subprocess.run(
            command,
            cwd=str(cwd or self.work_root),
            env=run_env,
            text=True,
            capture_output=True,
        )
        if check and completed.returncode != 0:
            raise AssertionError(
                f"Command {' '.join(command)} failed:\nSTDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}"
            )
        return CommandResult(completed.stdout, completed.stderr, completed.returncode)

    def checkpoint_path(self, name: str) -> Path:
        return self.work_root / name

    def replace_in_checkpoint(self, name: str, needle: str, replacement: str) -> None:
        checkpoint_md = self.checkpoint_path(name) / "CHECKPOINT.md"
        contents = checkpoint_md.read_text(encoding="utf-8")
        if needle not in contents:
            raise AssertionError(f"Needle not found in CHECKPOINT.md: {needle}")
        checkpoint_md.write_text(contents.replace(needle, replacement), encoding="utf-8")

    def write_checkpoint_file(self, name: str, relative: str, contents: str = "") -> Path:
        target = self.checkpoint_path(name) / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        _write(target, contents)
        return target

    def read_events(self) -> List[Dict[str, Any]]:
        log_path = self.work_root / "checkpoints_events.log"
        if not log_path.exists():
            return []
        events: List[Dict[str, Any]] = []
        for line in log_path.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            events.append(json.loads(line))
        return events
