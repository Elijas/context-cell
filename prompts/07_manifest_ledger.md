# MANIFEST LEDGER for AI Agents

## What It Is

A table listing all outputs from your CHECKPOINT. MUST be first thing in MANIFEST section.

## Format

```markdown
# MANIFEST

## MANIFEST LEDGER

| Name | Path | Purpose |
|------|------|---------|
| output.py | ::THIS/ARTIFACTS/output.py | Main module |
| config.json | ::PROJECT/config/settings.json | Configuration |
```

## Critical Rules

1. **Position**: MUST be first subsection under `# MANIFEST`
2. **Columns**: Name, Path, Purpose (in that order)
3. **Paths**: MUST use correct rooted prefix:
   - Your CHECKPOINT files → `::THIS/`
   - Other CHECKPOINT files → `::WORK/`
   - Project files (not in any CHECKPOINT) → `::PROJECT/`
4. **Completeness**: List every deliverable output

## During Development

Start with stub:

```markdown
| Name | Path | Purpose |
|------|------|---------|
| (stub) | (stub) | (stub) |
```

Update as you create artifacts.

## Before Setting VALID: true

Ledger MUST have real entries:

```markdown
| Name | Path | Purpose |
|------|------|---------|
| auth.py | ::THIS/ARTIFACTS/auth.py | Authentication module |
| tests.py | ::THIS/ARTIFACTS/tests.py | Unit tests |
```

All paths MUST:
- Use rooted prefixes
- Point to actual files that exist
- Be accurate and current

## What to Include

List outputs in:
- `::THIS/ARTIFACTS/` - Main deliverables
- `::THIS/LOGS/` - Execution logs, test results
- `::PROJECT/` - Project-level outputs (if any)

## What NOT to Include

Don't list:
- Temporary files in STAGE/
- Files you depend on (those go in Dependencies section)
- Files that don't exist yet (unless stub during development)

## Common Patterns

**Single output:**
```markdown
| Name | Path | Purpose |
|------|------|---------|
| report.md | ::THIS/ARTIFACTS/report.md | Analysis report |
```

**Multiple outputs:**
```markdown
| Name | Path | Purpose |
|------|------|---------|
| module.py | ::THIS/ARTIFACTS/module.py | Main implementation |
| test_module.py | ::THIS/ARTIFACTS/test_module.py | Unit tests |
| results.log | ::THIS/LOGS/test_results_20251103.log | Test execution log |
```

**Permanent blocker (no outputs):**
```markdown
| Name | Path | Purpose |
|------|------|---------|
| N/A | N/A | No outputs - work proven impossible (see STATUS) |
```

## Update Checklist

Update MANIFEST LEDGER when:
- [ ] Creating new artifact
- [ ] Moving/renaming artifact
- [ ] Deleting artifact
- [ ] Before running harness
- [ ] Before setting VALID: true

## Quick Check

Before closing CHECKPOINT:

1. Is MANIFEST LEDGER first in MANIFEST?
2. Are all outputs listed?
3. Do all paths use rooted prefixes?
4. Do all paths point to real files?
5. Is Purpose column filled for each entry?

If "no" to any, fix before setting VALID: true.

## Validation

```bash
acft validate ::THIS
```

This checks:
- MANIFEST LEDGER exists
- MANIFEST LEDGER is first
- Correct table structure
- Rooted paths used
- Paths resolve (when VALID: true)
- No stubs remain (when VALID: true)
