#!/bin/bash

# Test 01: --help flag shows usage information

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

# Run with --help flag
exit_code=0
output=$("$CELL_ORIENT" --help 2>&1) || exit_code=$?

# Verify exit code is 0
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    exit 1
fi

# Verify usage information appears
if ! echo "$output" | grep -q "Usage:"; then
    echo "✗ 'Usage:' not found in help output"
    echo "  Output: $output"
    exit 1
fi

# Verify flag descriptions appear
if ! echo "$output" | grep -q "\-\-DISCOVERY"; then
    echo "✗ --DISCOVERY flag not described"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "\-\-ABSTRACT"; then
    echo "✗ --ABSTRACT flag not described"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "\-\-ancestors"; then
    echo "✗ --ancestors flag not described"
    echo "  Output: $output"
    exit 1
fi

echo "✓ --help flag shows correct usage information"
exit 0
