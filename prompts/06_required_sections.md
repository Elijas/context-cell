# Required Sections for AI Agents

## The Five Sections

Every CHECKPOINT.md MUST have these sections in this EXACT order:

```markdown
# STATUS
# HARNESS
# CONTEXT
# MANIFEST
# LOG
```

**All uppercase. Level-1 headers. Exact spelling.**

## What Goes in Each Section

### # STATUS

**Purpose:** Current state and success criteria

**Must include:**
- Context recap (what's this about?)
- Success criteria (how do I know I'm done?)
- Exit conditions (when do I stop?)
- Risks/blockers (what's blocking or risky?)

**Update when:** State changes, blockers discovered, scope shifts

### # HARNESS

**Purpose:** How to verify the work

**Must include:**
- Exact commands to run
- Expected outputs
- What passing looks like

**Update when:** Before starting BUILD stage, when verification approach changes

**Critical:** Define this BEFORE you build anything.

### # CONTEXT

**Purpose:** Why you made decisions

**Must include:**
- Decisions made
- Alternatives considered
- Rationale for choices

**Update when:** Making significant decisions, choosing between approaches

### # MANIFEST

**Purpose:** What you created and depend on

**Must include (in order):**

1. **MANIFEST LEDGER** (first!)
```markdown
## MANIFEST LEDGER

| Name | Path | Purpose |
|------|------|---------|
| output.py | ::THIS/ARTIFACTS/output.py | Main module |
```

2. **Dependencies**
```markdown
## Dependencies

### CHECKPOINT DEPENDENCIES
- ::WORK/other_v1_02/CHECKPOINT.md (LIFECYCLE: active, VALID: true)

### SYSTEM DEPENDENCIES
- Python 3.11+
- PostgreSQL
```

**Update when:** Creating artifacts, discovering dependencies

**Critical:** Use rooted paths everywhere.

### # LOG

**Purpose:** Timestamped history

**Format:**
```markdown
## LOG

**2025-11-03T14:30:00Z** - [Claude] Created CHECKPOINT
- Initial setup from user directive

**2025-11-03T15:45:00Z** - [Claude] Ran harness
- All tests passed
- See ::THIS/LOGS/harness_20251103_154500.log
```

**Update when:** Every significant action
- Creating CHECKPOINT
- Major decisions
- Running harness
- Discovering blockers
- Closing CHECKPOINT

**Use ISO 8601 UTC timestamps:** `YYYY-MM-DDTHH:MM:SSZ`

## Common Mistakes

❌ **Don't do this:**
- Skip sections
- Wrong order
- Lowercase headers (`# status`)
- Missing MANIFEST LEDGER
- No timestamps in LOG
- Relative paths in MANIFEST

✅ **Do this:**
- All five sections present
- Exact order
- Uppercase headers (`# STATUS`)
- MANIFEST LEDGER first in MANIFEST
- ISO 8601 timestamps
- Rooted paths everywhere

## Quick Template

```markdown
---
VALID: false
LIFECYCLE: active
---

# STATUS

## Context Recap
[What's this about?]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Exit Conditions
[When to stop]

## Risks and Blockers
[None currently / Document blockers]

# HARNESS

## Verification Commands
```bash
command1
command2
```

## Expected Outputs
[What passing looks like]

# CONTEXT

## Decisions Made
[Key choices]

## Alternatives Considered
[Other options and why not chosen]

# MANIFEST

## MANIFEST LEDGER

| Name | Path | Purpose |
|------|------|---------|
| (stub) | (stub) | (stub) |

## Dependencies

### CHECKPOINT DEPENDENCIES
[None / List with rooted paths]

### SYSTEM DEPENDENCIES
[None / List requirements]

# LOG

**YYYY-MM-DDTHH:MM:SSZ** - [Actor] Created CHECKPOINT
- Initial action
```

## Validation

Before setting VALID: true, run:
```bash
acft validate ::THIS
```

This checks:
- All five sections present
- Correct order
- Proper headers
- Rooted paths valid
- MANIFEST LEDGER populated
