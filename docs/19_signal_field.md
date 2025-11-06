# Bite 19: The SIGNAL Field (Harness Verdicts)

Besides `VALID` (handoff readiness), CHECKPOINTs can track `SIGNAL` (harness verdict).

## What's the Difference?

- **VALID** = "Is this contract trustworthy for handoff?" (true/false)
- **SIGNAL** = "What did the harness say last time it ran?" (pass/fail/blocked/pending)

## SIGNAL Values

- `pass` - Harness ran successfully, all checks passed
- `fail` - Harness ran but tests/checks failed
- `blocked` - Can't run harness (missing credentials, dependencies down)
- `pending` - Harness hasn't run yet

## Example Frontmatter

```yaml
---
VALID: false
LIFECYCLE: active
SIGNAL: fail
---
```

This says: "Work is active, harness ran but failed, not ready for handoff"

## Why Both Flags Exist

**Scenario 1:** Harness passes but contract incomplete
```yaml
VALID: false
SIGNAL: pass
```
- Tests pass but documentation needs work
- Implementation complete but CONTEXT section empty
- Everything works but not ready to hand off

**Scenario 2:** Contract ready but harness blocked
```yaml
VALID: false  # Can't be true if harness hasn't run
SIGNAL: blocked
```
- Waiting for credentials
- External dependency unavailable
- Can't verify yet but contract structure is good

**Scenario 3:** Ready to hand off
```yaml
VALID: true
SIGNAL: pass
```
- Harness ran and passed
- Contract complete
- Next agent can proceed

## The Mental Model

Think of it like:
- **SIGNAL** = test suite results (did the code work?)
- **VALID** = code review approval (is everything documented and ready?)

Both are useful, measuring different things.

## Common Patterns

**During development:**
```yaml
VALID: false
SIGNAL: pending  # haven't run harness yet
```

**Tests failing, still debugging:**
```yaml
VALID: false
SIGNAL: fail
```

**Tests pass, finishing docs:**
```yaml
VALID: false
SIGNAL: pass
```

**Ready to go:**
```yaml
VALID: true
SIGNAL: pass
```

**Blocked but documented:**
```yaml
VALID: false
SIGNAL: blocked
```

## Key Insight

`SIGNAL` is **technical feedback** - it tells you if the harness verdict.

`VALID` is **contract completeness** - it tells you if a fresh agent can trust this CHECKPOINT.

You can't have `VALID: true` with `SIGNAL: fail` or `SIGNAL: pending`. If the harness hasn't run clean, the contract isn't trustworthy for handoff.

But `SIGNAL: blocked` with a credible blocker contract documented in the LOG is acceptable (though you still keep `VALID: false` until the harness actually runs).
