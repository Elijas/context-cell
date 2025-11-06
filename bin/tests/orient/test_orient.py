import json


def test_orient_reports_basic_metadata(project_builder):
    project_builder.run_acft(["new", "orient_v1_01"])
    checkpoint_dir = project_builder.checkpoint_path("orient_v1_01")

    result = project_builder.run_acft(["orient", "::THIS", "--json"], cwd=checkpoint_dir)
    payload = json.loads(result.stdout)

    assert payload["name"] == "orient_v1_01"
    assert "relationships" in payload
    assert "manifest_ledger" in payload


def test_orient_sections_and_depth(project_builder):
    project_builder.run_acft(["new", "line_v1_01"])
    project_builder.run_acft(["new", "line_v1_02"])
    project_builder.run_acft(
        ["new", "delegate_v1_01", "--delegate-of", "::WORK/line_v1_01"]
    )
    checkpoint_dir = project_builder.checkpoint_path("line_v1_01")

    result = project_builder.run_acft(
        ["orient", "::WORK/line_v1_01", "--depth", "2", "--sections", "STATUS,LOG", "--json"],
        cwd=checkpoint_dir,
    )
    payload = json.loads(result.stdout)

    children = {item["checkpoint"] for item in payload["relationships"]["children"]}
    assert any(name.endswith("line_v1_02") for name in children)
    assert any(name.endswith("delegate_v1_01") for name in children)
    sections = payload["sections"]
    assert "STATUS" in sections and "LOG" in sections
