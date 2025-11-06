import os
from pathlib import Path


def test_init_creates_both_files_when_none_exist(tmp_path):
    """Test that init creates both config files when run in an empty directory."""
    from tests.util import ACFT_BIN
    import subprocess

    # Change to the temp directory
    result = subprocess.run(
        [str(ACFT_BIN), "init"],
        cwd=str(tmp_path),
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0, f"Failed: {result.stderr}"
    assert "Created: checkpoints_project.toml, checkpoints_work.toml" in result.stdout

    # Verify both files exist
    project_toml = tmp_path / "checkpoints_project.toml"
    work_toml = tmp_path / "checkpoints_work.toml"

    assert project_toml.exists(), "checkpoints_project.toml should exist"
    assert work_toml.exists(), "checkpoints_work.toml should exist"

    # Verify files are not empty (they contain marker comments)
    project_content = project_toml.read_text()
    work_content = work_toml.read_text()

    assert len(project_content) > 0, "checkpoints_project.toml should not be empty"
    assert len(work_content) > 0, "checkpoints_work.toml should not be empty"


def test_init_skips_when_project_exists_in_current_dir(tmp_path):
    """Test that init doesn't create files when they already exist in current directory."""
    from tests.util import ACFT_BIN
    import subprocess

    # Create checkpoints_project.toml
    project_toml = tmp_path / "checkpoints_project.toml"
    project_toml.write_text("project = true\n")

    # Create checkpoints_work.toml
    work_toml = tmp_path / "checkpoints_work.toml"
    work_toml.write_text("work = true\n")

    result = subprocess.run(
        [str(ACFT_BIN), "init"],
        cwd=str(tmp_path),
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0
    assert "already exist" in result.stdout


def test_init_skips_when_project_exists_in_parent_dir(tmp_path):
    """Test that init doesn't create project config when it exists in parent directory."""
    from tests.util import ACFT_BIN
    import subprocess

    # Create checkpoints_project.toml in parent
    project_toml = tmp_path / "checkpoints_project.toml"
    project_toml.write_text("project = true\n")

    # Create checkpoints_work.toml in parent
    work_toml = tmp_path / "checkpoints_work.toml"
    work_toml.write_text("work = true\n")

    # Create subdirectory and run init there
    subdir = tmp_path / "subdir"
    subdir.mkdir()

    result = subprocess.run(
        [str(ACFT_BIN), "init"],
        cwd=str(subdir),
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0
    assert "already exist" in result.stdout

    # Verify files were not created in subdirectory
    assert not (subdir / "checkpoints_project.toml").exists()
    assert not (subdir / "checkpoints_work.toml").exists()


def test_init_creates_work_when_only_project_exists(tmp_path):
    """Test that init creates work config when only project config exists."""
    from tests.util import ACFT_BIN
    import subprocess

    # Create only checkpoints_project.toml
    project_toml = tmp_path / "checkpoints_project.toml"
    project_toml.write_text("project = true\n")

    result = subprocess.run(
        [str(ACFT_BIN), "init"],
        cwd=str(tmp_path),
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0
    assert "Created: checkpoints_work.toml" in result.stdout
    assert "checkpoints_project.toml" not in result.stdout or "already exist" in result.stdout

    # Verify work file was created
    work_toml = tmp_path / "checkpoints_work.toml"
    assert work_toml.exists()


def test_init_creates_project_when_only_work_exists(tmp_path):
    """Test that init creates project config when only work config exists."""
    from tests.util import ACFT_BIN
    import subprocess

    # Create only checkpoints_work.toml
    work_toml = tmp_path / "checkpoints_work.toml"
    work_toml.write_text("work = true\n")

    result = subprocess.run(
        [str(ACFT_BIN), "init"],
        cwd=str(tmp_path),
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0
    assert "Created: checkpoints_project.toml" in result.stdout

    # Verify project file was created
    project_toml = tmp_path / "checkpoints_project.toml"
    assert project_toml.exists()


def test_init_respects_parent_work_but_not_project(tmp_path):
    """Test init when work config is in parent but project config doesn't exist."""
    from tests.util import ACFT_BIN
    import subprocess

    # Create checkpoints_work.toml in parent
    work_toml = tmp_path / "checkpoints_work.toml"
    work_toml.write_text("work = true\n")

    # Create subdirectory
    subdir = tmp_path / "subdir"
    subdir.mkdir()

    result = subprocess.run(
        [str(ACFT_BIN), "init"],
        cwd=str(subdir),
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0

    # Should create project file in subdirectory since none exists in hierarchy
    assert (subdir / "checkpoints_project.toml").exists()

    # Should not create work file since it exists in parent
    assert not (subdir / "checkpoints_work.toml").exists()


def test_init_multiple_parent_levels(tmp_path):
    """Test that init searches up multiple directory levels."""
    from tests.util import ACFT_BIN
    import subprocess

    # Create config files at root
    project_toml = tmp_path / "checkpoints_project.toml"
    project_toml.write_text("project = true\n")
    work_toml = tmp_path / "checkpoints_work.toml"
    work_toml.write_text("work = true\n")

    # Create nested subdirectories
    deep_dir = tmp_path / "level1" / "level2" / "level3"
    deep_dir.mkdir(parents=True)

    result = subprocess.run(
        [str(ACFT_BIN), "init"],
        cwd=str(deep_dir),
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0
    assert "already exist" in result.stdout

    # Verify no files created in deep directory
    assert not (deep_dir / "checkpoints_project.toml").exists()
    assert not (deep_dir / "checkpoints_work.toml").exists()
