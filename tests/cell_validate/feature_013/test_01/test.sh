#!/bin/bash

# Test 01: Non-existent path produces error

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

cd "$SCRIPT_DIR"
set +e
output=$("$CELL_VALIDATE" /nonexistent/path/to/cell 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    exit 1
fi

if ! echo "$output" | grep -q "Error: Path does not exist"; then
    echo "✗ Expected 'Path does not exist' error"
    echo "  Output: $output"
    exit 1
fi

echo "✓ Non-existent path produces error"
exit 0
