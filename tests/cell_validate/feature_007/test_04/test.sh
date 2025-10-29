#!/bin/bash

# Test test_04: Missing LOG fails validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/test_v1_01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

cat > "$TEST_ROOT/test_v1_01/CELL.md" << 'EOF'
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
EOF

cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" test_v1_01 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ] || ! echo "$output" | grep -q "Missing required section"; then
    echo "✗ Expected error containing 'Missing required section'"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/projectroot.toml"

echo "✓ Missing LOG fails validation"
exit 0
