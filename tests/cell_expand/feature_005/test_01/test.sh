#!/bin/bash

# Test 01: Error when @root used without cellproject.toml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Create test directory without cellproject.toml
TEST_ROOT="$SCRIPT_DIR/test_temp"
mkdir -p "$TEST_ROOT/subdir"

# Run cell expand @root from directory without cellproject.toml
cd "$TEST_ROOT/subdir"
set +e  # Allow command to fail
output=$("$CELL_EXPAND" @root 2>&1)
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

# Verify error message mentions missing cellproject.toml
if ! echo "$output" | grep -q "No cellproject.toml found"; then
    echo "✗ Expected 'No cellproject.toml found' in error message"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ @root without cellproject.toml produces correct error"
exit 0
