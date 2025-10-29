# cell validate Tests

Comprehensive test suite for the `cell validate` command.

## Test Organization

Tests are organized by feature, following the features defined in `/Users/user/Development/context-cell/spec/cell_validate/02_features.md`.

```
tests/cell_validate/
├── feature_001/    # Valid work cell passes
├── feature_002/    # Invalid naming convention
├── feature_003/    # Missing CELL.md
├── feature_004/    # Missing YAML frontmatter
├── feature_005/    # Missing work_complete field
├── feature_006/    # Invalid work_complete value
├── feature_007/    # Missing section
├── feature_008/    # Sections out of order
├── feature_009/    # DISCOVERY beyond line 12
├── feature_010/    # Multiple errors reported
├── feature_011/    # Path argument support
├── feature_012/    # @root path support
├── feature_013/    # Invalid path error
├── feature_014/    # No cellproject.toml error
└── feature_015/    # Missing path argument error
```

## Running Tests

**Run all tests:**
```bash
./run_all_tests.sh
```

**Run specific feature:**
```bash
cd feature_001/test_01
./test.sh
```

## Test Coverage

Tests validate:
- ✓ Naming convention compliance
- ✓ CELL.md existence
- ✓ YAML frontmatter validation
- ✓ work_complete field presence and values
- ✓ Required section presence
- ✓ Section order enforcement
- ✓ DISCOVERY position (within 12 lines)
- ✓ Multiple error reporting
- ✓ Path argument handling
- ✓ @root path support
- ✓ Error handling for invalid inputs

## Writing New Tests

Follow the template in each test directory. Key principles:
1. Each test is self-contained with its own fixtures
2. Tests exit 0 on success, 1 on failure
3. Tests print ✓ on success, ✗ on failure with details
4. Both positive and negative test cases
5. Test both exit codes and output messages

## Test Structure

Each test script follows this pattern:
- Creates temporary test fixtures in its own directory
- Runs `cell validate` with appropriate arguments
- Validates exit code and output
- Cleans up fixtures after test
- Prints clear success/failure message
