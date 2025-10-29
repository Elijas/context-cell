#!/bin/bash

# Test 02: Relative path support

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/auth_v1_01/testing_v1_01"

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

create_cell "$TEST_ROOT/execution/auth_v1_01" "Auth cell"
create_cell "$TEST_ROOT/execution/auth_v1_01/testing_v1_01" "Testing cell"

# Run from testing_v1_01 with relative path to auth_v1_01
cd "$TEST_ROOT/execution/auth_v1_01/testing_v1_01"
output=$("$CELL_ORIENT" .. 2>&1)

# Should show auth_v1_01's perspective (with testing_v1_01 as child)
if ! echo "$output" | grep -q "testing_v1_01/ \[✓\]"; then
    echo "✗ testing_v1_01 not found (should be shown as child of auth_v1_01)"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Relative path argument works correctly"
exit 0
