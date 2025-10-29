#!/bin/bash

# Test 02: DISCOVERY on line 12 (edge case - valid)

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

# Create CELL.md with DISCOVERY on line 12 (valid - within limit)
cat > "$TEST_ROOT/test_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---
Comment line
Comment line
Comment line
Comment line
Comment line
Comment line
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

cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" test_v1_01 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0 (DISCOVERY on line 12 is valid), got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/projectroot.toml"

echo "✓ DISCOVERY on line 12 (edge case) passes validation"
exit 0
