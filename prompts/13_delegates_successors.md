# Delegates and Successors for AI Agents

## Two Continuation Patterns

### SUCCESSOR (Linear Continuation)

**When:** Advancing the same line of work to the next step

**Pattern:**
```
auth_v1_01 → auth_v1_02 → auth_v1_03  (same version, increment step)
auth_v1_05 → auth_v2_01                (version bump = restart)
```

**Rules:**
1. Parent sets `LIFECYCLE: superseded` and `VALID: false`
2. Parent LOG: `- TIMESTAMP - Superseded by ::WORK/auth_v1_02`
3. Child STATUS: Reference what was inherited from parent
4. Only ONE active CHECKPOINT per branch+version at a time

**Use acft:**
```bash
acft close --path ::WORK/auth_v1_01 --lifecycle superseded --status false \
  --message "Superseded by ::WORK/auth_v1_02"
```

### DELEGATE (Parallel Sub-Task)

**When:** Spinning out a scoped sub-problem on behalf of parent

**Pattern:**
```
auth_v1_02 (active, waiting)
  └─> parse_tokens_v1_01 (delegate, reports back)
```

**Rules:**
1. Child frontmatter: `DELEGATE_OF: ::WORK/auth_v1_02`
2. Parent stays `LIFECYCLE: active`
3. Parent LOG: `- TIMESTAMP - Delegated to ::WORK/parse_tokens_v1_01 for JWT parsing`
4. Child LOG: `- TIMESTAMP - Delegated from ::WORK/auth_v1_02 to parse JWT tokens`
5. Child LOG when done: `- TIMESTAMP - Completed, reporting back to ::WORK/auth_v1_02`

**Use acft:**
```bash
acft new parse_tokens_v1_01 --delegate-of ::WORK/auth_v1_02
```

## Critical Cross-Linking Requirements

**ALWAYS cross-link in BOTH directions:**
- Parent LOG → child path (rooted: `::WORK/child_v1_01`)
- Child frontmatter → parent path (for delegates: `DELEGATE_OF`)
- Child STATUS → parent context (what was inherited)

**Failure mode:** Missing cross-links = orphaned CHECKPOINTs (failure mode: "Orphaned Successors")

## Decision Tree for Agents

```
Need to continue work?
├─ Same logical task, next iteration?
│  └─> SUCCESSOR (increment step or version)
│
└─ Sub-problem needs separate focus?
   └─> DELEGATE (new branch, link back)
```

## Version vs Step Increment

**Increment step** (`_v1_01` → `_v1_02`):
- Continuous work on same approach
- Incremental progress
- Context carries forward smoothly

**Bump version** (`_v1_05` → `_v2_01`):
- Fundamental pivot or restart
- Different approach/strategy
- CONTEXT must explain why the pivot happened

## Validation Checks

Before creating successor/delegate:
1. ✓ Parent LOG has timestamp + link to child
2. ✓ Child has `DELEGATE_OF` (for delegates) or STATUS recap (for successors)
3. ✓ Rooted paths used everywhere
4. ✓ Only ONE active CHECKPOINT per branch+version (for successors)
