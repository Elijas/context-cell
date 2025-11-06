# Consolidation for AI Agents

## When to Consolidate

**Scenario:** Multiple exploratory CHECKPOINTs, need single authoritative deliverable

**Example:**
```
plan_a_v1_01 (rejected)
plan_b_v1_02 (chosen)
plan_c_v1_01 (rejected)
  ↓
unified_auth_v1_01 (consolidated)
```

## Consolidation Process

### Step 1: Create Unified CHECKPOINT

```yaml
---
VALID: false
LIFECYCLE: active
SUPERSEDES: ["::WORK/plan_a_v1_01", "::WORK/plan_b_v1_02", "::WORK/plan_c_v1_01"]
---
```

### Step 2: Mark Predecessors as Superseded

```bash
acft close --path ::WORK/plan_a_v1_01 \
  --status false --lifecycle superseded \
  --message "Superseded by ::WORK/unified_auth_v1_01"
```

Do this for EACH predecessor.

### Step 3: Copy Materials to Unified CHECKPOINT

**Chosen approach:**
- Copy deliverables to `::THIS/ARTIFACTS/`
- Update MANIFEST LEDGER with rooted paths

**Rejected approaches:**
- Archive raw inputs to `::THIS/STAGE/_archive/` IF needed
- Or document key insights in CONTEXT only
- Don't copy everything - be selective

**Document decision in CONTEXT:**
```markdown
## Why Plan B

Plan B was chosen because:
- [criterion 1]
- [criterion 2]

Plan A rejected due to: [reason]
Plan C rejected due to: [reason]

Key learnings from exploration: [insights]
```

### Step 4: Validate Isolation

```bash
acft orient ::THIS --sections HARNESS,MANIFEST
```

**Test:** Can you understand the deliverable WITHOUT reading superseded CHECKPOINTs?

If no → consolidation incomplete. Add more context to STATUS/CONTEXT.

## Critical Rules

**1. Self-Containment:**
- Unified CHECKPOINT must stand alone
- Future agents should NOT need to read superseded CHECKPOINTs
- Copy necessary context, don't just link back

**2. Cross-Link Both Directions:**
```
Unified frontmatter: SUPERSEDES: ["::WORK/plan_a_v1_01", ...]
Each predecessor LOG: - TIMESTAMP - Superseded by ::WORK/unified_auth_v1_01
```

**3. Clean MANIFEST:**
- List ONLY final deliverables
- Don't include exploratory artifacts
- Each entry: rooted path to `::THIS/ARTIFACTS/`

**4. Preserve History:**
- Don't delete superseded CHECKPOINTs
- Set `LIFECYCLE: superseded` and `VALID: false`
- Leave on disk for auditability

## Anti-Pattern: Incomplete Consolidation

**BAD:**
```markdown
# unified_auth_v1_01

## HARNESS

See ::WORK/plan_b_v1_02 for implementation details.
```

**GOOD:**
```markdown
# unified_auth_v1_01

## HARNESS

Implementation uses OAuth2 flow with JWT tokens.
Deliverables in ::THIS/ARTIFACTS/auth.py pass all
security checks documented below.

[Full harness description]
```

## Decision Tree

```
Multiple exploratory CHECKPOINTs exist?
├─ All still being actively developed?
│  └─> DON'T consolidate yet (let exploration continue)
│
└─ One approach chosen, others rejected?
   ├─> Consolidate into unified CHECKPOINT
   ├─> Mark predecessors superseded
   ├─> Copy winning deliverables
   └─> Document decision in CONTEXT
```

## MANIFEST Structure After Consolidation

```markdown
## MANIFEST LEDGER

- `auth_implementation.py` - ::THIS/ARTIFACTS/auth_implementation.py - OAuth2 + JWT implementation
- `auth_tests.py` - ::THIS/ARTIFACTS/auth_tests.py - Security test suite
- `design_rationale.md` - ::THIS/ARTIFACTS/design_rationale.md - Why Plan B won

## Dependencies

### CHECKPOINT DEPENDENCIES

[List any other CHECKPOINTs the consolidated work depends on - NOT the superseded exploratory ones]

### SYSTEM DEPENDENCIES

[External dependencies]
```

## Validation Checklist

Before setting `VALID: true` on consolidated CHECKPOINT:

```
□ SUPERSEDES field lists all predecessors
□ Each predecessor LOG has "Superseded by" entry
□ ARTIFACTS/ contains chosen deliverables
□ MANIFEST LEDGER lists only final outputs (not exploration artifacts)
□ CONTEXT explains why chosen approach won
□ HARNESS section stands alone (no "see plan_b for details")
□ STATUS doesn't require reading superseded CHECKPOINTs
□ `acft validate ::THIS` passes
□ `acft orient ::THIS --sections HARNESS,MANIFEST` is self-explanatory
```

## Key Insight

**Consolidation = Research notes → Published paper**

- Research notes (plan_a, plan_b, plan_c): Messy, exploratory, branching
- Published paper (unified): Distilled, clear, authoritative

Keep research notes for audit trail, but future work references only the paper.
