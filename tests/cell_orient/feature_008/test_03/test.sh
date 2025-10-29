#!/bin/bash

# Test 03: Malformed CELL.md (missing frontmatter) causes cell to be ignored

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/auth_v1_01"
mkdir -p "$TEST_ROOT/execution/parent_v1_01/malformed_v1_01"

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

# Create valid cell
cat > "$TEST_ROOT/execution/parent_v1_01/auth_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Valid cell

# ABSTRACT
Abstract.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Create malformed cell (no YAML frontmatter with work_complete)
cat > "$TEST_ROOT/execution/parent_v1_01/malformed_v1_01/CELL.md" << 'EOF'
# DISCOVERY
Malformed cell without frontmatter

# ABSTRACT
This cell has no YAML frontmatter with work_complete field.

# FULL_RATIONALE
Rationale.

# FULL_IMPLEMENTATION
Implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cd "$TEST_ROOT/execution/parent_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Verify valid cell appears
if ! echo "$output" | grep -q "auth_v1_01/ \[✓\]"; then
    echo "✗ auth_v1_01 not found"
    echo "  Output: $output"
    exit 1
fi

# Verify malformed cell does NOT appear
if echo "$output" | grep -q "malformed_v1_01"; then
    echo "✗ malformed_v1_01 should not appear (missing frontmatter)"
    echo "  Output: $output"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ Malformed CELL.md files are correctly ignored"
exit 0
