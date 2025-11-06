# Bite 6: The VALID Flag (The Quality Gate)

Every CHECKPOINT has a frontmatter flag that acts as a **quality gate**:

```yaml
---
VALID: false
---
```

**What it means:**

- `VALID: false` - Work in progress, don't trust the outputs yet
- `VALID: true` - Harness passed, outputs verified, safe to depend on

**The rule is simple but strict:**

You can ONLY set `VALID: true` if:

1. **LIFECYCLE is active** (you're still developing it)
2. **You ran the harness and it passed**
   - Verification commands executed
   - Tests passed
   - MANIFEST ledger lists the actual outputs

**For temporary blockers:**

If the harness can't run yet (missing dependency, waiting for something):
- Document the blocker in STATUS
- Keep `VALID: false`
- Keep `LIFECYCLE: active`
- Work can resume when blocker is resolved

**For permanent blockers:**

If you proved something is impossible:
- Document the blocker in STATUS
- Keep `VALID: false`
- Set `LIFECYCLE: archived`
- This signals "stopped developing, can't work"

**Why this matters:**

Without this gate, you get "I think I'm done" syndrome. The VALID flag forces you to prove it before anyone else depends on your work.

Think of it like a **green checkmark** that you only get after passing the test.
