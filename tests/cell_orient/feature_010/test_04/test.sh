#!/bin/bash

# Test 04: Invalid path error

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Run with nonexistent path
cd "$TEST_ROOT"
exit_code=0
output=$("$CELL_ORIENT" /nonexistent/path 2>&1) || exit_code=$?

# Verify exit code is 1
if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    echo "  Output: $output"
    exit 1
fi

# Verify error message
if ! echo "$output" | grep -q "Path does not exist"; then
    echo "✗ Expected error message about path not existing"
    echo "  Output: $output"
    exit 1
fi

rm -rf "$TEST_ROOT/projectroot.toml"

echo "✓ Invalid path produces correct error"
exit 0
