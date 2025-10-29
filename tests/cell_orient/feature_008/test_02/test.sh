#!/bin/bash

# Test 02: Missing CELL.md causes directory to be ignored

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/auth_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/nocell_v1_01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create parent cell to run from
mkdir -p "$TEST_ROOT/execution/parent_v1_01"
cat > "$TEST_ROOT/execution/parent_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Parent cell

# ABSTRACT
Abstract.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Create valid cell with CELL.md
cat > "$TEST_ROOT/execution/parent_v1_01/auth_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Valid cell with CELL.md

# ABSTRACT
Abstract.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# nocell_v1_01 has valid name but NO CELL.md file (already created as directory)

cd "$TEST_ROOT/execution/parent_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify valid cell appears
if ! echo "$output" | grep -q "auth_v1_01/ \[✓\]"; then
    echo "✗ auth_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

# Verify nocell_v1_01 does NOT appear
if echo "$output" | grep -q "nocell_v1_01"; then
    echo "✗ nocell_v1_01 should not appear (missing CELL.md)"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ Directories without CELL.md are correctly ignored"
exit 0
