import json


def test_validate_reports_no_errors(project_builder):
    project_builder.run_acft(["new", "validate_v1_01"])
    checkpoint_dir = project_builder.checkpoint_path("validate_v1_01")

    result = project_builder.run_acft(["validate", "::THIS", "--json"], cwd=checkpoint_dir)
    payload = json.loads(result.stdout)

    assert payload["errors"] == []


def test_validate_flags_unrooted_paths(project_builder):
    project_builder.run_acft(["new", "validate_v1_02"])
    project_builder.replace_in_checkpoint(
        "validate_v1_02",
        "::THIS/ARTIFACTS/stub",
        "../relative/path",
    )
    checkpoint_dir = project_builder.checkpoint_path("validate_v1_02")

    result = project_builder.run_acft(["validate", "::THIS", "--json"], cwd=checkpoint_dir, check=False)
    payload = json.loads(result.stdout)

    assert any("unrooted" in error for error in payload["errors"])
