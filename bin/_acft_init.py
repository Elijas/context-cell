from __future__ import annotations

import argparse
from pathlib import Path

from _lib import AcftContext


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "init",
        help="Initialize ACF configuration files in the current directory.",
    )
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    """
    Create checkpoints_project.toml and checkpoints_work.toml in the current
    directory if they don't already exist here or in any parent directories.
    """
    cwd = Path.cwd()

    # Check if checkpoints_project.toml exists in current or parent directories
    project_exists = _search_upwards_for_file(cwd, "checkpoints_project.toml")

    # Check if checkpoints_work.toml exists in current or parent directories
    work_exists = _search_upwards_for_file(cwd, "checkpoints_work.toml")

    created_files = []

    # Create checkpoints_project.toml if it doesn't exist
    if not project_exists:
        project_toml = cwd / "checkpoints_project.toml"
        project_toml_content = """# Agent Checkpoints Framework - Project Root Marker
#
# This file is intentionally empty and serves as a marker to identify
# the project root directory for rooted path expansion (::PROJECT).
"""
        project_toml.write_text(project_toml_content, encoding="utf-8")
        created_files.append("checkpoints_project.toml")

    # Create checkpoints_work.toml if it doesn't exist
    if not work_exists:
        work_toml = cwd / "checkpoints_work.toml"
        work_toml_content = """# Agent Checkpoints Framework - Work Root Marker
#
# This file is intentionally empty and serves as a marker to identify
# the work root directory for rooted path expansion (::WORK).
"""
        work_toml.write_text(work_toml_content, encoding="utf-8")
        created_files.append("checkpoints_work.toml")

    if created_files:
        print(f"Created: {', '.join(created_files)}")
    else:
        print("Configuration files already exist in this directory or parent directories.")

    return 0


def _search_upwards_for_file(start: Path, filename: str) -> bool:
    """
    Search upwards from start directory to see if filename exists in
    current or any parent directory.

    Returns True if file exists, False otherwise.
    """
    current = start
    while True:
        if (current / filename).exists():
            return True
        if current == current.parent:
            break
        current = current.parent
    return False
