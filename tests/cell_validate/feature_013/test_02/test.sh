#!/bin/bash

# Test 02: Path is a file, not directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
touch "$TEST_ROOT/test_file.txt"

cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" test_file.txt 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    rm -f "$TEST_ROOT/test_file.txt"
    exit 1
fi

if ! echo "$output" | grep -q "Error: Path is not a directory"; then
    echo "✗ Expected 'Path is not a directory' error"
    echo "  Output: $output"
    rm -f "$TEST_ROOT/test_file.txt"
    exit 1
fi

rm -f "$TEST_ROOT/test_file.txt"

echo "✓ Path is a file produces error"
exit 0
