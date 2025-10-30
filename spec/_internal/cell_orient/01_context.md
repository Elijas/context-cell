# context

`cell orient` shows work cell hierarchy from current location's perspective. Composable command using section and relationship flags.

Default behavior: `cell orient .` shows vantage-based view with DISCOVERY sections.

Output structure organized into sections based on relationship:
- **ANCESTRY** - Path from project root down to current location
- **PEERS** - Sibling cells at same level as current location
- **CHILDREN** - Immediate subordinates of current location

Only sections with cells are displayed (empty sections omitted).

# context

Section flags control which CELL.md sections to display:

- `--DISCOVERY` - One-line description (fast, reads first 12 lines only)
- `--ABSTRACT` - Full summary (5-10 sentences with metrics)

Can be combined: `cell orient --DISCOVERY --ABSTRACT .`

Default when no section flag specified: `--DISCOVERY`

# context

Relationship flags filter hierarchy display:

- `--ancestors` - All parent cells up to project root
- `--peers` - Sibling cells at same level
- `--children` - Immediate subordinate cells (one level down only)

Can be combined: `cell orient --ancestors --children .`

Default when no relationship flag specified: `--ancestors --peers --children` (full vantage view)

# context

Vantage-based view shows hierarchy relative to current location:

**Ancestry section**: Path from project root down to current location (inclusive). Shows where you are in the hierarchy.

**Peers section**: Siblings at same level as current location. Shows parallel work streams.

**Children section**: Immediate subordinates of current location (one level only, not recursive). Shows delegated work.

Output format:
```
=== ANCESTRY ===
[cells from project root down to current, in hierarchical order]

=== PEERS ===
[sibling cells at same level]

=== CHILDREN ===
[immediate child cells]
```

Only sections with cells are displayed. Empty sections are omitted entirely.

# context

Work cell directory naming pattern: `{branch}_v{version}_{step}`

Examples: `auth_v1_01`, `data_prep_v2_03`, `input_validation_v1_05`

Directory is valid work cell if all three conditions met:
1. Name matches pattern: `^[a-z][a-z0-9_]*_v[0-9]+_[0-9]{2}$`
2. Contains `CELL.md` file
3. CELL.md has required YAML frontmatter with `work_complete` field

Invalid directories are silently ignored during traversal. No warnings or errors for non-matching directories.

# context

CELL.md structure for section extraction:

```markdown
---
work_complete: true
---

# DISCOVERY
Single line description

# ABSTRACT
Multiple paragraph summary with metrics and details...
```

**DISCOVERY extraction**: Read first 12 lines only (performance optimization). Extract single line after `# DISCOVERY` heading. Strip leading/trailing whitespace.

**ABSTRACT extraction**: Read full file. Extract all content between `# ABSTRACT` heading and next `#` heading (or end of file). Preserve paragraph structure. Strip leading/trailing whitespace.

Both sections are mandatory in CELL.md format, but extraction may fail gracefully if malformed.

# context

Project root detection by walking up directory tree:

Starting from target directory, walk up checking each parent directory for `cellproject.toml` file.

If found: Use that directory as project root.
If reached filesystem root without finding: Exit with error code 1 and message "No cellproject.toml found in directory hierarchy"

Ancestry always goes from project root down to current location, including all ancestor work cells in the path.

# context

Command requires path argument:

```bash
cell orient .                    # Current directory
cell orient path/to/work_cell    # Specific directory
```

Path can be:
- Relative path (resolved from current working directory)
- Absolute path
- Directory that is or contains a work cell
- Special symbols: `.` (current dir), `@project`, `@project/subpath`, `@tree`, `@tree/subpath`

**`@project` auto-correction**: When using `@project` alone and `celltree.toml` exists (making `@tree` different from `@project`), command auto-corrects to `@tree` with a warning. This helps discover work cells hierarchy naturally. Use `@project/explicit/path` for literal project root paths.

**`@tree` symbol**: Expands to TREE_ROOT (directory containing `celltree.toml`, or PROJECT_ROOT if not found). Use for work cells hierarchy root.

If path is not itself a work cell:
- Walk up to find nearest parent work cell
- If no parent work cell found, use project root as vantage point

Path validation:
- If path argument missing: Exit with error code 1 and message "Missing PATH argument"
- If path doesn't exist: Exit with error code 1 and message "Path does not exist: {path}"
- If path is not within project (above cellproject.toml): Exit with error code 1 and message "Path is outside project root"

# context

Error handling exit codes and messages:

**Exit code 1** (errors):
- Missing path argument: "Missing PATH argument"
- No `cellproject.toml` found in hierarchy: "No cellproject.toml found in directory hierarchy"
- Path argument doesn't exist: "Path does not exist: {path}"
- Path is not within project: "Path is outside project root"

**Exit code 0** (success, including empty results):
- No work cells to display: "No work cells found in current location"
- Normal execution with output: Display vantage view and exit

Empty output is not an error condition. Simply inform user and exit cleanly.

# context

Output format for each cell:

**With DISCOVERY only** (default):
```
{cell_name}/ [work_complete_indicator]
  {discovery_line}
```

**With ABSTRACT only**:
```
{cell_name}/ [work_complete_indicator]
  {abstract_paragraph_line_1}
  {abstract_paragraph_line_2}
  ...
```

**With both DISCOVERY and ABSTRACT**:
```
{cell_name}/ [work_complete_indicator]
  DISCOVERY: {discovery_line}
  ABSTRACT:
    {abstract_paragraph_line_1}
    {abstract_paragraph_line_2}
    ...
```

work_complete indicators:
- `[✓]` when `work_complete: true`
- `[✗]` when `work_complete: false`

Indentation:
- Cell header: No indentation
- Section content: 2 spaces
- ABSTRACT content when combined with DISCOVERY: 4 spaces (2 for label + 2 for content)

# context

Common usage patterns demonstrating composability:

```bash
# Quick overview (default) - DISCOVERY for all relationships
cell orient .

# Detailed view - ABSTRACT for all relationships
cell orient --ABSTRACT .

# Complete view - both sections for all relationships
cell orient --DISCOVERY --ABSTRACT .

# Only peers - DISCOVERY for peers only
cell orient --peers .

# Vertical context - ancestors and children with abstracts
cell orient --ABSTRACT --ancestors --children .

# Just my children with full detail
cell orient --DISCOVERY --ABSTRACT --children .

# Orient from different location
cell orient ../other_branch_v1_01

# Absolute path
cell orient /path/to/work/cell
```

Composability eliminates need for separate tree/abstract commands. All combinations of section and relationship flags are valid.
