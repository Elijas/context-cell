#!/bin/bash

# Test 01: --ABSTRACT flag shows full abstract sections

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

# Create test hierarchy
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/auth_v1_01/testing_v1_01"

# Create projectroot.toml
cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
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

# Create cells with multi-line abstracts
create_cell "$TEST_ROOT/execution/auth_v1_01" \
    "Implement JWT authentication middleware" \
    "This cell provides authentication using JSON Web Tokens for secure API access. It handles token generation, validation, and refresh logic. The implementation follows industry best practices for security."

create_cell "$TEST_ROOT/execution/auth_v1_01/testing_v1_01" \
    "Unit tests for auth middleware" \
    "Comprehensive test suite covering all authentication scenarios including token expiration, invalid tokens, and edge cases."

# Run with --ABSTRACT flag
cd "$TEST_ROOT/execution/auth_v1_01/testing_v1_01"
output=$("$CELL_ORIENT" --ABSTRACT . 2>&1)

# Verify ABSTRACT content appears for auth_v1_01
if ! echo "$output" | grep -q "This cell provides authentication using JSON Web Tokens"; then
    echo "✗ ABSTRACT content not found for auth_v1_01"
    echo "  Output: $output"
    exit 1
fi

# Verify multi-line ABSTRACT is shown
if ! echo "$output" | grep -q "industry best practices for security"; then
    echo "✗ Full ABSTRACT content not displayed"
    echo "  Output: $output"
    exit 1
fi

# Verify DISCOVERY is NOT shown (only ABSTRACT requested)
if echo "$output" | grep -q "DISCOVERY:"; then
    echo "✗ DISCOVERY should not appear when only --ABSTRACT flag used"
    echo "  Output: $output"
    exit 1
fi

# Verify content is indented (should have leading spaces)
if ! echo "$output" | grep -q "  This cell provides authentication"; then
    echo "✗ ABSTRACT content not properly indented"
    echo "  Output: $output"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ --ABSTRACT flag shows full abstract sections correctly"
exit 0
