# ACF Implementation Audit Summary

**Date:** 2025-11-11
**Auditor:** Claude (Sonnet 4.5)
**Scope:** Systematic comparison of bin/ implementation vs. spec/ documentation

## Audit Methodology

1. Read all CLI command implementations in `bin/`
2. Compare behavior against specifications in `spec/FRAMEWORK_SPEC.md`, `spec/CLI_REFERENCE.md`, and `spec/SYSTEM_PROMPT.md`
3. Verify event emission compliance
4. Check frontmatter handling and validation rules
5. Validate LIFECYCLE state enforcement

## Issues Found

### Critical Bugs

#### ✅ FIXED: Bug #1 - Path Resolution in `acft new`
- **File:** `bin/_acft_new.py:48`
- **Issue:** Always created checkpoints at work_root level, ignoring checkpoint_root context
- **Impact:** Delegates created as siblings instead of children
- **Status:** Fixed in session by adding conditional logic to use checkpoint_root when available
- **Fix:** Added `parent_dir = ctx.checkpoint_root if ctx.checkpoint_root else ctx.work_root`

### Ambiguities Requiring Design Decision

#### 🟡 Ambiguity #002 - Harness Log Path Collision
- **Severity:** Medium
- **File:** `bin/_acft_verify.py:56`
- **Issue:** Uses checkpoint name only, creating potential collisions when delegates share names with top-level checkpoints
- **Status:** Documented in `002_harness_log_path_collision.md`
- **Recommendation:** Use full relative path from work_root

#### 🟡 Ambiguity #003 - Exit Terminology Inconsistency
- **Severity:** Low
- **Files:** Multiple spec files, validation implementation
- **Issue:** Spec uses both "exit criteria" and "exit conditions" interchangeably
- **Status:** Documented in `003_exit_terminology_inconsistency.md`
- **Recommendation:** Standardize on "exit criteria" throughout

## Validated Implementations

The following implementations were verified as correct and spec-compliant:

### ✅ `acft close`
- Correctly enforces `VALID: true` requires `LIFECYCLE: active`
- Validates MANIFEST LEDGER entries use `::THIS/ARTIFACTS` paths
- Emits proper events (`CHECKPOINT_VERIFIED`, optionally `CHECKPOINT_CLOSED`)
- Updates frontmatter atomically

### ✅ `acft orient`
- Properly discovers ancestry/peers/children relationships
- Handles both delegate-based and version-step-based lineage
- Displays contract signals (VALID, LIFECYCLE, SIGNAL) correctly
- Supports configurable section expansion and depth traversal

### ✅ `acft manifest`
- Implements all 13 failure catalogue checks from spec
- Detects missing harness, stale contracts, validation theater
- Supports quick (target only) and full (descendants) modes
- Emits MANIFEST_UPDATED with aggregated severity

### ✅ `acft validate`
- Enforces checkpoint naming convention (`{branch}_v{version}_{step}`)
- Validates frontmatter structure (VALID, LIFECYCLE)
- Enforces required section ordering (STATUS, HARNESS, CONTEXT, MANIFEST, LOG)
- Detects unrooted and relative paths
- Warns on leftover STAGE/ artifacts when VALID: true
- Checks for empty sections, missing context recap, goal fog

### ✅ `acft verify`
- Executes MANIFEST harness commands sequentially
- Creates uniquely timestamped log files
- Emits HARNESS_EXECUTED with command outcomes and log path
- Fails fast on command errors

### ✅ `acft expand`
- Correctly expands rooted prefixes (::PROJECT/, ::WORK/, ::THIS/)
- Supports symlink resolution when requested
- Provides clear error messages for missing paths

### ✅ Event Emission System
- All mutating commands emit structured events
- Event schema matches spec (TYPE, CHECKPOINT_PATH, ACTOR, TIMESTAMP, PAYLOAD)
- Canonical event types implemented:
  - CHECKPOINT_CREATED
  - HARNESS_EXECUTED
  - CHECKPOINT_VERIFIED
  - CHECKPOINT_CLOSED
  - MANIFEST_UPDATED
- Events written to both stdout (JSON) and event log file

### ✅ Core Library (`_lib.py`)
- AcftContext correctly discovers project/work/checkpoint roots
- Rooted path expansion handles all prefix types
- Checkpoint class properly parses frontmatter and sections
- YAML parsing supports both PyYAML and fallback implementation
- Manifest ledger parsing handles markdown list format

## Testing Performed

### Manual Verification Tests

1. **Delegate creation test:** Created test checkpoint hierarchy and verified fix for bug #1
2. **Path expansion test:** Verified rooted prefixes resolve correctly
3. **Event emission test:** Confirmed events appear in both stdout and log file

### Code Review Checks

- ✅ All commands handle missing roots gracefully with error messages
- ✅ Frontmatter updates preserve key ordering
- ✅ LOG entries use ISO 8601 UTC timestamps
- ✅ Section rewriting preserves markdown structure
- ✅ Failure catalogue detectors match spec definitions

## Recommendations

### Immediate Actions

1. **Decide on log path structure** - resolve ambiguity #002
   - If choosing full relative path: update implementation in `_acft_verify.py`
   - Update `CLI_REFERENCE.md` to clarify `{checkpoint}` placeholder meaning

2. **Standardize exit terminology** - resolve ambiguity #003
   - Recommend: use "exit criteria" throughout
   - Update all spec files in single commit
   - Verify validation logic matches

### Future Improvements

1. **Add unit tests** for critical path resolution logic
2. **Add integration tests** for delegate creation scenarios
3. **Document checkpoint naming conventions** - consider whether globally unique names are required or recommended
4. **Add checkpoint ID system** if global uniqueness becomes important

## Files Modified During Audit

- ✅ `bin/_acft_new.py` - Fixed to respect checkpoint_root context

## Files Requiring Updates (Pending Decision)

### If resolving ambiguity #002:
- `bin/_acft_verify.py` - Update log path construction
- `spec/CLI_REFERENCE.md` - Clarify `{checkpoint}` placeholder
- `spec/FRAMEWORK_SPEC.md` - Add note about log path structure

### If resolving ambiguity #003:
- `spec/FRAMEWORK_SPEC.md` - Standardize on "criteria"
- `spec/SYSTEM_PROMPT.md` - Update terminology
- `spec/FAILURE_CATALOGUE_TABLE.md` - Verify consistency
- `bin/_acft_validate.py` - Verify matches chosen term
- `bin/_acft_manifest.py` - Verify matches chosen term

## Conclusion

The ACF implementation is **largely sound and spec-compliant**. The critical bug in `acft new` has been fixed. The remaining issues are low-impact ambiguities that require design decisions rather than implementation bugs.

The framework demonstrates good separation of concerns, robust error handling, and consistent event emission patterns. The 13-item failure catalogue is fully implemented and the validation system catches the intended anti-patterns.
