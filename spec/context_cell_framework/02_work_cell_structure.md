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

- **`cellproject.toml`** - Marks PROJECT_ROOT at project/repository root. Required.
- **`celltree.toml`** - Marks TREE_ROOT where work cells hierarchy begins. Optional; if absent, TREE_ROOT defaults to PROJECT_ROOT.

Both files are empty and serve only as boundary markers for tools to locate roots.

**When to use `celltree.toml`:**

Use when work cells are nested deep in project structure (e.g., `project/work_cells/`) and you want shorter `@tree/` paths instead of long `@project/work_cells/` paths. This separates project codebase references (`@project/src/main.py`) from work cell references (`@tree/cell_v1_01/`).

## File Organization

File organization within work cell:

- **`_outputs/`** - Deliverables for consumption by other cells, humans, or external systems (modules, datasets, reports, APIs, compiled artifacts)
- **Root directory** - Working files (notebooks, debug scripts, scratch code)

Only files intended for consumption outside the cell belong in `_outputs/`.

## File Reference Conventions

When referencing files in CELL.md, use explicit prefixes to distinguish between path roots.

**Path Format:**

- **PROJECT_ROOT**: `@project/path/to/file.ext` - Use for project codebase files, schemas, documentation, configs
- **TREE_ROOT**: `@tree/path/to/file.ext` - Use for referencing other work cells and their outputs
- **CELL_ROOT**: `@this/path/to/file.ext` - Use for files within the current work cell
- **With line numbers**: `@project/path/file.py:15-25`, `@tree/cell_v1_01/file.py:15-25`, or `@this/file.py:15-25`
- **With sections**: `@project/path/file.md#section-name`, `@tree/cell_v1_01/CELL.md#abstract`, or `@this/file.md#section-name`

**CRITICAL: Never use bare paths or paths starting with just `/`**

- ❌ WRONG: `schemas/spec.json` (bare path - ambiguous)
- ❌ WRONG: `/schemas/spec.json` (leading slash without `@project` - ambiguous, could mean filesystem root)
- ✅ CORRECT: `@project/schemas/spec.json` (explicit project root)
- ✅ CORRECT: `@tree/cell_v1_01/_outputs/data.csv` (explicit work root, when celltree.toml exists)
- ✅ CORRECT: `@this/_outputs/result.csv` (explicit cell root)

**Usage by Root Type:**

**@project** - Project codebase and resources (non-work-cell files):
- `@project/src/main.py` - Source code
- `@project/schemas/spec.json` - API schemas
- `@project/docs/architecture.md` - Documentation
- `@project/config/settings.yaml` - Configuration files

**@tree** - Work cells and their outputs:
- `@tree/other_cell_v1_01/_outputs/data.csv` - Another cell's outputs (when using celltree.toml)
- `@tree/auth_v1_03/CELL.md` - Another cell's documentation
- `@project/work_cells/cell_v1_01/_outputs/data.csv` - Another cell (when not using celltree.toml)

**@this** - Current work cell files:
- `@this/_outputs/results.csv` - Current cell's outputs
- `@this/notebook.ipynb` - Current cell's working files

**Real-World Example:**

```markdown
# In ABSTRACT or FULL_IMPLEMENTATION sections:

Built recommendation system using collaborative filtering
(see `@this/_outputs/model.pkl` and `@this/_outputs/metrics.json`).

Implemented token validation per `@project/schemas/jwt_spec.json#claims`
specification (project schema). Preprocessing used data from
`@tree/data_prep_v1_02/_outputs/clean_dataset.csv` (another work cell's output).

Core validation logic adapted from `@tree/auth_v1_01/_outputs/validator.py:45-67`
(previous work cell). Dataset stats available in `@this/_outputs/dataset_stats.csv`
(current cell output).

Preprocessing approach based on `@project/docs/data_guidelines.md#normalization`
(project documentation).
```

**Key Pattern**: `@project` for codebase resources, `@tree` for work cell outputs, `@this` for current cell files.

**Rationale:**

- Explicit `@project/`, `@tree/`, and `@this/` prefixes eliminate all ambiguity
- `@project` and `@tree` conventions align with command syntax (`cell orient @project`, `cell expand @tree`)
- `@tree` paths remain short even when cells are deeply nested
- Prevents confusion with filesystem absolute paths (which start with `/` on Unix)
- Root-relative paths remain valid if work cells are moved or reorganized
- Line numbers and sections provide precise context for future reference
