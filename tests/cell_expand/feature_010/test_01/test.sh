#!/bin/bash

# Test 01: Command substitution works for cd and ls

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Create test directory
TEST_ROOT="$SCRIPT_DIR/test_temp"
mkdir -p "$TEST_ROOT/execution"

# Create cellproject.toml
cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Create test file
echo "test content" > "$TEST_ROOT/execution/test.txt"

# Change to test directory so cell expand can find cellproject.toml
cd "$TEST_ROOT"

# Test cd with command substitution (should stay in TEST_ROOT)
cd $("$CELL_EXPAND" @project)
if [ "$(pwd)" != "$TEST_ROOT" ]; then
    echo "✗ cd substitution failed: expected $TEST_ROOT, got $(pwd)"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Test ls with command substitution
ls_output=$(ls $("$CELL_EXPAND" @project/execution) 2>&1)
if ! echo "$ls_output" | grep -q "test.txt"; then
    echo "✗ ls substitution failed: test.txt not found"
    echo "  Output: $ls_output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ Command substitution works correctly"
exit 0
