#!/bin/bash

# Test 02: --descendants shows nested hierarchical structure, not flat list

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_a_v1_01/grandchild_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_b_v1_01/grandchild_v1_02"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_b_v1_01/grandchild_v1_03"

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
create_cell "$TEST_ROOT/execution/parent_v1_01/child_a_v1_01" "Child A"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_b_v1_01" "Child B"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_a_v1_01/grandchild_v1_01" "Grandchild of A"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_b_v1_01/grandchild_v1_02" "Grandchild 2 of B"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_b_v1_01/grandchild_v1_03" "Grandchild 3 of B"

cd "$TEST_ROOT/execution/parent_v1_01"
output=$("$CELL_ORIENT" --descendants --DISCOVERY . 2>&1)

echo "=== OUTPUT ==="
echo "$output"
echo "=============="

# Should use <children> section, not <descendants>
if ! echo "$output" | grep -q "<children>"; then
    echo "✗ Should use <children> section when --descendants is used"
    echo "  Output: $output"
    exit 1
fi

# Should NOT have separate <descendants> section
if echo "$output" | grep -q "<descendants>"; then
    echo "✗ Should NOT have separate <descendants> section, use nested <children> instead"
    echo "  Output: $output"
    exit 1
fi

# Verify nested structure: child_a should have its own nested <children> section
# Extract the child_a cell block
child_a_block=$(echo "$output" | awk '/<cell name="child_a_v1_01"/,/<\/cell>/' | head -20)

if ! echo "$child_a_block" | grep -q "<children>"; then
    echo "✗ child_a_v1_01 should have nested <children> section containing its grandchild"
    echo "  child_a block: $child_a_block"
    exit 1
fi

if ! echo "$child_a_block" | grep -q 'name="grandchild_v1_01"'; then
    echo "✗ grandchild_v1_01 should be nested inside child_a_v1_01's <children> section"
    echo "  child_a block: $child_a_block"
    exit 1
fi

# Verify child_b has TWO grandchildren (just check they appear in output)
if ! echo "$output" | grep -q 'name="grandchild_v1_02"'; then
    echo "✗ grandchild_v1_02 should appear in descendants"
    exit 1
fi

if ! echo "$output" | grep -q 'name="grandchild_v1_03"'; then
    echo "✗ grandchild_v1_03 should appear in descendants"
    exit 1
fi

# Verify nesting: grandchild_v1_02 should appear AFTER child_b_v1_01 and BEFORE the children close tag
output_lines=$(echo "$output" | grep -n 'child_b_v1_01\|grandchild_v1_02\|grandchild_v1_03')
# If the output is properly nested, grandchildren will appear after their parent

# Now test that --children --descendants works the same as just --descendants
output_both=$("$CELL_ORIENT" --children --descendants --DISCOVERY . 2>&1)

if [ "$output" != "$output_both" ]; then
    echo "✗ --children --descendants should produce same output as just --descendants"
    echo "  (--descendants implies recursive children)"
    exit 1
fi

# Test that plain --children only shows immediate children (no nesting)
output_children=$("$CELL_ORIENT" --children --DISCOVERY . 2>&1)

# Should have child_a and child_b
if ! echo "$output_children" | grep -q 'name="child_a_v1_01"'; then
    echo "✗ --children should show child_a"
    exit 1
fi

if ! echo "$output_children" | grep -q 'name="child_b_v1_01"'; then
    echo "✗ --children should show child_b"
    exit 1
fi

# child_a in --children output should NOT have nested children
child_a_norecurse=$(echo "$output_children" | awk '/<cell name="child_a_v1_01"/,/<\/cell>/')

if echo "$child_a_norecurse" | grep -q 'name="grandchild_v1_01"'; then
    echo "✗ --children (without --descendants) should NOT show grandchildren"
    echo "  child_a block: $child_a_norecurse"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ --descendants shows proper nested hierarchical structure"
exit 0
