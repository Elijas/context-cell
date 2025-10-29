# context

`cell validate` checks work cell structure for correctness. Validates naming convention, required files, and CELL.md format compliance.

Usage:

```bash
cell validate PATH
```

Exits with code 0 if valid, code 1 if any validation fails.

# context

Command requires path argument:

```bash
cell validate .                    # Current directory
cell validate path/to/work_cell    # Specific directory
cell validate @project                # Project root
```

Path can be:

- `.` - Current directory
- `@project` - Project root (first ancestral folder containing projectroot.toml)
- `@project/subpath` - Path relative to PROJECT_ROOT
- Relative path (resolved from current working directory)
- Absolute path

If path is not a work cell directory, validation fails.

If path argument is omitted, exits with error code 1 and message: "Missing PATH argument"

# context

Work cell directory name must match pattern: `^[a-z][a-z0-9_]*_v[0-9]+_[0-9]{2}$`

Rules:

- Starts with lowercase letter
- Contains only lowercase letters, digits, underscores
- Has version marker: `_v` followed by digits
- Ends with two-digit step number

Valid examples:

- `auth_v1_01`
- `data_prep_v2_03`
- `user_api_v10_99`

Invalid examples:

- `Auth_v1_01` - uppercase letter
- `auth-v1-01` - contains dashes
- `auth_v1_1` - single digit step (must be `01`)
- `_auth_v1_01` - starts with underscore
- `authv101` - missing `_v` separator

Error message: "Invalid naming convention: must match {branch}_v{version}_{step}"

# context

Work cell must contain `CELL.md` file.

Validation checks:

- File exists at `{CELL_ROOT}/CELL.md`
- File is readable

Error message: "Missing required file: CELL.md"

# context

CELL.md must begin with YAML frontmatter containing `work_complete` status.

Valid frontmatter:

```markdown
---
work_complete: true
---
```

Or:

```markdown
---
work_complete: false
---
```

Validation rules:

- First line must be `---` (opening delimiter)
- Must contain line with `work_complete: true` or `work_complete: false`
- Must have closing `---` delimiter
- Frontmatter must appear before any other content

Error messages:

- "Missing YAML frontmatter"
- "Missing work_complete field in frontmatter"
- "Invalid work_complete value: must be 'true' or 'false'"

# context

CELL.md must contain all required sections in strict order:

1. `# DISCOVERY`
2. `# ABSTRACT`
3. `# FULL_RATIONALE`
4. `# FULL_IMPLEMENTATION`
5. `# LOG`

Validation rules:

- Each section heading must appear exactly as shown (case-sensitive)
- Sections must appear in this exact order
- All five sections must be present

Error messages:

- "Missing required section: {SECTION_NAME}"
- "Sections out of order: {SECTION_A} must appear before {SECTION_B}"

# context

DISCOVERY section must appear within first 12 lines of CELL.md.

Validation:

- Count lines from start of file
- Find line containing `# DISCOVERY`
- Line number must be ≤ 12

Error message: "DISCOVERY section must appear within first 12 lines (found at line {N})"

Rationale: Optimization for tools that read only first 12 lines when scanning multiple cells.

# context

Output format for validation results:

**When all validations pass**:

```
✓ {cell_name}/ - Valid work cell
```

Exit code: 0

**When validations fail**:

```
✗ {cell_name}/ - {error_message_1}
✗ {cell_name}/ - {error_message_2}
...
```

Exit code: 1

Each error is reported on a separate line with the cell name and specific error message.

# context

When path argument is `@project`, find project root by walking up directory tree.

Find root by walking up from current directory until:

- `projectroot.toml` found → use that directory as root
- Reached filesystem root → error: "No projectroot.toml found in directory hierarchy"

Then validate the root directory as a work cell.

# context

Exit with error code 1 and message if:

- Path argument is missing
- Path argument doesn't exist
- Path is not a directory
- No `projectroot.toml` found when using `@project`
- Any validation rule fails

Validation continues through all rules even if early checks fail (report all errors, not just first one).
