# Bite 20: STAGE/ Directory (Temporary Parking)

CHECKPOINTs have two types of content: **deliverables** (in ARTIFACTS/) and **scratch work** (everything else).

The `STAGE/` directory has a special purpose: **temporary parking for raw inputs** you haven't yet distilled into the contract.

## When to Create STAGE/

Create STAGE/ when you need temporary parking for:
- Large dataset or document dumps
- Unprocessed excerpts from external sources
- Raw materials that need processing before becoming deliverables
- Temporary experiments

## What Goes in STAGE/

**DO put in STAGE/:**
- Raw data files
- Unprocessed excerpts
- Reference materials you're working from
- Temporary experiments
- Intermediate outputs you're still refining

**DON'T put in STAGE/:**
- Deliverables (those go in `ARTIFACTS/`)
- Other CHECKPOINTs' outputs (link to them with rooted paths like `::WORK/other_v1_01/ARTIFACTS/file.py`)
- Documentation (that goes in `CHECKPOINT.md` sections)
- Final outputs ready for consumption

## STAGE/ Lifecycle

1. **Create** STAGE/ when you need temporary parking
2. **Work** from the staged materials, processing them
3. **Distill** insights into CHECKPOINT.md or move deliverables to ARTIFACTS/
4. **Prune or archive** before setting VALID:true
5. **Remove** STAGE/ entirely if nothing remains

## The Mental Model

Think of STAGE/ as your **workbench**:
- Messy while you work
- Cleaned up before shipping
- Sometimes empty (and that's fine!)

**A missing STAGE/ is healthy.** It means you didn't need temporary parking.

**STAGE/ with content at closure gets a warning** (not a failure) - "Did you forget to clean up?"

## Example Usage

```
auth_v1_01/
├── CHECKPOINT.md
├── STAGE/
│   ├── reference_docs/        # Raw materials
│   │   ├── oauth_spec.pdf
│   │   └── jwt_examples.txt
│   ├── experiments/            # Temporary explorations
│   │   └── token_parsing_test.py
│   └── _archive/               # Processed, archived for reference
│       └── initial_design_notes.md
└── ARTIFACTS/
    └── auth_implementation.py  # Final deliverable
```

Before closing:
- `oauth_spec.pdf` - Delete (available online, linked in CONTEXT)
- `jwt_examples.txt` - Archive to `STAGE/_archive/` (might need reference)
- `token_parsing_test.py` - Delete (insights integrated into implementation)
- `initial_design_notes.md` - Keep archived (shows decision evolution)

## The Rule

**Validators treat missing STAGE/ as good.**

They flag a **warning** (not failure) if:
- STAGE/ exists
- You're setting VALID:true
- STAGE/ contains files outside of `_archive/`

This prompts you to ask: "Should these be deliverables, or can I clean them up?"

## Clean-Up Checklist

Before setting VALID:true:

```
□ Review STAGE/ contents
□ Move finished deliverables to ARTIFACTS/
□ Delete files available elsewhere (with links in CHECKPOINT.md)
□ Archive useful reference material to STAGE/_archive/
□ Remove STAGE/ if empty
```

## Key Insight

STAGE/ acknowledges that **work is messy** while in progress. But the framework insists: **deliverables are clean**.

By separating temporary parking (STAGE/) from final outputs (ARTIFACTS/), you make it clear what's ready for consumption vs what's still being refined.
