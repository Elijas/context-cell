def test_claude_help_invokes_wrapper(project_builder):
    result = project_builder.run_acft(["claude", "--", "--help"], check=True)
    assert "Usage:" in result.stdout
