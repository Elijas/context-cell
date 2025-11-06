# Bite 15: Delegates and Successors (How Work Continues)

Work rarely finishes in one CHECKPOINT. ACF has two ways to continue:

## 1. SUCCESSOR - The Next Step

**What it is:** The next step in the same line of work

**How it works:**
- Same branch, increment the step: `auth_v1_01` → `auth_v1_02` → `auth_v1_03`
- Or bump version for a restart: `auth_v1_03` → `auth_v2_01`
- The new CHECKPOINT **supersedes** the old one

**Example:**
```yaml
# auth_v1_01/CHECKPOINT.md
LIFECYCLE: superseded
VALID: false

# LOG
- 2025-02-10T15:00:00Z - Superseded by ::WORK/auth_v1_02 (scope expanded)
```

## 2. DELEGATE - Spin Out a Sub-Problem

**What it is:** A child CHECKPOINT that tackles a scoped sub-problem on behalf of its parent

**How it works:**
- Create a child CHECKPOINT: `auth_v1_02` spawns `parse_tokens_v1_01`
- Child sets `DELEGATE_OF: ::WORK/auth_v1_02` in frontmatter
- Child reports back in its LOG when done
- Parent remains `LIFECYCLE: active` (waiting for the delegate)

**Example:**
```yaml
# parse_tokens_v1_01/CHECKPOINT.md
---
VALID: false
LIFECYCLE: active
DELEGATE_OF: ::WORK/auth_v1_02
---

# LOG
- 2025-02-10T16:00:00Z - Delegated from ::WORK/auth_v1_02 to parse JWT tokens
- 2025-02-10T18:30:00Z - Completed, reporting back to ::WORK/auth_v1_02
```

## Mental Model

- **Successor** = "Chapter 2" (linear continuation)
- **Delegate** = "Footnote research" (parallel sub-task)

## Why Cross-Linking Matters

Without explicit succession/delegation, you end up with:
- Orphaned CHECKPOINTs (no clear parent)
- Unclear relationships (which work depends on what?)
- Lost context (why was this created?)

**The rule:** Cross-link in both directions:
- Parent LOG → child path
- Child frontmatter → parent path

This keeps the audit trail intact so anyone can reconstruct the work history.

## Key Differences

| Aspect | Successor | Delegate |
|--------|-----------|----------|
| Parent state | `LIFECYCLE: superseded` | `LIFECYCLE: active` |
| Relationship | Replaces parent | Reports to parent |
| Branch | Same branch name | Often different branch |
| Use case | Continue main work | Tackle sub-problem |
