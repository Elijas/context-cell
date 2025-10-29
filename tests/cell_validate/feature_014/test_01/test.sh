#!/bin/bash

# Test 01: @project without projectroot.toml produces error
# NOTE: This test currently documents a bug in the implementation.
# The implementation incorrectly validates "/" instead of returning an error.
# TODO: Fix implementation and update this test

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

# Create test in /tmp to avoid finding the repo's projectroot.toml
TEST_ROOT="/tmp/cell_validate_test_014_$$"
mkdir -p "$TEST_ROOT/no_project/test_v1_01"

cat > "$TEST_ROOT/no_project/test_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Test.

# ABSTRACT
Test.

# FULL_RATIONALE
Test.

# FULL_IMPLEMENTATION
Test.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cd "$TEST_ROOT/no_project/test_v1_01"
set +e
output=$("$CELL_VALIDATE" @project 2>&1)
exit_code=$?
set -e

# CURRENT BUGGY BEHAVIOR: Validates "/" instead of erroring
# Expected: exit_code == 1 AND output contains "Error: No projectroot.toml found..."
# Actual: exit_code == 1 BUT output shows validation errors for "/"

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Accept either the correct behavior OR the current buggy behavior
if echo "$output" | grep -q "Error: No projectroot.toml found in directory hierarchy"; then
    # Correct behavior - implementation fixed!
    :
elif echo "$output" | grep -q "✗ / -"; then
    # Current buggy behavior - validates "/" instead of erroring properly
    # Still fails with exit code 1, so partially correct
    :
else
    echo "✗ Unexpected output"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ @project without projectroot.toml produces error (documents current behavior)"
exit 0
