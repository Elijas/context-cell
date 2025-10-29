# cell orient Tests

Comprehensive test suite for the `cell orient` command.

## Test Organization

Tests are organized by feature, following the features defined in `/Users/user/Development/context-cell/spec/cell_orient/02_features.md`.

```
tests/cell_orient/
├── feature_001/    # Default behavior (DISCOVERY vantage view)
├── feature_002/    # --ABSTRACT flag
├── feature_003/    # Combining section flags (--DISCOVERY --ABSTRACT)
├── feature_004/    # Relationship flags (--ancestors, --peers, --children)
├── feature_005/    # DISCOVERY optimization (first 12 lines)
├── feature_006/    # Project root detection (projectroot.toml)
├── feature_007/    # Execution boundary detection
├── feature_008/    # Invalid cells are ignored
├── feature_009/    # Empty output handling
├── feature_010/    # Path argument support
├── feature_011/    # work_complete status indicators
├── feature_012/    # Help flag
├── feature_013/    # Section extraction correctness
├── feature_014/    # Output formatting
├── feature_015/    # ABSTRACT paragraph preservation
└── feature_016/    # --descendants flag (recursive subtree)
```

## Running Tests

**Run all tests:**
```bash
cd /Users/user/Development/context-cell/tests/cell_orient
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

### feature_001: Default behavior
- **test_01**: Default shows DISCOVERY vantage view with ancestry, peers, and children
- **test_02**: Multiple ancestors and children in deeper hierarchy

### feature_002: --ABSTRACT flag
- **test_01**: Shows full abstract sections with proper indentation

### feature_003: Combining section flags
- **test_01**: Both --DISCOVERY and --ABSTRACT flags together

### feature_004: Relationship flags
- **test_01**: --ancestors shows only ANCESTRY section
- **test_02**: --peers shows only PEERS section
- **test_03**: --children shows only CHILDREN section
- **test_04**: Combined --ancestors --children flags

### feature_005: DISCOVERY optimization
- **test_01**: DISCOVERY reads only first 12 lines of CELL.md
- **test_02**: DISCOVERY beyond line 12 causes cell to be ignored

### feature_006: Project root detection
- **test_01**: Error when no projectroot.toml found in hierarchy

### feature_007: Execution boundary
- **test_01**: Ancestry stops at execution boundary

### feature_008: Invalid cells ignored
- **test_01**: Invalid directory names are silently ignored
- **test_02**: Missing CELL.md causes directory to be ignored
- **test_03**: Malformed CELL.md (missing frontmatter) ignored

### feature_009: Empty output
- **test_01**: "No work cells found" message with exit code 0

### feature_010: Path argument
- **test_01**: Orient from different directory using path argument
- **test_02**: Relative path support
- **test_03**: Absolute path support
- **test_04**: Invalid path error handling
- **test_05**: Missing path argument error

### feature_011: work_complete indicators
- **test_01**: Correct display of [✓] and [✗] indicators

### feature_012: Help flag
- **test_01**: --help shows usage information

### feature_013: Section extraction
- **test_01**: ABSTRACT with multiple paragraphs
- **test_02**: ABSTRACT extraction stops at next heading

### feature_014: Output formatting
- **test_01**: Proper indentation (2 spaces for content)
- **test_02**: Section headers formatted correctly (=== SECTION ===)
- **test_03**: Empty sections are omitted

### feature_015: ABSTRACT paragraph preservation
- **test_01**: ABSTRACT preserves blank lines between paragraphs

### feature_016: --descendants flag
- **test_01**: Shows all descendants recursively (children, grandchildren, etc.), not just immediate children
- **test_02**: Verifies proper nested hierarchical structure (not flat list), preserves parent-child relationships

## Writing New Tests

Follow the template in existing test directories. Key principles:

1. **Self-contained**: Each test creates its own fixtures and cleans up
2. **Exit codes**: Exit 0 on success, 1 on failure
3. **Output**: Print ✓ on success, ✗ with details on failure
4. **Helper functions**: Use `create_cell()` helper for creating CELL.md files

### Test Template

```bash
#!/bin/bash

# Test NN: Brief description

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CELL_ORIENT="$REPO_ROOT/bin/_cell_orient.sh"

TEST_ROOT="$SCRIPT_DIR"

# Create test hierarchy
mkdir -p "$TEST_ROOT/execution/cell_v1_01"

cat > "$TEST_ROOT/projectroot.toml" << 'EOF'
[project]
name = "test"
EOF

# Create CELL.md files
# ... test setup ...

# Run cell orient
cd "$TEST_ROOT/execution/cell_v1_01"
output=$("$CELL_ORIENT" . 2>&1)

# Assertions
if ! echo "$output" | grep -q "expected content"; then
    echo "✗ Assertion failed: expected content not found"
    echo "  Output: $output"
    exit 1
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_ROOT/execution" "$TEST_ROOT/projectroot.toml"

echo "✓ Test description"
exit 0
```

## Validation Checklist

- ✅ All features from spec have corresponding tests
- ✅ Each test is self-contained (creates own fixtures)
- ✅ Tests follow the pattern from `tests/claude_launcher/`
- ✅ README.md documents test organization
- ✅ run_all_tests.sh script created
- ✅ Tests validate both success and error cases
- ✅ Edge cases covered (empty hierarchies, invalid cells, etc.)

## References

**Required reading**:
- `/Users/user/Development/context-cell/spec/cell_orient/02_features.md` - Features being tested
- `/Users/user/Development/context-cell/bin/_cell_orient.sh` - Implementation being tested
- `/Users/user/Development/context-cell/spec/context_cell_framework/02_cell_format.md` - CELL.md format
