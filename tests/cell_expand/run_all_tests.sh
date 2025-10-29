#!/bin/bash

# Run all cell expand tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0
passed=0
total=0

echo "Running cell expand test suite..."
echo ""

for test_script in "$SCRIPT_DIR"/feature_*/test_*/test.sh; do
    if [ -f "$test_script" ]; then
        feature=$(basename $(dirname $(dirname "$test_script")))
        test_name=$(basename $(dirname "$test_script"))

        ((total++))

        echo -n "[$feature/$test_name] "

        if bash "$test_script" > /dev/null 2>&1; then
            ((passed++))
            echo "✓"
        else
            ((failed++))
            echo "✗ FAILED"
            echo "  Re-running with output:"
            bash "$test_script" 2>&1 | sed 's/^/    /'
            echo ""
        fi
    fi
done

echo ""
echo "======================================"
echo "Test Results:"
echo "  Total:  $total"
echo "  Passed: $passed"
echo "  Failed: $failed"
echo "======================================"

if [ $failed -gt 0 ]; then
    exit 1
fi

echo ""
echo "All tests passed! ✓"
exit 0
