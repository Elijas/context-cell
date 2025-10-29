#!/bin/bash

# Test 01: @root works from deeply nested directories

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Create deeply nested test directory
TEST_ROOT="$SCRIPT_DIR/test_temp"
mkdir -p "$TEST_ROOT/a/b/c/d/e/f/g"

# Create cellproject.toml at root
cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Run cell expand from deepest subdirectory
cd "$TEST_ROOT/a/b/c/d/e/f/g"
output=$("$CELL_EXPAND" @root 2>&1)
exit_code=$?

# Verify exit code
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Verify output is correct absolute path
if [ "$output" != "$TEST_ROOT" ]; then
    echo "✗ Expected $TEST_ROOT, got $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ @root works from deeply nested directories"
exit 0
