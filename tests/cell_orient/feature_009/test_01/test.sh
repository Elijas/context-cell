#!/bin/bash

# Test 01: No work cells found message with exit code 0

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution"

cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Run from empty execution directory
cd "$TEST_ROOT/execution"
exit_code=0
output=$("$CELL_ORIENT" . 2>&1) || exit_code=$?

# Verify exit code is 0 (not an error)
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    exit 1
fi

# Verify message
if ! echo "$output" | grep -q "No work cells found in current location"; then
    echo "✗ Expected 'No work cells found' message"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Empty hierarchy shows correct message with exit code 0"
exit 0
