#!/bin/bash

# Test 01: Invalid name + missing section reports multiple errors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/Invalid-Name"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create CELL.md without LOG section
cat > "$TEST_ROOT/Invalid-Name/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Test discovery.

# ABSTRACT
Test abstract.

# FULL_RATIONALE
Test rationale.

# FULL_IMPLEMENTATION
Test implementation.
EOF

cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" Invalid-Name 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Invalid-Name" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

# Check for both errors
if ! echo "$output" | grep -q "Invalid naming convention"; then
    echo "✗ Expected naming error not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Invalid-Name" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

if ! echo "$output" | grep -q "Missing required section"; then
    echo "✗ Expected missing section error not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Invalid-Name" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/Invalid-Name" "$TEST_ROOT/projectroot.toml"

echo "✓ Multiple errors reported correctly"
exit 0
