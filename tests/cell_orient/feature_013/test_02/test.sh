#!/bin/bash

# Test 02: ABSTRACT stops at next heading

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/auth_v1_01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

cat > "$TEST_ROOT/execution/auth_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Auth middleware

# ABSTRACT
This is the abstract content.
It should only include this text.

# FULL_RATIONALE
This is rationale content and should NOT be included in ABSTRACT.

# FULL_IMPLEMENTATION
Implementation content.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cd "$TEST_ROOT/execution/auth_v1_01"
output=$("$CELL_ORIENT" --ABSTRACT . 2>&1)

# Verify ABSTRACT content appears
if ! echo "$output" | grep -q "This is the abstract content"; then
    echo "✗ ABSTRACT content not found"
    echo "  Output: $output"
    exit 1
fi

# Verify FULL_RATIONALE content does NOT appear
if echo "$output" | grep -q "This is rationale content and should NOT be included"; then
    echo "✗ FULL_RATIONALE content should not appear in ABSTRACT"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ ABSTRACT extraction stops at next heading"
exit 0
