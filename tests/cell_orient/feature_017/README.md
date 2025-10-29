# feature_017: @project and @tree distinction

Tests that `@project` and `@tree` are distinct path symbols that reference different roots when treeroot.toml exists.

## Test Structure

```
project_root/
├── projectroot.toml          # CELL_PROJECT_ROOT marker
├── src/                      # Project codebase
└── explorations/
    └── v4/
        ├── treeroot.toml     # CELL_WORK_ROOT marker
        └── test_v1_01/       # Work cell
            └── CELL.md
```

## Expected Behavior

### Test 1: @project references project root

From `explorations/v4/test_v1_01/`:

```bash
cd explorations/v4/test_v1_01
cell orient @project 2>&1
```

**Expected:**
- Output orients from `project_root/` (not work root)
- XML output shows both `@project` and `@tree` paths
- Exit code: 0

### Test 2: @tree references work root when treeroot.toml exists

From `explorations/v4/test_v1_01/`:

```bash
cd explorations/v4/test_v1_01
cell orient @tree 2>&1
```

**Expected:**
- Output orients from `explorations/v4/` (work root, not project root)
- Exit code: 0

### Test 3: @tree falls back to @project when treeroot.toml absent

From project with no treeroot.toml:

```bash
# Remove treeroot.toml
rm explorations/v4/treeroot.toml
cd explorations/v4/test_v1_01
cell orient @tree 2>&1
```

**Expected:**
- Output orients from project root (since @tree == @project)
- Exit code: 0

## Test Commands

```bash
# Setup
cd /Users/user/Development/context-cell/tests/cell_orient/feature_017
./setup.sh

# Run test
./test.sh

# Cleanup
./cleanup.sh
```
