#!/bin/bash

# Test 01: Subpath expansion with multiple path components

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Create test directory
TEST_ROOT="$SCRIPT_DIR/test_temp"
mkdir -p "$TEST_ROOT/subdir"

# Create projectroot.toml
cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Run cell expand with subpath
cd "$TEST_ROOT/subdir"
output=$("$CELL_EXPAND" @project/execution/cell_v1_01 2>&1)
exit_code=$?

# Verify exit code
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Verify output has @project expanded and subpath appended
expected="$TEST_ROOT/execution/cell_v1_01"
if [ "$output" != "$expected" ]; then
    echo "✗ Expected $expected, got $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ @project/subpath expands correctly"
exit 0
