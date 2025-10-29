#!/bin/bash

# Test 01: Error when no path argument provided

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Run cell expand with no arguments
set +e  # Allow command to fail
output=$("$CELL_EXPAND" 2>&1)
exit_code=$?
set -e  # Re-enable exit on error

# Verify non-zero exit code
if [ -z "$exit_code" ] || [ "$exit_code" -eq 0 ]; then
    echo "✗ Expected non-zero exit code, got $exit_code"
    echo "  Output: $output"
    exit 1
fi

# Verify error message mentions missing argument
if ! echo "$output" | grep -q "Missing PATH argument"; then
    echo "✗ Expected 'Missing PATH argument' in error message"
    echo "  Output: $output"
    exit 1
fi

echo "✓ Missing path argument produces correct error"
exit 0
