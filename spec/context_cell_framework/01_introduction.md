# Context Cell Framework Introduction

## Framework Overview

Context Cell is a hierarchical work organization framework for AI agents. It uses versioned "work cells" (folders) with state synchronization to organize complex work into manageable, trackable units.

## Terminology Conventions

**Terminology**: Framework primitives use ALL CAPS to distinguish them from general prose (like legal documents use WHEREAS/THEREFORE). Examples: CELL.md, UP_TO_DATE, DISCOVERY, ABSTRACT, FULL_RATIONALE, FULL_IMPLEMENTATION, LOG, AGENTS.md.

**Path Roots**: Two distinct path roots are used throughout:
- **CELL_PROJECT_ROOT**: The project root directory marked by `cellproject.toml`, referenced as `@root/` in paths
- **WORK_CELL_ROOT**: The current work cell directory, referenced as `./` in paths
