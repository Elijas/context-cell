#!/bin/bash

# Test 02: Invalid root directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/Invalid-Root"

cat > "$TEST_ROOT/Invalid-Root/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

cat > "$TEST_ROOT/Invalid-Root/CELL.md" << 'EOF'
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

cd "$TEST_ROOT/Invalid-Root"
set +e
output=$("$CELL_VALIDATE" @project 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Invalid-Root"
    exit 1
fi

if ! echo "$output" | grep -q "Invalid naming convention"; then
    echo "✗ Expected naming error"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Invalid-Root"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/Invalid-Root"

echo "✓ Invalid root directory validation fails correctly"
exit 0
