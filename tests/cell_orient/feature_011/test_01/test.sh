#!/bin/bash

# Test 01: work_complete status indicators (✓ and ✗)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/uptodate_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/outofdate_v1_01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create parent cell
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

# Create cell with work_complete: true
cat > "$TEST_ROOT/execution/parent_v1_01/uptodate_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Cell that is up to date

# ABSTRACT
Abstract.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Create cell with work_complete: false
cat > "$TEST_ROOT/execution/parent_v1_01/outofdate_v1_01/CELL.md" << 'EOF'
---
work_complete: false
---

# DISCOVERY
Cell that is out of date

# ABSTRACT
Abstract.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cd "$TEST_ROOT/execution/parent_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify up-to-date cell shows ✓
if ! echo "$output" | grep -q "uptodate_v1_01/ \[✓\]"; then
    echo "✗ uptodate_v1_01 should show [✓] indicator"
    echo "  Output: $output"
    exit 1
fi

# Verify out-of-date cell shows ✗
if ! echo "$output" | grep -q "outofdate_v1_01/ \[✗\]"; then
    echo "✗ outofdate_v1_01 should show [✗] indicator"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ work_complete indicators display correctly"
exit 0
