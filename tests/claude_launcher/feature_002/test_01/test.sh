#!/bin/bash

# Test 01: Help flag
# Verify that --help displays help message and exits

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
LAUNCHER="$REPO_ROOT/bin/claude_launcher.sh"

# Test --help flag
if output=$("$LAUNCHER" --help 2>&1); then
    if echo "$output" | grep -q "Usage: claude_launcher.sh"; then
        echo "✓ --help displays usage information"
        exit 0
    else
        echo "✗ --help output does not contain usage information"
        echo "  Got: $output"
        exit 1
    fi
else
    echo "✗ --help exited with error code $?"
    exit 1
fi
