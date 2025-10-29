# Command Reference

## Command: cell orient

Command `cell orient PATH` shows work cell structure from specified location's perspective in structured XML format. Composable command using section and relationship flags.

PATH argument is required. Use `.` for current directory.

Default behavior: `cell orient .` shows vantage-based view with DISCOVERY sections (one-line summaries).

### XML Output Format

Output is structured XML for easy parsing by LLMs and tools:

```xml
<orient path="@project/cell_v1_01" expanded="/abs/path/to/cell" root="@project → /abs/path/to/root">
  <ancestry>
    <cell name="parent_v1_01" work_complete="true" path="@project/parent_v1_01/CELL.md">
      <discovery>One line summary</discovery>
    </cell>
  </ancestry>

  <peers>
    <cell name="sibling_v1_01" work_complete="false" path="@project/sibling_v1_01/CELL.md">
      <discovery>One line summary</discovery>
    </cell>
  </peers>

  <children>
    <cell name="child_v1_01" work_complete="true" path="@this/child_v1_01/CELL.md">
      <discovery>One line summary</discovery>
    </cell>
  </children>
</orient>
```

**Root-level attributes:**

- `path` - Symbolic path using `@project/` or `@this/` prefixes
- `expanded` - Absolute filesystem path to current location
- `root` - Shows what `@project` expands to (e.g., "@project → /abs/path")

**Cell attributes:**

- `name` - Work cell directory name
- `work_complete` - Boolean status ("true" or "false")
- `path` - Always ends with `/CELL.md` for direct file access

**Hierarchy sections:**

- `<ancestry>` - Parent cells up to execution boundary
- `<peers>` - Siblings at same level
- `<children>` - Immediate subordinate cells (recursively nested when using `--descendants`)

### Section Flags

Section flags control which CELL.md sections to display within each `<cell>` tag:

- `--DISCOVERY` - One-line summaries in `<discovery>` tags (fast)
- `--ABSTRACT` - Full paragraphs in `<abstract>` tags (detailed, 5-10 sentences with metrics)

Multiple section flags can be combined: `cell orient --DISCOVERY --ABSTRACT .`

Default: `--DISCOVERY` (optimized for speed)

**XML output with both sections:**

```xml
<cell name="example_v1_01" work_complete="true" path="@this/example_v1_01/CELL.md">
  <discovery>One line summary</discovery>
  <abstract>
    Detailed multi-sentence paragraph with specific metrics,
    concrete findings, and quantified results...
  </abstract>
</cell>
```

### Relationship Flags

Relationship flags filter which parts of hierarchy to show:

- `--ancestors` - Parent, grandparent, etc. (where you are in tree)
- `--peers` - Siblings at same level (parallel work)
- `--children` - Immediate subordinate cells (delegated work)
- `--descendants` - All subordinate cells recursively with nested `<children>` sections (entire subtree)

Multiple relationship flags can be combined: `cell orient --ancestors --children .`

Note: `--descendants` implies `--children`, so `--descendants --children` is equivalent to just `--descendants`.

Default: `--ancestors --peers --children` (full vantage view)

### Path Argument (Required)

PATH argument is required and supports special symbols:

- `.` - CELL_ROOT (current work cell)
- `@project` - PROJECT_ROOT (auto-corrects to `@tree` with warning if they differ)
- `@project/subpath` - Explicit path from PROJECT_ROOT (e.g., `@project/auth_v1_01`)
- `@tree` - TREE_ROOT (treeroot.toml location, or PROJECT_ROOT if not found)
- `@tree/subpath` - Explicit path from TREE_ROOT (e.g., `@tree/cell_v1_01`)

If PATH is omitted, command exits with error code 1 and message: "Missing PATH argument"

**Auto-correction behavior**: When you run `cell orient @project` and `treeroot.toml` exists (making `@tree` different from `@project`), the command automatically uses `@tree` instead and shows a warning. This helps you discover the work cells hierarchy root naturally. Use `@project/explicit/path` for literal project root paths.

Note: The same `@project`, `@tree`, and `.` symbols are used in CELL.md file references (see File Reference Conventions in 02_work_cell_structure.md).

### Usage Examples

Common `cell orient` usage patterns:

```bash
# Quick overview (default)
cell orient .

# Detailed view with abstracts
cell orient --ABSTRACT .

# Both discovery and abstract together
cell orient --DISCOVERY --ABSTRACT .

# Only peers at my level
cell orient --peers .

# Ancestors and children with abstracts
cell orient --ABSTRACT --ancestors --children .

# Orient from project/work root (auto-corrects to @tree with warning if different)
cell orient @project

# Orient from work cells hierarchy root (explicit, no warning)
cell orient @tree

# Full work cells tree from work root
cell orient --descendants --DISCOVERY @tree

# Entire work cells hierarchy with detailed abstracts
cell orient --descendants --ABSTRACT @tree

# Orient from specific cell using explicit paths
cell orient @project/work_cells/testing_v1_01
cell orient @tree/testing_v1_01
```

Composable design eliminates need for separate tree/abstract commands.

### Why XML Format

XML structure provides:

- **Machine-parseable** - Easy extraction of specific cells or attributes
- **Unambiguous status** - `work_complete="true"` vs text-based status indicators
- **Direct file paths** - Cell paths include `/CELL.md` for immediate access
- **Context-rich** - Root expansion and tip embedded in output
- **Composable sections** - Mix `<discovery>` and `<abstract>` cleanly

## Command: cell validate

Command `cell validate PATH` checks work cell structure for correctness.

PATH argument is required. Use `.` for current directory.

Validates:

- Naming convention compliance (`{branch}_v{version}_{step}`)
- Required file present (CELL.md)
- CELL.md format correctness (YAML frontmatter with work_complete status, required sections in strict order: DISCOVERY, ABSTRACT, FULL_RATIONALE, FULL_IMPLEMENTATION, LOG)

### Path Argument (Required)

PATH argument is required and supports special symbols:

- `.` - CELL_ROOT (current work cell)
- `@project` - PROJECT_ROOT (first ancestral folder containing projectroot.toml)
- `@project/subpath` - Path relative to PROJECT_ROOT
- `@tree` - TREE_ROOT (treeroot.toml location, or PROJECT_ROOT if not found)
- `@tree/subpath` - Path relative to TREE_ROOT

If PATH is omitted, command exits with error code 1 and message: "Missing PATH argument"

### Usage Examples

```bash
# Validate current directory
cell validate .

# Validate project root
cell validate @project

# Validate work cells root
cell validate @tree

# Validate specific cell using paths
cell validate @project/work_cells/auth_v1_01
cell validate @tree/auth_v1_01
```

## Command: cell claude

Command `cell claude` launches new Claude instance for subagent work.

Usage:

```bash
cd testing_v1_01 && cell claude --window-title "testing_v1_01" \
  "Work in the current cell. Test JWT validation."
```

Opens new window with specified title and initial prompt. Subagent works independently in child cell with own work_complete status.

## Command: cell spec

Command `cell spec` outputs complete Context Cell framework specification in a single concatenated format, eliminating need for additional navigation.

### Options

- `--path PATH` - Directory containing files to concatenate (default: spec/context_cell_framework relative to script)
- `--project-root PATH` - Context Cell project root path to include in output (PROJECT_ROOT)
- `--help` - Show help message

Both `--path` and `--project-root` support `@project` path symbols.

### Path Symbols

Supports the same path symbols as `cell orient`:

- `@project` - PROJECT_ROOT (first ancestral folder containing projectroot.toml)
- `@project/subpath` - Path relative to PROJECT_ROOT
- `@tree` - TREE_ROOT (treeroot.toml location, or PROJECT_ROOT if not found)
- `@tree/subpath` - Path relative to TREE_ROOT

### Usage Examples

```bash
# Use default specification path
cell spec

# Output specification from custom path
cell spec --path /custom/spec/path

# Use @project symbol for paths
cell spec --path @project/spec/context_cell_framework

# Include project root context
cell spec --project-root @project

# Combine options
cell spec --path @project/custom/spec --project-root @project
```

## Command: cell expand

Command `cell expand` expands `@project` and `@tree` path symbols to absolute paths.

The `@project` symbol expands to PROJECT_ROOT (the directory containing `projectroot.toml`). The `@tree` symbol expands to TREE_ROOT (the directory containing `treeroot.toml`, or PROJECT_ROOT if treeroot.toml doesn't exist). This command converts symbolic paths to absolute paths for use in scripts and commands.

Paths without `@project` or `@tree` symbols pass through unchanged, making it safe to use with any path.

### Path Formats

Input and output formats:

- `@project` → `/absolute/path/to/project/root`
- `@project/subpath` → `/absolute/path/to/project/root/subpath`
- `@tree` → `/absolute/path/to/work/root`
- `@tree/subpath` → `/absolute/path/to/work/root/subpath`
- `/absolute/path` → `/absolute/path` (unchanged)
- `relative/path` → `relative/path` (unchanged)

### Use Cases

This command is useful for:

- **Path normalization**: Convert symbolic paths to absolute paths
- **Cross-tool compatibility**: Some tools don't understand `@project` symbols
- **Complex path operations**: Build paths with shell parameter expansion
- **Script portability**: Write scripts that work from any directory

### Usage Examples

Common `cell expand` usage patterns:

```bash
# Expand @project to absolute path
cell expand @project
# Output: /absolute/path/to/project/root

# Expand @tree to absolute path
cell expand @tree
# Output: /absolute/path/to/work/root

# Expand @project/subpath
cell expand @project/foo/bar
# Output: /absolute/path/to/project/root/foo/bar

# Expand @tree/subpath
cell expand @tree/cell_v1_01
# Output: /absolute/path/to/work/root/cell_v1_01

# Navigate using expansion
cd $(cell expand @project/auth_v1_01)
cd $(cell expand @tree/cell_v1_01)

# Read files using expansion
cat $(cell expand @project/schemas/spec.json)
cat $(cell expand @tree/cell_v1_01/CELL.md)

# List directory using expansion
ls -la $(cell expand @tree)

# Use in find commands
find $(cell expand @project) -name "*.py"
find $(cell expand @tree) -name "CELL.md"

# Copy to expanded path
cp data.csv $(cell expand @tree/prep_v1_01/)

# Absolute paths pass through unchanged
cell expand /usr/local/bin
# Output: /usr/local/bin

# Relative paths pass through unchanged
cell expand relative/path
# Output: relative/path
```

### Exit Codes

- `0` - Success
- `1` - Error (no projectroot.toml found when expanding @project symbol, or missing path argument)

### Notes for AI Agents

When working with paths in CELL.md files, remember that file references use `@project/` and `@tree/` prefixes for root paths (see File Reference Conventions mentioned previously).

Use `cell expand` to convert these symbolic paths to absolute paths for shell commands and navigation:

```bash
# Get project root
cd $(cell expand @project)

# Get work root
cd $(cell expand @tree)

# Navigate to subpath
cd $(cell expand @project/auth_v1_01)
cd $(cell expand @tree/auth_v1_01)

# Use in any shell command
cat $(cell expand @project/schemas/spec.json)
cat $(cell expand @tree/cell_v1_01/CELL.md)
find $(cell expand @project) -name "*.py"
find $(cell expand @tree) -name "CELL.md"
```

The `@project` and `@tree` symbols are consistent across all Context Cell commands (`cell orient @project`, `cell orient @tree`, `cell validate @tree`) and CELL.md file references (`@project/path/to/file.ext`, `@tree/cell_v1_01/file.ext`).
