#!/bin/bash

# Test 02: Dash in name fails validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/auth-v1-01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

cat > "$TEST_ROOT/auth-v1-01/CELL.md" << 'EOF'
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

cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" auth-v1-01 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/auth-v1-01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

if ! echo "$output" | grep -q "Invalid naming convention"; then
    echo "✗ Expected naming error not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/auth-v1-01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/auth-v1-01" "$TEST_ROOT/projectroot.toml"

echo "✓ Dash in name fails validation"
exit 0
