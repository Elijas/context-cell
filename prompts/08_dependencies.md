# Dependencies for AI Agents

## Where They Go

In MANIFEST section, AFTER the MANIFEST LEDGER:

```markdown
# MANIFEST

## MANIFEST LEDGER
[outputs here]

## Dependencies

### CHECKPOINT DEPENDENCIES
[other CHECKPOINTs you need]

### SYSTEM DEPENDENCIES
[external requirements]
```

## Two Types

### CHECKPOINT DEPENDENCIES

Other CHECKPOINTs your work depends on:

```markdown
### CHECKPOINT DEPENDENCIES

- ::WORK/auth_v2_01/CHECKPOINT.md (LIFECYCLE: active, VALID: true)
  Status: ready
  Purpose: Authentication module we import

- ::WORK/data_model_v1_03/CHECKPOINT.md (LIFECYCLE: active, VALID: false)
  Status: pending
  Purpose: Data structures we need (blocked on this)
```

**Must include:**
- Rooted path to CHECKPOINT.md
- LIFECYCLE state
- VALID state
- Status: ready/pending/blocked
- Purpose: Why you need it

### SYSTEM DEPENDENCIES

External requirements:

```markdown
### SYSTEM DEPENDENCIES

- Python 3.11+
- PostgreSQL 14
- AWS credentials (read access to S3 bucket xyz)
- OpenAI API key (GPT-4 access)
```

**Include:**
- Software with version requirements
- Services and APIs
- Credentials and access needs
- Environment requirements

## When to Update

Update Dependencies section when:
- [ ] Starting CHECKPOINT (identify what you need)
- [ ] Discovering new dependency
- [ ] Dependency changes state (pending → ready)
- [ ] Dependency becomes blocker
- [ ] Before setting VALID: true

## Blocker Handling

If dependency is blocking you:

1. Mark status as "blocked"
2. Document in STATUS section
3. Keep VALID: false
4. Keep LIFECYCLE: active (temporary blocker)
5. Log in LOG section

Example:
```markdown
### CHECKPOINT DEPENDENCIES

- ::WORK/api_client_v1_05/CHECKPOINT.md (LIFECYCLE: active, VALID: false)
  Status: blocked
  Purpose: API client we need to call backend
  Note: Waiting for API client to pass harness before we can test our integration
```

## Common Patterns

**No CHECKPOINT dependencies:**
```markdown
### CHECKPOINT DEPENDENCIES

None - this is a leaf CHECKPOINT with no upstream dependencies
```

**Multiple CHECKPOINT dependencies:**
```markdown
### CHECKPOINT DEPENDENCIES

- ::WORK/auth_v2_01/CHECKPOINT.md (LIFECYCLE: active, VALID: true)
  Status: ready
  Purpose: Authentication

- ::WORK/database_v3_02/CHECKPOINT.md (LIFECYCLE: active, VALID: true)
  Status: ready
  Purpose: Database schema and migrations
```

**Minimal system requirements:**
```markdown
### SYSTEM DEPENDENCIES

- Python 3.11+
- Standard library only (no external packages)
```

**Complex system requirements:**
```markdown
### SYSTEM DEPENDENCIES

- Python 3.11+
- PostgreSQL 14
- Redis 7.0
- AWS credentials (S3 read/write to bucket xyz)
- Stripe API key (test mode)
- SMTP server (for email notifications)
```

## Why This Matters

Dependencies section prevents:
- **Dependency fog** - unclear what you need
- **Silent failures** - missing deps cause mysterious errors
- **Blocked work** - starting without checking dependencies available

Make dependencies explicit up front, catch blockers early.

## Quick Check

Before setting VALID: true:

1. Are all CHECKPOINT dependencies listed?
2. Are their LIFECYCLE/VALID states current?
3. Are any dependencies blocking you?
4. Are all system dependencies documented?
5. Can harness actually run with these dependencies?

If uncertain about any dependency state, check it before proceeding.
