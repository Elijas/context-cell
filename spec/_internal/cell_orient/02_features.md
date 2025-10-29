# feature_001

Running `cell orient .` with no flags shows vantage-based view with DISCOVERY sections.

Output includes:
- ANCESTRY section (if any ancestors exist between project root and current)
- PEERS section (if any peers exist at same level)
- CHILDREN section (if any children exist)

Each cell shows:
- Cell directory name with trailing slash
- work_complete status indicator `[✓]` or `[✗]`
- Single-line DISCOVERY content indented by 2 spaces

Empty sections are omitted entirely.

**Test**: Create work cell hierarchy with ancestors, peers, and children. Run `cell orient .` from middle cell. Verify output shows all three sections with DISCOVERY content and correct work_complete indicators.

# feature_002

Running `cell orient --ABSTRACT .` shows vantage-based view with ABSTRACT sections.

Each cell shows:
- Cell directory name with trailing slash
- work_complete status indicator
- Full ABSTRACT content (multiple lines, preserving paragraph structure)
- ABSTRACT content indented by 2 spaces

**Test**: Create work cells with multi-paragraph ABSTRACT sections. Run `cell orient --ABSTRACT .` from work cell. Verify output shows full ABSTRACT sections with proper indentation and paragraph breaks.

# feature_003

Running `cell orient --DISCOVERY --ABSTRACT .` shows both sections for each cell.

Output format for each cell:
```
cell_name/ [✓]
  DISCOVERY: {single line}
  ABSTRACT:
    {paragraph line 1}
    {paragraph line 2}
    ...
```

DISCOVERY label and content on same line. ABSTRACT label on own line, content indented additional 2 spaces (4 spaces total from cell name).

**Test**: Run `cell orient --DISCOVERY --ABSTRACT .` from work cell. Verify both sections appear with proper labeling and indentation structure.

# feature_004

Relationship flags filter which sections appear in output:

- `--ancestors` shows only ANCESTRY section
- `--peers` shows only PEERS section
- `--children` shows only CHILDREN section
- Combined flags show only requested sections: `--ancestors --children`

Omitted relationship sections do not appear in output at all (no headers, no content).

**Test**: Create hierarchy with ancestors, peers, and children. Run with each flag combination (`--ancestors`, `--peers`, `--children`, `--ancestors --children`, etc.). Verify only requested sections appear in output.

# feature_005

When reading DISCOVERY (and only DISCOVERY, not ABSTRACT), script reads only first 12 lines of CELL.md for performance optimization.

When ABSTRACT is requested (alone or combined with DISCOVERY), full file must be read.

**Test**: Create CELL.md with 100+ lines of content. Run `cell orient .` (DISCOVERY only) and verify it works correctly. Instrument or profile to confirm only first 12 lines are read, not entire file.

# feature_006

Command finds project root by walking up directory tree looking for `projectroot.toml` file.

If not found after reaching filesystem root, exits with error code 1 and message: "No projectroot.toml found in directory hierarchy"

**Test**: Run `cell orient` from directory tree without `projectroot.toml`. Verify exits with error code 1 and correct error message. Run from directory with `projectroot.toml` in parent path and verify it finds root correctly.

# feature_007

Ancestry includes all ancestor work cells from project root down to current location.

**Test**: Create hierarchy:
```
project_root/
  grandparent_v1_01/
    parent_v1_01/
      current_v1_01/
```
Run `cell orient .` from `current_v1_01`. Verify ANCESTRY includes both `grandparent_v1_01` and `parent_v1_01` in hierarchical order.

# feature_008

Directories that don't match work cell pattern or lack CELL.md or lack proper YAML frontmatter are silently ignored during traversal.

No warnings, no errors, simply omitted from output.

Valid work cell requirements:
1. Name matches `^[a-z][a-z0-9_]*_v[0-9]+_[0-9]{2}$`
2. Contains `CELL.md` file
3. CELL.md has YAML frontmatter with `work_complete` field

**Test**: Create hierarchy with:
- Invalid names (wrong pattern)
- Directories without CELL.md
- CELL.md without frontmatter
- Valid work cells

Run `cell orient .`. Verify only valid work cells appear in output, invalid ones silently ignored.

# feature_009

If no work cells exist in any requested relationship direction, output message: "No work cells found in current location"

Exit with code 0 (success, not an error condition).

**Test**: Run `cell orient .` from directory with no work cells in any direction. Verify message appears and exit code is 0. Also test with relationship filters like `--peers` when no peers exist.

# feature_010

Command requires path argument to orient from specified location:

```bash
cell orient .                      # Current directory
cell orient path/to/work_cell      # Relative path
cell orient ../sibling_cell        # Relative path
cell orient /absolute/path/to/cell # Absolute path
```

Shows vantage view from specified path's perspective.

Path validation:
- If path argument missing: Error code 1, "Missing PATH argument"
- If path doesn't exist: Error code 1, "Path does not exist: {path}"
- If path outside project: Error code 1, "Path is outside project root"

**Test**: Run `cell orient` without path argument. Verify error code 1 and "Missing PATH argument" message. Run with valid path and verify success. Run with invalid/missing path and verify appropriate error messages.

**Test**: Create multiple work cells. Run `cell orient other_cell_v1_01` from different directory. Verify output shows vantage from other_cell's perspective. Test with relative path, absolute path, and nonexistent path (verify error).

# feature_011

If specified path is not itself a work cell, walks up to find nearest parent work cell or project root.

Resolution order:
1. If path is valid work cell: Use it as vantage point
2. If not, walk up to find parent work cell: Use parent as vantage point
3. If no parent work cell: Use project root as vantage point

**Test**: Create hierarchy. Run `cell orient some_random_subdir` where subdir is inside work cell. Verify it resolves to parent work cell as vantage point.

# feature_012

Section headers (ANCESTRY, PEERS, CHILDREN) are displayed with clear formatting:

```
=== ANCESTRY ===

=== PEERS ===

=== CHILDREN ===
```

Headers only appear if section has content. Empty sections completely omitted (no header displayed).

Sections appear in fixed order: ANCESTRY, then PEERS, then CHILDREN (if present).

**Test**: Run `cell orient .` from various positions in hierarchy. Verify section headers only appear when sections have content, and always in correct order.

# feature_013

Work cell names are displayed with trailing slash to indicate directory nature:

```
auth_v1_01/ [✓]
  Implement JWT authentication middleware
```

work_complete indicator follows immediately after slash with space before bracket.

**Test**: Examine output from any `cell orient` execution. Verify all work cell names end with `/` and indicator format is consistent.

# feature_014

Command handles work cells at project root correctly. If current location IS the project root:

- ANCESTRY section is empty
- PEERS shows sibling work cells at root level
- CHILDREN shows immediate children of root

**Test**: Create work cell at project root with peers and children. Run `cell orient .` from root work cell. Verify ANCESTRY is empty, PEERS and CHILDREN show correctly.

# feature_015

When ABSTRACT section contains multiple paragraphs separated by blank lines, preserve paragraph structure in output.

Blank lines in ABSTRACT are preserved. All content between `# ABSTRACT` and next section heading is included.

**Test**: Create CELL.md with ABSTRACT containing 3 paragraphs separated by blank lines. Run `cell orient --ABSTRACT .`. Verify output preserves paragraph breaks and shows all content.

# feature_016

Flag `--descendants` enables recursive nesting of children in `<children>` XML sections.

Behavior:
- `--children` shows immediate subordinate cells without nesting
- `--descendants` shows ALL cells in the subtree with nested `<children>` sections
- Each cell can have its own nested `<children>` containing its immediate children
- This preserves hierarchical relationships (you can see which grandchild belongs to which child)
- `--descendants` implies `--children`

Output structure with `--descendants`:
```xml
<children>
  <cell name="child_v1_01">
    <children>
      <cell name="grandchild_v1_01"/>
    </children>
  </cell>
</children>
```

Not a flat list in separate `<descendants>` section.

**Test**: Create hierarchy with multiple levels (parent → child → grandchild → great-grandchild). Run `cell orient --descendants .` from parent. Verify output shows nested `<children>` sections preserving hierarchy. Compare with `cell orient --children .` which shows only immediate children without nesting.

# feature_017

When `cell orient @project` is run and `treeroot.toml` exists (making `@tree` different from `@project`), command auto-corrects to use `@tree` instead and displays warning to stderr.

Behavior:
- If `@project` == `@tree` (no treeroot.toml): Uses project root, no warning
- If `@project` != `@tree` (treeroot.toml exists): Auto-corrects to `@tree`, shows warning
- Warning message: "Warning: @project differs from @tree. Auto-correcting to @tree (use @project/path for explicit project root path)"
- Warning goes to stderr, not stdout
- `@project/explicit/path` always uses literal project root, no auto-correction

**Test**: Create project structure with `projectroot.toml` at root and `treeroot.toml` in `work_cells/`. From deep work cell, run `cell orient @project`. Verify (1) command orients from `work_cells/` not project root, (2) warning appears on stderr, (3) `cell orient @project/work_cells` uses literal project root with no warning.
