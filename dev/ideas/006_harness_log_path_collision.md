# Ambiguity #002: Harness Log Path Collision Risk

**Date:** 2025-11-11
**Discovered during:** Systematic audit of ACF implementation vs. specification
**Severity:** Medium
**Status:** Unresolved - requires design decision

## Issue Summary

The harness execution log path construction in `acft verify` uses only the checkpoint directory name, not the full relative path. This creates a potential collision when checkpoints with identical names exist at different hierarchy depths.

## Current Implementation

**File:** `bin/_acft_verify.py:56-59`

```python
logs_dir = ctx.work_root / "logs" / checkpoint.name
logs_dir.mkdir(parents=True, exist_ok=True)
timestamp = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
log_path = logs_dir / f"harness_{timestamp}.log"
```

## Collision Scenario

Given this checkpoint structure:
```
work_root/
├── child_v1_01/              # Top-level checkpoint
│   └── CHECKPOINT.md
└── parent_v1_01/             # Another top-level checkpoint
    └── child_v1_01/          # Delegate with same name
        └── CHECKPOINT.md
```

Both checkpoints log to the **same directory**:
- `work/child_v1_01/` → harness logs to `work/logs/child_v1_01/harness_*.log`
- `work/parent_v1_01/child_v1_01/` → **also** logs to `work/logs/child_v1_01/harness_*.log`

Timestamps prevent file overwrites, but the logs directory is shared, making it unclear which checkpoint produced which log file.

## Specification Ambiguity

**CLI Reference (line 94):**
> Persist command output under `::WORK/logs/{checkpoint}/harness_{timestamp}.log`

The `{checkpoint}` placeholder is ambiguous:
- Interpretation A: Checkpoint directory **name** only (`child_v1_01`)
- Interpretation B: Full relative **path** from work root (`parent_v1_01/child_v1_01`)

## Design Options

### Option A: Use Full Relative Path
```python
rel_path = checkpoint.path.relative_to(ctx.work_root)
logs_dir = ctx.work_root / "logs" / rel_path
```

**Pros:**
- Eliminates collision risk entirely
- Log directory structure mirrors checkpoint hierarchy
- Clear provenance for every log file

**Cons:**
- Deeper nesting in logs directory
- Breaks existing log paths if anyone depends on them

**Example:**
- Top-level: `logs/child_v1_01/harness_*.log`
- Delegate: `logs/parent_v1_01/child_v1_01/harness_*.log`

### Option B: Keep Current Behavior (Name Only)
Keep using `checkpoint.name` as-is.

**Pros:**
- Simpler flat structure in logs directory
- No breaking changes
- Timestamps already prevent file overwrites

**Cons:**
- Ambiguous provenance when names collide
- Requires manual inspection to determine which checkpoint ran which log

**Mitigation:** Document that checkpoint names should be unique across the work hierarchy, or accept that log directories may be shared by multiple checkpoints with the same name.

### Option C: Enforce Globally Unique Names
Add validation that checkpoint names must be globally unique across the work hierarchy.

**Pros:**
- Eliminates ambiguity at the source
- Simpler mental model: one name = one checkpoint

**Cons:**
- Restricts naming flexibility for delegates
- Delegates would need different names than their parents even for identical tasks
- May conflict with natural naming patterns (e.g., `cleanup_v1_01` delegate inside multiple parent checkpoints)

## Recommendation

**Prefer Option A** (use full relative path) for these reasons:

1. **Future-proof:** Scales cleanly as checkpoint hierarchies grow deeper
2. **Self-documenting:** Log directory structure provides visual hierarchy
3. **Zero ambiguity:** No need to cross-reference checkpoint locations when reviewing logs
4. **Low risk:** Breaking change is minimal since harness logs are typically ephemeral debugging artifacts

However, this requires:
- Updating `CLI_REFERENCE.md` to clarify `{checkpoint}` means "full relative path from work root"
- Updating `SYSTEM_PROMPT.md` to reflect the same
- Adding a note in `FRAMEWORK_SPEC.md` §9 about log path structure

## Related Files

- `bin/_acft_verify.py` (implementation)
- `spec/CLI_REFERENCE.md` (documentation)
- `spec/FRAMEWORK_SPEC.md` (specification)
- `spec/SYSTEM_PROMPT.md` (agent guidance)
