# SIGNAL Field for AI Agents

## Two Quality Indicators

| Field | Meaning | Values |
|-------|---------|--------|
| `VALID` | Contract trustworthy for handoff? | `true`, `false` |
| `SIGNAL` | Latest harness verdict? | `pass`, `fail`, `blocked`, `pending` |

## SIGNAL Values

- **`pass`** - Harness ran, all checks passed
- **`fail`** - Harness ran, checks failed
- **`blocked`** - Cannot run harness (credentials, dependencies, etc.)
- **`pending`** - Harness not run yet

## Critical Rules

**1. SIGNAL is optional, VALID is required**
```yaml
VALID: false        # ✓ Required
LIFECYCLE: active   # ✓ Required
SIGNAL: pass        # ✓ Optional
```

**2. Cannot have VALID:true with SIGNAL:fail or SIGNAL:pending**
```yaml
VALID: true
SIGNAL: fail   # ✗ INVALID - can't hand off failed harness
```

```yaml
VALID: true
SIGNAL: pending   # ✗ INVALID - must run harness before handoff
```

**3. SIGNAL:blocked with VALID:false is acceptable**
```yaml
VALID: false
SIGNAL: blocked   # ✓ OK if blocker documented in LOG
```

But you must document the blocker contract:
- Who owns unblocking?
- When expected?
- What's the remediation path?

## State Transitions

```
Start:
VALID: false, SIGNAL: pending

↓ (run harness)

Pass path:
VALID: false, SIGNAL: pass → finish docs → VALID: true, SIGNAL: pass

Fail path:
VALID: false, SIGNAL: fail → fix bugs → run again

Blocked path:
VALID: false, SIGNAL: blocked → document blocker → wait → unblock → run harness
```

## Setting SIGNAL

**Using acft:**
```bash
acft close --signal pass      # Harness passed
acft close --signal fail      # Harness failed
acft close --signal blocked   # Cannot run harness
acft close --signal pending   # Not run yet
```

**Manual editing:**
```yaml
---
VALID: false
SIGNAL: fail
---
```

Then add LOG entry:
```markdown
# LOG
- 2025-02-10T14:32:00Z - Harness failed: 3 tests failing in auth module
```

## Common Patterns for Agents

**Pattern 1: Development cycle**
```
1. Create CHECKPOINT (VALID:false, SIGNAL:pending)
2. Build implementation
3. Run harness (SIGNAL → pass/fail)
4. If pass: finish docs, set VALID:true
5. If fail: fix, go to step 3
```

**Pattern 2: Blocked waiting for external dependency**
```
1. Try to run harness
2. Realize credentials missing
3. Set SIGNAL:blocked, VALID:false
4. Document blocker in LOG with owner/timeline
5. When unblocked: run harness, update SIGNAL
```

**Pattern 3: Incremental validation**
```
1. Build partial implementation
2. Run harness (SIGNAL:fail - expected)
3. Continue building
4. Run harness again (SIGNAL:pass)
5. Finish contract, set VALID:true
```

## Decision Logic

```python
def can_set_valid_true(signal):
    if signal == "pass":
        return True  # Harness passed, can hand off
    elif signal == "blocked":
        return True  # Only if credible blocker contract exists
    else:  # fail or pending
        return False  # Must run harness clean first
```

## LOG Integration

Always log SIGNAL changes:

```markdown
# LOG
- 2025-02-10T14:00:00Z - Created CHECKPOINT, SIGNAL:pending
- 2025-02-10T15:30:00Z - Ran harness, SIGNAL:fail (auth tests failing)
- 2025-02-10T16:45:00Z - Fixed auth, ran harness, SIGNAL:pass
- 2025-02-10T17:00:00Z - Completed documentation, VALID:true
```

## Key Distinction

**SIGNAL = Technical feedback**
- Did the code work?
- Did tests pass?
- Can the harness run?

**VALID = Contract completeness**
- Is documentation complete?
- Can a fresh agent resume?
- Is the handoff package ready?

## When to Omit SIGNAL

SIGNAL is optional. Omit it when:
- Work is very early stage (nothing to run yet)
- Harness doesn't exist yet
- You're focused on design/planning, not implementation

But once you have a harness, use SIGNAL to track its verdict.

## Event Integration

When using `acft verify --record`:
```json
{
  "TYPE": "HARNESS_EXECUTED",
  "PAYLOAD": {
    "STATUS": "pass",  // or "fail"
    "LOG_PATH": "::WORK/logs/..."
  }
}
```

This triggers `acft close` to update SIGNAL automatically.
