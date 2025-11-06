# Quick Reference for AI Agents

## Minimum Required Contract

```yaml
---
VALID: false
LIFECYCLE: active
---

# STATUS
[Current state, success criteria, open questions]

# HARNESS
[5-10 sentence summary, rooted paths to deliverables]

# CONTEXT
[Why this approach, alternatives considered]

# MANIFEST

## MANIFEST LEDGER
- `file` - ::THIS/ARTIFACTS/file - Purpose

## Harness
[Commands to verify]

## Dependencies
### CHECKPOINT DEPENDENCIES
[Upstream CHECKPOINTs]
### SYSTEM DEPENDENCIES
[External dependencies]

# LOG
- TIMESTAMP - Event description
```

## Critical Rules

**Frontmatter:**
- VALID: true|false (required)
- LIFECYCLE: active|superseded|archived (required)

**Sections (must be in this order):**
1. STATUS
2. HARNESS
3. CONTEXT
4. MANIFEST
5. LOG

**Paths:**
- Always rooted: ::PROJECT/, ::WORK/, ::THIS/
- Never: ./, ../, or bare paths

**LOG:**
- ISO 8601 UTC timestamps: 2025-02-10T14:32:00Z
- Chronological order

**VALID:true requires:**
- Harness ran (SIGNAL:pass) OR credible blocker
- MANIFEST LEDGER populated
- All sections complete
- Self-contained (fresh agent can resume)

## Command Reference

```bash
# Create
acft new branch_v1_01
acft new child_v1_01 --delegate-of ::WORK/parent_v1_01

# Inspect
acft orient ::THIS
acft orient ::WORK/path --sections HARNESS,MANIFEST --json

# Validate
acft validate ::THIS
acft manifest --mode full --emit

# Verify
acft verify --record  # Emits HARNESS_EXECUTED

# Close
acft close --status true --signal pass
acft close --status false --signal blocked --message "Reason"
acft close --lifecycle superseded --message "Superseded by ::WORK/new"

# Utilities
acft expand ::PROJECT/path
acft events tail --follow
```

## Decision Trees

### Can I set VALID:true?
```
Harness ran clean? → YES
MANIFEST LEDGER populated? → YES
All sections complete? → YES
Fresh agent can resume? → YES
  → SET VALID:true

Otherwise → KEEP VALID:false
```

### How to continue work?
```
Same task, next step? → Successor (increment step)
Same task, restart? → Successor (bump version)
Sub-task to delegate? → Delegate (new branch)
```

### What goes where?
```
Deliverables → ARTIFACTS/
Raw inputs → STAGE/ (temporary)
Documentation → CHECKPOINT.md sections
Other CHECKPOINT outputs → Link via rooted paths (never copy)
```

## Naming Pattern

```
{branch}_v{version}_{step}

auth_v1_01 → auth_v1_02  (increment step)
auth_v1_03 → auth_v2_01  (bump version)
```

## Five-Stage Workflow

```
PREPARE:  Define success signal
SPECIFY:  Design harness
BUILD:    Implement + update contract
VERIFY:   Run harness
HANDOFF:  Set VALID:true when ready
```

## Blocker Contract Template

```markdown
## Blocker
**What:** [Specific issue]
**Owner:** [Team/person/ticket]
**Expected:** [Date/milestone]
**Remediation:** [Next steps]
```

## Event Types

- CHECKPOINT_CREATED - New CHECKPOINT
- HARNESS_EXECUTED - Harness ran
- CHECKPOINT_VERIFIED - VALID/SIGNAL changed
- CHECKPOINT_CLOSED - Work complete
- MANIFEST_UPDATED - Deliverables changed

## SIGNAL Values

- `pass` - Harness ran, succeeded
- `fail` - Harness ran, failed
- `blocked` - Cannot run harness
- `pending` - Not run yet

## Common Anti-Patterns

❌ Validation theater (VALID:true without harness)
❌ Goal fog (no success criteria)
❌ Dependency fog (dependencies undocumented)
❌ History drift (context only in ancestors)
❌ Relative paths (./ARTIFACTS instead of ::THIS/ARTIFACTS)

## Succession Patterns

**Successor:**
```yaml
# Old CHECKPOINT
LIFECYCLE: superseded
VALID: false

# New CHECKPOINT
# STATUS mentions inherited context
```

**Delegate:**
```yaml
# Child CHECKPOINT
DELEGATE_OF: ::WORK/parent_v1_01

# Parent CHECKPOINT
LIFECYCLE: active  # Still active, waiting
```

## MANIFEST LEDGER Format

```markdown
## MANIFEST LEDGER
- `name` - ::THIS/ARTIFACTS/path - One-line purpose
- `name` - ::THIS/ARTIFACTS/path - One-line purpose
```

Every deliverable: name, rooted path, purpose.

## Three North Star Principles

1. **Harness-first:** Design verification before implementation
2. **Self-contained:** Fresh agent resumes without asking
3. **Low-friction:** Minimal rules, maximum clarity

## Agent Checklist: Before Setting VALID:true

```
□ Harness has run (or credible blocker documented)
□ MANIFEST LEDGER complete with rooted paths
□ HARNESS section complete (5-10 sentences)
□ CONTEXT explains decisions
□ STATUS has context recap
□ LOG shows timeline
□ Dependencies documented with status
□ acft validate passes
□ Fresh agent could resume without questions
```

## When In Doubt

- Read CHECKPOINT.md first, code second
- Use rooted paths everywhere
- Run the harness, don't assume
- Document decisions in CONTEXT
- Keep VALID:false until actually ready
- Cross-link relationships (parent ↔ child)

## Final Reminder

ACF = Contract system, not process prescription

Focus on: Resumable, Verifiable, Trustworthy work
