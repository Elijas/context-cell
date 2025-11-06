# STAGE/ Directory for AI Agents

## Purpose

STAGE/ = temporary parking for raw inputs not yet distilled into contract or deliverables.

## Critical Rules

**1. STAGE/ is optional**
- Create only when needed
- Missing STAGE/ is healthy (no temporary parking needed)
- Presence doesn't indicate a problem

**2. STAGE/ lifecycle**
```
Create → Use while working → Prune before VALID:true → Remove if empty
```

**3. Clean up before handoff**
- Validator warns (not fails) if STAGE/ has content when VALID:true
- Archive or delete staged materials before closing

## What Goes Where

| Content Type | Location | Why |
|--------------|----------|-----|
| Final deliverables | `ARTIFACTS/` | For consumption by others |
| Raw data dumps | `STAGE/` | Temporary, being processed |
| Reference docs | `STAGE/` or linked | If processing, stage it; if just referencing, link it |
| Experiments | `STAGE/experiments/` | Temporary explorations |
| Processed archives | `STAGE/_archive/` | Kept for reference, not active |
| Other CHECKPOINT outputs | Link via rooted paths | Never copy, always link |
| Documentation | `CHECKPOINT.md` | Contract sections |

## Common Patterns

### Pattern 1: Large Dataset Processing
```
1. Receive dataset → STAGE/raw_data/
2. Process and analyze
3. Extract insights → document in CHECKPOINT.md
4. Generate summary → ARTIFACTS/summary.csv
5. Delete STAGE/raw_data/ (or archive if needed for auditability)
```

### Pattern 2: Document Excerpts
```
1. Pull excerpts from external docs → STAGE/excerpts/
2. Distill into CONTEXT section
3. Link to original sources in CONTEXT
4. Delete STAGE/excerpts/ (info now in contract)
```

### Pattern 3: Experimental Code
```
1. Try multiple approaches → STAGE/experiments/
2. Choose winning approach
3. Refine to deliverable → ARTIFACTS/implementation.py
4. Delete STAGE/experiments/ (or archive for decision record)
```

## Directory Structure

```
checkpoint_v1_01/
├── CHECKPOINT.md           # Contract (required)
├── ARTIFACTS/              # Deliverables (create when ready)
│   └── output.py
├── STAGE/                  # Temporary (optional, prune before close)
│   ├── raw_inputs/
│   ├── experiments/
│   └── _archive/           # Processed materials kept for reference
└── notes/                  # Scratch work (optional, not part of contract)
```

## Validation Logic

```python
def validate_stage(checkpoint):
    if not checkpoint.has_stage():
        return "OK"  # Missing STAGE is healthy

    if checkpoint.valid and checkpoint.stage_has_active_content():
        return "WARNING: STAGE/ has content at closure, review before handoff"

    return "OK"
```

## Clean-Up Decision Tree

```
STAGE/ file exists?
├─ Is it a final deliverable?
│  └─> Move to ARTIFACTS/, update MANIFEST LEDGER
│
├─ Is it available elsewhere (URL, other CHECKPOINT)?
│  └─> Delete, link from CHECKPOINT.md with rooted path
│
├─ Is it useful for decision auditability?
│  └─> Archive to STAGE/_archive/
│
└─ Is it temporary/obsolete?
   └─> Delete
```

## Integration with Other Directories

**ARTIFACTS/ vs STAGE/:**
- ARTIFACTS/ = consumer-ready, versioned, documented
- STAGE/ = work-in-progress, raw, temporary

**STAGE/ vs notes/:**
- STAGE/ = raw external inputs being processed
- notes/ = personal scratchpad, planning documents

**STAGE/ vs other CHECKPOINTs:**
- Never copy another CHECKPOINT's outputs to your STAGE/
- Link with rooted paths: `::WORK/other_v1_01/ARTIFACTS/file.py`

## Commands

**Check STAGE/ status:**
```bash
acft validate ::THIS  # Warns if STAGE/ has content at closure
```

**Clean up STAGE/:**
```bash
# Review contents
ls -la ::THIS/STAGE/

# Remove if empty
rmdir ::THIS/STAGE/

# Archive important materials
mkdir -p ::THIS/STAGE/_archive/
mv ::THIS/STAGE/old_experiments/ ::THIS/STAGE/_archive/
```

## Key Agent Behaviors

**When creating CHECKPOINT:**
- Don't create STAGE/ preemptively
- Create only when you actually need temporary parking

**During work:**
- Use STAGE/ freely for temporary materials
- Don't worry about cleanliness while working

**Before setting VALID:true:**
- Review STAGE/ contents
- Move deliverables to ARTIFACTS/
- Delete or archive everything else
- Remove STAGE/ if empty

**When resuming others' work:**
- If STAGE/ exists, treat as temporary/suspect
- Trust only ARTIFACTS/ and CHECKPOINT.md
- Don't rely on STAGE/ contents for understanding

## Anti-Pattern: STAGE Bloat

**BAD:**
```
STAGE/
├── raw_data_v1/
├── raw_data_v2/
├── raw_data_v3/
├── old_experiments_2024/
├── old_experiments_2025/
├── draft_outputs/
└── archive_of_archives/

VALID: true  # ✗ Should have cleaned up first
```

**GOOD:**
```
STAGE/
└── _archive/
    └── initial_exploration.md  # Kept for decision context

ARTIFACTS/
├── final_output.py
└── documentation.md

VALID: true  # ✓ Clean handoff
```
