#!/bin/bash

# Test 01: Default shows DISCOVERY vantage view with all three sections

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

# Create temporary test hierarchy
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/auth_v1_01/testing_v1_01"
mkdir -p "$TEST_ROOT/execution/auth_v1_01/testing_v1_02"

# Create cellproject.toml at test root
cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Helper function to create a work cell with CELL.md
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
Test rationale content.

# FULL_IMPLEMENTATION
Test implementation content.

# LOG
- 2025-01-01T00:00:00Z: Created test cell
EOF
}

# Create cells
create_cell "$TEST_ROOT/execution/auth_v1_01" \
    "Implement JWT authentication middleware" \
    "This cell provides authentication using JSON Web Tokens for secure API access."

create_cell "$TEST_ROOT/execution/auth_v1_01/testing_v1_01" \
    "Unit tests for auth middleware" \
    "Comprehensive test suite covering all authentication scenarios."

create_cell "$TEST_ROOT/execution/auth_v1_01/testing_v1_02" \
    "Integration tests for auth flow" \
    "End-to-end testing of authentication flow."

# Run from testing_v1_01 (has ancestor and peer, no children)
cd "$TEST_ROOT/execution/auth_v1_01/testing_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify ANCESTRY section appears
if ! echo "$output" | grep -q "=== ANCESTRY ==="; then
    echo "✗ ANCESTRY section not found"
    echo "  Output: $output"
    exit 1
fi

# Verify auth_v1_01 appears in ancestry
if ! echo "$output" | grep -q "auth_v1_01/ \[✓\]"; then
    echo "✗ auth_v1_01 not found in ancestry"
    echo "  Output: $output"
    exit 1
fi

# Verify DISCOVERY content for auth_v1_01
if ! echo "$output" | grep -q "Implement JWT authentication middleware"; then
    echo "✗ DISCOVERY content for auth_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

# Verify PEERS section appears
if ! echo "$output" | grep -q "=== PEERS ==="; then
    echo "✗ PEERS section not found"
    echo "  Output: $output"
    exit 1
fi

# Verify testing_v1_02 appears as peer
if ! echo "$output" | grep -q "testing_v1_02/ \[✓\]"; then
    echo "✗ testing_v1_02 not found in peers"
    echo "  Output: $output"
    exit 1
fi

# Verify CHILDREN section does NOT appear (no children exist)
if echo "$output" | grep -q "=== CHILDREN ==="; then
    echo "✗ CHILDREN section should not appear (no children exist)"
    echo "  Output: $output"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Default DISCOVERY vantage view shows correct sections"
exit 0
