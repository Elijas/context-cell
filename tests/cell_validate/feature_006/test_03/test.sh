#!/bin/bash

# Test test_03: work_complete: 1 fails validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/test_v1_01"

cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

cat > "$TEST_ROOT/test_v1_01/CELL.md" << 'EOF'
---
work_complete: 1
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

cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" test_v1_01 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ] || ! echo "$output" | grep -q "work_complete"; then
    echo "✗ Expected error containing 'work_complete'"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/cellproject.toml"

echo "✓ work_complete: 1 fails validation"
exit 0
