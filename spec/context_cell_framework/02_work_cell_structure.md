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

## Project Root Marker

Project root (CELL_PROJECT_ROOT) is marked by `cellproject.toml` file at repository root. This file is empty and serves only as a boundary marker for tools to locate the project root.

## File Organization

File organization within work cell:

- **`_outputs/`** - Deliverables for consumption by other cells, humans, or external systems (modules, datasets, reports, APIs, compiled artifacts)
- **Root directory** - Working files (notebooks, debug scripts, scratch code)

Only files intended for consumption outside the cell belong in `_outputs/`.

## File Reference Conventions

When referencing files in CELL.md, use explicit prefixes to distinguish between CELL_PROJECT_ROOT and WORK_CELL_ROOT.

**Path Format:**

- **CELL_PROJECT_ROOT**: `@root/path/to/file.ext` - ALWAYS use `@root/` prefix for project root paths
- **WORK_CELL_ROOT**: `./path/to/file.ext` - ALWAYS use `./` prefix for current cell paths
- **With line numbers**: `@root/path/file.py:15-25` or `./file.py:15-25`
- **With sections**: `@root/path/file.md#section-name` or `./file.md#section-name`

**CRITICAL: Never use bare paths or paths starting with just `/`**

- ❌ WRONG: `schemas/spec.json` (bare path - ambiguous)
- ❌ WRONG: `/schemas/spec.json` (leading slash without `@root` - ambiguous, could mean filesystem root)
- ✅ CORRECT: `@root/schemas/spec.json` (explicit project root)
- ✅ CORRECT: `./_outputs/result.csv` (explicit cell root)

**Common patterns:**

- `@root/other_cell_v1_01/_outputs/file.ext` - Another cell's outputs
- `@root/schemas/spec.json` - Project schemas or documentation
- `./_outputs/result.csv` - Current cell's outputs
- `./script.py` - Current cell's working files

**Examples:**

```markdown
# In ABSTRACT or FULL_IMPLEMENTATION sections:

Built recommendation system using collaborative filtering
(see `./_outputs/model.pkl` and `./_outputs/metrics.json`).

Implemented token validation per `@root/schemas/jwt_spec.json#claims`
specification. Core validation logic adapted from
`@root/auth_v1_01/_outputs/validator.py:45-67`.

Dataset stats available in `./_outputs/dataset_stats.csv`. Preprocessing
approach based on `@root/docs/data_guidelines.md#normalization`.
```

**Rationale:**

- Explicit `@root/` and `./` prefixes eliminate all ambiguity
- `@root` convention aligns with `cell orient @root` command syntax
- Prevents confusion with filesystem absolute paths (which start with `/` on Unix)
- Root-relative paths remain valid if work cells are moved or reorganized
- Line numbers and sections provide precise context for future reference
