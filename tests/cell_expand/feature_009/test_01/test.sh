#!/bin/bash

# Test 01: --help shows usage information

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Test --help
output=$("$CELL_EXPAND" --help 2>&1)
exit_code=$?

# Verify exit code 0
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    exit 1
fi

# Verify help text contains key information
if ! echo "$output" | grep -q "Usage:"; then
    echo "✗ Help text missing 'Usage:'"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "@root"; then
    echo "✗ Help text missing '@root' information"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "EXAMPLES"; then
    echo "✗ Help text missing 'EXAMPLES' section"
    echo "  Output: $output"
    exit 1
fi

# Test -h alias
output_h=$("$CELL_EXPAND" -h 2>&1)
if [ "$output" != "$output_h" ]; then
    echo "✗ -h output differs from --help"
    exit 1
fi

echo "✓ Help flag shows complete usage information"
exit 0
