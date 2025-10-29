#!/bin/bash

# Test 05: Combined flags
# Verify that single-letter flags can be combined (e.g., -st for -s -t)

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
echo "$@" > /tmp/mock_claude_test05.log
exit 0
EOF

chmod +x "$MOCK_DIR/claude"

# Add mock to PATH
export PATH="$MOCK_DIR:$PATH"

# Test 1: -st (sonnet + thinking)
rm -f /tmp/mock_claude_test05.log
"$LAUNCHER" -st "test prompt" > /dev/null 2>&1
if grep -q "sonnet" /tmp/mock_claude_test05.log && grep -q '"alwaysThinkingEnabled": true' /tmp/mock_claude_test05.log; then
    echo "✓ -st combines sonnet and thinking flags"
else
    echo "✗ -st did not combine sonnet and thinking flags"
    cat /tmp/mock_claude_test05.log
    exit 1
fi

# Test 2: -hf (haiku + fast/no thinking)
rm -f /tmp/mock_claude_test05.log
"$LAUNCHER" -hf "test prompt" > /dev/null 2>&1
if grep -q "haiku" /tmp/mock_claude_test05.log && grep -q '"alwaysThinkingEnabled": false' /tmp/mock_claude_test05.log; then
    echo "✓ -hf combines haiku and fast flags"
else
    echo "✗ -hf did not combine haiku and fast flags"
    cat /tmp/mock_claude_test05.log
    exit 1
fi

# Test 3: -op (opus + with-permission-checks)
rm -f /tmp/mock_claude_test05.log
"$LAUNCHER" -op "test prompt" > /dev/null 2>&1
if grep -q "opus" /tmp/mock_claude_test05.log && ! grep -q "\--dangerously-skip-permissions" /tmp/mock_claude_test05.log; then
    echo "✓ -op combines opus and permission-checks flags"
else
    echo "✗ -op did not combine opus and permission-checks flags"
    cat /tmp/mock_claude_test05.log
    exit 1
fi

# Clean up
rm -f /tmp/mock_claude_test05.log
rm -rf "$MOCK_DIR"

exit 0
