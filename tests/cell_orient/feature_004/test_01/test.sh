#!/bin/bash

# Test 01: --ancestors flag shows only ANCESTRY section

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

# Create test hierarchy
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_01/grandchild_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_02"

cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Helper function
create_cell() {
    local cell_path="$1"
    local discovery="$2"
    cat > "$cell_path/CELL.md" << EOF
---
work_complete: true
---

# DISCOVERY
$discovery

# ABSTRACT
Abstract content.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF
}

create_cell "$TEST_ROOT/execution/parent_v1_01" "Parent cell"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_v1_01" "Child cell"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_v1_02" "Sibling cell"
create_cell "$TEST_ROOT/execution/parent_v1_01/child_v1_01/grandchild_v1_01" "Grandchild cell"

# Run with --ancestors flag from child_v1_01
cd "$TEST_ROOT/execution/parent_v1_01/child_v1_01"
output=$("$CELL_ORIENT" --ancestors . 2>&1)

# Verify ANCESTRY section appears
if ! echo "$output" | grep -q "=== ANCESTRY ==="; then
    echo "✗ ANCESTRY section not found"
    echo "  Output: $output"
    exit 1
fi

# Verify ancestors are shown
if ! echo "$output" | grep -q "parent_v1_01/ \[✓\]"; then
    echo "✗ parent_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "child_v1_01/ \[✓\]"; then
    echo "✗ child_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

# Verify PEERS section does NOT appear
if echo "$output" | grep -q "=== PEERS ==="; then
    echo "✗ PEERS section should not appear with --ancestors flag"
    echo "  Output: $output"
    exit 1
fi

# Verify CHILDREN section does NOT appear
if echo "$output" | grep -q "=== CHILDREN ==="; then
    echo "✗ CHILDREN section should not appear with --ancestors flag"
    echo "  Output: $output"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ --ancestors flag shows only ANCESTRY section"
exit 0
