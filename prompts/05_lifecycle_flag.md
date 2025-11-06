# LIFECYCLE Flag for AI Agents

## What It Tracks

LIFECYCLE = development attention (are you still working on this?)

This prevents accidentally resuming work in the wrong checkpoint.

```yaml
LIFECYCLE: active      # I'm working on this
LIFECYCLE: superseded  # Stopped, newer version exists
LIFECYCLE: archived    # Stopped, no newer version
```

## State Meanings

### active
- Current work in progress or completed work still maintained
- You can update and develop here
- Only state that allows VALID: true

### superseded
- Replaced by a newer version
- Keep for history but don't develop
- MUST have VALID: false
- MUST have SUPERSEDED_BY field

### archived
- Stopped developing, no successor
- Permanent blocker, pivot, dead-end, obsolete
- MUST have VALID: false
- LOG should explain why

## Valid State Combinations

```yaml
# Active work
VALID: false, LIFECYCLE: active     # In progress
VALID: true,  LIFECYCLE: active     # Done and verified

# Historical work
VALID: false, LIFECYCLE: superseded # Replaced
VALID: false, LIFECYCLE: archived   # Abandoned
```

## Critical Rule

**VALID: true is ONLY possible when LIFECYCLE: active**

## When Creating a Successor

**New checkpoint:**
```yaml
---
VALID: false
LIFECYCLE: active
SUPERSEDES: ["::WORK/old_v1_03"]
---
```

**Old checkpoint (update it):**
```yaml
---
VALID: false
LIFECYCLE: superseded
SUPERSEDED_BY: ::WORK/new_v2_01
---
```

Also add LOG entry in both explaining the succession.

## When Archiving

```yaml
---
VALID: false
LIFECYCLE: archived
---
```

**Must add LOG entry explaining:**
- Why archived (permanent blocker, pivot, obsolete)
- What was attempted
- Final state

## Common Scenarios

**Permanent blocker:**
```yaml
VALID: false
LIFECYCLE: archived
```

**Temporary blocker (still trying):**
```yaml
VALID: false
LIFECYCLE: active
```

**Replaced by better version:**
```yaml
VALID: false
LIFECYCLE: superseded
SUPERSEDED_BY: ::WORK/better_v2_01
```

**Completed work:**
```yaml
VALID: true
LIFECYCLE: active
```

## Quick Checks

Before setting LIFECYCLE:

**superseded:**
- [ ] Created successor checkpoint?
- [ ] Added SUPERSEDED_BY field?
- [ ] Set VALID: false?
- [ ] Updated successor's SUPERSEDES field?

**archived:**
- [ ] Documented reason in STATUS?
- [ ] Added LOG entry explaining?
- [ ] Set VALID: false?

**active:**
- [ ] Still developing or maintaining?
- [ ] Not replaced by newer version?
