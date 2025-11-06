from __future__ import annotations

import argparse
from typing import Dict, List

from _lib import AcftContext, AcftError, EventEmitter


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "close",
        help="Flip VALID/SIGNAL/LIFECYCLE and append a LOG entry.",
    )
    parser.add_argument(
        "--path",
        metavar="PATH",
        help="Target checkpoint (default ::THIS).",
    )
    parser.add_argument(
        "--status",
        choices=["true", "false"],
        required=True,
        help="Desired VALID status.",
    )
    parser.add_argument(
        "--signal",
        choices=["pass", "fail", "blocked", "pending"],
        help="Record latest harness verdict.",
    )
    parser.add_argument(
        "--lifecycle",
        choices=["active", "superseded", "archived"],
        help="Override LIFECYCLE.",
    )
    parser.add_argument(
        "--message",
        help="Custom LOG message describing the status change.",
    )
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    checkpoint = ctx.checkpoint_from_arg(args.path)
    status_bool = args.status == "true"
    lifecycle = args.lifecycle or checkpoint.frontmatter.get("LIFECYCLE")
    if lifecycle not in {"active", "superseded", "archived"}:
        raise AcftError("LIFECYCLE must be active, superseded, or archived.")
    if lifecycle != "active" and status_bool:
        raise AcftError("Cannot set VALID: true when LIFECYCLE is not active.")

    checkpoint.frontmatter["VALID"] = status_bool
    checkpoint.frontmatter["LIFECYCLE"] = lifecycle

    if args.signal:
        checkpoint.frontmatter["SIGNAL"] = args.signal
    elif "SIGNAL" not in checkpoint.frontmatter:
        checkpoint.frontmatter["SIGNAL"] = "pending"

    if status_bool:
        ledger = checkpoint.manifest_ledger()
        if not ledger:
            raise AcftError("Cannot set VALID: true without MANIFEST LEDGER entries.")
        missing_rooted = [
            entry for entry in ledger if not entry.path.startswith("::THIS/ARTIFACTS")
        ]
        if missing_rooted:
            raise AcftError(
                "All MANIFEST LEDGER entries must use ::THIS/ARTIFACTS paths before closure."
            )

    checkpoint.write_frontmatter()
    message = args.message
    if not message:
        status_text = "VALID: true" if status_bool else "VALID: false"
        message = f"Status updated to {status_text} (SIGNAL={checkpoint.frontmatter.get('SIGNAL')})"
    checkpoint.append_log_entry(message)

    emitter = EventEmitter(ctx)
    payload: Dict[str, object] = {
        "VALID": status_bool,
        "SIGNAL": checkpoint.frontmatter.get("SIGNAL"),
        "MESSAGE": message,
        "LIFECYCLE": lifecycle,
    }
    emitter.emit("CHECKPOINT_VERIFIED", checkpoint, payload)
    if status_bool:
        emitter.emit("CHECKPOINT_CLOSED", checkpoint, payload)
    print(
        f"Updated {ctx.to_rooted(checkpoint.path)} -> VALID={status_bool}, "
        f"SIGNAL={checkpoint.frontmatter.get('SIGNAL')}, LIFECYCLE={lifecycle}"
    )
    return 0
