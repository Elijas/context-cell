#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
BIN_ROOT="$(cd -- "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"

export PYTHONPATH="$BIN_ROOT${PYTHONPATH:+:$PYTHONPATH}"

PYTHON_BIN="${PYTHON_BIN:-python3}"

# Run bash tests first
bash_tests_failed=0
echo "Running bash tests..."
for bash_test in "$SCRIPT_DIR"/**/test_*.sh; do
    if [ -f "$bash_test" ] && [ -x "$bash_test" ]; then
        echo ""
        echo "Running: $bash_test"
        if ! "$bash_test"; then
            bash_tests_failed=1
        fi
    fi
done

# Run Python tests
echo ""
echo "Running Python tests..."
"$PYTHON_BIN" -m pytest -q "$SCRIPT_DIR"
python_exit=$?

# Exit with error if any tests failed
if [ $bash_tests_failed -ne 0 ] || [ $python_exit -ne 0 ]; then
    exit 1
fi

exit 0
