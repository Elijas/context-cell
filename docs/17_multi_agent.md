# Bite 17: Multi-Agent Considerations (Working Together)

ACF is designed for **multiple agents** (or humans) to work on the same problem without stepping on each other.

**The core principle:** Each CHECKPOINT is a **self-contained contract**. A fresh agent should be able to resume work without reverse-engineering intent.

## How Multi-Agent Work Happens

### 1. Handoff Between Agents

**Scenario:** Agent A finishes, Agent B continues

**What happens:**
- Agent A works on `auth_v1_01`, closes it with `VALID: true`
- Agent B reads just `auth_v1_01/CHECKPOINT.md` and knows:
  - What was built (MANIFEST LEDGER)
  - How to verify it (MANIFEST commands)
  - Why decisions were made (CONTEXT)
  - What happened (LOG)
- Agent B creates `auth_v1_02` to continue

**Why this works:** No context in Slack, no "ask the previous agent," no code archaeology. Everything needed is in the contract.

### 2. Parallel Delegation

**Scenario:** One agent splits work, multiple agents execute

**What happens:**
- Agent A delegates `parse_tokens_v1_01` and `validate_auth_v1_01`
- Agent B works on parsing, Agent C works on validation
- Both report back to parent via LOG cross-links
- Agent A waits for both to complete before continuing

**Why this works:** Each delegate is independent, with its own harness and deliverables. No shared state to conflict over.

### 3. The AGENTS.md File (Optional)

When multiple agents share a CHECKPOINT, document roles and protocols:

**Example AGENTS.md:**
```markdown
# Agent Roles

- **Agent A (Builder)**: Implements features, updates ARTIFACTS/
- **Agent B (Verifier)**: Runs harness, updates SIGNAL in frontmatter
- **Escalation**: If harness fails 3x, create delegate CHECKPOINT for investigation
```

Not required, but helpful for coordination when work is complex.

## Key Insight

Because everything is **explicit**, agents don't need to guess:
- Rooted paths (no ambiguity about what file is referenced)
- MANIFEST LEDGER (exactly what exists)
- LOG entries (chronological record of decisions)
- HARNESS section (how to verify)

**The anti-pattern ACF avoids:** "Just read the code and figure it out"

Instead, ACF says: "Read the contract first, code second."

## What Makes This Work

**Self-containment:**
- Each CHECKPOINT has its own `ARTIFACTS/` (deliverables)
- Each CHECKPOINT has its own harness (verification)
- Each CHECKPOINT documents its own context (decisions)

**Explicit relationships:**
- Successors are clear (`auth_v1_01` → `auth_v1_02`)
- Delegates are linked (`DELEGATE_OF: ::WORK/parent`)
- Dependencies are documented (MANIFEST → Dependencies)

**Single source of truth:**
- `CHECKPOINT.md` is authoritative
- If anything is stale, set `VALID: false`
- Fresh agents trust `VALID: true` checkpoints

## Example Multi-Agent Flow

1. **Agent A**: Creates `auth_v1_01`, builds prototype, sets `VALID: false`, notes "needs security review" in STATUS
2. **Agent B**: Reviews `auth_v1_01`, finds issues, creates delegate `security_audit_v1_01`
3. **Agent C**: Completes security audit, reports findings in delegate's LOG
4. **Agent B**: Reads audit results, creates `auth_v1_02` with fixes
5. **Agent D**: Reviews `auth_v1_02`, runs harness, sets `VALID: true`

At each step, the agent only needs to read the relevant CHECKPOINT contracts, not the entire history.
