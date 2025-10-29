#!/bin/bash

# Test 02: Model selection
# Verify that model flags correctly set the model parameter

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
echo "MOCK_CLAUDE_CALLED" > /tmp/mock_claude_test02.log
echo "$@" >> /tmp/mock_claude_test02.log
exit 0
EOF

chmod +x "$MOCK_DIR/claude"

# Add mock to PATH
export PATH="$MOCK_DIR:$PATH"

# Clean up log file
rm -f /tmp/mock_claude_test02.log

# Test 1: Default (should be sonnet)
"$LAUNCHER" "test prompt" > /dev/null 2>&1
if [ -f /tmp/mock_claude_test02.log ]; then
    if grep -q "sonnet" /tmp/mock_claude_test02.log; then
        echo "✓ Default model is sonnet"
    else
        echo "✗ Default model is not sonnet"
        cat /tmp/mock_claude_test02.log
        exit 1
    fi
else
    echo "✗ Mock claude was not called"
    exit 1
fi

# Test 2: Haiku flag
rm -f /tmp/mock_claude_test02.log
"$LAUNCHER" -h "test prompt" > /dev/null 2>&1
if grep -q "haiku" /tmp/mock_claude_test02.log; then
    echo "✓ -h flag sets model to haiku"
else
    echo "✗ -h flag did not set model to haiku"
    cat /tmp/mock_claude_test02.log
    exit 1
fi

# Test 3: Opus flag
rm -f /tmp/mock_claude_test02.log
"$LAUNCHER" --opus "test prompt" > /dev/null 2>&1
if grep -q "opus" /tmp/mock_claude_test02.log; then
    echo "✓ --opus flag sets model to opus"
else
    echo "✗ --opus flag did not set model to opus"
    cat /tmp/mock_claude_test02.log
    exit 1
fi

# Clean up
rm -f /tmp/mock_claude_test02.log
rm -rf "$MOCK_DIR"

exit 0
