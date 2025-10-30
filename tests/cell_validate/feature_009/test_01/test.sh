#!/bin/bash

# Test 01: DISCOVERY on line 13 fails validation

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

# Create CELL.md with DISCOVERY on line 13
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

if [ $exit_code -ne 1 ] || ! echo "$output" | grep -q "DISCOVERY section must appear within first 12 lines"; then
    echo "✗ Expected DISCOVERY position error"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/cellproject.toml"

echo "✓ DISCOVERY on line 13 fails validation"
exit 0
