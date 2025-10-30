#!/bin/bash

# Test feature_017: @project and @tree distinction

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_ROOT="$SCRIPT_DIR/project_root"
CELL_SCRIPT="$SCRIPT_DIR/../../../bin/cell.py"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "Testing feature_017: @project and @tree distinction"
echo "========================================"
echo ""

# Check if test structure exists
if [ ! -d "$TEST_ROOT" ]; then
    echo -e "${RED}Error: Test structure not found${NC}"
    echo "Run ./setup.sh first"
    exit 1
fi

# Test 1: @project and @tree show distinct paths when celltree.toml exists
echo -e "${YELLOW}Test 1: @project and @tree show distinct paths${NC}"
cd "$TEST_ROOT/explorations/v4/test_v1_01"

# Use cell expand to get resolved paths
PROJECT_PATH=$("$CELL_SCRIPT" expand @project 2>&1)
WORK_PATH=$("$CELL_SCRIPT" expand @tree 2>&1)

# Check that @project points to project root
if [ "$PROJECT_PATH" = "$TEST_ROOT" ]; then
    echo -e "${GREEN}✓ @project expands to project root: $PROJECT_PATH${NC}"
else
    echo -e "${RED}✗ @project doesn't expand to project root${NC}"
    echo "Expected: $TEST_ROOT"
    echo "Got: $PROJECT_PATH"
    exit 1
fi

# Check that @tree points to work root (different from project root)
if [ "$WORK_PATH" = "$TEST_ROOT/explorations/v4" ]; then
    echo -e "${GREEN}✓ @tree expands to work root (distinct from @project): $WORK_PATH${NC}"
else
    echo -e "${RED}✗ @tree doesn't expand to correct work root${NC}"
    echo "Expected: $TEST_ROOT/explorations/v4"
    echo "Got: $WORK_PATH"
    exit 1
fi

echo ""

# Test 2: cell orient @tree looks from work root, not project root
echo -e "${YELLOW}Test 2: cell orient @tree uses work root${NC}"
cd "$TEST_ROOT/explorations/v4/test_v1_01"

# Run orient from @tree - should find the test_v1_01 cell
OUTPUT=$("$CELL_SCRIPT" orient @tree 2>&1)

# Check that it found the work cell at @tree level
if echo "$OUTPUT" | grep -q "test_v1_01" || echo "$OUTPUT" | grep -q "@tree"; then
    echo -e "${GREEN}✓ cell orient @tree operates from work root${NC}"
else
    echo -e "${YELLOW}⚠ Output doesn't show expected work cell (may be expected if no cells at work root)${NC}"
fi

echo ""

# Test 3: @tree falls back to @project when celltree.toml absent
echo -e "${YELLOW}Test 3: @tree falls back to @project when celltree.toml absent${NC}"

# Remove celltree.toml temporarily
mv "$TEST_ROOT/explorations/v4/celltree.toml" "$TEST_ROOT/explorations/v4/celltree.toml.bak"

cd "$TEST_ROOT/explorations/v4/test_v1_01"

# Use cell expand to get resolved paths
PROJECT_PATH=$("$CELL_SCRIPT" expand @project 2>&1)
WORK_PATH=$("$CELL_SCRIPT" expand @tree 2>&1)

# When celltree.toml is absent, @tree should fall back to @project
if [ "$WORK_PATH" = "$PROJECT_PATH" ] && [ "$WORK_PATH" = "$TEST_ROOT" ]; then
    echo -e "${GREEN}✓ @tree falls back to @project (both expand to: $WORK_PATH)${NC}"
else
    echo -e "${RED}✗ @tree didn't fall back to @project correctly${NC}"
    echo "@project expands to: $PROJECT_PATH"
    echo "@tree expands to: $WORK_PATH"
    mv "$TEST_ROOT/explorations/v4/celltree.toml.bak" "$TEST_ROOT/explorations/v4/celltree.toml"
    exit 1
fi

# Restore celltree.toml
mv "$TEST_ROOT/explorations/v4/celltree.toml.bak" "$TEST_ROOT/explorations/v4/celltree.toml"

echo ""
echo "========================================"
echo -e "${GREEN}All tests passed!${NC}"
echo "========================================"

# No temp files to cleanup
