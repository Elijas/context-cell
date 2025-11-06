def test_verify_executes_harness_and_emits_event(project_builder):
    project_builder.run_acft(["new", "verify_v1_01"])
    checkpoint_dir = project_builder.checkpoint_path("verify_v1_01")

    project_builder.replace_in_checkpoint(
        "verify_v1_01",
        "# add verification commands here",
        'echo "harness-ok"',
    )

    result = project_builder.run_acft(
        ["verify", "::THIS", "--record"],
        cwd=checkpoint_dir,
    )
    assert result.returncode == 0, result.stderr

    log_dir = project_builder.work_root / "logs" / "verify_v1_01"
    assert log_dir.exists(), "Log directory missing after verify"
    assert any(log_dir.iterdir()), "Harness log not created"

    events = project_builder.read_events()
    types = [event["TYPE"] for event in events]
    assert "HARNESS_EXECUTED" in types


def test_verify_dry_run_skips_execution(project_builder):
    project_builder.run_acft(["new", "verify_v1_02"])
    checkpoint_dir = project_builder.checkpoint_path("verify_v1_02")
    project_builder.replace_in_checkpoint(
        "verify_v1_02",
        "# add verification commands here",
        'echo "dry-run"',
    )

    result = project_builder.run_acft(
        ["verify", "::THIS", "--dry-run"],
        cwd=checkpoint_dir,
    )
    assert result.returncode == 0, result.stderr
    log_dir = project_builder.work_root / "logs" / "verify_v1_02"
    assert not log_dir.exists()


def test_verify_failure_propagates_exit_code(project_builder):
    project_builder.run_acft(["new", "verify_v1_03"])
    checkpoint_dir = project_builder.checkpoint_path("verify_v1_03")
    project_builder.replace_in_checkpoint(
        "verify_v1_03",
        "# add verification commands here",
        "false",
    )

    result = project_builder.run_acft(
        ["verify", "::THIS", "--record"],
        cwd=checkpoint_dir,
        check=False,
    )
    assert result.returncode != 0
    events = [event for event in project_builder.read_events() if event["TYPE"] == "HARNESS_EXECUTED"]
    # Even on failure the event should record the failure state for traceability
    assert events, "Expected HARNESS_EXECUTED event even when harness fails"
    assert events[-1]["PAYLOAD"]["STATUS"] == "fail"


def test_verify_section_filters_commands(project_builder):
    project_builder.run_acft(["new", "verify_v1_04"])
    checkpoint_dir = project_builder.checkpoint_path("verify_v1_04")
    project_builder.replace_in_checkpoint(
        "verify_v1_04",
        "## Dependencies",
        "## Additional Harness\n```sh\necho extra\n```\n\n## Dependencies",
    )
    project_builder.replace_in_checkpoint(
        "verify_v1_04",
        "# add verification commands here",
        'echo "main"',
    )

    result = project_builder.run_acft(
        ["verify", "::THIS", "--section", "Additional", "--record"],
        cwd=checkpoint_dir,
    )
    assert result.returncode == 0
    log_dir = project_builder.work_root / "logs" / "verify_v1_04"
    log_files = list(log_dir.glob("*.log"))
    assert log_files, "Expected log files for section run"
    log_text = log_files[-1].read_text(encoding="utf-8")
    assert "extra" in log_text and "main" not in log_text
