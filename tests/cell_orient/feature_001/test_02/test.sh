#!/bin/bash

# Test 02: Multiple ancestors and children in deeper hierarchy

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

# Create temporary test hierarchy
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/auth_v1_01/testing_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/auth_v1_01/testing_v1_02"

# Create cellproject.toml
cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Helper function
create_cell() {
    local cell_path="$1"
    local discovery="$2"
    local abstract="$3"
    local work_complete="${4:-true}"

    cat > "$cell_path/CELL.md" << EOF
---
work_complete: $work_complete
---

# DISCOVERY
$discovery

# ABSTRACT
$abstract

# FULL_RATIONALE
Test rationale.

# FULL_IMPLEMENTATION
Test implementation.

# LOG
- 2025-01-01T00:00:00Z: Created test cell
EOF
}

# Create cells
create_cell "$TEST_ROOT/execution/parent_v1_01" \
    "Parent work cell" \
    "Top-level parent work cell."

create_cell "$TEST_ROOT/execution/parent_v1_01/auth_v1_01" \
    "Authentication module" \
    "Handles authentication logic."

create_cell "$TEST_ROOT/execution/parent_v1_01/auth_v1_01/testing_v1_01" \
    "Unit tests" \
    "Unit test suite."

create_cell "$TEST_ROOT/execution/parent_v1_01/auth_v1_01/testing_v1_02" \
    "Integration tests" \
    "Integration test suite."

# Run from auth_v1_01 (has parent ancestor and two children, no peers)
cd "$TEST_ROOT/execution/parent_v1_01/auth_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify ANCESTRY section shows parent_v1_01 and auth_v1_01
if ! echo "$output" | grep -q "=== ANCESTRY ==="; then
    echo "✗ ANCESTRY section not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "parent_v1_01/ \[✓\]"; then
    echo "✗ parent_v1_01 not found in ancestry"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "auth_v1_01/ \[✓\]"; then
    echo "✗ auth_v1_01 not found in ancestry"
    echo "  Output: $output"
    exit 1
fi

# Verify CHILDREN section shows both testing cells
if ! echo "$output" | grep -q "=== CHILDREN ==="; then
    echo "✗ CHILDREN section not found"
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

# Verify PEERS section does NOT appear (no siblings)
if echo "$output" | grep -q "=== PEERS ==="; then
    echo "✗ PEERS section should not appear (no siblings)"
    echo "  Output: $output"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Multiple ancestors and children displayed correctly"
exit 0
