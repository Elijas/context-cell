#!/bin/bash

# Test 01: Missing path argument produces error

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

# Run cell validate with no path argument
set +e  # Allow command to fail
output=$("$CELL_VALIDATE" 2>&1)
exit_code=$?
set -e  # Re-enable exit on error

# Verify non-zero exit code
if [ "$exit_code" -eq 0 ]; then
    echo "✗ Expected non-zero exit code, got 0"
    echo "  Output: $output"
    exit 1
fi

# Verify error message mentions missing path
if ! echo "$output" | grep -q "Missing PATH argument"; then
    echo "✗ Expected 'Missing PATH argument' in error message"
    echo "  Output: $output"
    exit 1
fi

echo "✓ Missing path argument produces correct error"
exit 0
