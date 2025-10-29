#!/bin/bash

# Test 03: Thinking mode
# Verify that thinking flags correctly set the alwaysThinkingEnabled parameter

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
LAUNCHER="$REPO_ROOT/bin/claude_launcher.sh"
MOCK_DIR="$SCRIPT_DIR/mock_bin"

# Create mock bin directory
mkdir -p "$MOCK_DIR"

# Create mock claude command that captures arguments
cat > "$MOCK_DIR/claude" << 'EOF'
#!/bin/bash
echo "$@" > /tmp/mock_claude_test03.log
exit 0
EOF

chmod +x "$MOCK_DIR/claude"

# Add mock to PATH
export PATH="$MOCK_DIR:$PATH"

# Test 1: Default (should have thinking enabled for sonnet)
rm -f /tmp/mock_claude_test03.log
"$LAUNCHER" "test prompt" > /dev/null 2>&1
if grep -q '"alwaysThinkingEnabled": true' /tmp/mock_claude_test03.log; then
    echo "✓ Default has thinking enabled"
else
    echo "✗ Default does not have thinking enabled"
    cat /tmp/mock_claude_test03.log
    exit 1
fi

# Test 2: Fast flag (disable thinking)
rm -f /tmp/mock_claude_test03.log
"$LAUNCHER" -f "test prompt" > /dev/null 2>&1
if grep -q '"alwaysThinkingEnabled": false' /tmp/mock_claude_test03.log; then
    echo "✓ -f flag disables thinking"
else
    echo "✗ -f flag did not disable thinking"
    cat /tmp/mock_claude_test03.log
    exit 1
fi

# Test 3: Haiku should default to no thinking
rm -f /tmp/mock_claude_test03.log
"$LAUNCHER" -h "test prompt" > /dev/null 2>&1
if grep -q '"alwaysThinkingEnabled": false' /tmp/mock_claude_test03.log; then
    echo "✓ Haiku defaults to thinking disabled"
else
    echo "✗ Haiku does not default to thinking disabled"
    cat /tmp/mock_claude_test03.log
    exit 1
fi

# Test 4: Haiku with explicit thinking flag
rm -f /tmp/mock_claude_test03.log
"$LAUNCHER" -h -t "test prompt" > /dev/null 2>&1
if grep -q '"alwaysThinkingEnabled": true' /tmp/mock_claude_test03.log; then
    echo "✓ -t flag can enable thinking for haiku"
else
    echo "✗ -t flag did not enable thinking for haiku"
    cat /tmp/mock_claude_test03.log
    exit 1
fi

# Clean up
rm -f /tmp/mock_claude_test03.log
rm -rf "$MOCK_DIR"

exit 0
