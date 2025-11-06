def test_expand_outputs_absolute_paths(project_builder):
    result = project_builder.run_acft(["expand", "::PROJECT", "::WORK"])
    outputs = [line for line in result.stdout.splitlines() if line.strip()]
    assert len(outputs) == 2
    for line in outputs:
        assert line.startswith("/"), f"Expected absolute path, got {line}"


def test_expand_this_inside_checkpoint(project_builder):
    project_builder.run_acft(["new", "expand_v1_01"])
    checkpoint_dir = project_builder.checkpoint_path("expand_v1_01")

    result = project_builder.run_acft(["expand", "::THIS"], cwd=checkpoint_dir)
    output = result.stdout.strip()
    assert output.endswith("expand_v1_01")


def test_expand_project_fails_without_marker(project_builder):
    """Test that ::PROJECT fails when checkpoints_project.toml is missing."""
    # Remove the marker file
    (project_builder.project_root / "checkpoints_project.toml").unlink()

    result = project_builder.run_acft(["expand", "::PROJECT"], check=False)
    assert result.returncode != 0
    assert "Cannot expand ::PROJECT" in result.stderr
    assert "no checkpoints_project.toml found" in result.stderr


def test_expand_work_fails_without_marker(project_builder):
    """Test that ::WORK fails when checkpoints_work.toml is missing."""
    # Remove the marker file
    (project_builder.work_root / "checkpoints_work.toml").unlink()

    result = project_builder.run_acft(["expand", "::WORK"], check=False)
    assert result.returncode != 0
    assert "Cannot expand ::WORK" in result.stderr
    assert "no checkpoints_work.toml found" in result.stderr


def test_expand_this_fails_without_checkpoint(project_builder):
    """Test that ::THIS fails when CHECKPOINT.md is not found."""
    result = project_builder.run_acft(["expand", "::THIS"], check=False)
    assert result.returncode != 0
    assert "Cannot expand ::THIS" in result.stderr
    assert "no CHECKPOINT.md found" in result.stderr


def test_expand_project_ignores_git_directory(project_builder, tmp_path):
    """Test that .git directory is no longer used as a marker for ::PROJECT."""
    import tempfile
    import shutil
    from pathlib import Path

    # Create a nested structure: outer has checkpoints_project.toml, inner has .git
    outer = Path(tempfile.mkdtemp(prefix="acft_git_test_"))
    try:
        inner = outer / "inner"
        inner.mkdir()

        # Put checkpoints_project.toml in outer
        (outer / "checkpoints_project.toml").write_text("project = true\n")

        # Put .git in inner (should be ignored)
        git_dir = inner / ".git"
        git_dir.mkdir()
        (git_dir / "config").write_text("[core]\n")

        # Run from inner directory - should find outer, not stop at .git
        result = project_builder.run_acft(["expand", "::PROJECT"], cwd=inner, check=True)
        expanded = result.stdout.strip()

        # Should expand to outer directory, not inner
        # Resolve both paths to handle symlink differences (/var vs /private/var on macOS)
        assert Path(expanded).resolve() == outer.resolve()
    finally:
        shutil.rmtree(outer, ignore_errors=True)
