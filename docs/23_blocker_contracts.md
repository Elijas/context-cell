# Bite 23: Credible Blocker Contracts (Handling Blocked Work)

Sometimes you can't run the harness because something external is blocking you: missing credentials, unavailable API, pending infrastructure.

ACF handles this with **credible blocker contracts**.

## What's a Blocker Contract?

When you can't verify but want to keep the CHECKPOINT active, you document:

1. **What's blocking** - Specific issue preventing verification
2. **Who owns it** - Person/team responsible for unblocking
3. **When expected** - Target date or milestone
4. **Remediation path** - What happens when unblocked

## Example Blocker Contract

```yaml
---
VALID: false
LIFECYCLE: active
SIGNAL: blocked
---

# STATUS

## Current State
Implementation complete but cannot verify - production API credentials unavailable.

## Blocker
**What:** Production API access credentials needed for harness
**Owner:** Platform team (ticket OPS-4567)
**Expected:** 2025-02-15
**Remediation:** Once credentials arrive, run `acft verify --record`, update SIGNAL

# LOG
- 2025-02-10T14:00:00Z - Implementation complete, harness designed
- 2025-02-10T14:30:00Z - Cannot run harness, API credentials blocked
- 2025-02-10T14:45:00Z - Filed OPS-4567 for credentials, ETA 2025-02-15
```

## Why This Matters

**Without blocker contract:**
- CHECKPOINT sits in limbo
- Next agent doesn't know what's blocking
- Unclear who should follow up
- Work appears incomplete without context

**With blocker contract:**
- Explicit about what's blocking
- Clear ownership of unblocking
- Timeline visible
- Next steps documented
- Fresh agent knows exactly what to do when unblocked

## Key Rules

1. Keep `VALID: false` until harness actually runs
2. Set `SIGNAL: blocked` to indicate can't verify
3. Document blocker in STATUS with all four elements (what/who/when/remediation)
4. Log the blocker event with timestamp
5. When unblocked, run harness and update SIGNAL

## Common Blockers

**External dependencies:**
- API credentials unavailable
- Third-party service down
- External dataset not yet delivered

**Internal dependencies:**
- Other CHECKPOINT not complete yet
- Infrastructure not provisioned
- Review approval pending

**Environmental:**
- Production access not granted
- Test environment not ready
- Tool/library installation blocked

## The Philosophy

ACF prefers **"blocked but documented"** over **"looks good to me"** validation theater.

Better to say:
> "I can't verify this yet because X, owner Y is working on it, expected by Z"

Than to say:
> "Looks good to me!" (without actually running the harness)

## When to Use vs When to Delegate

**Use blocker contract when:**
- External dependency, out of your control
- Known timeline for resolution
- You want to keep this CHECKPOINT active while waiting

**Delegate instead when:**
- Unblocking is substantial work
- You can parallelize (someone else can work on unblocking)
- Unclear timeline, needs investigation

Example: Don't create a blocker contract for "need to build auth system". That's not a blocker, that's work. Delegate it.
