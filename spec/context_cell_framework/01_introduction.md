# Context Cell Framework Introduction

## Framework Overview

Context Cell is a hierarchical work organization framework for AI agents. It uses versioned "work cells" (folders) with state synchronization to organize complex work into manageable, trackable units.

## Terminology Conventions

**Terminology**: Framework primitives use ALL CAPS to distinguish them from general prose (like legal documents use WHEREAS/THEREFORE). Examples: CELL.md, UP_TO_DATE, DISCOVERY, ABSTRACT, FULL_RATIONALE, FULL_IMPLEMENTATION, LOG, AGENTS.md.

**Path Roots**: Three distinct path roots are used throughout:
- **PROJECT_ROOT**: The project/codebase root marked by `cellproject.toml`, referenced as `@project/` in paths. Use for referencing project codebase files, schemas, documentation, and other non-work-cell resources.
- **TREE_ROOT**: The work cells hierarchy root marked by `celltree.toml` (optional marker; defaults to PROJECT_ROOT if absent), referenced as `@tree/` in paths. Use for referencing other work cells and their outputs.
- **CELL_ROOT**: The current work cell directory, referenced as `@this/` in paths. Use for referencing files within the current work cell.
