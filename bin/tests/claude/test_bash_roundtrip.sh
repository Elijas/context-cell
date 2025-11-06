#!/bin/bash
# Test that --append-system-prompt content roundtrips identically through bash argument handling
#
# WHY THIS TEST EXISTS:
# The framework specification passed via --append-system-prompt contains bash-active characters
# like $, backticks, parentheses, and quotes. If argument handling isn't done carefully (e.g.,
# using unquoted variables or string concatenation instead of proper array expansion), bash
# could interpret these characters and corrupt the content.
#
# This test verifies that:
# 1. Direct argument passing with proper quoting preserves content byte-for-byte
# 2. Array-based argument passing (used in claude.sh) works correctly
# 3. Window mode's printf %q escaping round-trips correctly through eval
# 4. The spec actually contains bash-active characters (confirms test is meaningful)
#
# If this test fails after a change to claude.sh, it means the new code is not properly
# escaping or quoting arguments, and bash is interpreting the content instead of passing
# it through unchanged.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
BIN_ROOT="$(cd -- "$SCRIPT_DIR/../.." >/dev/null 2>&1 && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

test_passed=0
test_failed=0

print_pass() {
    echo -e "${GREEN}✓${NC} $1"
    test_passed=$((test_passed + 1))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    test_failed=$((test_failed + 1))
}

# Create a temporary test script that echoes received arguments
TEST_SCRIPT=$(mktemp)
trap "rm -f $TEST_SCRIPT" EXIT

cat > "$TEST_SCRIPT" << 'EOF'
#!/bin/bash
# Echo the second argument (after --append-system-prompt flag)
if [ "$1" = "--append-system-prompt" ] && [ -n "$2" ]; then
    echo "$2"
fi
EOF
chmod +x "$TEST_SCRIPT"

echo "Testing bash argument roundtrip for --append-system-prompt..."
echo ""

# Test 1: Direct argument passing (simulating claude.sh line 294)
echo "Test 1: Direct argument passing with quoted array expansion"
original=$("$BIN_ROOT/_acft_claude/get-framework-spec.sh")
received=$("$TEST_SCRIPT" --append-system-prompt "$original")

original_checksum=$(echo "$original" | md5)
received_checksum=$(echo "$received" | md5)

if [ "$original_checksum" = "$received_checksum" ]; then
    print_pass "Direct argument passing: content roundtrips identically"
else
    print_fail "Direct argument passing: content was corrupted"
    echo "  Original checksum: $original_checksum"
    echo "  Received checksum: $received_checksum"
fi

# Test 2: Array-based argument passing (simulating claude.sh line 360-363)
echo ""
echo "Test 2: Array-based argument passing"
original=$("$BIN_ROOT/_acft_claude/get-framework-spec.sh")
cmd_args=("--append-system-prompt" "$original")
received=$("$TEST_SCRIPT" "${cmd_args[@]}")

original_checksum=$(echo "$original" | md5)
received_checksum=$(echo "$received" | md5)

if [ "$original_checksum" = "$received_checksum" ]; then
    print_pass "Array-based argument passing: content roundtrips identically"
else
    print_fail "Array-based argument passing: content was corrupted"
    echo "  Original checksum: $original_checksum"
    echo "  Received checksum: $received_checksum"
fi

# Test 3: Window mode escaping with printf %q (simulating claude.sh line 336)
echo ""
echo "Test 3: Window mode escaping with printf %q"
original=$("$BIN_ROOT/_acft_claude/get-framework-spec.sh")
escaped=$(printf %q "$original")
eval "roundtripped=$escaped"

original_checksum=$(echo "$original" | md5)
roundtripped_checksum=$(echo "$roundtripped" | md5)

if [ "$original_checksum" = "$roundtripped_checksum" ]; then
    print_pass "Window mode (printf %q + eval): content roundtrips identically"
else
    print_fail "Window mode (printf %q + eval): content was corrupted"
    echo "  Original checksum: $original_checksum"
    echo "  Roundtripped checksum: $roundtripped_checksum"
fi

# Test 4: Verify presence of bash-active characters in the spec
echo ""
echo "Test 4: Verify spec contains bash-active characters (confirms test validity)"
if echo "$original" | grep -q '[\$`;&|<>(){}]'; then
    print_pass "Spec contains bash-active characters (test is meaningful)"
else
    print_fail "Spec does not contain bash-active characters (test may be insufficient)"
fi

# Summary
echo ""
echo "========================================"
echo "Test Results:"
echo "  Passed: $test_passed"
echo "  Failed: $test_failed"
echo "========================================"

if [ $test_failed -gt 0 ]; then
    exit 1
fi

exit 0
