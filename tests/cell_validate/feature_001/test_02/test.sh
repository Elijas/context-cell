#!/bin/bash

# Test 02: Valid cell with work_complete: false passes validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

# Create test structure
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/valid_v1_02"

# Create projectroot.toml
cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create valid CELL.md with work_complete: false
cat > "$TEST_ROOT/valid_v1_02/CELL.md" << 'EOF'
---
work_complete: false
---

# DISCOVERY
Implement data validation layer.

# ABSTRACT
Data validation using schema definitions.

# FULL_RATIONALE
Schema validation ensures data integrity.

# FULL_IMPLEMENTATION
Implementation using validation library.

# LOG
- 2025-01-01T00:00:00Z: Created test cell
EOF

# Run validation
cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" valid_v1_02 2>&1)
exit_code=$?
set -e

# Verify exit code is 0 (still valid)
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_02" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

# Verify success message
if ! echo "$output" | grep -q "✓ valid_v1_02/ - Valid work cell"; then
    echo "✗ Expected success message not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_02" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/valid_v1_02" "$TEST_ROOT/projectroot.toml"

echo "✓ Valid cell with work_complete: false passes validation"
exit 0
