#!/bin/bash

# Test 01: Absolute, relative, and dot-relative paths pass through unchanged

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Test absolute path
output=$("$CELL_EXPAND" /usr/local/bin 2>&1)
if [ "$output" != "/usr/local/bin" ]; then
    echo "✗ Absolute path: Expected /usr/local/bin, got $output"
    exit 1
fi

# Test relative path
output=$("$CELL_EXPAND" relative/path 2>&1)
if [ "$output" != "relative/path" ]; then
    echo "✗ Relative path: Expected relative/path, got $output"
    exit 1
fi

# Test dot-relative path
output=$("$CELL_EXPAND" ./foo/bar 2>&1)
if [ "$output" != "./foo/bar" ]; then
    echo "✗ Dot-relative path: Expected ./foo/bar, got $output"
    exit 1
fi

echo "✓ Non-@project paths pass through unchanged"
exit 0
