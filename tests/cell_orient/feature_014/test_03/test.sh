#!/bin/bash

# Test 03: Empty sections are omitted

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/only_child_v1_01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

cat > "$TEST_ROOT/execution/only_child_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Only child with no peers

# ABSTRACT
Abstract.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cd "$TEST_ROOT/execution/only_child_v1_01"
output=$("$CELL_ORIENT" --peers . 2>&1)

# Should show "No work cells found" since --peers requested but no peers exist
if ! echo "$output" | grep -q "No work cells found in current location"; then
    echo "✗ Expected 'No work cells found' message when filtering shows empty result"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ Empty sections properly omitted"
exit 0
