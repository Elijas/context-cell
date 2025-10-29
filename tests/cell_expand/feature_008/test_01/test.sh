#!/bin/bash

# Test 01: Multi-level subpaths preserve structure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Create test directory
TEST_ROOT="$SCRIPT_DIR/test_temp"
mkdir -p "$TEST_ROOT"

# Create cellproject.toml
cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Test complex subpath
cd "$TEST_ROOT"
complex_path="@root/execution/auth_v1_01/testing_v1_02/_outputs/results.json"
output=$("$CELL_EXPAND" "$complex_path" 2>&1)
exit_code=$?

# Verify exit code
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Verify full path structure preserved
expected="$TEST_ROOT/execution/auth_v1_01/testing_v1_02/_outputs/results.json"
if [ "$output" != "$expected" ]; then
    echo "✗ Expected $expected"
    echo "  Got $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ Complex subpaths preserve full structure"
exit 0
