# Bite 25: Quick Reference (Your ACF Cheat Sheet)

You've learned the complete framework! Here's a **quick reference** to keep handy.

## Core File Structure

```
project/
├── checkpoints_project.toml    # Marks project root (::PROJECT/)
└── work/
    ├── checkpoints_work.toml   # Marks work root (::WORK/)
    ├── checkpoints_events.log  # Event stream (optional)
    └── auth_v1_01/             # A CHECKPOINT
        ├── CHECKPOINT.md       # The contract (required)
        ├── ARTIFACTS/          # Deliverables (create when ready)
        └── STAGE/              # Temporary parking (optional)
```

## Required Frontmatter

```yaml
---
VALID: false                    # true|false (handoff ready?)
LIFECYCLE: active               # active|superseded|archived
---
```

## Optional Frontmatter

```yaml
SIGNAL: pass                    # pass|fail|blocked|pending
DELEGATE_OF: ::WORK/parent      # For delegates
SUPERSEDES: ["::WORK/old"]      # For consolidation
TAGS: ["spike", "urgent"]       # Categories
OWNER: agent-name               # Responsibility
```

## Required Sections (Must Be In This Order)

1. **STATUS** - Current state, goals, success criteria, open questions
2. **HARNESS** - 5-10 sentence executive summary for fresh agents
3. **CONTEXT** - Why this approach, alternatives considered, decisions
4. **MANIFEST** - LEDGER + harness commands + dependencies
5. **LOG** - Chronological timeline with ISO 8601 timestamps

## Essential Commands

```bash
# Create
acft new branch_v1_01

# Inspect
acft orient ::THIS
acft orient ::WORK/auth_v1_02 --sections HARNESS,MANIFEST

# Validate
acft validate ::THIS
acft manifest --mode full

# Verify
acft verify --record

# Close
acft close --status true --signal pass
acft close --status false --signal blocked --message "Waiting for credentials"

# Paths
acft expand ::PROJECT/src/app.py
```

## The Five-Stage Workflow

1. **PREPARE** - Define "How will we know this works?" before coding
2. **SPECIFY** - Design harness, document dependencies
3. **BUILD** - Implement while keeping contract current
4. **VERIFY** - Run harness, record outcomes
5. **HANDOFF** - Complete contract, set VALID:true only when ready

## Rooted Paths (Always Use These)

- `::PROJECT/` - Repository root (marked by checkpoints_project.toml)
- `::WORK/` - CHECKPOINT work root (marked by checkpoints_work.toml)
- `::THIS/` - Current CHECKPOINT directory

**Never use:** `./`, `../`, or bare paths like `ARTIFACTS/file.py`

## Naming Convention

```
{branch}_v{version}_{step}

Examples:
- auth_v1_01 → auth_v1_02 → auth_v1_03  (increment step)
- auth_v1_03 → auth_v2_01               (bump version = restart)
```

## When Can I Set VALID:true?

Only when ALL are true:
- ✓ Harness has run clean (SIGNAL: pass) OR credible blocker documented
- ✓ MANIFEST LEDGER populated with rooted paths
- ✓ All required sections complete and current
- ✓ Fresh agent can resume without reverse-engineering or asking questions
- ✓ `acft validate ::THIS` passes

## LOG Format

```markdown
# LOG
- 2025-02-10T14:32:00Z - Created CHECKPOINT for auth implementation
- 2025-02-10T16:45:00Z - Harness passed, all tests green
- 2025-02-10T17:00:00Z - Set VALID:true, ready for handoff
```

Always use ISO 8601 UTC timestamps.

## Succession Patterns

**Linear succession (continue work):**
```
auth_v1_01 → auth_v1_02
- Old: LIFECYCLE:superseded, VALID:false
- New: Reference old in STATUS
```

**Delegation (parallel sub-task):**
```
auth_v1_02 spawns parse_tokens_v1_01
- Parent: LIFECYCLE:active (waiting)
- Child: DELEGATE_OF: ::WORK/auth_v1_02
- Cross-link in both LOGs
```

## MANIFEST Structure

```markdown
# MANIFEST

## MANIFEST LEDGER
- `file.py` - ::THIS/ARTIFACTS/file.py - One-line purpose
- `test.py` - ::THIS/ARTIFACTS/test.py - One-line purpose

## Harness
Commands to run, expected outcomes

## Dependencies

### CHECKPOINT DEPENDENCIES
- ::WORK/other_v1_01 - LIFECYCLE:active, VALID:true - Purpose

### SYSTEM DEPENDENCIES
- PostgreSQL 14+ - Available, connected - Purpose
```

## The 13 Failure Modes

1. Validation Theater - Setting VALID:true without running harness
2. Goal Fog - No clear success criteria
3. Dependency Fog - Dependencies not documented
4. History Drift - Context only in ancestors
5. Scope Shock - Midstream changes not logged
6. (See Bite 13 for complete list)

## Three North Star Principles

1. **Harness-first** - Design verification before implementation
2. **Self-contained** - Fresh agent can resume without asking
3. **Low-friction** - Minimal but strict rules, everything else optional

## Blocker Contract Elements

When SIGNAL:blocked, document:
- **What:** Specific blocking issue
- **Who:** Owner/team responsible
- **When:** Target date or milestone
- **Remediation:** Next steps when unblocked

## One Final Insight

**ACF is a contract system, not a process prescription.**

The framework tells you **what to document**, not **how to work**. Use it to make your work:
- **Resumable** - Fresh agents can pick up where you left off
- **Verifiable** - Harness proves it works
- **Trustworthy** - VALID:true means something

---

**You now understand the Agent Checkpoints Framework!**

Go create self-contained contracts that let agents (human or AI) hand off work with confidence.
