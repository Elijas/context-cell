from __future__ import annotations

import argparse
import os
import subprocess
from pathlib import Path

from _lib import AcftContext, AcftError


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "claude",
        help="Launch the Claude helper wrapper.",
        add_help=False,
    )
    parser.add_argument("claude_args", nargs=argparse.REMAINDER, help=argparse.SUPPRESS)
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    script_dir = Path(__file__).resolve().parent
    claude_script = script_dir / "claude.sh"
    if not claude_script.exists():
        raise AcftError(f"Claude launcher not found at {claude_script}")

    env = os.environ.copy()
    env["ACFT_PARENT_CMD"] = "acft claude"
    process = subprocess.run([str(claude_script)] + args.claude_args, env=env)
    return process.returncode
