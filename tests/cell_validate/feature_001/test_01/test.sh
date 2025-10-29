#!/bin/bash

# Test 01: Minimal valid work cell passes validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

# Create test structure
TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/valid_v1_01"

# Create cellproject.toml
cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Create valid CELL.md
cat > "$TEST_ROOT/valid_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Implement user authentication middleware for API endpoints.

# ABSTRACT
This cell provides authentication functionality using JWT tokens.

# FULL_RATIONALE
JWT provides stateless authentication suitable for RESTful APIs.

# FULL_IMPLEMENTATION
Implementation includes token generation, validation, and middleware.

# LOG
- 2025-01-01T00:00:00Z: Created test cell
EOF

# Run validation
cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" valid_v1_01 2>&1)
exit_code=$?
set -e

# Verify exit code is 0
if [ $exit_code -ne 0 ]; then
    echo "✗ Expected exit code 0, got $exit_code"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

# Verify success message
if ! echo "$output" | grep -q "✓ valid_v1_01/ - Valid work cell"; then
    echo "✗ Expected success message not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/valid_v1_01" "$TEST_ROOT/cellproject.toml"

echo "✓ Minimal valid work cell passes validation"
exit 0
