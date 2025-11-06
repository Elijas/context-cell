def test_close_sets_valid_true_and_emits_events(project_builder):
    project_builder.run_acft(["new", "close_v1_01"])
    checkpoint_dir = project_builder.checkpoint_path("close_v1_01")

    project_builder.replace_in_checkpoint(
        "close_v1_01",
        "Placeholder -> ::THIS/ARTIFACTS/stub -> Replace once deliverables exist.",
        "Summary -> ::THIS/ARTIFACTS/report.md -> Final handoff artifact.",
    )
    project_builder.write_checkpoint_file("close_v1_01", "ARTIFACTS/report.md", "ready")

    result = project_builder.run_acft(
        ["close", "--status", "true", "--signal", "pass", "--message", "Ready for handoff"],
        cwd=checkpoint_dir,
    )
    assert result.returncode == 0, result.stderr

    events = project_builder.read_events()
    types = [event["TYPE"] for event in events]
    assert "CHECKPOINT_VERIFIED" in types
    assert "CHECKPOINT_CLOSED" in types

    verified = [event for event in events if event["TYPE"] == "CHECKPOINT_VERIFIED"][-1]
    assert verified["PAYLOAD"]["VALID"] is True
    assert verified["PAYLOAD"]["SIGNAL"] == "pass"


def test_close_requires_manifest_entries(project_builder):
    project_builder.run_acft(["new", "close_v1_02"])
    checkpoint_dir = project_builder.checkpoint_path("close_v1_02")
    project_builder.replace_in_checkpoint(
        "close_v1_02",
        "- Placeholder -> ::THIS/ARTIFACTS/stub -> Replace once deliverables exist.",
        "",
    )

    result = project_builder.run_acft(
        ["close", "--status", "true"],
        cwd=checkpoint_dir,
        check=False,
    )
    assert result.returncode != 0
    assert "MANIFEST LEDGER" in (result.stderr or result.stdout)
