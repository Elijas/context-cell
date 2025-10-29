#!/bin/bash

# Test 03: Absolute path works

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/valid_v1_01"

cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

cat > "$TEST_ROOT/valid_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Test.

# ABSTRACT
Test.

# FULL_RATIONALE
Test.

# FULL_IMPLEMENTATION
Test.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Use absolute path
absolute_path="$TEST_ROOT/valid_v1_01"
set +e
output=$("$CELL_VALIDATE" "$absolute_path" 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/cellproject.toml"

echo "✓ Absolute path works"
exit 0
