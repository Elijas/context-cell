# Issue: Undocumented `_bootstrap/` folder pattern

## Observed Usage

Found in production work cells at multiple levels (parent: `project_v1_01/_bootstrap/`, child: `feature_v1_01/_bootstrap/`).

**Pattern**: `_bootstrap/` directory contains a `prompt.md` file with initial setup instructions for creating the work cell:
- Instructions for what the cell should document
- Boundaries and scope definitions
- Parent-child relationship guidance
- Requirements and structural expectations
- References to source materials or prior work

**Usage in CELL.md**: Referenced primarily in FULL_RATIONALE and definition clarification work:
- `../_bootstrap/prompt.md` - cited to understand original intent
- Used when clarifying scope: "Original prompt ambiguity (../_bootstrap/prompt.md lines 12-13)"
- Helps prevent scope creep by documenting initial constraints

**Example content**:
```markdown
create a workcell whose only purpose is to describe the project for any kind of work that will
  be done on it

  this was done pretty well in /path/to/prior/work

  with MANIFEST.md being an earlier version of the CELL.md system

  DONT go into other_feature_v4, it's out of scope
```

## Philosophy

**`_bootstrap/` documents the "creation context" of the work cell**:
- Why this cell was created (original prompt/request)
- What it was intended to accomplish
- What constraints or boundaries were established
- How it fits into parent-child hierarchy

**Value proposition**:
1. **Intent preservation**: Future readers understand why cell exists, not just what it contains
2. **Scope enforcement**: Original boundaries prevent feature creep during execution
3. **Retrospective clarity**: Weeks/months later, understand the original ask vs what evolved
4. **Handoff documentation**: When subagents/humans take over, they see the initiating context

**Relationship to CELL.md**:
- `_bootstrap/prompt.md` = "the ask" (what someone requested)
- `CELL.md` = "the response" (what was actually done, how, and why)
- Bootstrap is static (doesn't change after creation)
- CELL.md is dynamic (evolves as work progresses)

## Recommendation

**Consider as human best practice, NOT as framework requirement**.

**Rationale for exclusion from framework**:
1. **Human-centric pattern**: Primarily valuable for humans organizing their own work cells with custom prompts
2. **Not universally applicable**: Many cells are created organically without formal "bootstrap" prompts
3. **Redundant with FULL_RATIONALE**: The "why this cell exists" context should already be in FULL_RATIONALE section
4. **Adds cognitive overhead**: Another optional folder for agents to understand/manage
5. **Limited agent utility**: Agents don't typically need to reference bootstrap prompts during execution

**Rationale for documenting as best practice**:
1. **Solves real problem**: Helps humans track complex delegation chains across subagents
2. **Already in use**: Demonstrates value in production scenarios
3. **Low cost when needed**: Simple to create (one markdown file)
4. **Optional pattern**: Users can adopt without framework changes

**Proposed documentation approach**:

Add to hypothetical "Best Practices" or "Advanced Patterns" documentation (not core spec):

```markdown
## Bootstrap Prompts (Human Pattern)

When creating work cells through complex prompt chains or delegation, consider preserving the original prompt in `_bootstrap/prompt.md`:

```
work_cell_v1_01/
├── _bootstrap/
│   └── prompt.md          # Original prompt that created this cell
├── CELL.md                # Cell documentation (includes FULL_RATIONALE)
└── ...
```

This helps future context-switching by documenting:
- Original request or problem statement
- Scope boundaries ("don't include X")
- References to prior work or templates
- Relationship to parent cell's objectives

**Note**: This is a human organizational pattern, not a framework requirement. CELL.md's FULL_RATIONALE section should still document why the cell exists—bootstrap is supplementary context about the creation process itself.
```

**AI agent guidance**: Agents don't need to create or maintain `_bootstrap/` folders. If they exist, agents can reference them for context (e.g., "original prompt specified X boundary") but should prioritize CELL.md content as authoritative.
