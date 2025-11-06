# VALID Flag for AI Agents

## The Contract

```yaml
VALID: false  # Don't trust the outputs yet
VALID: true   # Harness passed AND still actively developing
```

## When to Set VALID: true

You MUST have ALL of these:

✓ **LIFECYCLE: active** (still developing)
✓ **Harness passed:**
  - Executed all harness commands
  - Results meet success criteria
  - MANIFEST ledger populated with rooted paths
  - Outcomes logged with timestamps
  - Execution logs saved to LOGS/

## Critical Rule

**VALID: true is ONLY possible when LIFECYCLE: active**

If LIFECYCLE is superseded or archived, VALID MUST be false.

## Temporary Blockers

When you CAN'T run harness yet:

**Examples:**
- Waiting for dependency
- Missing credentials
- Upstream work incomplete

**What to do:**
1. Document blocker in STATUS
2. Keep VALID: false
3. Keep LIFECYCLE: active
4. Log the blocker

**When blocker resolves:**
1. Run the harness
2. Only then set VALID: true

## Permanent Blockers

When work is proven impossible:

**Examples:**
- Library doesn't support feature
- Approach fundamentally broken
- Requirements contradictory

**What to do:**
1. Document blocker in STATUS
2. Explain what failed and why
3. Keep VALID: false
4. Set LIFECYCLE: archived
5. Log the blocker

## Valid State Combinations

```yaml
# Working on it, not done yet
VALID: false
LIFECYCLE: active

# Working on it, harness passed
VALID: true
LIFECYCLE: active

# Replaced by newer version
VALID: false
LIFECYCLE: superseded

# Abandoned or permanently blocked
VALID: false
LIFECYCLE: archived
```

## Critical Rules

❌ **NEVER do this:**
- Set VALID: true without running harness
- Set VALID: true when LIFECYCLE is not active
- Set VALID: true with temporary blocker
- Set VALID: true based on "looks good to me"

✅ **ALWAYS do this:**
- Run harness before setting VALID: true
- Verify LIFECYCLE: active before setting VALID: true
- Document blockers clearly
- Log verification results
- Use `acft validate ::THIS` before closing

## Quick Check Before Setting VALID: true

Ask yourself:
1. Is LIFECYCLE: active? (if not, VALID MUST be false)
2. Did I run the harness? (see LOGS/)
3. Did it pass? (see LOG entries)
4. Is MANIFEST complete? (rooted paths present)

If you answered "no" to ANY of these, keep VALID: false.
