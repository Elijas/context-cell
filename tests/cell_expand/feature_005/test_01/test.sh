#!/bin/bash

# Test 01: Error when @project used without projectroot.toml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Create test directory without projectroot.toml
TEST_ROOT="$SCRIPT_DIR/test_temp"
mkdir -p "$TEST_ROOT/subdir"

# Run cell expand @project from directory without projectroot.toml
cd "$TEST_ROOT/subdir"
set +e  # Allow command to fail
output=$("$CELL_EXPAND" @project 2>&1)
exit_code=$?
set -e  # Re-enable exit on error

# Verify non-zero exit code
if [ -z "$exit_code" ] || [ "$exit_code" -eq 0 ]; then
    echo "✗ Expected non-zero exit code, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Verify error message mentions missing projectroot.toml
if ! echo "$output" | grep -q "No projectroot.toml found"; then
    echo "✗ Expected 'No projectroot.toml found' in error message"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ @project without projectroot.toml produces correct error"
exit 0
