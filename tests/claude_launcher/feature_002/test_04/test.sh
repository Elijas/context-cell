#!/bin/bash

# Test 04: Permissions
# Verify that permission flags correctly control --dangerously-skip-permissions

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
echo "$@" > /tmp/mock_claude_test04.log
exit 0
EOF

chmod +x "$MOCK_DIR/claude"

# Add mock to PATH
export PATH="$MOCK_DIR:$PATH"

# Test 1: Default (should skip permissions)
rm -f /tmp/mock_claude_test04.log
"$LAUNCHER" "test prompt" > /dev/null 2>&1
if grep -q "\--dangerously-skip-permissions" /tmp/mock_claude_test04.log; then
    echo "✓ Default skips permission checks"
else
    echo "✗ Default does not skip permission checks"
    cat /tmp/mock_claude_test04.log
    exit 1
fi

# Test 2: Explicit -d flag (should skip permissions)
rm -f /tmp/mock_claude_test04.log
"$LAUNCHER" -d "test prompt" > /dev/null 2>&1
if grep -q "\--dangerously-skip-permissions" /tmp/mock_claude_test04.log; then
    echo "✓ -d flag skips permission checks"
else
    echo "✗ -d flag does not skip permission checks"
    cat /tmp/mock_claude_test04.log
    exit 1
fi

# Test 3: -p flag (should NOT skip permissions)
rm -f /tmp/mock_claude_test04.log
"$LAUNCHER" -p "test prompt" > /dev/null 2>&1
if ! grep -q "\--dangerously-skip-permissions" /tmp/mock_claude_test04.log; then
    echo "✓ -p flag enables permission checks"
else
    echo "✗ -p flag did not enable permission checks"
    cat /tmp/mock_claude_test04.log
    exit 1
fi

# Clean up
rm -f /tmp/mock_claude_test04.log
rm -rf "$MOCK_DIR"

exit 0
