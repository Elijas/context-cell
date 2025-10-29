#!/bin/bash

# Test 03: Absolute path support

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
Auth cell

# ABSTRACT
Abstract.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Run from different directory with absolute path
cd "$REPO_ROOT"
ABS_PATH="$TEST_ROOT/execution/auth_v1_01"
output=$("$CELL_ORIENT" "$ABS_PATH" 2>&1)

# Verify it shows auth_v1_01
if ! echo "$output" | grep -q "auth_v1_01/ \[✓\]"; then
    echo "✗ auth_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ Absolute path argument works correctly"
exit 0
