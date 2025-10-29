# feature_001

Valid work cell passes all validation checks.

Valid work cell requirements:
- Name matches pattern
- Contains CELL.md
- Has valid YAML frontmatter
- Contains all required sections in order
- DISCOVERY within first 12 lines

Output:
```
✓ {cell_name}/ - Valid work cell
```

Exit code: 0

**Test**: Create valid work cell. Run `cell validate .` from inside. Verify success.

# feature_002

Directory with invalid name fails validation.

Invalid names:
- Contains uppercase: `Auth_v1_01`
- Contains dashes: `auth-v1-01`
- Single digit step: `auth_v1_1`
- Starts with underscore: `_auth_v1_01`

Output:
```
✗ {cell_name}/ - Invalid naming convention: must match {branch}_v{version}_{step}
```

Exit code: 1

**Test**: Create directories with invalid names. Verify error message.

# feature_003

Directory without CELL.md fails validation.

Output:
```
✗ {cell_name}/ - Missing required file: CELL.md
```

Exit code: 1

**Test**: Create work cell directory without CELL.md. Verify error.

# feature_004

CELL.md without YAML frontmatter fails validation.

Output:
```
✗ {cell_name}/ - Missing YAML frontmatter
```

Exit code: 1

**Test**: Create CELL.md starting with `# DISCOVERY` (no frontmatter). Verify error.

# feature_005

YAML frontmatter without work_complete field fails validation.

Example invalid frontmatter:
```markdown
---
other_field: value
---
```

Output:
```
✗ {cell_name}/ - Missing work_complete field in frontmatter
```

Exit code: 1

**Test**: Create CELL.md with frontmatter but no work_complete field. Verify error.

# feature_006

work_complete field with invalid value fails validation.

Invalid values: `yes`, `no`, `1`, `0`, `True`, `False`
Valid values: `true`, `false`

Output:
```
✗ {cell_name}/ - Invalid work_complete value: must be 'true' or 'false'
```

Exit code: 1

**Test**: Create CELL.md with `work_complete: yes`. Verify error.

# feature_007

CELL.md missing any required section fails validation.

Required sections: DISCOVERY, ABSTRACT, FULL_RATIONALE, FULL_IMPLEMENTATION, LOG

Output:
```
✗ {cell_name}/ - Missing required section: {SECTION_NAME}
```

Exit code: 1

**Test**: Create CELL.md without ABSTRACT section. Verify error.

# feature_008

CELL.md with sections in wrong order fails validation.

Correct order: DISCOVERY → ABSTRACT → FULL_RATIONALE → FULL_IMPLEMENTATION → LOG

Output:
```
✗ {cell_name}/ - Sections out of order: {SECTION_A} must appear before {SECTION_B}
```

Exit code: 1

**Test**: Create CELL.md with ABSTRACT before DISCOVERY. Verify error.

# feature_009

CELL.md with DISCOVERY section after line 12 fails validation.

Output:
```
✗ {cell_name}/ - DISCOVERY section must appear within first 12 lines (found at line {N})
```

Exit code: 1

**Test**: Create CELL.md with lots of comments, DISCOVERY on line 15. Verify error.

# feature_010

Work cell with multiple validation failures reports all errors.

Example output:
```
✗ invalid-name/ - Invalid naming convention: must match {branch}_v{version}_{step}
✗ invalid-name/ - Missing required section: LOG
```

Exit code: 1

**Test**: Create invalid cell with multiple issues. Verify all errors reported.

# feature_011

Command validates specified path, not current directory.

Usage:
```bash
cell validate path/to/work_cell
```

**Test**: Run from parent directory, validate child. Verify validation runs on child.

# feature_012

Command validates project root when path is `@project`.

Usage:
```bash
cell validate @project
```

Finds `projectroot.toml` and validates that directory.

**Test**: Run from nested directory with `@project`. Verify validates root.

# feature_013

Non-existent path produces error.

Output:
```
Error: Path does not exist: {path}
```

Exit code: 1

**Test**: Run `cell validate /nonexistent/path`. Verify error.

# feature_014

Using `@project` without projectroot.toml produces error.

Output:
```
Error: No projectroot.toml found in directory hierarchy
```

Exit code: 1

**Test**: Run `cell validate @project` from directory without projectroot.toml. Verify error.

# feature_015

Missing path argument produces error.

Output:
```
Error: Missing PATH argument
```

Exit code: 1

**Test**: Run `cell validate` with no arguments. Verify error code 1 and error message.
