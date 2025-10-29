#!/bin/bash

# Test 01: Uppercase letter in name fails validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

# Create test structure
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/Auth_v1_01"

# Create projectroot.toml
cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create CELL.md (valid format but invalid name)
cat > "$TEST_ROOT/Auth_v1_01/CELL.md" << 'EOF'
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
- 2025-01-01T00:00:00Z: Created test cell
EOF

# Run validation
cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" Auth_v1_01 2>&1)
exit_code=$?
set -e

# Verify exit code is 1
if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Auth_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

# Verify error message contains naming convention error
if ! echo "$output" | grep -q "✗ Auth_v1_01/"; then
    echo "✗ Expected error prefix not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Auth_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

if ! echo "$output" | grep -q "Invalid naming convention"; then
    echo "✗ Expected 'Invalid naming convention' error not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Auth_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/Auth_v1_01" "$TEST_ROOT/projectroot.toml"

echo "✓ Uppercase letter in name fails validation"
exit 0
