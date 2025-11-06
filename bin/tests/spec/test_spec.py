def test_spec_prints_requested_document(project_builder):
    result = project_builder.run_acft(["spec", "--doc", "guide"], cwd=project_builder.project_root)
    assert "Harness Manual" in result.stdout


def test_spec_custom_path(project_builder):
    custom_doc = project_builder.project_root / "spec" / "CUSTOM.md"
    custom_doc.write_text("Custom Spec", encoding="utf-8")

    result = project_builder.run_acft(["spec", "--path", str(custom_doc)], cwd=project_builder.project_root)
    assert "Custom Spec" in result.stdout
