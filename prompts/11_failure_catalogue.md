# Failure Catalogue for AI Agents

## What It Is

13 documented anti-patterns that break the framework. Each discovered in production use.

## Purpose

Prevent common failures by knowing what to avoid.

## Key Failure Modes

### Validation Theater
**Problem**: Setting VALID: true without running harness

**Symptoms:**
- LOG says "manual review" instead of showing harness execution
- No recent HARNESS_EXECUTED event when VALID: true
- No logs in LOGS/ directory

**Fix:**
- Run harness commands from HARNESS section
- Save outputs to LOGS/
- Log execution in LOG section
- Only then set VALID: true

### Goal Fog
**Problem**: Success criteria or exit conditions undefined

**Symptoms:**
- STATUS lacks clear objectives
- LOG shows busy work without closure
- HARNESS hard to write (because unclear what success means)

**Fix:**
- State measurable success criteria in STATUS during PREPARE
- Define exit conditions
- Update criteria as facts change
- Log when criteria met or redefined

### Dependency Fog
**Problem**: Work relies on sibling/parent deliverables without explicit contract

**Symptoms:**
- MANIFEST references paths without status
- LOG lacks dependency checkpoints
- Work fails mysteriously

**Fix:**
- Document each dependency in MANIFEST with status (ready/pending/blocked)
- Log when dependencies change
- Mark VALID: false until upstream resolved

### History Drift
**Problem**: Major context lives only in ancestor CHECKPOINTs

**Symptoms:**
- Successor CHECKPOINTs lack synopsis
- New agents reread entire work hierarchy
- Context scattered across multiple files

**Fix:**
- Include "Context recap" in STATUS summarizing inherited decisions
- Use rooted links to prior work
- Reference prior LOG entries before new decisions

### Scope Shock
**Problem**: Stakeholder shifts scope midstream

**Symptoms:**
- LOG shows new directives
- STATUS still reflects old plan
- Child CHECKPOINTs lack links to pivot

**Fix:**
- Log the change with stakeholder source
- Capture superseded context in CONTEXT section
- Either adapt plan or open/retire CHECKPOINTs with clear cross-links

### Other Failure Modes

The complete list includes 13 patterns:

1. Missing harness
2. Stale contract
3. Ghost deliverables
4. Opaque paths
5. Undocumented blockers
6. Silent stage pollution
7. Version drift
8. Scope shock
9. History drift
10. Dependency fog
11. Goal fog
12. Validation theater
13. Ledger drift

See `spec/FAILURE_CATALOGUE_TABLE.md` for complete details.

## How to Use

### Before Closing CHECKPOINT

Audit yourself against all 13 failure modes:

- [ ] Harness defined and executed?
- [ ] MANIFEST LEDGER current?
- [ ] Deliverables exist at listed paths?
- [ ] All paths use rooted prefixes?
- [ ] Blockers documented?
- [ ] STAGE/ cleared or empty?
- [ ] No version conflicts?
- [ ] Scope changes logged with sources?
- [ ] Context recap in STATUS?
- [ ] Dependencies explicit with status?
- [ ] Success criteria clear?
- [ ] VALID: true only if harness passed?
- [ ] MANIFEST LEDGER matches ARTIFACTS/?

### During Development

Watch for symptoms:
- Unclear what success means → Goal fog
- Missing dependency causing failures → Dependency fog
- Can't explain what happened → History drift
- Requirements changed → Scope shock
- Ready to close but harness not run → Validation theater

Catch failures early, fix immediately.

## Detection Methods

Each failure mode has detection methods:

**Automated:**
- `acft validate ::THIS` catches many patterns
- `rg` searches for anti-patterns (e.g., `rg "manual review"`)
- Missing events in event stream

**Manual:**
- Reviewing CHECKPOINT.md sections
- Checking MANIFEST LEDGER vs ARTIFACTS/
- Verifying rooted paths resolve
- Confirming harness actually ran

Run validation before setting VALID: true.

## Why This Matters

Failure catalogue = framework immune system:
- Identifies infections (anti-patterns)
- Provides remedies (fixes)
- Prevents recurrence (by naming them)

These aren't theoretical. They all broke real work. Learn from them.

## Quick Reference

Common failure → Quick fix:

- **No harness** → Define verification commands in HARNESS
- **Stale MANIFEST** → Update MANIFEST LEDGER when creating artifacts
- **Bare paths** → Convert to rooted paths (::THIS/, ::WORK/, ::PROJECT/)
- **Undocumented blocker** → Add to STATUS, log in LOG, keep VALID: false
- **Unclear success** → Write explicit success criteria in STATUS
- **Missing context** → Add context recap to STATUS
- **Dependency surprise** → Document all dependencies in MANIFEST with status

When in doubt, check `spec/FAILURE_CATALOGUE_TABLE.md` for full details.
