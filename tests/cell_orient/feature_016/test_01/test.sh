#!/bin/bash

# Test 01: --descendants flag shows all descendants recursively

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_01/grandchild_v1_01/greatgrand_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_02"

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
Abstract for $2.

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
create_cell "$TEST_ROOT/execution/parent_v1_01/child_v1_01/grandchild_v1_01" "Grandchild"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_v1_01/grandchild_v1_01/greatgrand_v1_01" "Great-grandchild"

cd "$TEST_ROOT/execution/parent_v1_01"
output=$("$CELL_ORIENT" --descendants --DISCOVERY . 2>&1)

# Verify children section appears (descendants uses nested children, not separate section)
if ! echo "$output" | grep -q "<children>"; then
    echo "✗ <children> section not found"
    echo "  Output: $output"
    exit 1
fi

# Verify all levels are shown (not just immediate children)
if ! echo "$output" | grep -q 'name="child_v1_01"'; then
    echo "✗ child_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q 'name="child_v1_02"'; then
    echo "✗ child_v1_02 not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q 'name="grandchild_v1_01"'; then
    echo "✗ grandchild_v1_01 not found (descendants should include grandchildren)"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q 'name="greatgrand_v1_01"'; then
    echo "✗ greatgrand_v1_01 not found (descendants should include great-grandchildren)"
    echo "  Output: $output"
    exit 1
fi

# Verify nested structure: extract child_v1_01 block and verify it contains grandchild
child_block=$(echo "$output" | awk '/<cell name="child_v1_01"/,/^    <\/cell>/')
if ! echo "$child_block" | grep -q 'name="grandchild_v1_01"'; then
    echo "✗ grandchild_v1_01 should be nested inside child_v1_01"
    echo "  child block: $child_block"
    exit 1
fi

# Now test with --children to verify it only shows immediate children (no nesting)
output_children=$("$CELL_ORIENT" --children --DISCOVERY . 2>&1)

if ! echo "$output_children" | grep -q "<children>"; then
    echo "✗ <children> section not found"
    echo "  Output: $output_children"
    exit 1
fi

if ! echo "$output_children" | grep -q 'name="child_v1_01"'; then
    echo "✗ child_v1_01 not found in --children output"
    echo "  Output: $output_children"
    exit 1
fi

if ! echo "$output_children" | grep -q 'name="child_v1_02"'; then
    echo "✗ child_v1_02 not found in --children output"
    echo "  Output: $output_children"
    exit 1
fi

# Verify --children does NOT show grandchildren (no recursion)
if echo "$output_children" | grep -q 'name="grandchild_v1_01"'; then
    echo "✗ grandchild_v1_01 should NOT appear in --children output (no recursion)"
    echo "  Output: $output_children"
    exit 1
fi

if echo "$output_children" | grep -q 'name="greatgrand_v1_01"'; then
    echo "✗ greatgrand_v1_01 should NOT appear in --children output (no recursion)"
    echo "  Output: $output_children"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ --descendants flag shows all descendants recursively"
exit 0
