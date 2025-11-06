# Bite 22: Frontmatter Fields (Beyond the Basics)

We've covered the required frontmatter fields (`VALID`, `LIFECYCLE`). Now let's look at **optional fields** that add useful metadata.

## Optional Frontmatter Fields

### SIGNAL (covered in Bite 19)
```yaml
SIGNAL: pass  # pass|fail|blocked|pending
```
Records the latest harness verdict.

### SUPERSEDES
```yaml
SUPERSEDES: ["::WORK/plan_a_v1_01", "::WORK/plan_b_v1_02"]
```
Lists CHECKPOINTs this one replaces (used during consolidation).

### DELEGATE_OF
```yaml
DELEGATE_OF: ::WORK/auth_v1_02
```
Links delegate CHECKPOINT to its parent.

### TAGS
```yaml
TAGS: ["spike", "security", "urgent"]
```
Categories for filtering and organization.

### OWNER
```yaml
OWNER: agent-alpha
```
Tracks who's responsible (person or agent name).

## Example Complete Frontmatter

```yaml
---
VALID: false
LIFECYCLE: active
SIGNAL: pass
DELEGATE_OF: ::WORK/auth_v1_02
TAGS: ["security-audit", "delegate"]
OWNER: security-agent
---
```

## When to Use Optional Fields

**SUPERSEDES:**
- Use during consolidation to link unified CHECKPOINT to predecessors
- Lists multiple CHECKPOINTs being merged into one

**DELEGATE_OF:**
- Always use for delegate CHECKPOINTs
- Helps track parent-child relationships
- Makes delegation explicit

**TAGS:**
- Use when you need to categorize or filter work
- Examples: "spike", "bug-fix", "research", "urgent", "blocked"
- Helps automation find CHECKPOINTs by type

**OWNER:**
- Use in multi-agent scenarios to clarify responsibility
- Can be a person name or agent identifier
- Optional but helpful for coordination

## Key Insight

Optional fields are **metadata for automation and filtering**. They don't change the contract itself, but they help:
- Track relationships (SUPERSEDES, DELEGATE_OF)
- Filter work (TAGS)
- Assign responsibility (OWNER)
- Record verification status (SIGNAL)

**Don't use them unless they add value.** The framework works fine with just `VALID` and `LIFECYCLE`.

## What's Required vs Optional

**Required (framework fails without these):**
- `VALID: true` or `VALID: false`
- `LIFECYCLE: active|superseded|archived`

**Optional (add only if useful):**
- `SIGNAL`
- `SUPERSEDES`
- `DELEGATE_OF`
- `TAGS`
- `OWNER`
- Any custom fields your team needs

The framework stays minimal - you add metadata only when it serves a purpose.
