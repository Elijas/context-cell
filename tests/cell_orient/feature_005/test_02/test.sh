#!/bin/bash

# Test 02: DISCOVERY beyond line 12 means cell is invalid

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/invalid_v1_01"

cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Create CELL.md with DISCOVERY on line 15 (beyond the 12-line limit)
cat > "$TEST_ROOT/execution/invalid_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# Some extra comments here
# Comment line
# Comment line
# Comment line
# Comment line
# Comment line
# Comment line

# DISCOVERY
This discovery is on line 15 and should not be found

# ABSTRACT
Abstract content.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Run from the directory
cd "$TEST_ROOT/execution"
output=$("$CELL_ORIENT" . 2>&1)

# Cell should not appear in output (empty result message expected)
if ! echo "$output" | grep -q "No work cells found in current location"; then
    echo "✗ Expected 'No work cells found' message"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ DISCOVERY beyond line 12 causes cell to be ignored"
exit 0
