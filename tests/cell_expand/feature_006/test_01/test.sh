#!/bin/bash

# Test 01: Absolute and relative paths work without cellproject.toml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Create test directory without cellproject.toml
TEST_ROOT="$SCRIPT_DIR/test_temp"
mkdir -p "$TEST_ROOT/subdir"

# Run from directory without cellproject.toml
cd "$TEST_ROOT/subdir"

# Test absolute path
output=$("$CELL_EXPAND" /absolute/path 2>&1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "✗ Absolute path failed with exit code $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi
if [ "$output" != "/absolute/path" ]; then
    echo "✗ Expected /absolute/path, got $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Test relative path
output=$("$CELL_EXPAND" relative/path 2>&1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "✗ Relative path failed with exit code $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi
if [ "$output" != "relative/path" ]; then
    echo "✗ Expected relative/path, got $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ Non-@project paths work without cellproject.toml"
exit 0
