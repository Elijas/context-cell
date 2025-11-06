from __future__ import annotations

import argparse
import json
from typing import List

from _lib import (
    AcftContext,
    checkpoint_name_parts,
    detect_unrooted_paths,
    validate_section_order,
)


def register(subparsers: argparse._SubParsersAction) -> None:
    parser = subparsers.add_parser(
        "validate",
        help="Lint checkpoint structure against the harness specification.",
    )
    parser.add_argument("path", nargs="?", default="::THIS", help="Rooted path (default ::THIS).")
    parser.add_argument("--strict", action="store_true", help="Treat warnings as failures.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    parser.set_defaults(handler=run)


def run(args: argparse.Namespace, ctx: AcftContext) -> int:
    checkpoint = ctx.checkpoint_from_arg(args.path)
    errors: List[str] = []
    warnings: List[str] = []

    parts = checkpoint_name_parts(checkpoint.name)
    if not parts:
        errors.append(
            f"Directory name '{checkpoint.name}' must match {{branch}}_v{{version}}_{{step}}."
        )

    if "VALID" not in checkpoint.frontmatter or "LIFECYCLE" not in checkpoint.frontmatter:
        errors.append("Frontmatter must declare VALID and LIFECYCLE keys.")
    else:
        lifecycle = checkpoint.frontmatter.get("LIFECYCLE")
        if lifecycle not in {"active", "superseded", "archived"}:
            errors.append("LIFECYCLE must be active, superseded, or archived.")
        if lifecycle != "active" and checkpoint.frontmatter.get("VALID") not in {False, "false"}:
            errors.append("LIFECYCLE != active requires VALID: false.")

    section_errors, section_warnings = validate_section_order(checkpoint.section_order)
    errors.extend(section_errors)
    warnings.extend(section_warnings)

    combined_text = "\n".join(
        checkpoint.sections.get(name, "") for name in checkpoint.section_order
    )
    unrooted = detect_unrooted_paths(combined_text)
    if unrooted:
        errors.append("Detected unrooted or relative paths: " + ", ".join(sorted(set(unrooted))))

    stage_dir = checkpoint.path / "STAGE"
    if stage_dir.exists() and any(stage_dir.iterdir()) and checkpoint.frontmatter.get("VALID"):
        warnings.append("STAGE/ contains files while VALID: true.")

    for section_name in ["STATUS", "HARNESS", "CONTEXT", "MANIFEST"]:
        if not checkpoint.sections.get(section_name, "").strip():
            warnings.append(f"{section_name} section is empty.")

    status = checkpoint.sections.get("STATUS", "")
    if "Context recap" not in status:
        warnings.append("STATUS should include a 'Context recap'.")
    if "Success criteria" not in status or "Exit criteria" not in status:
        warnings.append("STATUS should list success and exit criteria.")

    manifest = checkpoint.sections.get("MANIFEST", "")
    if "## MANIFEST LEDGER" not in manifest:
        warnings.append("MANIFEST should begin with ## MANIFEST LEDGER.")

    result = {
        "checkpoint": ctx.to_rooted(checkpoint.path),
        "errors": errors,
        "warnings": warnings,
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"Validation report for {result['checkpoint']}:")
        if errors:
            print("Errors:")
            for item in errors:
                print(f"  - {item}")
        if warnings:
            print("Warnings:")
            for item in warnings:
                print(f"  - {item}")
        if not errors and not warnings:
            print("No structural issues detected.")

    if errors or (args.strict and warnings):
        return 1
    return 0
