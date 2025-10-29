# Work Cell Structure and Organization

## Naming Convention

Work cells are folders with specific naming: `{branch}_v{version}_{step}`

Examples: `auth_v1_01`, `api_v2_03`, `data_prep_v1_01`

Components:

- **Branch**: short, lowercase, underscores for multi-word (e.g., `input_validation`, `auth`)
- **Version**: v1, v2, v3 (increment for fundamental rethinking/restart)
- **Step**: 01, 02, 03 (two digits, sequential progress within version)

## File Requirements

Every work cell contains exactly one required file:

- `CELL.md` - Core work cell document with YAML frontmatter (work_complete status), DISCOVERY, ABSTRACT, FULL_RATIONALE, FULL_IMPLEMENTATION, and LOG (detailed specification for each is described down below)

Optional:

- `_outputs/` - Directory containing deliverables for other cells or humans (create when needed)

## Project Root Markers

Two optional marker files define path roots:

- **`projectroot.toml`** - Marks PROJECT_ROOT at project/repository root. Required.
- **`treeroot.toml`** - Marks TREE_ROOT where work cells hierarchy begins. Optional; if absent, TREE_ROOT defaults to PROJECT_ROOT.

Both files are empty and serve only as boundary markers for tools to locate roots.

**When to use `treeroot.toml`:**

Use when work cells are nested deep in project structure (e.g., `project/work_cells/`) and you want shorter `@tree/` paths instead of long `@project/work_cells/` paths. This separates project codebase references (`@project/src/main.py`) from work cell references (`@tree/cell_v1_01/`).

## File Organization

File organization within work cell:

- **`_outputs/`** - Deliverables for consumption by other cells, humans, or external systems (modules, datasets, reports, APIs, compiled artifacts)
- **Root directory** - Working files (notebooks, debug scripts, scratch code)

Only files intended for consumption outside the cell belong in `_outputs/`.

## File Reference Conventions

When referencing files in CELL.md, use explicit prefixes to distinguish between path roots.

**Path Format:**

- **PROJECT_ROOT**: `@project/path/to/file.ext` - ALWAYS use `@project/` prefix for project root paths
- **TREE_ROOT**: `@tree/path/to/file.ext` - ALWAYS use `@tree/` prefix for work cells hierarchy paths (when treeroot.toml exists)
- **CELL_ROOT**: `@this/path/to/file.ext` - ALWAYS use `@this/` prefix for current cell paths
- **With line numbers**: `@project/path/file.py:15-25`, `@tree/cell_v1_01/file.py:15-25`, or `@this/file.py:15-25`
- **With sections**: `@project/path/file.md#section-name`, `@tree/cell_v1_01/CELL.md#abstract`, or `@this/file.md#section-name`

**CRITICAL: Never use bare paths or paths starting with just `/`**

- ❌ WRONG: `schemas/spec.json` (bare path - ambiguous)
- ❌ WRONG: `/schemas/spec.json` (leading slash without `@project` - ambiguous, could mean filesystem root)
- ✅ CORRECT: `@project/schemas/spec.json` (explicit project root)
- ✅ CORRECT: `@tree/cell_v1_01/_outputs/data.csv` (explicit work root, when treeroot.toml exists)
- ✅ CORRECT: `@this/_outputs/result.csv` (explicit cell root)

**Common patterns:**

- `@project/src/main.py` - Project codebase files
- `@project/schemas/spec.json` - Project schemas or documentation
- `@tree/other_cell_v1_01/_outputs/file.ext` - Another cell's outputs (when using treeroot.toml)
- `@project/work_cells/cell_v1_01/_outputs/file.ext` - Another cell's outputs (when not using treeroot.toml)
- `@this/_outputs/result.csv` - Current cell's outputs
- `@this/script.py` - Current cell's working files

**Examples:**

```markdown
# In ABSTRACT or FULL_IMPLEMENTATION sections:

Built recommendation system using collaborative filtering
(see `@this/_outputs/model.pkl` and `@this/_outputs/metrics.json`).

Implemented token validation per `@project/schemas/jwt_spec.json#claims`
specification. Preprocessing used data from
`@tree/data_prep_v1_02/_outputs/clean_dataset.csv`.

Core validation logic adapted from  `@tree/auth_v1_01/_outputs/validator.py:45-67`.
Dataset stats available in `@this/_outputs/dataset_stats.csv`.

Preprocessing approach based on `@project/docs/data_guidelines.md#normalization`.
```

**Rationale:**

- Explicit `@project/`, `@tree/`, and `@this/` prefixes eliminate all ambiguity
- `@project` and `@tree` conventions align with command syntax (`cell orient @project`, `cell expand @tree`)
- `@tree` paths remain short even when cells are deeply nested
- Prevents confusion with filesystem absolute paths (which start with `/` on Unix)
- Root-relative paths remain valid if work cells are moved or reorganized
- Line numbers and sections provide precise context for future reference
