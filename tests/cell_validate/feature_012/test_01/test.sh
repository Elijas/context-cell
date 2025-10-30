#!/bin/bash

# Test 01: Validate @project from nested directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/root_v1_01/nested/child_v1_01"

cat > "$TEST_ROOT/root_v1_01/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

cat > "$TEST_ROOT/root_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Root cell discovery.

# ABSTRACT
Root cell abstract.

# FULL_RATIONALE
Root cell rationale.

# FULL_IMPLEMENTATION
Root cell implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cat > "$TEST_ROOT/root_v1_01/nested/child_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Child cell.

# ABSTRACT
Child abstract.

# FULL_RATIONALE
Child rationale.

# FULL_IMPLEMENTATION
Child implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Run from nested directory with @project
cd "$TEST_ROOT/root_v1_01/nested/child_v1_01"
set +e
output=$("$CELL_VALIDATE" @project 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/root_v1_01"
    exit 1
fi

if ! echo "$output" | grep -q "✓ root_v1_01/ - Valid work cell"; then
    echo "✗ Expected to validate root_v1_01"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/root_v1_01"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/root_v1_01"

echo "✓ Validate @project from nested directory works"
exit 0
