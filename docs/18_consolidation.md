# Bite 18: Consolidation Philosophy (Merging Exploratory Work)

Sometimes you explore multiple approaches in parallel, then need to **consolidate** them into one authoritative deliverable.

**The scenario:**
- You tried 3 different auth approaches: `plan_a_v1_01`, `plan_b_v1_02`, `plan_c_v1_01`
- Plan B won, but useful context exists in A and C
- You need to create a single unified CHECKPOINT

## How Consolidation Works

### 1. Create the Unified CHECKPOINT

```yaml
# unified_auth_v1_01/CHECKPOINT.md
---
VALID: false
LIFECYCLE: active
SUPERSEDES: ["::WORK/plan_a_v1_01", "::WORK/plan_b_v1_02", "::WORK/plan_c_v1_01"]
---
```

The `SUPERSEDES` field lists all the exploratory CHECKPOINTs being merged.

### 2. Retire the Predecessors

Mark each exploratory CHECKPOINT as superseded:

```bash
acft close --path ::WORK/plan_a_v1_01 --status false --lifecycle superseded \
  --message "Superseded by ::WORK/unified_auth_v1_01"

acft close --path ::WORK/plan_b_v1_02 --status false --lifecycle superseded \
  --message "Superseded by ::WORK/unified_auth_v1_01"

acft close --path ::WORK/plan_c_v1_01 --status false --lifecycle superseded \
  --message "Superseded by ::WORK/unified_auth_v1_01"
```

Each predecessor gets `SUPERSEDED_BY` recorded in its LOG.

### 3. Copy Necessary Materials

**For the winning approach:**
- Move deliverables to `unified_auth_v1_01/ARTIFACTS/`
- Update MANIFEST LEDGER to list them

**For rejected approaches:**
- Archive source material to `unified_auth_v1_01/STAGE/_archive/` if needed
- Or just document key insights in CONTEXT

**Document the decision:**
- CONTEXT should explain why Plan B won
- What were the tradeoffs?
- What did you learn from A and C?

### 4. Make It Standalone

The unified CHECKPOINT should be **self-contained**:
- Future agents read only `unified_auth_v1_01/CHECKPOINT.md`
- They shouldn't need to open `plan_a_v1_01` to understand the work
- HARNESS and MANIFEST reference only the unified deliverables

**Validate isolation:**
```bash
acft orient ::THIS --sections HARNESS,MANIFEST
```

If this requires reading superseded CHECKPOINTs, you haven't consolidated properly.

## Why Consolidation Matters

**Without consolidation:**
- Sprawling tree of exploratory work
- Unclear which approach is authoritative
- New agents waste time reading dead ends

**With consolidation:**
- One clear path forward
- Historical exploration preserved but not in the way
- Clean handoff to next agent

## The Mental Model

Think of exploratory CHECKPOINTs as **research notes** and the consolidated CHECKPOINT as the **published paper**.

- Research notes: Messy, branching, full of dead ends
- Paper: Distilled, clear, with just enough context

You keep the research notes (superseded CHECKPOINTs) for auditability, but future work references only the paper (unified CHECKPOINT).

## Key Principles

1. **Preserve history** - Don't delete superseded CHECKPOINTs, mark them `LIFECYCLE: superseded`
2. **Make consolidation standalone** - Copy what you need, don't just link back
3. **Document the decision** - CONTEXT explains why this approach won
4. **One unified MANIFEST** - List only final deliverables, not all exploration artifacts
5. **Cross-link in both directions** - Parent `SUPERSEDES`, children `SUPERSEDED_BY`
