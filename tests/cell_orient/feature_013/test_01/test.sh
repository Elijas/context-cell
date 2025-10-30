#!/bin/bash

# Test 01: ABSTRACT with multiple paragraphs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/auth_v1_01"

cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Create cell with multi-paragraph ABSTRACT
cat > "$TEST_ROOT/execution/auth_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Auth middleware

# ABSTRACT
First paragraph of the abstract describes the authentication system.

Second paragraph provides implementation details and design decisions.

Third paragraph explains integration points and usage.

# FULL_RATIONALE
Rationale content.

# FULL_IMPLEMENTATION
Implementation content.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cd "$TEST_ROOT/execution/auth_v1_01"
output=$("$CELL_ORIENT" --ABSTRACT . 2>&1)

# Verify all paragraphs appear
if ! echo "$output" | grep -q "First paragraph of the abstract"; then
    echo "✗ First paragraph not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "Second paragraph provides implementation details"; then
    echo "✗ Second paragraph not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "Third paragraph explains integration points"; then
    echo "✗ Third paragraph not found"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Multi-paragraph ABSTRACT extracted correctly"
exit 0
