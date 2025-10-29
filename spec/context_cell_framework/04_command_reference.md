# Command Reference

## Command: cell orient

Command `cell orient PATH` shows work cell structure from specified location's perspective in structured XML format. Composable command using section and relationship flags.

PATH argument is required. Use `.` for current directory.

Default behavior: `cell orient .` shows vantage-based view with DISCOVERY sections (one-line summaries).

### XML Output Format

Output is structured XML for easy parsing by LLMs and tools:

```xml
<orient path="@root/cell_v1_01" expanded="/abs/path/to/cell" root="@root → /abs/path/to/root">
  <ancestry>
    <cell name="parent_v1_01" work_complete="true" path="@root/parent_v1_01/CELL.md">
      <discovery>One line summary</discovery>
    </cell>
  </ancestry>

  <peers>
    <cell name="sibling_v1_01" work_complete="false" path="@root/sibling_v1_01/CELL.md">
      <discovery>One line summary</discovery>
    </cell>
  </peers>

  <children>
    <cell name="child_v1_01" work_complete="true" path="./child_v1_01/CELL.md">
      <discovery>One line summary</discovery>
    </cell>
  </children>
</orient>
```

**Root-level attributes:**
- `path` - Symbolic path using `@root/` or `./` prefixes
- `expanded` - Absolute filesystem path to current location
- `root` - Shows what `@root` expands to (e.g., "@root → /abs/path")

**Cell attributes:**
- `name` - Work cell directory name
- `work_complete` - Boolean status ("true" or "false")
- `path` - Always ends with `/CELL.md` for direct file access

**Hierarchy sections:**
- `<ancestry>` - Parent cells up to execution boundary
- `<peers>` - Siblings at same level
- `<children>` - Immediate subordinate cells

### Section Flags

Section flags control which CELL.md sections to display within each `<cell>` tag:

- `--DISCOVERY` - One-line summaries in `<discovery>` tags (fast)
- `--ABSTRACT` - Full paragraphs in `<abstract>` tags (detailed, 5-10 sentences with metrics)

Multiple section flags can be combined: `cell orient --DISCOVERY --ABSTRACT .`

Default: `--DISCOVERY` (optimized for speed)

**XML output with both sections:**
```xml
<cell name="example_v1_01" work_complete="true" path="./example_v1_01/CELL.md">
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
- `--descendants` - All subordinate cells recursively (entire subtree)

Multiple relationship flags can be combined: `cell orient --ancestors --children .`

Default: `--ancestors --peers --children` (full vantage view)

### Path Argument (Required)

PATH argument is required and supports special symbols:

- `.` - WORK_CELL_ROOT (current work cell)
- `@root` - CELL_PROJECT_ROOT (first ancestral folder containing cellproject.toml)
- `@root/subpath` - Path relative to CELL_PROJECT_ROOT (e.g., `@root/cell_v1_01`)

If PATH is omitted, command exits with error code 1 and message: "Missing PATH argument"

Note: The same `@root` and `.` symbols are used in CELL.md file references (see File Reference Conventions in 02_work_cell_structure.md).

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

# Full project tree from root
cell orient --descendants --DISCOVERY @root

# Entire project with detailed abstracts
cell orient --descendants --ABSTRACT @root

# Orient from specific cell using @root path
cell orient @root/testing_v1_01
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

- `.` - WORK_CELL_ROOT (current work cell)
- `@root` - CELL_PROJECT_ROOT (first ancestral folder containing cellproject.toml)
- `@root/subpath` - Path relative to CELL_PROJECT_ROOT

If PATH is omitted, command exits with error code 1 and message: "Missing PATH argument"

### Usage Examples

```bash
# Validate current directory
cell validate .

# Validate project root
cell validate @root

# Validate specific cell using @root path
cell validate @root/auth_v1_01
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
- `--project-root PATH` - Context Cell project root path to include in output (CELL_PROJECT_ROOT)
- `--help` - Show help message

Both `--path` and `--project-root` support `@root` path symbols.

### Path Symbols

Supports the same path symbols as `cell orient`:

- `@root` - CELL_PROJECT_ROOT (first ancestral folder containing cellproject.toml)
- `@root/subpath` - Path relative to CELL_PROJECT_ROOT

### Usage Examples

```bash
# Use default specification path
cell spec

# Output specification from custom path
cell spec --path /custom/spec/path

# Use @root symbol for paths
cell spec --path @root/spec/context_cell_framework

# Include project root context
cell spec --project-root @root

# Combine options
cell spec --path @root/custom/spec --project-root @root
```

## Command: cell expand

Command `cell expand` expands `@root` path symbols to absolute paths.

The `@root` symbol expands to CELL_PROJECT_ROOT (the directory containing `cellproject.toml`). This command converts symbolic paths to absolute paths for use in scripts and commands.

Paths without `@root` symbols pass through unchanged, making it safe to use with any path.

### Path Formats

Input and output formats:

- `@root` → `/absolute/path/to/project/root`
- `@root/subpath` → `/absolute/path/to/project/root/subpath`
- `/absolute/path` → `/absolute/path` (unchanged)
- `relative/path` → `relative/path` (unchanged)

### Use Cases

This command is useful for:

- **Path normalization**: Convert symbolic paths to absolute paths
- **Cross-tool compatibility**: Some tools don't understand `@root` symbols
- **Complex path operations**: Build paths with shell parameter expansion
- **Script portability**: Write scripts that work from any directory

### Usage Examples

Common `cell expand` usage patterns:

```bash
# Expand @root to absolute path
cell expand @root
# Output: /absolute/path/to/project/root

# Expand @root/subpath
cell expand @root/foo/bar
# Output: /absolute/path/to/project/root/foo/bar

# Navigate using expansion
cd $(cell expand @root/auth_v1_01)

# Read files using expansion
cat $(cell expand @root/schemas/spec.json)

# List directory using expansion
ls -la $(cell expand @root/foo/bar)

# Use in find commands
find $(cell expand @root) -name "CELL.md"

# Copy to expanded path
cp data.csv $(cell expand @root/prep_v1_01/)

# Absolute paths pass through unchanged
cell expand /usr/local/bin
# Output: /usr/local/bin

# Relative paths pass through unchanged
cell expand relative/path
# Output: relative/path
```

### Exit Codes

- `0` - Success
- `1` - Error (no cellproject.toml found when expanding @root symbol, or missing path argument)

### Notes for AI Agents

When working with paths in CELL.md files, remember that file references use `@root/` prefix for project root paths (see File Reference Conventions mentioned previously).

Use `cell expand` to convert these symbolic paths to absolute paths for shell commands and navigation:

```bash
# Get project root
cd $(cell expand @root)

# Navigate to subpath
cd $(cell expand @root/auth_v1_01)

# Use in any shell command
cat $(cell expand @root/schemas/spec.json)
find $(cell expand @root) -name "*.py"
```

The `@root` symbol is consistent across all Context Cell commands (`cell orient @root`, `cell validate @root`) and CELL.md file references (`@root/path/to/file.ext`).
