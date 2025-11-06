# LOG Format for AI Agents

## Purpose

Timestamped audit trail of all significant actions in CHECKPOINT.

## Format

```markdown
# LOG

**YYYY-MM-DDTHH:MM:SSZ** - [Actor] Action description
- Detail 1
- Detail 2
- Links to artifacts or external sources

**YYYY-MM-DDTHH:MM:SSZ** - [Actor] Next action
- More details
```

## Components

### Timestamp
- **Format**: ISO 8601 UTC
- **Pattern**: `YYYY-MM-DDTHH:MM:SSZ`
- **Example**: `2025-11-03T14:30:00Z`
- **Always use UTC**: The `Z` at the end means UTC timezone

### Actor
- **Format**: `[ActorName]`
- **Examples**:
  - `[Claude]` - AI agent
  - `[Alice]` - Human name
  - `[System]` - Automated process
- **Brackets required**: Always use square brackets

### Action
- **Format**: Brief description of what happened
- **Style**: Past tense, clear, specific
- **Examples**:
  - "Created CHECKPOINT"
  - "Ran harness"
  - "Discovered blocker"
  - "Updated success criteria"

### Details (optional but recommended)
- Bullet points under the action
- Specific information about what happened
- Links to artifacts, logs, or external sources
- Rooted paths when referencing files

## When to Log

MUST log these events:

1. **CHECKPOINT creation**
   ```markdown
   **2025-11-03T14:30:00Z** - [Claude] Created CHECKPOINT
   - Initialized from user directive (see transcript link)
   - Created initial structure with five required sections
   ```

2. **Major decisions**
   ```markdown
   **2025-11-03T15:00:00Z** - [Claude] Chose PostgreSQL over MongoDB
   - Need ACID guarantees for transactions
   - Team has PostgreSQL expertise
   - See CONTEXT section for full rationale
   ```

3. **Harness execution**
   ```markdown
   **2025-11-03T17:20:00Z** - [Claude] Ran harness
   - All tests passed (127 tests, 0 failures)
   - Build completed successfully
   - See ::THIS/LOGS/harness_20251103_172000.log
   ```

4. **Blocker discovery**
   ```markdown
   **2025-11-03T16:00:00Z** - [Claude] Discovered blocker
   - Upstream API endpoint not yet deployed
   - Cannot test integration until API available
   - Updated STATUS section with blocker details
   ```

5. **Scope changes**
   ```markdown
   **2025-11-04T10:00:00Z** - [Alice] Scope change requested
   - Source: Slack message from @bob (link)
   - Now includes admin panel in addition to user interface
   - Updated success criteria in STATUS
   ```

6. **CHECKPOINT closure**
   ```markdown
   **2025-11-04T18:00:00Z** - [Claude] Closed CHECKPOINT
   - Harness passed, all criteria met
   - Set VALID: true, LIFECYCLE: active
   - Deliverables documented in MANIFEST LEDGER
   ```

## Examples

### Initial Creation
```markdown
**2025-11-03T14:30:00Z** - [Claude] Created CHECKPOINT
- Initialized auth_v1_01 from user request
- Created directory structure and CHECKPOINT.md
- Populated stub sections
```

### Iterative Work
```markdown
**2025-11-03T15:45:00Z** - [Claude] Implemented authentication module
- Created ::THIS/ARTIFACTS/auth.py
- Added JWT token generation and validation
- Updated MANIFEST LEDGER

**2025-11-03T16:30:00Z** - [Claude] Wrote tests
- Created ::THIS/ARTIFACTS/test_auth.py
- 15 test cases covering happy path and edge cases
- Updated MANIFEST LEDGER
```

### Blocker and Resolution
```markdown
**2025-11-03T17:00:00Z** - [Claude] Discovered dependency blocker
- Need ::WORK/database_v1_02 to complete integration tests
- Database schema not yet finalized
- Set VALID: false, documented in STATUS

**2025-11-04T09:00:00Z** - [Claude] Blocker resolved
- ::WORK/database_v1_02 now VALID: true
- Proceeding with integration tests
```

### Scope Change with Citation
```markdown
**2025-11-04T11:00:00Z** - [Bob] Requested scope change
- Source: Email thread "Auth requirements update" (2025-11-04)
- Add OAuth support in addition to JWT
- Updated success criteria in STATUS
- May require version bump to v2
```

## Quick Reference

**Timestamp generation:**
- Command line: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
- Python: `datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")`
- Just remember: `YYYY-MM-DDTHH:MM:SSZ`

**Entry template:**
```markdown
**YYYY-MM-DDTHH:MM:SSZ** - [Actor] Action
- Detail
- Detail
- Link/reference
```

## Anti-Patterns

❌ **Don't do this:**
- Missing timestamps
- Non-UTC timestamps without timezone
- Unclear actor (`Updated file` - who?)
- Vague actions (`Did stuff`)
- No context for scope changes

✅ **Do this:**
- ISO 8601 UTC timestamps
- Clear actor identification
- Specific action descriptions
- Details with links/paths
- Cite sources for scope changes

## Why This Matters

LOG section prevents:
- **History drift**: Forgetting what happened when
- **Lost context**: Not knowing why decisions were made
- **Unclear timeline**: Can't reconstruct sequence of events
- **Missing audit trail**: No accountability

Always log significant actions. Future you will thank present you.
