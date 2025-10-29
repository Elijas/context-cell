#!/bin/bash

# Unified Test Runner
# Discovers and runs all test.sh scripts in the tests directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

passed=0
failed=0
total=0

# Find all test.sh files recursively
test_files=$(find "$SCRIPT_DIR" -type f -name "test.sh" | sort)

if [ -z "$test_files" ]; then
    echo -e "${YELLOW}No test.sh files found${NC}"
    exit 0
fi

echo "========================================"
echo "Context Cell Test Runner"
echo "========================================"
echo ""

# Run each test
while IFS= read -r test_file; do
    ((total++))

    # Get relative path for display
    rel_path="${test_file#$SCRIPT_DIR/}"
    test_dir="$(dirname "$test_file")"

    echo -e "${BLUE}Running:${NC} $rel_path"
    echo "----------------------------------------"

    # Run the test and capture output
    if output=$("$test_file" 2>&1); then
        echo "$output"
        ((passed++))
        echo ""
    else
        echo "$output"
        ((failed++))
        echo ""
    fi
done <<< "$test_files"

# Print summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo -e "${GREEN}Passed${NC}: $passed"
echo -e "${RED}Failed${NC}: $failed"
echo "Total:  $total"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    exit 1
fi
