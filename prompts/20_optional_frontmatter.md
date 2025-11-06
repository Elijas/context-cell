# Optional Frontmatter Fields for AI Agents

## Required vs Optional

**REQUIRED (must have):**
```yaml
VALID: false        # true|false
LIFECYCLE: active   # active|superseded|archived
```

**OPTIONAL (use when needed):**
```yaml
SIGNAL: pass               # pass|fail|blocked|pending
SUPERSEDES: ["..."]        # List of superseded CHECKPOINTs
DELEGATE_OF: "::WORK/..."  # Parent CHECKPOINT for delegates
TAGS: ["..."]              # Categories for filtering
OWNER: "agent-name"        # Responsible party
```

## Field Reference

### SIGNAL
**Purpose:** Record latest harness verdict
**Values:** `pass`, `fail`, `blocked`, `pending`
**When to use:** Once harness exists and has run
**Example:**
```yaml
SIGNAL: pass  # Harness ran successfully
```

### SUPERSEDES
**Purpose:** Link consolidated CHECKPOINT to predecessors
**Type:** List of rooted paths
**When to use:** During consolidation (merging multiple CHECKPOINTs)
**Example:**
```yaml
SUPERSEDES: ["::WORK/plan_a_v1_01", "::WORK/plan_b_v1_02", "::WORK/plan_c_v1_01"]
```
**Cross-linking:** Each predecessor should have LOG entry "Superseded by ::WORK/unified_v1_01"

### DELEGATE_OF
**Purpose:** Link delegate to parent CHECKPOINT
**Type:** Single rooted path
**When to use:** Always for delegate CHECKPOINTs
**Example:**
```yaml
DELEGATE_OF: ::WORK/auth_v1_02
```
**Cross-linking:** Parent LOG should reference delegate: "Delegated to ::WORK/parse_tokens_v1_01"

### TAGS
**Purpose:** Categorize work for filtering/organization
**Type:** List of strings
**When to use:** When categorization helps automation or human navigation
**Example:**
```yaml
TAGS: ["spike", "security", "urgent", "needs-review"]
```
**Common tags:**
- Work type: "spike", "bug-fix", "feature", "research", "refactor"
- Status: "urgent", "blocked", "needs-review"
- Domain: "security", "performance", "ui", "api"

### OWNER
**Purpose:** Track responsibility (person or agent)
**Type:** String (identifier)
**When to use:** Multi-agent scenarios or team coordination
**Example:**
```yaml
OWNER: agent-alpha
```
**Note:** Not enforced by framework, purely informational

## Complete Example

```yaml
---
VALID: false
LIFECYCLE: active
SIGNAL: fail
DELEGATE_OF: ::WORK/auth_v1_02
TAGS: ["security-audit", "delegate", "urgent"]
OWNER: security-agent
---
```

## Agent Decision Tree

```
Creating new CHECKPOINT?
├─ Is it a delegate?
│  └─> Add DELEGATE_OF: ::WORK/parent
│
├─ Is it consolidating multiple CHECKPOINTs?
│  └─> Add SUPERSEDES: [list]
│
├─ Need to categorize?
│  └─> Add TAGS: [categories]
│
├─ Multi-agent scenario?
│  └─> Add OWNER: agent-name
│
└─ Otherwise?
   └─> Just use VALID + LIFECYCLE (minimal)
```

## Validation Rules

**DELEGATE_OF:**
- Must be rooted path if present
- Parent CHECKPOINT should exist
- Parent LOG should reference this delegate

**SUPERSEDES:**
- Each path must be rooted
- Each predecessor should have LIFECYCLE: superseded
- Each predecessor LOG should reference this CHECKPOINT

**TAGS:**
- Array of strings
- No enforcement of tag vocabulary (flexible)

**OWNER:**
- Free-form string
- No validation of existence

## CLI Integration

**Creating delegates:**
```bash
acft new parse_tokens_v1_01 --delegate-of ::WORK/auth_v1_02
# Auto-sets DELEGATE_OF in frontmatter
```

**Creating with tags:**
```bash
acft new security_audit_v1_01 --tags spike,security,urgent
# Sets TAGS: ["spike", "security", "urgent"]
```

**Manual editing:**
```yaml
# Just add fields to frontmatter, respecting YAML syntax
---
VALID: false
LIFECYCLE: active
CUSTOM_FIELD: custom-value  # Framework allows custom fields
---
```

## Custom Fields

**You can add custom fields** if your team needs them:
```yaml
---
VALID: false
LIFECYCLE: active
PRIORITY: high
TEAM: backend
JIRA_TICKET: PROJ-1234
---
```

Framework doesn't validate custom fields, but doesn't break if they exist.

**Guidelines for custom fields:**
- Use UPPERCASE for contract-relevant fields (matches framework style)
- Use lowercase for metadata/convenience fields
- Document custom fields in your team's documentation
- Don't rely on custom fields for core contract validity

## Key Agent Behaviors

**When creating CHECKPOINT:**
- Always set VALID and LIFECYCLE (required)
- Set DELEGATE_OF if delegating
- Set SUPERSEDES if consolidating
- Set TAGS if categorization helps
- Set SIGNAL once harness runs

**When closing CHECKPOINT:**
- Update SIGNAL with harness verdict
- Ensure cross-links match frontmatter (DELEGATE_OF ↔ parent LOG)

**When resuming CHECKPOINT:**
- Check DELEGATE_OF to understand relationship
- Check TAGS to understand context
- Check OWNER if unclear who's responsible
- Don't rely on optional fields being present

## Anti-Pattern: Over-Metadata

**BAD:**
```yaml
---
VALID: false
LIFECYCLE: active
SIGNAL: pending
TAGS: ["active", "false", "pending", "in-progress", "not-done", "wip"]
OWNER: agent-1
BACKUP_OWNER: agent-2
CREATED_BY: agent-1
CREATED_AT: 2025-02-10
LAST_MODIFIED: 2025-02-11
VERSION: 1
ITERATION: 3
---
```

**GOOD:**
```yaml
---
VALID: false
LIFECYCLE: active
TAGS: ["security-audit"]
---
```

Use optional fields sparingly. LOG provides timeline, LIFECYCLE provides state, tags should add semantic meaning not duplicate existing fields.
