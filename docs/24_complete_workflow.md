# Bite 24: Putting It All Together (Complete Workflow Example)

We've covered all the pieces. Now let's see how they work together in a **complete workflow**.

## Scenario: Implement User Authentication

### Step 1: PREPARE (Define Success)

**Create the CHECKPOINT:**
```bash
acft new auth_v1_01
```

**Define success criteria before coding:**

```yaml
---
VALID: false
LIFECYCLE: active
SIGNAL: pending
---

# STATUS

## Goal
Implement JWT-based authentication for API

## Success Criteria
- Users can login with username/password
- JWT tokens issued with 1hr expiry
- Protected endpoints verify tokens
- Tests pass with 90%+ coverage

## Open Questions
- Token refresh strategy?
- Session storage approach?

# HARNESS
[Will populate after designing harness]

# CONTEXT
[Will document decisions as we make them]

# MANIFEST
[Will list deliverables as they're created]

# LOG
- 2025-02-10T10:00:00Z - Created CHECKPOINT for JWT authentication
```

### Step 2: SPECIFY (Design the Harness)

**Add harness before implementing:**

```markdown
# MANIFEST

## MANIFEST LEDGER
[Will populate as deliverables are created]

## Harness

Run the test suite:
```bash
pytest tests/auth/ -v --cov=auth
```

Manual verification:
```bash
# Should return JWT token
curl -X POST localhost:8000/login -d '{"user":"test","pass":"test123"}'

# Should accept valid token
curl -H "Authorization: Bearer $TOKEN" localhost:8000/protected

# Should reject invalid token
curl -H "Authorization: Bearer invalid" localhost:8000/protected
```

Expected: All tests pass, manual checks succeed

## Dependencies

### SYSTEM DEPENDENCIES
- PostgreSQL 14+ (for user storage) - Available locally
- pytest, pytest-cov - Installed
- Flask 2.0+ - Installed
```

### Step 3: BUILD (Implement)

**Create implementation in ARTIFACTS/:**
- `ARTIFACTS/auth.py` - JWT implementation
- `ARTIFACTS/tests/auth_tests.py` - Test suite

**Update MANIFEST LEDGER as you create files:**
```markdown
## MANIFEST LEDGER
- `auth.py` - ::THIS/ARTIFACTS/auth.py - JWT token generation and validation
- `auth_tests.py` - ::THIS/ARTIFACTS/tests/auth_tests.py - Test suite with 95% coverage
```

**Log progress:**
```markdown
# LOG
- 2025-02-10T10:00:00Z - Created CHECKPOINT for JWT authentication
- 2025-02-10T12:30:00Z - Implemented JWT generation and validation
- 2025-02-10T14:00:00Z - Test suite complete
```

### Step 4: VERIFY (Run the Harness)

**Execute verification:**
```bash
acft verify --record
```

**If it passes:**
```bash
acft close --signal pass
```

**Update LOG:**
```markdown
- 2025-02-10T15:00:00Z - Harness passed, all tests green, manual checks succeed
```

### Step 5: HANDOFF (Complete the Contract)

**Fill in all sections:**

```markdown
# STATUS

## Context Recap
Starting fresh, no prior auth implementation

## Goal
JWT-based authentication for API - COMPLETE

## Success Criteria Met
✓ Users can login with username/password
✓ JWT tokens issued with 1hr expiry
✓ Protected endpoints verify tokens
✓ Tests pass with 95% coverage

# HARNESS

JWT authentication system implemented and verified. Users authenticate via POST to /login with credentials, receive JWT token with 1hr expiry. Protected endpoints validate tokens. Test suite achieves 95% coverage. Manual verification confirms token generation, validation, and rejection of invalid tokens all work correctly.

# CONTEXT

## Why JWT
Chose JWT over session-based auth because:
- Stateless (scales horizontally)
- Standard (RFC 7519)
- Client can inspect claims

Considered sessions but rejected due to state management complexity in distributed deployment.

## Token Expiry
1hr expiry balances security (short-lived) with UX (not too frequent re-auth). Refresh tokens deferred to auth_v1_02 based on user feedback priority.
```

**Validate and close:**
```bash
acft validate ::THIS
acft close --status true --signal pass --message "Auth implementation complete and verified"
```

## The Complete CHECKPOINT

```yaml
---
VALID: true
LIFECYCLE: active
SIGNAL: pass
---

# STATUS

## Context Recap
Starting fresh, no prior auth implementation

## Goal
JWT-based authentication for API - COMPLETE

## Success Criteria Met
✓ Users can login with username/password
✓ JWT tokens issued with 1hr expiry
✓ Protected endpoints verify tokens
✓ Tests pass with 95% coverage

# HARNESS

JWT authentication system implemented and verified. Users authenticate via POST to /login, receive JWT token with 1hr expiry. Protected endpoints validate tokens. Test suite achieves 95% coverage with all tests passing.

# CONTEXT

## Why JWT
Chose JWT over session-based auth because:
- Stateless (scales horizontally)
- Standard (RFC 7519)
- Client can inspect claims

## Token Expiry
1hr expiry balances security with UX. Refresh tokens deferred to v1_02.

# MANIFEST

## MANIFEST LEDGER
- `auth.py` - ::THIS/ARTIFACTS/auth.py - JWT token generation and validation
- `auth_tests.py` - ::THIS/ARTIFACTS/tests/auth_tests.py - Test suite (95% coverage)

## Harness
[Commands listed above - all passed]

## Dependencies
### SYSTEM DEPENDENCIES
- PostgreSQL 14+ - Available, connected
- pytest, pytest-cov - Installed
- Flask 2.0+ - Installed

# LOG
- 2025-02-10T10:00:00Z - Created CHECKPOINT for JWT authentication
- 2025-02-10T12:30:00Z - Implemented JWT generation and validation
- 2025-02-10T14:00:00Z - Test suite complete
- 2025-02-10T15:00:00Z - Harness passed (SIGNAL:pass)
- 2025-02-10T15:15:00Z - Contract complete, set VALID:true
```

## Key Takeaways

**The workflow ensures:**
1. Success defined before coding (PREPARE)
2. Verification designed before implementing (SPECIFY)
3. Work tracked as it happens (BUILD)
4. Harness actually runs (VERIFY)
5. Contract complete for handoff (HANDOFF)

**At each stage, CHECKPOINT.md stays current** - it's not documentation written afterward, it's the working contract throughout.

This is **harness-first, contract-driven development** in action.
