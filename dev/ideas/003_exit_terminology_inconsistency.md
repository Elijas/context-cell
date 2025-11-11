# Ambiguity #003: Exit Terminology Inconsistency

**Date:** 2025-11-11
**Discovered during:** Systematic audit of ACF implementation vs. specification
**Severity:** Low
**Status:** Unresolved - requires terminology standardization

## Issue Summary

The ACF specification uses two different terms interchangeably when referring to checkpoint completion conditions: **"exit criteria"** and **"exit conditions"**. The implementation validates for one variant, causing misalignment depending on which part of the spec an agent follows.

## Inconsistency Locations

### Specification Uses "Exit Conditions"

**File:** `spec/FRAMEWORK_SPEC.md` (multiple locations)

Section 3.2 table (line ~88):
```markdown
| `# STATUS`   | Rolling facts, risks, open questions discovered while working.
| Keep it current by... enumerate current success criteria and **exit conditions**
```

Section 4 workflow (line ~115):
```markdown
1. **PREPARE** - Define the question "How will we know this works?" before implementation.
   - Summarize inherited context: which CHECKPOINTS delivered what, open risks, outstanding dependencies.
   - Write explicit success criteria and **exit conditions** so pivots are intentional, not accidental.
```

### Specification Uses "Exit Criteria"

**File:** `spec/FAILURE_CATALOGUE_TABLE.md` (line ~12)

```markdown
| Goal fog | Missing explicit success or **exit criteria**. |
```

Also in `spec/FRAMEWORK_SPEC.md` §7 table where the catalogue is included.

### Implementation Validates for "Criteria"

**File:** `bin/_acft_validate.py:68`

```python
if "Success criteria" not in status or "Exit criteria" not in status:
    warnings.append("STATUS should list success and exit criteria.")
```

**File:** `bin/_acft_manifest.py:388`

```python
def check_goal_fog(
    checkpoint: Checkpoint, ctx: AcftContext, _: Sequence[Checkpoint]
) -> Optional[str]:
    status = checkpoint.sections.get("STATUS", "")
    if "Success criteria" not in status or "Exit criteria" not in status:
        return "STATUS must capture success and exit criteria."
```

## Impact

Agents following different sections of the spec will use different terminology:
- Agent reading §3.2 or §4 → writes "**exit conditions**" in STATUS
- Agent reading failure catalogue → writes "**exit criteria**" in STATUS
- Validation → warns about missing "**exit criteria**"

This creates confusion and validation noise without adding value.

## Design Options

### Option A: Standardize on "Criteria"
Change all spec references to use "exit criteria" consistently.

**Rationale:**
- Parallels "success criteria" (already standard)
- Implementation already validates for this term
- Failure catalogue already uses this term

**Changes required:**
- `spec/FRAMEWORK_SPEC.md` §3.2 table: "exit conditions" → "exit criteria"
- `spec/FRAMEWORK_SPEC.md` §4 workflow: "exit conditions" → "exit criteria"
- `spec/SYSTEM_PROMPT.md` (if it has similar language)

### Option B: Standardize on "Conditions"
Change spec and implementation to use "exit conditions" consistently.

**Rationale:**
- "Criteria" implies evaluation metrics, while "conditions" implies state-based triggers
- Exit might naturally be condition-based ("when X is done") vs. criteria-based ("did we achieve Y?")

**Changes required:**
- `spec/FAILURE_CATALOGUE_TABLE.md`: "exit criteria" → "exit conditions"
- `bin/_acft_validate.py:68`: "Exit criteria" → "Exit conditions"
- `bin/_acft_manifest.py:388`: "Exit criteria" → "Exit conditions"

### Option C: Accept Both Terms
Allow both "exit criteria" and "exit conditions" in validation.

**Implementation:**
```python
has_exit = "Exit criteria" in status or "Exit conditions" in status
if "Success criteria" not in status or not has_exit:
    warnings.append("STATUS should list success criteria and exit criteria/conditions.")
```

**Rationale:**
- Preserves flexibility for agent interpretation
- Acknowledges that both terms are semantically similar

**Cons:**
- Maintains ambiguity rather than resolving it
- Requires more complex validation logic

## Recommendation

**Prefer Option A** (standardize on "criteria") for these reasons:

1. **Minimal disruption:** Implementation already uses "criteria"
2. **Parallel structure:** Matches "success criteria" terminology
3. **Clear ownership:** Failure catalogue is the authoritative reference for validation rules
4. **Single source of truth:** Easier to maintain consistency going forward

However, this requires a coordinated update across specification files to ensure all references are aligned.

## Related Files

- `spec/FRAMEWORK_SPEC.md` (multiple sections)
- `spec/FAILURE_CATALOGUE_TABLE.md` (goal_fog entry)
- `spec/SYSTEM_PROMPT.md` (agent guidance)
- `bin/_acft_validate.py` (validation implementation)
- `bin/_acft_manifest.py` (failure catalogue implementation)

## Resolution Path

1. Choose standardized term (recommend "criteria")
2. Update all spec files in a single commit
3. Verify implementation matches chosen term
4. Add note in `FRAMEWORK_FOUNDATION.md` documenting why this term was chosen
5. Bump spec version to signal the clarification
