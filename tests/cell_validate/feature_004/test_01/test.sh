#!/bin/bash

# Test 01: CELL.md without frontmatter fails validation

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

# Create CELL.md without frontmatter
cat > "$TEST_ROOT/test_v1_01/CELL.md" << 'EOF'
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

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

if ! echo "$output" | grep -q "YAML frontmatter"; then
    echo "✗ Expected frontmatter error not found"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/projectroot.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/test_v1_01" "$TEST_ROOT/projectroot.toml"

echo "✓ CELL.md without frontmatter fails validation"
exit 0
