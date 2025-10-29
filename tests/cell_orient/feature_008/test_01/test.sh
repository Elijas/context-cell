#!/bin/bash

# Test 01: Invalid directory names are ignored

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/auth_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/invalid-name"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/_private"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/.hidden"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/no_version"

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

# Create a parent cell to run from
create_cell "$TEST_ROOT/execution/parent_v1_01" "Parent cell"

# Create valid child cell
create_cell "$TEST_ROOT/execution/parent_v1_01/auth_v1_01" "Valid auth cell"

# Create invalid cells with CELL.md files
create_cell "$TEST_ROOT/execution/parent_v1_01/invalid-name" "Has dash (invalid)"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/_private"
create_cell "$TEST_ROOT/execution/parent_v1_01/_private" "Starts with underscore (ignored)"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/.hidden"
create_cell "$TEST_ROOT/execution/parent_v1_01/.hidden" "Starts with dot (ignored)"
create_cell "$TEST_ROOT/execution/parent_v1_01/no_version" "Missing version pattern (invalid)"

# Run from parent_v1_01
cd "$TEST_ROOT/execution/parent_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify only valid cell appears
if ! echo "$output" | grep -q "auth_v1_01/ \[✓\]"; then
    echo "✗ Valid cell auth_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

# Verify invalid cells do NOT appear
if echo "$output" | grep -q "invalid-name"; then
    echo "✗ invalid-name should not appear (has dash)"
    echo "  Output: $output"
    exit 1
fi

if echo "$output" | grep -q "_private"; then
    echo "✗ _private should not appear (starts with _)"
    echo "  Output: $output"
    exit 1
fi

if echo "$output" | grep -q ".hidden"; then
    echo "✗ .hidden should not appear (starts with .)"
    echo "  Output: $output"
    exit 1
fi

if echo "$output" | grep -q "no_version"; then
    echo "✗ no_version should not appear (missing version pattern)"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Invalid directory names are correctly ignored"
exit 0
