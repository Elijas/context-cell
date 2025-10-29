#!/bin/bash

# Test 01: Ancestry stops at execution boundary

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/above_execution"
mkdir -p "$TEST_ROOT/above_execution/execution/parent_v1_01/child_v1_01"

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

# Create directory above execution with non-work-cell name (no version pattern)
# This tests that ancestry stops at execution boundary even when there are
# directories above it (they just won't be valid work cells)
create_cell "$TEST_ROOT/above_execution/execution/parent_v1_01" "Parent cell"
create_cell "$TEST_ROOT/above_execution/execution/parent_v1_01/child_v1_01" "Child cell"

# Run from child_v1_01
cd "$TEST_ROOT/above_execution/execution/parent_v1_01/child_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify ANCESTRY shows parent_v1_01 and child_v1_01
if ! echo "$output" | grep -q "parent_v1_01/ \[✓\]"; then
    echo "✗ parent_v1_01 not found in ancestry"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "child_v1_01/ \[✓\]"; then
    echo "✗ child_v1_01 not found in ancestry"
    echo "  Output: $output"
    exit 1
fi

# Verify execution boundary is respected (only 2 cells in ancestry)
cell_count=$(echo "$output" | grep -c "/ \[✓\]" || true)
if [ "$cell_count" -ne 2 ]; then
    echo "✗ Expected exactly 2 cells in ancestry, got $cell_count"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/above_execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Ancestry correctly stops at execution boundary"
exit 0
