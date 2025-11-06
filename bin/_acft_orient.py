from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence

from _lib import (
    AcftContext,
    Checkpoint,
    PathResolutionError,
    checkpoint_name_parts,
    render_table,
)


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "orient",
        help="Summarise ancestry, peers, children, and contract signals.",
    )
    parser.add_argument("path", nargs="?", default="::THIS", help="Rooted path (default ::THIS).")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    parser.add_argument(
        "--sections",
        action="append",
        metavar="SEC1,SEC2",
        help="Include full section text (comma separated, can repeat).",
    )
    parser.add_argument(
        "--depth",
        type=int,
        default=1,
        help="Depth for descendant walk (children, grandchildren, ...).",
    )
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    checkpoint = ctx.checkpoint_from_arg(args.path)
    all_checkpoints = ctx.scan_checkpoints()
    relationships = gather_relationships(
        checkpoint, all_checkpoints, ctx, depth=args.depth
    )
    ledger = [
        {"name": entry.name, "path": entry.path, "purpose": entry.purpose}
        for entry in checkpoint.manifest_ledger()
    ]
    logs = checkpoint.log_entries()
    latest_log = logs[-1].raw_timestamp if logs else None
    status_sentence = checkpoint.first_status_sentence()
    data: Dict[str, Any] = {
        "checkpoint": ctx.to_rooted(checkpoint.path),
        "name": checkpoint.name,
        "VALID": checkpoint.frontmatter.get("VALID"),
        "LIFECYCLE": checkpoint.frontmatter.get("LIFECYCLE"),
        "SIGNAL": checkpoint.frontmatter.get("SIGNAL"),
        "latest_log": latest_log,
        "status_headline": status_sentence,
        "manifest_ledger": ledger,
        "relationships": relationships,
    }

    requested_sections: List[str] = []
    if args.sections:
        for token in args.sections:
            for part in token.split(","):
                part = part.strip()
                if part:
                    requested_sections.append(part.upper())

    if requested_sections:
        sections_payload: Dict[str, str] = {}
        for section_name in requested_sections:
            sections_payload[section_name] = checkpoint.sections.get(section_name, "")
        data["sections"] = sections_payload

    if args.json:
        print(json.dumps(data, indent=2, sort_keys=True))
        return 0

    print(f"Checkpoint: {data['checkpoint']}")
    print(
        f"VALID: {data['VALID']}  "
        f"LIFECYCLE: {data['LIFECYCLE']}  "
        f"SIGNAL: {data['SIGNAL']}"
    )
    print(f"Latest LOG: {data['latest_log'] or '—'}")
    print(f"STATUS: {status_sentence or '∅'}")
    if ledger:
        print("MANIFEST LEDGER:")
        for entry in ledger[:5]:
            preview = f"- {entry['name']} -> {entry['path']}"
            if entry["purpose"]:
                preview += f" -> {entry['purpose']}"
            print(preview)
        if len(ledger) > 5:
            print(f"... ({len(ledger) - 5} more)")
    else:
        print("MANIFEST LEDGER: ∅")

    for rel_kind in ("ancestry", "peers", "children"):
        entries = data["relationships"][rel_kind]
        print(f"{rel_kind.title()}:")
        if not entries:
            print("  ∅")
            continue
        rows = [
            {
                "CHECKPOINT": item["checkpoint"],
                "VALID": str(item["VALID"]),
                "LIFE": item["LIFECYCLE"],
                "SIGNAL": str(item.get("SIGNAL", "")),
                "DIST": str(item.get("distance", 0)),
            }
            for item in entries
        ]
        table = render_table(rows, ["CHECKPOINT", "VALID", "LIFE", "SIGNAL", "DIST"])
        for line in table.splitlines():
            print(f"  {line}")

    if requested_sections:
        print("\n---")
        for section_name in requested_sections:
            print(f"# {section_name}")
            print(checkpoint.sections.get(section_name, "").strip())
            print()

    return 0


def gather_relationships(
    target: Checkpoint,
    checkpoints: Sequence[Checkpoint],
    ctx: AcftContext,
    depth: int = 1,
) -> Dict[str, List[Dict[str, Any]]]:
    rel = {"ancestry": [], "peers": [], "children": []}
    parts_target = checkpoint_name_parts(target.name)
    target_delegate = target.frontmatter.get("DELEGATE_OF")
    delegate_path: Optional[Path] = None
    if isinstance(target_delegate, str):
        try:
            delegate_path = ctx.expand(target_delegate)
        except PathResolutionError:
            delegate_path = None

    def enrich(cp: Checkpoint, distance: int = 1) -> Dict[str, Any]:
        return {
            "checkpoint": ctx.to_rooted(cp.path),
            "VALID": cp.frontmatter.get("VALID"),
            "LIFECYCLE": cp.frontmatter.get("LIFECYCLE"),
            "SIGNAL": cp.frontmatter.get("SIGNAL"),
            "distance": distance,
        }

    for cp in checkpoints:
        if cp.path == target.path:
            continue
        parts = checkpoint_name_parts(cp.name)
        delegate_of = cp.frontmatter.get("DELEGATE_OF")
        delegate_abs: Optional[Path] = None
        if isinstance(delegate_of, str):
            try:
                delegate_abs = ctx.expand(delegate_of)
            except PathResolutionError:
                delegate_abs = None

        if delegate_path and cp.path == delegate_path:
            rel["ancestry"].append(enrich(cp))
        elif delegate_abs and delegate_abs == target.path:
            rel["children"].append(enrich(cp))
        elif (
            target_delegate
            and delegate_of == target_delegate
            and cp.path != target.path
        ):
            rel["peers"].append(enrich(cp))

        if parts_target and parts:
            if (
                parts["branch"] == parts_target["branch"]
                and parts["version"] == parts_target["version"]
            ):
                if parts["step"] < parts_target["step"]:
                    rel["ancestry"].append(enrich(cp))
                elif parts["step"] > parts_target["step"]:
                    rel["children"].append(enrich(cp))
            elif (
                parts["branch"] == parts_target["branch"]
                and parts["version"] < parts_target["version"]
            ):
                rel["ancestry"].append(enrich(cp))
            elif (
                parts["branch"] == parts_target["branch"]
                and parts["version"] > parts_target["version"]
            ):
                rel["children"].append(enrich(cp))

    if depth > 1:
        expanded_children: List[Dict[str, Any]] = list(rel["children"])
        queue = [(child, child["distance"]) for child in rel["children"]]
        visited = {target.path}
        while queue:
            child_entry, dist = queue.pop()
            child_path = ctx.expand(child_entry["checkpoint"])
            visited.add(child_path)
            if dist >= depth:
                expanded_children.append(child_entry)
                continue
            for cp in checkpoints:
                if cp.path == child_path or cp.path in visited:
                    continue
                child_delegate = cp.frontmatter.get("DELEGATE_OF")
                try:
                    delegate_abs = (
                        ctx.expand(child_delegate)
                        if isinstance(child_delegate, str)
                        else None
                    )
                except PathResolutionError:
                    delegate_abs = None
                parts = checkpoint_name_parts(cp.name)
                parts_child = checkpoint_name_parts(Path(child_path).name)
                if delegate_abs and delegate_abs == child_path:
                    entry = enrich(cp, distance=dist + 1)
                    expanded_children.append(entry)
                    queue.append((entry, dist + 1))
                elif parts and parts_child and parts["branch"] == parts_child["branch"]:
                    if parts["version"] > parts_child["version"]:
                        entry = enrich(cp, distance=dist + 1)
                        expanded_children.append(entry)
                        queue.append((entry, dist + 1))
                    elif (
                        parts["version"] == parts_child["version"]
                        and parts["step"] > parts_child["step"]
                    ):
                        entry = enrich(cp, distance=dist + 1)
                        expanded_children.append(entry)
                        queue.append((entry, dist + 1))
        rel["children"] = expanded_children

    for key in rel:
        rel[key] = sorted(
            rel[key], key=lambda item: (item.get("distance", 0), item["checkpoint"])
        )
    return rel
