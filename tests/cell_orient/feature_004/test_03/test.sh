#!/bin/bash

# Test 03: --children flag shows only CHILDREN section

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_02"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
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

create_cell "$TEST_ROOT/execution/parent_v1_01" "Parent"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_v1_01" "Child 1"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_v1_02" "Child 2"

cd "$TEST_ROOT/execution/parent_v1_01"
output=$("$CELL_ORIENT" --children . 2>&1)

# Verify CHILDREN section appears
if ! echo "$output" | grep -q "=== CHILDREN ==="; then
    echo "✗ CHILDREN section not found"
    echo "  Output: $output"
    exit 1
fi

# Verify children are shown
if ! echo "$output" | grep -q "child_v1_01/ \[✓\]"; then
    echo "✗ child_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "child_v1_02/ \[✓\]"; then
    echo "✗ child_v1_02 not found"
    echo "  Output: $output"
    exit 1
fi

# Verify ANCESTRY and PEERS sections do NOT appear
if echo "$output" | grep -q "=== ANCESTRY ==="; then
    echo "✗ ANCESTRY section should not appear"
    echo "  Output: $output"
    exit 1
fi

if echo "$output" | grep -q "=== PEERS ==="; then
    echo "✗ PEERS section should not appear"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ --children flag shows only CHILDREN section"
exit 0
