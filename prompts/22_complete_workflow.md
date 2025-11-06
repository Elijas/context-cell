# Complete Workflow Example for AI Agents

## Full Lifecycle: Auth Implementation

### PREPARE Stage

**1. Create CHECKPOINT**
```bash
acft new auth_v1_01
```

**2. Define success BEFORE coding**
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
```

**3. Log creation**
```markdown
# LOG
- 2025-02-10T10:00:00Z - Created CHECKPOINT for JWT authentication
```

### SPECIFY Stage

**4. Design harness BEFORE implementing**
```markdown
# MANIFEST

## Harness

Automated tests:
```bash
pytest tests/auth/ -v --cov=auth
```

Manual verification:
```bash
curl -X POST localhost:8000/login -d '{"user":"test","pass":"test123"}'
curl -H "Authorization: Bearer $TOKEN" localhost:8000/protected
```

Expected: All tests pass, tokens validate correctly

## Dependencies
### SYSTEM DEPENDENCIES
- PostgreSQL 14+ - Available
- pytest, pytest-cov - Installed
```

**5. Stub MANIFEST LEDGER**
```markdown
## MANIFEST LEDGER
[Will populate as deliverables are created]
```

### BUILD Stage

**6. Implement deliverables**
```
ARTIFACTS/
├── auth.py
└── tests/
    └── auth_tests.py
```

**7. Update MANIFEST LEDGER as you create files**
```markdown
## MANIFEST LEDGER
- `auth.py` - ::THIS/ARTIFACTS/auth.py - JWT generation and validation
- `auth_tests.py` - ::THIS/ARTIFACTS/tests/auth_tests.py - Test suite
```

**8. Update STATUS as you learn**
```markdown
## Open Questions
- Token refresh strategy? → RESOLVED: Defer to v1_02 per user feedback
```

**9. Log progress**
```markdown
# LOG
- 2025-02-10T12:30:00Z - Implementation complete
- 2025-02-10T14:00:00Z - Test suite complete
```

### VERIFY Stage

**10. Run harness**
```bash
acft verify --record
# This emits HARNESS_EXECUTED event
```

**11. Update SIGNAL based on outcome**
```bash
# If passed:
acft close --signal pass

# If failed:
acft close --signal fail
# Then fix issues and return to step 10
```

**12. Log verification**
```markdown
- 2025-02-10T15:00:00Z - Harness passed, SIGNAL:pass
```

### HANDOFF Stage

**13. Complete HARNESS section**
```markdown
# HARNESS

JWT authentication system implemented and verified. Users authenticate via POST to /login, receive JWT token with 1hr expiry. Protected endpoints validate tokens. Test suite achieves 95% coverage. All tests pass, manual checks succeed.

Deliverables in ::THIS/ARTIFACTS/auth.py and tests/.
```

**14. Complete CONTEXT section**
```markdown
# CONTEXT

## Why JWT
Chose JWT over session-based auth because:
- Stateless (scales horizontally)
- Standard (RFC 7519)
- Client can inspect claims

Considered sessions but rejected due to state management complexity.

## Token Expiry
1hr expiry balances security with UX. Refresh tokens deferred to v1_02.
```

**15. Validate structure**
```bash
acft validate ::THIS
```

**16. Close as VALID:true**
```bash
acft close --status true --signal pass \
  --message "Auth implementation complete and verified"
```

**17. Final LOG entry**
```markdown
- 2025-02-10T15:15:00Z - Set VALID:true, ready for handoff
```

## Final CHECKPOINT State

```yaml
---
VALID: true
LIFECYCLE: active
SIGNAL: pass
---

# STATUS
[Context recap, success criteria met, no open questions]

# HARNESS
[5-10 sentence summary with rooted paths to deliverables]

# CONTEXT
[Why JWT, why 1hr expiry, alternatives considered]

# MANIFEST

## MANIFEST LEDGER
- `auth.py` - ::THIS/ARTIFACTS/auth.py - JWT implementation
- `auth_tests.py` - ::THIS/ARTIFACTS/tests/auth_tests.py - Tests (95% coverage)

## Harness
[Commands that passed]

## Dependencies
[Listed with status]

# LOG
[Complete timeline from creation to closure]
```

## Agent Checklist: Verify Workflow Complete

Before setting VALID:true:
```
□ Success criteria defined in STATUS (PREPARE)
□ Harness designed in MANIFEST (SPECIFY)
□ Deliverables in ARTIFACTS/ (BUILD)
□ Harness actually ran (VERIFY)
□ MANIFEST LEDGER populated with rooted paths
□ HARNESS section complete (5-10 sentences)
□ CONTEXT explains decisions
□ STATUS has context recap
□ LOG shows complete timeline
□ SIGNAL: pass (harness succeeded)
□ acft validate passes
```

## State Transitions

```
Create → VALID:false, SIGNAL:pending
↓
Design harness → VALID:false, SIGNAL:pending
↓
Implement → VALID:false, SIGNAL:pending
↓
Run harness → VALID:false, SIGNAL:pass (if succeeded)
↓
Complete contract → VALID:true, SIGNAL:pass
```

## Common Deviations

**Harness fails:**
```
VERIFY stage → SIGNAL:fail
↓
Fix implementation (back to BUILD)
↓
Run harness again (VERIFY)
```

**Blocked during VERIFY:**
```
VERIFY stage → SIGNAL:blocked
↓
Document blocker contract in STATUS
↓
Wait for unblock
↓
Run harness (VERIFY)
```

**Scope changes during BUILD:**
```
BUILD stage → New requirement arrives
↓
Log scope change with source
↓
Update STATUS with new criteria
↓
Continue BUILD
```

## Key Agent Behaviors

**Throughout workflow:**
- Update CHECKPOINT.md continuously (not at the end)
- Keep VALID:false until harness passes and contract complete
- Log decisions and events with timestamps
- Use rooted paths everywhere

**Never:**
- Skip harness design (SPECIFY before BUILD)
- Set VALID:true without running harness
- Assume fresh agent knows context not in CHECKPOINT.md
- Leave sections incomplete when closing

## Integration with Multi-Agent

**Agent A completes auth_v1_01:**
```yaml
VALID: true
LIFECYCLE: active
```

**Agent B continues with auth_v1_02:**
```bash
# Reads auth_v1_01/CHECKPOINT.md
# Creates successor
acft new auth_v1_02

# Marks predecessor superseded
acft close --path ::WORK/auth_v1_01 --lifecycle superseded \
  --message "Superseded by ::WORK/auth_v1_02"
```

**Agent B's STATUS includes:**
```markdown
## Context Recap
Inherited from ::WORK/auth_v1_01: JWT auth with 1hr expiry.
This CHECKPOINT adds token refresh capability per user request.
```

## Complete Timeline Example

```
T+0:00  - acft new auth_v1_01
T+0:05  - Define success criteria in STATUS
T+0:15  - Design harness in MANIFEST
T+2:30  - Implement auth.py
T+4:00  - Write test suite
T+4:30  - acft verify --record → pass
T+4:35  - Complete HARNESS section
T+4:40  - Complete CONTEXT section
T+4:45  - acft validate → pass
T+4:50  - acft close --status true --signal pass
```

Total: ~5 hours from empty CHECKPOINT to trustworthy handoff contract.
