from __future__ import annotations

import argparse
from pathlib import Path
from typing import Dict, List, Optional

from _lib import (
    AcftContext,
    AcftError,
    EventEmitter,
    build_checkpoint_template,
    checkpoint_name_parts,
)


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "new",
        help="Scaffold a new checkpoint and emit CHECKPOINT_CREATED.",
    )
    parser.add_argument("name", help="{branch}_v{version}_{step} checkpoint name.")
    parser.add_argument(
        "--delegate-of",
        metavar="PATH",
        help="Rooted path to parent checkpoint (sets frontmatter DELEGATE_OF).",
    )
    parser.add_argument(
        "--tags",
        metavar="TAG1,TAG2",
        help="Comma-separated tags recorded in frontmatter.",
    )
    parser.add_argument(
        "--no-open",
        action="store_true",
        help="Skip the initial LOG entry (for dry scaffolding).",
    )
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    if not ctx.work_root:
        raise AcftError("Cannot create checkpoint: no checkpoints_work.toml found in ancestor directories")
    name = args.name.strip()
    if not checkpoint_name_parts(name):
        raise AcftError(
            "Checkpoint names must follow {branch}_v{version}_{step} (e.g., auth_v1_01)."
        )
    target_dir = ctx.work_root / name
    if target_dir.exists():
        raise AcftError(f"Checkpoint directory already exists: {target_dir}")

    delegate_of_rooted: Optional[str] = None
    if args.delegate_of:
        delegate_path = ctx.expand(args.delegate_of)
        if not (delegate_path / "CHECKPOINT.md").exists():
            raise AcftError("Delegate path does not contain CHECKPOINT.md")
        delegate_of_rooted = ctx.to_rooted(delegate_path)

    tags: Optional[List[str]] = None
    if args.tags:
        tags = [tag.strip() for tag in args.tags.split(",") if tag.strip()]
        if not tags:
            tags = None

    target_dir.mkdir(parents=False, exist_ok=False)
    checkpoint_md = target_dir / "CHECKPOINT.md"
    checkpoint_md.write_text(
        build_checkpoint_template(name, delegate_of=delegate_of_rooted, tags=tags),
        encoding="utf-8",
    )

    checkpoint = ctx.checkpoint_from_arg(ctx.to_rooted(target_dir))
    if not args.no_open:
        checkpoint.append_log_entry("CHECKPOINT scaffolding created")

    emitter = EventEmitter(ctx)
    payload: Dict[str, object] = {}
    if delegate_of_rooted:
        payload["DELEGATE_OF"] = delegate_of_rooted
    if tags:
        payload["TAGS"] = tags
    emitter.emit("CHECKPOINT_CREATED", checkpoint, payload)
    print(f"Created checkpoint at {ctx.to_rooted(target_dir)}")
    return 0
