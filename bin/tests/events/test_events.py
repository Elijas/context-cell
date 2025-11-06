import json


def test_events_tail_filters_by_type(project_builder):
    project_builder.run_acft(["new", "events_v1_01"])
    checkpoint_dir = project_builder.checkpoint_path("events_v1_01")

    project_builder.replace_in_checkpoint(
        "events_v1_01",
        "Placeholder -> ::THIS/ARTIFACTS/stub -> Replace once deliverables exist.",
        "Log -> ::THIS/ARTIFACTS/log.md -> Deliverable",
    )
    project_builder.write_checkpoint_file("events_v1_01", "ARTIFACTS/log.md", "ok")
    project_builder.run_acft(["close", "--status", "true", "--signal", "pass"], cwd=checkpoint_dir)

    result = project_builder.run_acft(
        ["events", "tail", "--since=-1d", "--types", "CHECKPOINT_CREATED"],
        check=True,
    )

    lines = [line for line in result.stdout.splitlines() if line.strip()]
    assert lines, "Expected at least one event in tail output"
    for line in lines:
        event = json.loads(line)
        assert event["TYPE"] == "CHECKPOINT_CREATED"


def test_events_tail_with_iso_timestamp(project_builder):
    project_builder.run_acft(["new", "events_v1_02"])
    events = project_builder.read_events()
    timestamp = events[-1]["TIMESTAMP"]

    result = project_builder.run_acft(
        ["events", "tail", "--since", timestamp, "--types", "CHECKPOINT_CREATED"],
        check=True,
    )
    lines = [line for line in result.stdout.splitlines() if line.strip()]
    assert lines, "Expected events when using ISO timestamp"
