#!/bin/bash

# Test 01: DISCOVERY reads only first 12 lines (optimization test)

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

# Create CELL.md with DISCOVERY within first 12 lines, followed by 100+ lines
cat > "$TEST_ROOT/execution/auth_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Implement JWT authentication middleware

# ABSTRACT
This is a long abstract that contains many lines.
Line 2 of abstract.
Line 3 of abstract.
Line 4 of abstract.

# FULL_RATIONALE
This is line 13 and should not be read when only DISCOVERY is requested.
Line 14.
Line 15.
Line 16.
Line 17.
Line 18.
Line 19.
Line 20.
Line 21.
Line 22.
Line 23.
Line 24.
Line 25.
Line 26.
Line 27.
Line 28.
Line 29.
Line 30.

# FULL_IMPLEMENTATION
Implementation content that is far beyond the first 12 lines.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Run with default (DISCOVERY only)
cd "$TEST_ROOT/execution/auth_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify it works correctly
if ! echo "$output" | grep -q "Implement JWT authentication middleware"; then
    echo "✗ DISCOVERY content not found"
    echo "  Output: $output"
    exit 1
fi

# Verify it doesn't include content from beyond line 12
if echo "$output" | grep -q "line 13 and should not be read"; then
    echo "✗ Content beyond first 12 lines appeared (optimization not working)"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/cellproject.toml"

echo "✓ DISCOVERY optimization works (reads only first 12 lines)"
exit 0
