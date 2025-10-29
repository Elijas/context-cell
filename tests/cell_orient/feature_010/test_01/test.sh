#!/bin/bash

# Test 01: Orient from different directory using path argument

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/auth_v1_01/testing_v1_01"
mkdir -p "$TEST_ROOT/execution/auth_v1_01/testing_v1_02"

cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

create_cell() {
    cat > "$1/CELL.md" << EOF
---
work_complete: true
---

# DISCOVERY
$2

# ABSTRACT
Abstract.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF
}

create_cell "$TEST_ROOT/execution/auth_v1_01" "Auth cell"
create_cell "$TEST_ROOT/execution/auth_v1_01/testing_v1_01" "Testing 1"
create_cell "$TEST_ROOT/execution/auth_v1_01/testing_v1_02" "Testing 2"

# Run from execution directory but orient from auth_v1_01
cd "$TEST_ROOT/execution"
output=$("$CELL_ORIENT" auth_v1_01 2>&1)

# Verify it shows auth_v1_01's vantage (children, not peers)
if ! echo "$output" | grep -q "=== CHILDREN ==="; then
    echo "✗ CHILDREN section not found (should show auth_v1_01's children)"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "testing_v1_01/ \[✓\]"; then
    echo "✗ testing_v1_01 not found in children"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "testing_v1_02/ \[✓\]"; then
    echo "✗ testing_v1_02 not found in children"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Path argument correctly orients from different directory"
exit 0
