# Bite 7: The LIFECYCLE Flag (Development Attention)

Every CHECKPOINT also has a LIFECYCLE flag that tracks **whether you're still developing it**:

```yaml
---
VALID: false
LIFECYCLE: active
---
```

**The three states:**

- `LIFECYCLE: active` - "I'm working on this now"
- `LIFECYCLE: superseded` - "Stopped working, there's a newer version"
- `LIFECYCLE: archived` - "Stopped working" (impossible, scrapped, dead-end, pivot)

**Key insight:** LIFECYCLE tracks **development attention**, not quality. It prevents teams from accidentally resuming work in the wrong checkpoint.

**How they work together:**

```yaml
VALID: false, LIFECYCLE: active     # Working on it now
VALID: true,  LIFECYCLE: active     # Done and verified
VALID: false, LIFECYCLE: superseded # Stopped, replaced by newer version
VALID: false, LIFECYCLE: archived   # Stopped (can't work, pivoted, etc.)
```

**Important rule:** Only `LIFECYCLE: active` can have `VALID: true`.

**Cross-linking when superseding:**

When you create a new version:

```yaml
# New: auth_v2_01/CHECKPOINT.md
SUPERSEDES: ["::WORK/auth_v1_03"]

# Old: auth_v1_03/CHECKPOINT.md
SUPERSEDED_BY: ::WORK/auth_v2_01
LIFECYCLE: superseded
```

This creates a **history chain** you can follow backward and forward.
