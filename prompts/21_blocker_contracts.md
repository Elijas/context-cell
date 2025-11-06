# Credible Blocker Contracts for AI Agents

## Purpose

Document explicit blockers preventing harness execution while keeping CHECKPOINT active.

## Four Required Elements

Every blocker contract must document:

1. **WHAT** - Specific issue preventing verification
2. **WHO** - Owner/team responsible for unblocking
3. **WHEN** - Target date or milestone
4. **REMEDIATION** - Next steps when unblocked

## Template

```yaml
---
VALID: false
LIFECYCLE: active
SIGNAL: blocked
---

# STATUS

## Blocker
**What:** [Specific blocking issue]
**Owner:** [Team/person/ticket]
**Expected:** [Date or milestone]
**Remediation:** [What to do when unblocked]
```

## Example

```markdown
## Blocker
**What:** Production database credentials needed for migration harness
**Owner:** DevOps team (ticket INFRA-892)
**Expected:** 2025-02-18
**Remediation:** Run `acft verify --record`, verify migration, set VALID:true if pass

# LOG
- 2025-02-10T10:00:00Z - Migration script complete, harness ready
- 2025-02-10T10:30:00Z - SIGNAL:blocked - no prod DB access
- 2025-02-10T10:45:00Z - Filed INFRA-892 for credentials, ETA 2025-02-18
```

## Critical Rules

**1. Keep VALID:false until harness runs**
```yaml
VALID: false     # ✓ Correct - can't be true without verification
SIGNAL: blocked
```

```yaml
VALID: true      # ✗ WRONG - validation theater
SIGNAL: blocked
```

**2. Set SIGNAL:blocked**
```yaml
SIGNAL: blocked  # Indicates "can't verify, not won't verify"
```

**3. Document in STATUS (not just LOG)**
- STATUS has the current blocker contract
- LOG shows the timeline of blocking/unblocking

**4. Log blocking event with timestamp**
```markdown
- 2025-02-10T14:30:00Z - SIGNAL:blocked - [reason]
```

**5. When unblocked, run harness immediately**
```bash
# Credentials arrive
acft verify --record
acft close --signal pass --status true  # If harness passes
```

## Decision Tree: Blocker vs Delegate

```
Can't proceed?
├─ Is it external/out of your control?
│  ├─ Yes → Create blocker contract
│  └─ No → Is it substantial work?
│      ├─ Yes → Delegate CHECKPOINT for it
│      └─ No → Just do it
│
└─ Is timeline known/short?
   ├─ Yes → Blocker contract, wait
   └─ No → Consider delegate to investigate
```

## Common Blocker Types

**External Dependencies:**
```markdown
**What:** API endpoint https://api.example.com returns 503
**Owner:** External vendor support (ticket #12345)
**Expected:** SLA says 2 business days
**Remediation:** Retry harness when API available
```

**Credentials/Access:**
```markdown
**What:** AWS production account access needed
**Owner:** Security team (request SEC-456)
**Expected:** Approval process takes 3-5 days
**Remediation:** Run terraform plan and apply in prod account
```

**Upstream CHECKPOINT:**
```markdown
**What:** Depends on ::WORK/auth_v1_03 deliverables
**Owner:** Agent-Beta working on auth_v1_03
**Expected:** auth_v1_03 ETA 2025-02-12 per its LOG
**Remediation:** Once auth_v1_03 VALID:true, integrate and verify
```

**Infrastructure:**
```markdown
**What:** Test cluster not provisioned yet
**Owner:** Platform team (provisioning in progress)
**Expected:** 2025-02-14 per platform roadmap
**Remediation:** Deploy to test cluster, run integration tests
```

## Anti-Patterns

**Too Vague:**
```markdown
❌ **What:** Blocked on stuff
   **Owner:** Someone
   **Expected:** Soon
   **Remediation:** Fix it
```

**Not Really a Blocker:**
```markdown
❌ **What:** Need to implement auth system
   **Owner:** Me
   **Expected:** Next week
   **Remediation:** Write the code
```
→ This is not a blocker, this is work. Either do it or delegate it.

**No Ownership:**
```markdown
❌ **What:** API credentials needed
   **Owner:** Unknown
   **Expected:** Someday
   **Remediation:** Wait
```
→ If no owner, find one. If truly unknown, escalate or delegate investigation.

## Update Pattern

**When blocked:**
```bash
acft close --signal blocked --message "API credentials unavailable"
# Update STATUS with blocker contract
```

**When unblocked:**
```bash
# Document unblocking
# LOG: - TIMESTAMP - Credentials received, running harness

acft verify --record
acft close --signal pass  # or fail, based on outcome
```

## Validation Checks

Before accepting blocker contract:
```
□ All four elements present (what/who/when/remediation)
□ SIGNAL: blocked in frontmatter
□ VALID: false (not true)
□ LOG entry documenting when blocked
□ Owner is specific (person/team/ticket, not "someone")
□ Timeline is concrete (date/milestone, not "eventually")
□ Remediation is actionable (clear next steps)
```

## Multi-Agent Coordination

**Agent A blocks work:**
```yaml
# checkpoint_v1_01
VALID: false
SIGNAL: blocked

# STATUS
**What:** Needs design review approval
**Owner:** Agent-Reviewer
**Expected:** Within 24h per team protocol
**Remediation:** Address review feedback, rerun harness
```

**Agent-Reviewer picks up:**
1. Sees blocked CHECKPOINT
2. Reviews design
3. Provides feedback in LOG or creates delegate
4. Agent A resumes when unblocked

## Key Philosophy

**Prefer "blocked but documented" over validation theater.**

```
Bad: Set VALID:true, write "should work, didn't test"
Good: Set SIGNAL:blocked, document exactly what's needed
```

Blockers are **honest status**, not failure. They acknowledge reality while maintaining contract integrity.
