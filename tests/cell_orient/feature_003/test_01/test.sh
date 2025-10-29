#!/bin/bash

# Test 01: Combining --DISCOVERY and --ABSTRACT flags

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

# Create test hierarchy
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/auth_v1_01"

# Create projectroot.toml
cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create cell
cat > "$TEST_ROOT/execution/auth_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Implement JWT authentication middleware

# ABSTRACT
This cell provides authentication using JSON Web Tokens for secure API access.
It handles token generation, validation, and refresh logic.

# FULL_RATIONALE
Test rationale.

# FULL_IMPLEMENTATION
Test implementation.

# LOG
- 2025-01-01T00:00:00Z: Created test cell
EOF

# Run with both flags
cd "$TEST_ROOT/execution/auth_v1_01"
output=$("$CELL_ORIENT" --DISCOVERY --ABSTRACT . 2>&1)

# Verify both sections appear with proper labels
if ! echo "$output" | grep -q "DISCOVERY: Implement JWT authentication middleware"; then
    echo "✗ DISCOVERY with label not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "ABSTRACT:"; then
    echo "✗ ABSTRACT label not found"
    echo "  Output: $output"
    exit 1
fi

# Verify ABSTRACT content appears
if ! echo "$output" | grep -q "This cell provides authentication using JSON Web Tokens"; then
    echo "✗ ABSTRACT content not found"
    echo "  Output: $output"
    exit 1
fi

# Verify proper indentation structure
# DISCOVERY should be: "  DISCOVERY: {content}"
# ABSTRACT should be: "  ABSTRACT:" then "    {content}"
if ! echo "$output" | grep -q "^  DISCOVERY:"; then
    echo "✗ DISCOVERY not properly indented"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "^  ABSTRACT:"; then
    echo "✗ ABSTRACT label not properly indented"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "^    This cell provides authentication"; then
    echo "✗ ABSTRACT content not indented with 4 spaces"
    echo "  Output: $output"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ Combined --DISCOVERY --ABSTRACT flags work correctly"
exit 0
