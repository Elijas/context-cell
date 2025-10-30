#!/bin/bash

# Test 01: Validate from parent directory

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
Test discovery.

# ABSTRACT
Test abstract.

# FULL_RATIONALE
Test rationale.

# FULL_IMPLEMENTATION
Test implementation.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

# Run from test directory (parent) with path to child
cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" valid_v1_01 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

if ! echo "$output" | grep -q "✓ valid_v1_01/ - Valid work cell"; then
    echo "✗ Expected success message"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/cellproject.toml"

echo "✓ Validate from parent directory works"
exit 0
