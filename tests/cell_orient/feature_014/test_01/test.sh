#!/bin/bash

# Test 01: Proper indentation for cell content

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

cat > "$TEST_ROOT/execution/auth_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Auth middleware implementation

# ABSTRACT
Abstract content.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cd "$TEST_ROOT/execution/auth_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify cell name with trailing slash
if ! echo "$output" | grep -q "^auth_v1_01/ \[✓\]"; then
    echo "✗ Cell name not formatted correctly (should be 'auth_v1_01/ [✓]')"
    echo "  Output: $output"
    exit 1
fi

# Verify DISCOVERY content is indented by 2 spaces
if ! echo "$output" | grep -q "^  Auth middleware implementation"; then
    echo "✗ DISCOVERY content not indented by 2 spaces"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Cell content properly indented"
exit 0
