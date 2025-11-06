def test_scaffold_creates_checkpoint_and_event(project_builder):
    result = project_builder.run_acft(["new", "alpha_v1_01"])
    assert result.returncode == 0, result.stderr

    checkpoint_dir = project_builder.checkpoint_path("alpha_v1_01")
    assert (checkpoint_dir / "CHECKPOINT.md").exists(), "CHECKPOINT.md missing"

    manifest_dir = checkpoint_dir / "ARTIFACTS"
    assert not manifest_dir.exists(), "ARTIFACTS should not exist by default"

    events = project_builder.read_events()
    event_types = [event["TYPE"] for event in events]
    assert "CHECKPOINT_CREATED" in event_types

    log_contents = (checkpoint_dir / "CHECKPOINT.md").read_text(encoding="utf-8")
    assert "CHECKPOINT scaffolding created" in log_contents


def test_new_supports_delegate_tags_and_no_open(project_builder):
    project_builder.run_acft(["new", "parent_v1_01"])
    result = project_builder.run_acft(
        [
            "new",
            "child_v1_01",
            "--delegate-of",
            "::WORK/parent_v1_01",
            "--tags",
            "spike,experiment",
            "--no-open",
        ]
    )
    assert result.returncode == 0, result.stderr

    checkpoint_dir = project_builder.checkpoint_path("child_v1_01")
    text = (checkpoint_dir / "CHECKPOINT.md").read_text(encoding="utf-8")
    assert "::WORK/parent_v1_01" in text
    assert "TAGS:" in text and "spike" in text

    log_section = text.split("# LOG", 1)[1]
    assert "CHECKPOINT scaffolding created" not in log_section

    events = [event for event in project_builder.read_events() if event["TYPE"] == "CHECKPOINT_CREATED"]
    child_event = [event for event in events if event["CHECKPOINT_PATH"].endswith("child_v1_01")][-1]
    assert child_event["PAYLOAD"]["DELEGATE_OF"] == "::WORK/parent_v1_01"
    assert child_event["PAYLOAD"]["TAGS"] == ["spike", "experiment"]
