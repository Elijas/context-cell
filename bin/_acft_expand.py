from __future__ import annotations

import argparse
import sys
from pathlib import Path

from _lib import AcftContext, PathResolutionError


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "expand",
        help="Expand rooted prefixes to absolute paths.",
    )
    parser.add_argument("paths", nargs="+", help="Rooted or relative paths to expand.")
    parser.add_argument(
        "--resolve-symlinks",
        action="store_true",
        help="Resolve symbolic links in the expanded output.",
    )
    parser.add_argument(
        "-f",
        "--allow-future",
        action="store_true",
        help="Allow expanding paths that don't exist yet (skip existence check).",
    )
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    try:
        outputs = []
        for item in args.paths:
            expanded = ctx.expand(item, resolve_symlinks=args.resolve_symlinks)
            expanded_path = Path(expanded)

            # By default, check that the path exists
            if not args.allow_future and not expanded_path.exists():
                print(f"acft path error: Expanded path does not exist: {expanded}", file=sys.stderr)
                print(f"\nIf you want to expand a future path that doesn't exist yet, use:", file=sys.stderr)
                print(f"  acft expand --allow-future {item}", file=sys.stderr)
                print(f"  acft expand -f {item}", file=sys.stderr)
                return 1

            outputs.append(str(expanded))

        print("\n".join(outputs))
        return 0
    except PathResolutionError as e:
        print(f"acft path error: {e}", file=sys.stderr)
        print("\nTip: Run 'acft init' to create the required configuration files.", file=sys.stderr)
        return 2


def expand_paths(paths: list[str], *, resolve_symlinks: bool = False) -> list[str]:
    ctx = AcftContext.discover()
    return [str(ctx.expand(item, resolve_symlinks=resolve_symlinks)) for item in paths]
