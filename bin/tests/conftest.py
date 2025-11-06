import pytest

from tests.util import ProjectBuilder


@pytest.fixture()
def project_builder():
    builder = ProjectBuilder()
    try:
        yield builder
    finally:
        builder.cleanup()
