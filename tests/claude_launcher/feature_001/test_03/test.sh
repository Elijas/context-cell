#!/bin/bash

# Test 03: No cellproject.toml found (should fail)
# When no cellproject.toml exists, -y flag should exit with error

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
LAUNCHER="$REPO_ROOT/bin/claude_launcher.sh"
MOCK_CLAUDE="$REPO_ROOT/tests/mocks/claude"

# Change to nested directory where no cellproject.toml exists
cd "$SCRIPT_DIR/some/path/here"

# Run the launcher with -y flag - it should fail
if output=$(PATH="$(dirname "$MOCK_CLAUDE"):$PATH" "$LAUNCHER" -y "test prompt" 2>&1); then
    echo "✗ Should have failed when no cellproject.toml exists"
    echo "  Got: $output"
    exit 1
else
    # Check that it failed with the correct error message
    if echo "$output" | grep -q "Could not find cellproject.toml"; then
        echo "✓ Correctly failed when no cellproject.toml found"
        echo "  Error message: $output"
        exit 0
    else
        echo "✗ Failed but with unexpected error message"
        echo "  Got: $output"
        exit 1
    fi
fi
