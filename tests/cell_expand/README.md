# cell expand Tests

Comprehensive test suite for the `cell expand` command.

## Test Organization

Tests are organized by feature, following the features defined in `/Users/user/Development/context-cell/spec/cell_expand/02_features.md`.

```
tests/cell_expand/
├── feature_001/    # Expand @root to project root path
├── feature_002/    # Expand @root/subpath
├── feature_003/    # Non-@root paths pass through unchanged
├── feature_004/    # Missing path argument error
├── feature_005/    # @root without cellproject.toml error
├── feature_006/    # Non-@root paths work without cellproject.toml
├── feature_007/    # @root works from deep subdirectories
├── feature_008/    # Complex subpaths preserved
├── feature_009/    # Help flag
└── feature_010/    # Shell command substitution integration
```

## Running Tests

**Run all tests:**
```bash
cd /Users/user/Development/context-cell/tests/cell_expand
./run_all_tests.sh
```

**Run specific feature:**
```bash
cd feature_001/test_01
./test.sh
```

**Run single test with output:**
```bash
cd feature_001/test_01
bash -x ./test.sh
```

## Test Details

### feature_001: Expand @root to project root
- **test_01**: Basic @root expansion from subdirectory

### feature_002: Expand @root/subpath
- **test_01**: Subpath expansion with multiple path components

### feature_003: Non-@root paths pass through
- **test_01**: Absolute, relative, and dot-relative paths unchanged

### feature_004: Missing path argument
- **test_01**: Error when no path provided

### feature_005: @root without cellproject.toml
- **test_01**: Error when @root used without project root marker

### feature_006: Non-@root paths without cellproject.toml
- **test_01**: Absolute and relative paths work without project root

### feature_007: Deep subdirectory expansion
- **test_01**: @root works from deeply nested directories

### feature_008: Complex subpaths
- **test_01**: Multi-level subpaths preserve structure

### feature_009: Help flag
- **test_01**: --help shows usage information

### feature_010: Shell integration
- **test_01**: Command substitution works for cd and ls

## Writing New Tests

Follow the template in existing test directories. Key principles:

1. **Self-contained**: Each test creates its own fixtures and cleans up
2. **Exit codes**: Exit 0 on success, 1 on failure
3. **Output**: Print ✓ on success, ✗ with details on failure
4. **Cleanup**: Always remove temporary files/directories

### Test Template

```bash
#!/bin/bash

# Test 01: Brief description

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CELL_EXPAND="$REPO_ROOT/bin/_cell_expand.sh"

# Create test directory
TEST_ROOT="$SCRIPT_DIR/test_temp"
mkdir -p "$TEST_ROOT/subdir"

# Create cellproject.toml
cat > "$TEST_ROOT/cellproject.toml" << 'EOF'
[project]
name = "test"
EOF

# Run cell expand
cd "$TEST_ROOT/subdir"
output=$("$CELL_EXPAND" @root 2>&1)

# Assertions
if [ "$output" != "$TEST_ROOT" ]; then
    echo "✗ Expected $TEST_ROOT, got $output"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT"

echo "✓ Test description"
exit 0
```

## Validation Checklist

- ✅ All features from spec have corresponding tests
- ✅ Each test is self-contained (creates own fixtures)
- ✅ Tests follow the pattern from `tests/cell_orient/`
- ✅ README.md documents test organization
- ✅ run_all_tests.sh script created
- ✅ Tests validate both success and error cases
- ✅ Edge cases covered (deep paths, missing args, etc.)

## References

**Required reading**:
- `/Users/user/Development/context-cell/spec/cell_expand/02_features.md` - Features being tested
- `/Users/user/Development/context-cell/bin/_cell_expand.sh` - Implementation being tested
