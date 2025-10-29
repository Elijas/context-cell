#!/bin/bash

# Test 02: Section headers formatted correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_02"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/child_v1_01/grandchild_v1_01"

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
create_cell "$TEST_ROOT/execution/parent_v1_01/child_v1_01/grandchild_v1_01" "Grandchild"

cd "$TEST_ROOT/execution/parent_v1_01/child_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify section headers
if ! echo "$output" | grep -q "^=== ANCESTRY ===$"; then
    echo "✗ ANCESTRY header not formatted correctly"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "^=== PEERS ===$"; then
    echo "✗ PEERS header not formatted correctly"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "^=== CHILDREN ===$"; then
    echo "✗ CHILDREN header not formatted correctly"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ Section headers formatted correctly"
exit 0
