# CELL.md Format Specification

## Purpose and Authority

This file is the authoritative specification for CELL.md format. All CELL.md files must follow the structure and requirements defined here.

## YAML Frontmatter Structure

CELL.md begins with YAML frontmatter containing work completion status:

- `work_complete: true` - Work cell has completed the work it set out to accomplish
- `work_complete: false` - Work is still in progress or not yet started

Self-declared status indicating whether the work described in CELL.md has been completed. Uses standard YAML frontmatter syntax for machine-parseable metadata.

## Required Document Structure

CELL.md has required structure:

```markdown
---
work_complete: false
---

# DISCOVERY

Single line describing the work

# ABSTRACT

Information-dense summary: objectives, approach, expected outcomes, what was done, how, results, blockers, next steps.
Use specific metrics, concrete tech names, references, quantified results.
Typically 5-10 sentences; fewer if trivial, more if complex.

# FULL_RATIONALE

Detailed explanation of where this work came from, why it exists, and the reasoning that led to its creation.
Common subsections: Upstream Request, Problem Discovery, Prior Art, Alternatives Considered, Strategic Decisions, Why This Cell Exists.

# FULL_IMPLEMENTATION

Full detailed technical context about what was done and how.
Common subsections: Objective, Dependencies, Approach, Implementation Details, Results, Outputs, Decisions, Blockers, Next Steps.

# LOG

- 2025-01-01T00:00:00Z: Created work cell
```

Six elements in strict order: YAML frontmatter with work_complete status, DISCOVERY (one line), ABSTRACT (information-dense summary), FULL_RATIONALE (why we're doing this), FULL_IMPLEMENTATION (what and how we're doing it), LOG (timestamped). This order must not be changed.

## DISCOVERY Section Requirements

DISCOVERY section contains a single line describing the work with no subsections or structure. Just plain text description.

Example: `Implement JWT authentication middleware`

## ABSTRACT Section Requirements

ABSTRACT section is an information-dense summary: objectives, approach, expected outcomes, what was done, how, results, blockers, next steps.

Use specific metrics, concrete tech names, references, quantified results.
Typically 5-10 sentences; fewer if trivial, more if complex.

Should reference files using path conventions (`./_outputs/` for WORK_CELL_ROOT, `@root/` for CELL_PROJECT_ROOT), not embed data directly.

Example: "Built ML recommendation system using hybrid collaborative + content-based filtering achieving 18.1% precision@10 on 45k users. Implemented item-based k-NN with cosine similarity, weighted interactions (click=1, save=2, share=3). Dataset: 2.1M events July-Sept 2024 with 99.6% sparsity (see `./_outputs/dataset_stats.csv`). ~50ms response time, 85% Redis cache hit. Currently tuning hyperparameters targeting 20%+ precision@10."

## FULL_IMPLEMENTATION Section Requirements

FULL_IMPLEMENTATION section contains full detailed technical context about what was done and how.

Common subsections: Objective, Dependencies, Approach, Implementation Details, Results, Outputs, Decisions, Blockers, Next Steps.

Be thorough, don't hold back on volume. This is where the "what and how we're doing it" context goes.

## FULL_RATIONALE Section Requirements

FULL_RATIONALE section contains detailed explanation of where this work came from, why it exists, and the reasoning that led to its creation.

Common subsections: Upstream Request, Problem Discovery, Prior Art, Alternatives Considered, Strategic Decisions, Why This Cell Exists.

Be thorough, don't hold back on volume. This is where the "why we're doing this" context goes.

## LOG Section Requirements

LOG section contains timestamped log entries tracking major milestones, blockers, and approach changes.

Format: `- YYYY-MM-DDTHH:MM:SSZ: Description`

Generate timestamps with: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Example:

```markdown
# LOG

- 2025-01-01T00:00:00Z: Created work cell
- 2025-01-01T12:30:00Z: Completed initial implementation
- 2025-01-01T18:45:00Z: Blocked on dependency X, waiting for resolution
```

## Version Deprecation Protocol

When restarting with new version, add detailed deprecation post-mortem to old version's CELL.md:

```markdown
# DETAILED_DEPRECATION_POSTMORTEM

## Why v1 Failed

- Dead end: approach X didn't handle Y
- Blocker: Z required complete redesign

## What v2 Should Do Differently

- Use approach A instead of X
- Account for Y upfront
```

Like FULL_IMPLEMENTATION and FULL_RATIONALE, this is freeform and detailed - be thorough about what went wrong and why. Documents lessons learned for future reference.
