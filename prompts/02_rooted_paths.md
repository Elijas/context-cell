# Rooted Paths for AI Agents

## Critical Rule

ALWAYS use rooted paths in MANIFEST and dependency references. Never use bare relative paths like `./` or `../`.

## Path Prefixes

```
::THIS/ARTIFACTS/output.txt           ← Files produced inside my CHECKPOINT
::PROJECT/shared/config.json          ← Project root
::WORK/auth_v2_01/CHECKPOINT.md       ← Any CHECKPOINT from work root
```

## How It Works

The system locates two marker files:
- `checkpoints_project.toml` → defines ::PROJECT/
- `checkpoints_work.toml` → defines ::WORK/

These files are empty but mark the anchor points for path resolution.

## When Creating References

**Wrong:**
```yaml
dependencies:
  - ../other_checkpoint/output.txt
  - ./ARTIFACTS/result.json
```

**Correct:**
```yaml
dependencies:
  - ::WORK/other_checkpoint/output.txt
  - ::THIS/ARTIFACTS/result.json
```

## Common Patterns

- Reference my own artifacts: `::THIS/ARTIFACTS/foo.py`
- Reference project resource: `::PROJECT/shared/utils.py`
- Reference any checkpoint: `::WORK/some_checkpoint_v2_03/results.md`

## Why This Matters

Rooted paths stay valid when:
- Directories are moved
- Work is archived
- Checkpoints are mirrored to different systems

Tools resolve these automatically - you just need to use the correct prefix.
