#!/bin/bash

# Test 01: ABSTRACT preserves paragraph structure with blank lines

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"
mkdir -p "$TEST_ROOT/execution/test_v1_01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create CELL.md with multi-paragraph ABSTRACT
cat > "$TEST_ROOT/execution/test_v1_01/CELL.md" << 'EOF'
---
work_complete: true
---

# DISCOVERY
Single line discovery

# ABSTRACT
First paragraph with important context about the work.
This is still part of the first paragraph.

Second paragraph starts here after a blank line.
It continues with more details.

Third paragraph provides final thoughts.
And wraps up the abstract section.

# FULL_RATIONALE
Rationale section starts here.

# FULL_IMPLEMENTATION
Implementation details.

# LOG
- 2025-01-01T00:00:00Z: Created
EOF

cd "$TEST_ROOT/execution/test_v1_01"
output=$("$CELL_ORIENT" --ABSTRACT --self . 2>&1)

# Verify ABSTRACT section appears
if ! echo "$output" | grep -q "<abstract>"; then
    echo "✗ <abstract> section not found"
    echo "  Output: $output"
    exit 1
fi

# Verify first paragraph content is present
if ! echo "$output" | grep -q "First paragraph with important context"; then
    echo "✗ First paragraph not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "This is still part of the first paragraph"; then
    echo "✗ First paragraph continuation not found"
    echo "  Output: $output"
    exit 1
fi

# Verify second paragraph content is present
if ! echo "$output" | grep -q "Second paragraph starts here"; then
    echo "✗ Second paragraph not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "It continues with more details"; then
    echo "✗ Second paragraph continuation not found"
    echo "  Output: $output"
    exit 1
fi

# Verify third paragraph content is present
if ! echo "$output" | grep -q "Third paragraph provides final thoughts"; then
    echo "✗ Third paragraph not found"
    echo "  Output: $output"
    exit 1
fi

if ! echo "$output" | grep -q "And wraps up the abstract section"; then
    echo "✗ Third paragraph continuation not found"
    echo "  Output: $output"
    exit 1
fi

# Verify content from FULL_RATIONALE does NOT appear (extraction should stop at next heading)
if echo "$output" | grep -q "Rationale section starts here"; then
    echo "✗ ABSTRACT extraction should stop at FULL_RATIONALE heading"
    echo "  Output: $output"
    exit 1
fi

# Extract just the abstract section for blank line verification
abstract_section=$(echo "$output" | sed -n '/<abstract>/,/<\/abstract>/p')

# Count non-empty lines in abstract (should have content lines)
content_lines=$(echo "$abstract_section" | grep -v "^[[:space:]]*$" | grep -v "<abstract>" | grep -v "</abstract>" | wc -l | tr -d ' ')

if [ "$content_lines" -lt 6 ]; then
    echo "✗ Expected at least 6 content lines in abstract (got $content_lines)"
    echo "  Abstract section: $abstract_section"
    exit 1
fi

# Verify blank lines exist between paragraphs by checking line count
# The abstract should have: 2 lines (para1) + blank + 2 lines (para2) + blank + 2 lines (para3) = more than 6 lines total
total_lines=$(echo "$abstract_section" | wc -l | tr -d ' ')

if [ "$total_lines" -lt 9 ]; then
    echo "✗ Expected more lines to accommodate blank lines between paragraphs (got $total_lines)"
    echo "  Abstract section: $abstract_section"
    exit 1
fi

cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ ABSTRACT preserves paragraph structure with blank lines"
exit 0
