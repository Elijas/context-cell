#!/bin/bash

# Test 03: Valid cell with complex name passes validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

# Create test structure
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/user_api_auth_v10_99"

# Create projectroot.toml
cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create valid CELL.md
cat > "$TEST_ROOT/user_api_auth_v10_99/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Complex authentication system.

# ABSTRACT
Multi-layered authentication approach.

# FULL_RATIONALE
Complex systems require comprehensive auth.

# FULL_IMPLEMENTATION
Implementation details here.

# LOG
- 2025-01-01T00:00:00Z: Created test cell
EOF

# Run validation
cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" user_api_auth_v10_99 2>&1)
exit_code=$?
set -e

# Verify exit code is 0
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/user_api_auth_v10_99" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

# Verify success message
if ! echo "$output" | grep -q "✓ user_api_auth_v10_99/ - Valid work cell"; then
    echo "✗ Expected success message not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/user_api_auth_v10_99" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/user_api_auth_v10_99" "$TEST_ROOT/projectroot.toml"

echo "✓ Valid cell with complex name passes validation"
exit 0
