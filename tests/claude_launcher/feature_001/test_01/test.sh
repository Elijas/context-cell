#!/bin/bash

# Test 01: Launch with -y flag from deep nested directory
# The launcher should find cellproject.toml, cd to it, and pass original dir via --add-dir

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
LAUNCHER="$REPO_ROOT/bin/claude_launcher.sh"
MOCK_CLAUDE="$REPO_ROOT/tests/mocks/claude"

# Expected project root is this test directory
EXPECTED_ROOT="$SCRIPT_DIR"
START_DIR="$SCRIPT_DIR/deep/nested/directory/structure"

# Change to deeply nested directory
cd "$START_DIR"

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

# Check that claude was launched from the original directory (not project root)
if ! echo "$output" | grep -q "Current directory: $START_DIR"; then
    echo "✗ Claude not launched from original directory"
    echo "  Expected directory: $START_DIR"
    echo "  Output: $output"
    exit 1
fi

# Check that --add-dir was NOT passed
if echo "$output" | grep -q "\-\-add\-dir"; then
    echo "✗ Should not pass --add-dir flag"
    echo "  Output: $output"
    exit 1
fi

echo "✓ Launched with -y from deeply nested directory"
echo "  Working from: $START_DIR"
echo "  Project root: $EXPECTED_ROOT"
exit 0
