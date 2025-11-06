from __future__ import annotations

import argparse
import subprocess
import time
from pathlib import Path
from typing import Any, Dict, List

from _lib import AcftContext, AcftError, EventEmitter, read_manifest_commands


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "verify",
        help="Execute harness commands documented in MANIFEST.",
    )
    parser.add_argument("path", nargs="?", default="::THIS", help="Rooted path (default ::THIS).")
    parser.add_argument(
        "--section",
        help="Restrict execution to a MANIFEST sub-heading (case insensitive).",
    )
    parser.add_argument("--dry-run", action="store_true", help="Print commands without running.")
    parser.add_argument(
        "--record",
        action="store_true",
        help="Emit HARNESS_EXECUTED event and fail if emission cannot append.",
    )
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    checkpoint = ctx.checkpoint_from_arg(args.path)
    harness_commands = read_manifest_commands(
        checkpoint.sections.get("MANIFEST", ""),
        section_filter=args.section,
    )
    harness_commands = [
        (section, cmd)
        for section, cmd in harness_commands
        if args.section is None
        or args.section.lower() in section.lower()
        or section == args.section.upper()
    ]
    commands = [cmd for _, cmd in harness_commands]
    if not commands:
        raise AcftError("No harness commands found in MANIFEST.")

    print(f"Running harness for {ctx.to_rooted(checkpoint.path)}:")
    for cmd in commands:
        print(f"  $ {cmd}")
    if args.dry_run:
        return 0

    if not ctx.work_root:
        raise AcftError("Cannot create log directory: no checkpoints_work.toml found in ancestor directories")
    logs_dir = ctx.work_root / "logs" / checkpoint.name
    logs_dir.mkdir(parents=True, exist_ok=True)
    timestamp = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    log_path = logs_dir / f"harness_{timestamp}.log"

    execution_log: List[Dict[str, Any]] = []
    overall_success = True
    with log_path.open("w", encoding="utf-8") as log_file:
        for command in commands:
            log_file.write(f"$ {command}\n")
            process = subprocess.run(
                command,
                shell=True,
                text=True,
                capture_output=True,
            )
            log_file.write(process.stdout or "")
            if process.stderr:
                log_file.write(process.stderr)
            log_file.write(f"[exit {process.returncode}]\n\n")
            execution_log.append(
                {
                    "command": command,
                    "exit_code": process.returncode,
                }
            )
            if process.returncode != 0:
                overall_success = False
                break

    status = "pass" if overall_success else "fail"
    print(f"Harness {'passed' if overall_success else 'failed'} (log: {log_path})")

    if args.record:
        emitter = EventEmitter(ctx)
        payload = {
            "STATUS": status,
            "COMMANDS": execution_log,
            "LOG_PATH": ctx.to_rooted(log_path),
        }
        emitter.emit("HARNESS_EXECUTED", checkpoint, payload)

    return 0 if overall_success else 1
