#!/bin/bash

# Setup test structure for feature_017

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_ROOT="$SCRIPT_DIR/project_root"

echo "Setting up test structure in $TEST_ROOT..."

# Clean any existing test structure
rm -rf "$TEST_ROOT"

# Create project root
mkdir -p "$TEST_ROOT"

# Create cellproject.toml marker
touch "$TEST_ROOT/cellproject.toml"

# Create project src directory (to make it clear this is project codebase)
mkdir -p "$TEST_ROOT/src"

# Create explorations/v4 structure
mkdir -p "$TEST_ROOT/explorations/v4"

# Create celltree.toml marker
touch "$TEST_ROOT/explorations/v4/celltree.toml"

# Create test work cell
mkdir -p "$TEST_ROOT/explorations/v4/test_v1_01"

# Create CELL.md
cat > "$TEST_ROOT/explorations/v4/test_v1_01/CELL.md" << 'EOF'
---
work_complete: false
---

# DISCOVERY

Test work cell for @project auto-correction

# ABSTRACT

This is a test work cell used to verify that `cell orient @project` auto-corrects
to `@tree` with a warning when celltree.toml exists. The work cell is located
deep in the project structure at explorations/v4/test_v1_01/.

# FULL_RATIONALE

Created to test feature_017: @project auto-correction to @tree behavior.

# FULL_IMPLEMENTATION

Minimal test work cell with required CELL.md sections.

# LOG

- 2025-01-29T00:00:00Z: Created test work cell
EOF

echo "Test structure created successfully!"
echo ""
echo "Structure:"
echo "  $TEST_ROOT/"
echo "  ├── cellproject.toml"
echo "  ├── src/"
echo "  └── explorations/"
echo "      └── v4/"
echo "          ├── celltree.toml"
echo "          └── test_v1_01/"
echo "              └── CELL.md"
echo ""
echo "Run ./test.sh to execute tests"
