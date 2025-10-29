#!/bin/bash

# Test 01: Directory without CELL.md fails validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/valid_v1_01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Don't create CELL.md - that's the test

cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" valid_v1_01 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

if ! echo "$output" | grep -q "Missing required file: CELL.md"; then
    echo "✗ Expected 'Missing required file: CELL.md' error not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/projectroot.toml"

echo "✓ Directory without CELL.md fails validation"
exit 0
