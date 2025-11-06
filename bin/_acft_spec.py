from __future__ import annotations

import argparse
from pathlib import Path

from _lib import AcftContext, AcftError


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "spec",
        help="Emit the framework documentation bundle for AI agent consumption.",
        description=(
            "Concatenate canonical framework documents so agents (or humans) can ingest the "
            "full specification without invoking additional commands."
        ),
    )
    parser.add_argument(
        "--doc",
        choices=["guide", "foundation", "prompt"],
        help="Select a canonical document.",
    )
    parser.add_argument(
        "--path",
        help="Explicit path to print (overrides --doc).",
    )
    parser.add_argument(
        "--full",
        action="store_true",
        help="Print the complete framework specification bundle.",
    )
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    spec_dir = ctx.acft_root / "spec"

    if args.full:
        bundle_files = [
            spec_dir / "FRAMEWORK_FOUNDATION.md",
            spec_dir / "FRAMEWORK_SPEC.md",
            spec_dir / "SYSTEM_PROMPT.md",
            spec_dir / "CLI_REFERENCE.md",
            spec_dir / "FAILURE_CATALOGUE_TABLE.md",
        ]
        missing = [str(path) for path in bundle_files if not path.exists()]
        if missing:
            raise AcftError(
                "Documentation files missing for --full bundle:\n" + "\n".join(missing)
            )
        pieces: list[str] = []
        for path in bundle_files:
            text = path.read_text(encoding="utf-8")
            pieces.append(text.rstrip("\n"))
        body = "\n\n".join(pieces)
        print("<ACFT_FRAMEWORK_SPECIFICATION>")
        if body:
            print(body)
        print("</ACFT_FRAMEWORK_SPECIFICATION>")
        return 0

    if args.path:
        target = (
            ctx.expand(args.path)
            if args.path.startswith("::")
            else Path(args.path).resolve()
        )
    elif args.doc == "guide":
        target = spec_dir / "FRAMEWORK_SPEC.md"
    elif args.doc == "foundation":
        target = spec_dir / "FRAMEWORK_FOUNDATION.md"
    elif args.doc == "prompt":
        target = spec_dir / "SYSTEM_PROMPT.md"
    else:
        target = spec_dir / "FRAMEWORK_SPEC.md"

    if not target.exists():
        raise AcftError(f"Documentation file not found: {target}")
    print(target.read_text(encoding="utf-8"))
    return 0
