#!/bin/bash

# Test 02: Many errors at once

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_VALIDATE="$REPO_ROOT/bin/_cell_validate.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/Bad-Name"

cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Create CELL.md with: no frontmatter, missing sections, out of order
cat > "$TEST_ROOT/Bad-Name/CELL.md" << 'EOF'
# ABSTRACT
Test abstract.

# DISCOVERY
Test discovery.
EOF

cd "$TEST_ROOT"
set +e
output=$("$CELL_VALIDATE" Bad-Name 2>&1)
exit_code=$?
set -e

if [ $exit_code -ne 1 ]; then
    echo "✗ Expected exit code 1, got $exit_code"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Bad-Name" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

# Should have multiple errors - check we got at least 2
error_count=$(echo "$output" | grep -c "✗" || true)
if [ "$error_count" -lt 2 ]; then
    echo "✗ Expected multiple errors, got $error_count"
    echo "  Output: $output"
    cd "$REPO_ROOT"
    rm -rf "$TEST_ROOT/Bad-Name" "$TEST_ROOT/cellproject.toml"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/Bad-Name" "$TEST_ROOT/cellproject.toml"

echo "✓ Many errors reported correctly"
exit 0
