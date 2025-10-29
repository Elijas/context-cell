# Quick Reference

Consolidated cheat sheet for the Context Cell framework.

## Work Cell Naming

Format: `{branch}_v{version}_{step}`

Examples: `auth_v1_01`, `api_v2_03`, `data_prep_v1_01`

- **branch**: short, lowercase, underscores (e.g., `auth`, `input_validation`)
- **version**: v1, v2, v3 (increment for fundamental restart)
- **step**: 01, 02, 03 (sequential progress within version)

## Required Files

Every work cell must have `CELL.md` with:

```markdown
---
work_complete: true  # or false
---

# DISCOVERY
Single line describing the work

# ABSTRACT
Information-dense summary (5-10 sentences): objectives, approach, outcomes, results, blockers, next steps. Use specific metrics, concrete tech names, references, quantified results.

# FULL_RATIONALE
Why we're doing this: upstream requests, problem discovery, prior art, alternatives considered, strategic decisions.

# FULL_IMPLEMENTATION
What and how we're doing it: objective, dependencies, approach, implementation details, results, outputs, decisions, blockers, next steps.

# LOG
- 2025-01-01T00:00:00Z: Created work cell
- 2025-01-01T12:30:00Z: Completed initial implementation
```

Order is strict: YAML frontmatter → DISCOVERY → ABSTRACT → FULL_RATIONALE → FULL_IMPLEMENTATION → LOG

## Path Conventions

**CRITICAL: Always use explicit prefixes**

- `@root/path/to/file` - CELL_PROJECT_ROOT (project root marked by cellproject.toml)
- `./path/to/file` - WORK_CELL_ROOT (current work cell)
- `@root/other_cell_v1_01/_outputs/file.ext` - Another cell's outputs
- `./_outputs/result.csv` - Current cell's outputs

❌ WRONG: `schemas/spec.json` (bare path - ambiguous)
❌ WRONG: `/schemas/spec.json` (leading slash without @root - ambiguous)
✅ CORRECT: `@root/schemas/spec.json`
✅ CORRECT: `./_outputs/result.csv`

## Commands

```bash
# Orient - show work cell structure in XML format
cell orient .                                    # Quick overview (DISCOVERY)
cell orient --ABSTRACT .                         # Detailed view (ABSTRACT)
cell orient --descendants --ABSTRACT @root       # Full project tree

# Validate - check work cell correctness
cell validate .                                  # Validate current cell
cell validate @root                              # Validate project root

# Expand - convert @root symbols to absolute paths
cell expand @root                                # Get project root path
cd $(cell expand @root/auth_v1_01)              # Navigate to cell

# Spec - output complete framework specification
cell spec                                        # Output full spec
cell spec --project-root @root                   # Include project context

# Claude - launch subagent for delegated work
cd testing_v1_01 && cell claude --window-title "testing_v1_01" "Work in current cell"
```

## Workflow Patterns

**CONTINUE** - Increment step for sequential progress
```
auth_v1_01 → auth_v1_02 → auth_v1_03
```

**RESTART** - Increment version for fresh start
```
auth_v1_03 → auth_v2_01
```
Add DETAILED_DEPRECATION_POSTMORTEM to old version explaining why it failed and what v2 should do differently.

**DELEGATE** - Create nested cell for subagent
```
auth_v1_01/testing_v1_01
```
Launch with: `cd testing_v1_01 && cell claude --window-title "testing_v1_01" "..."`

**INDEPENDENT** - Create new parallel branch
```
Start api_v1_01 while working on auth_v1_03
```

## File Organization

```
work_cell_v1_01/
├── CELL.md              # Required: work cell documentation
├── _outputs/            # Deliverables for other cells/humans
├── script.py            # Working files (root directory)
└── notebook.ipynb       # Working files (root directory)
```

Only files intended for consumption outside the cell go in `_outputs/`.

## Workflow Steps

1. **ORIENT_STEP**: Run `cell orient .` to understand context
2. **NAVIGATE_STEP**: `cd` to target work cell
3. **START_STEP**: Create or enter work cell
4. **WORK_STEP**: Make changes, update CELL.md periodically
5. **UPDATE_STEP**: Update CELL.md, set `work_complete: true` when done
6. **CREATE_STEP**: Create new work cell for next phase

## Key Principles

- ABSTRACT is compressed (5-10 sentences), FULL_* sections are detailed
- work_complete status is self-declared (true = work accomplished)
- Path prefixes (@root/ and ./) are mandatory, never use bare paths
- LOG uses ISO 8601 timestamps: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
