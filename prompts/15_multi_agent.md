# Multi-Agent Coordination for AI Agents

## Core Principle

Each CHECKPOINT = self-contained contract. Fresh agents resume without reverse-engineering.

## Three Multi-Agent Patterns

### Pattern 1: Sequential Handoff

```
Agent A: auth_v1_01 → VALID:true, LIFECYCLE:superseded
Agent B: reads auth_v1_01, creates auth_v1_02
```

**Rules for Agent B:**
1. Read `auth_v1_01/CHECKPOINT.md` (NOT code first)
2. Check MANIFEST LEDGER for deliverables
3. Review HARNESS for verification approach
4. Read CONTEXT for decisions made
5. Check LOG for timeline
6. Create successor with STATUS recap

**What Agent B should NOT need:**
- Chat history with Agent A
- Code archaeology
- Guessing intent from implementation
- Reading entire ancestor tree

### Pattern 2: Parallel Delegation

```
Agent A: auth_v1_01 (active, delegates)
  ├─> Agent B: parse_tokens_v1_01 (delegate)
  └─> Agent C: validate_auth_v1_01 (delegate)

Both report back, Agent A continues when both complete
```

**Rules for delegation:**
1. Parent LOG: `- TIMESTAMP - Delegated to ::WORK/parse_tokens_v1_01`
2. Child frontmatter: `DELEGATE_OF: ::WORK/auth_v1_01`
3. Child LOG: `- TIMESTAMP - Reporting back to ::WORK/auth_v1_01: [findings]`
4. Parent stays `LIFECYCLE: active` until delegates complete
5. No shared state between delegates

### Pattern 3: Shared CHECKPOINT (Multiple Roles)

When multiple agents work on same CHECKPOINT:

**Use AGENTS.md to coordinate:**
```markdown
# Agent Roles

- Builder: Updates ARTIFACTS/, keeps VALID:false
- Verifier: Runs harness, updates SIGNAL
- Reviewer: Checks CONTEXT, approves design

Escalation: If disagreement, create delegate for investigation
```

**Rules:**
1. Only ONE agent sets `VALID: true` (usually Verifier)
2. All agents add LOG entries when making decisions
3. Use STATUS to track open questions visible to all
4. Conflicts → delegate CHECKPOINT for resolution

## Critical Success Factors

**1. Self-Containment**
- Don't reference external state
- Everything needed is in CHECKPOINT.md or linked via rooted paths
- ARTIFACTS/ has all deliverables
- MANIFEST has all commands

**2. Explicit Over Implicit**
- Write success criteria (don't assume)
- Link dependencies (don't rely on memory)
- Document decisions in CONTEXT (don't expect agents to infer)
- Cross-link relationships (don't leave orphans)

**3. Trust VALID Flag**
- `VALID: true` → next agent can trust this contract
- `VALID: false` → more work needed, don't assume completeness
- When resuming, check VALID before trusting deliverables

## Agent Resumption Checklist

When resuming someone else's CHECKPOINT:

```
□ Read HARNESS first (5-10 sentence summary)
□ Check VALID flag (can I trust this?)
□ Check LIFECYCLE (active/superseded/archived?)
□ Review MANIFEST LEDGER (what exists?)
□ Read MANIFEST commands (how to verify?)
□ Check STATUS (open questions/risks?)
□ Read CONTEXT (why this approach?)
□ Scan LOG (what happened when?)
□ Check Dependencies (what do I need?)
```

**DON'T** dive into code first. Read the contract.

## Common Pitfalls

**History Drift** - Forcing new agent to read ancestor CHECKPOINTs
- Fix: Include context recap in STATUS

**Dependency Fog** - Unclear what this CHECKPOINT needs
- Fix: Document all dependencies in MANIFEST

**Goal Fog** - Success criteria not written down
- Fix: Write explicit success criteria in STATUS during PREPARE

**Orphaned Work** - No cross-links to parent/children
- Fix: Always link in both directions (parent LOG + child frontmatter)

## Coordination Without Synchronization

ACF enables **asynchronous collaboration**:
- No need for "sync meetings" between agents
- No shared mutable state
- Each CHECKPOINT is append-only (LOG) or versioned (successors)
- Conflicts resolved by creating new CHECKPOINTs, not editing shared ones

**The pattern:**
```
Agent A: Does work, documents in CHECKPOINT, sets VALID:true
Agent B: (hours/days later) Reads contract, continues or delegates
```

No real-time coordination needed because contract is complete.

## Key Decision: When to Delegate vs Continue

**Continue (successor):**
- Same logical task
- Natural next step
- Context carries forward smoothly

**Delegate (new branch):**
- Distinct sub-problem
- Could be parallelized
- Different verification needs
- Might need different agent expertise

When in doubt: delegate. It's easier to consolidate later than to untangle mixed concerns.
