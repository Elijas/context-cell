# North Star Principles for AI Agents

## Three Core Principles

### 1. Design the harness before you write a line of implementation

**Rule:** Define success signal + instrumentation + failure alarms BEFORE coding.

**In practice:**
```
Bad workflow:
1. Write implementation
2. Try to test it
3. Realize you don't know what success looks like
4. Improvise verification

Good workflow:
1. Write success criteria in STATUS (PREPARE stage)
2. Design harness in MANIFEST (SPECIFY stage)
3. Implement (BUILD stage)
4. Run harness (VERIFY stage)
```

**Agent behavior:**
- When starting work, ask "How will I know this works?"
- Document the answer in STATUS before coding
- Design harness commands in MANIFEST before building
- Never set VALID:true without running the harness

### 2. Treat every CHECKPOINT as a self-contained contract

**Rule:** Fresh agent resumes without reverse-engineering intent or asking predecessors.

**Contract completeness checklist:**
```
□ MANIFEST LEDGER lists all deliverables with rooted paths
□ MANIFEST documents harness commands and expected outcomes
□ CONTEXT explains why this approach (alternatives considered)
□ STATUS includes context recap (what was inherited)
□ LOG shows timeline of decisions
□ Dependencies documented in MANIFEST with status
```

**Agent behavior:**
- When resuming: read CHECKPOINT.md first, code second
- When closing: ensure contract is complete for next agent
- When delegating: provide full context in child's STATUS
- Never assume next agent has access to chat history or tribal knowledge

### 3. Keep collaboration low-friction under pressure

**Rule:** Minimal but strict rules. Everything else is optional.

**Strict (must follow):**
- Required sections: STATUS, HARNESS, CONTEXT, MANIFEST, LOG
- Required frontmatter: VALID, LIFECYCLE
- Rooted paths: `::THIS/`, `::PROJECT/`, `::WORK/`
- LOG timestamps: ISO 8601 UTC
- MANIFEST LEDGER before VALID:true

**Optional (use if helpful):**
- STAGE/ directory
- AGENTS.md file
- notes/ scratchpad
- SIGNAL field
- TAGS in frontmatter
- CLI tools (can edit manually)

**Agent behavior:**
- Follow strict rules religiously
- Use optional features when they add value
- Don't add ceremony beyond requirements
- Focus on contract clarity, not process perfection

## Decision Framework

When in doubt, ask:

**1. Harness-first:** "Can I verify this?"
- If no → design verification first
- If yes → document it in MANIFEST

**2. Self-contained:** "Can fresh agent resume?"
- If no → add context to CHECKPOINT.md
- If yes → ready for handoff

**3. Low-friction:** "Is this rule essential?"
- If yes → enforce strictly
- If no → make it optional

## Anti-Patterns to Avoid

**Validation Theater:** Setting VALID:true without running harness
- Violates: Harness-first principle
- Fix: Run harness, log outcomes

**History Drift:** Forcing agents to read ancestor CHECKPOINTs
- Violates: Self-contained principle
- Fix: Include context recap in STATUS

**Framework Bloat:** Adding unnecessary process/structure
- Violates: Low-friction principle
- Fix: Remove if not strictly required

## Core Insight

ACF makes invisible work visible:

| Without ACF | With ACF |
|-------------|----------|
| Intent in chat logs | Intent in CONTEXT |
| Verification ad-hoc | Verification in MANIFEST |
| Decisions tribal knowledge | Decisions in LOG |
| Timeline reconstructed | Timeline explicit |

**The goal:** Enable collaboration through explicit contracts, not synchronous communication.

## Practical Application

**When creating CHECKPOINT:**
1. ✓ Design harness first (how will I verify?)
2. ✓ Make contract self-contained (can fresh agent resume?)
3. ✓ Follow strict rules only (avoid ceremony)

**When working:**
1. ✓ Update contract as you learn
2. ✓ Run harness regularly
3. ✓ Keep VALID:false until ready

**When closing:**
1. ✓ Run harness one final time
2. ✓ Check contract is self-contained
3. ✓ Set VALID:true only if both pass

## Integration with Workflow

```
PREPARE → Define success signal (harness-first)
SPECIFY → Document contract (self-contained)
BUILD → Follow strict rules only (low-friction)
VERIFY → Run harness (harness-first)
HANDOFF → Ensure contract complete (self-contained)
```

Every stage reinforces all three principles.
