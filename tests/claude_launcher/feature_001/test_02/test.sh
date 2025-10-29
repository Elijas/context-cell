#!/bin/bash

# Test 02: Launch with -y flag from project root
# The launcher should find cellproject.toml in current directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
LAUNCHER="$REPO_ROOT/bin/claude_launcher.sh"
MOCK_CLAUDE="$REPO_ROOT/tests/mocks/claude"

# Expected project root is this test directory
EXPECTED_ROOT="$SCRIPT_DIR"

# Change to test directory (where cellproject.toml exists)
cd "$SCRIPT_DIR"

# Run the launcher with -y flag using mock claude
output=$(PATH="$(dirname "$MOCK_CLAUDE"):$PATH" "$LAUNCHER" -y "test prompt" 2>&1)

# Check that it printed "Project root:"
if ! echo "$output" | grep -q "Project root:"; then
    echo "✗ Did not print 'Project root:' label"
    echo "  Got: $output"
    exit 1
fi

# Check that it printed the project root path with indentation
if ! echo "$output" | grep -q "^  $EXPECTED_ROOT$"; then
    echo "✗ Did not print project root path with correct indentation"
    echo "  Expected to see:   $EXPECTED_ROOT"
    echo "  Got: $output"
    exit 1
fi

# Check that claude was launched from the original directory (same as project root in this case)
if ! echo "$output" | grep -q "Current directory: $EXPECTED_ROOT"; then
    echo "✗ Claude not launched from original directory"
    echo "  Expected directory: $EXPECTED_ROOT"
    echo "  Output: $output"
    exit 1
fi

# Check that --add-dir was NOT passed
if echo "$output" | grep -q "\-\-add\-dir"; then
    echo "✗ Should not pass --add-dir flag"
    echo "  Output: $output"
    exit 1
fi

echo "✓ Launched with -y from project root"
echo "  Working from: $SCRIPT_DIR"
exit 0
