from __future__ import annotations

import argparse
import json
import time
from typing import Any, Dict, Optional

from _lib import AcftContext, AcftError, parse_iso_timestamp, relative_duration_to_seconds


def register(subparsers: argparse._SubParsersAction) -> None:
    events = subparsers.add_parser(
        "events",
        help="Event stream utilities.",
    )
    events_sub = events.add_subparsers(dest="events_subcommand", metavar="SUBCOMMAND")
    def _show_help(_: argparse.Namespace, __: AcftContext) -> int:
        events.print_help()
        return 1

    events.set_defaults(handler=_show_help)

    tail = events_sub.add_parser("tail", help="Stream or list emitted events.")
    tail.add_argument("--since", help="ISO 8601 timestamp or relative duration (e.g., -10m).")
    tail.add_argument(
        "--types",
        help="Comma-separated list of TYPE filters (e.g., CHECKPOINT_CREATED).",
    )
    tail.add_argument(
        "--follow",
        action="store_true",
        help="Follow the event log (like tail -f).",
    )
    tail.set_defaults(handler=run_tail)


def run_tail(args: argparse.Namespace, ctx: AcftContext) -> int:
    if not ctx.work_root:
        raise AcftError("Cannot access event log: no checkpoints_work.toml found in ancestor directories")
    log_path = ctx.work_root / "checkpoints_events.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.touch(exist_ok=True)

    since_ts: Optional[float] = None
    if args.since:
        try:
            if args.since.startswith("-"):
                delta = relative_duration_to_seconds(args.since)
                since_ts = time.time() - delta
            else:
                since_ts = parse_iso_timestamp(args.since).timestamp()
        except Exception as exc:
            raise AcftError(f"Invalid --since value: {exc}") from exc

    types_filter: Optional[set[str]] = None
    if args.types:
        types_filter = {item.strip() for item in args.types.split(",") if item.strip()}

    def should_emit(event: Dict[str, Any]) -> bool:
        if types_filter and event.get("TYPE") not in types_filter:
            return False
        if since_ts is not None:
            ts = parse_iso_timestamp(event["TIMESTAMP"]).timestamp()
            if ts < since_ts:
                return False
        return True

    with log_path.open("r", encoding="utf-8") as stream:
        while True:
            position = stream.tell()
            line = stream.readline()
            if not line:
                if args.follow:
                    time.sleep(0.5)
                    stream.seek(position)
                    continue
                break
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if should_emit(event):
                print(json.dumps(event))

    return 0
