# Bite 21: The North Star Principles (Framework Philosophy)

We've covered the mechanics of ACF. Now let's zoom out: **Why does ACF exist? What principles guide it?**

## Three North Star Principles

### 1. Design the harness before you write a line of implementation

Don't start coding, then figure out testing later. Instead:
- Define the success signal first
- Plan the instrumentation
- Set up failure alarms
- **Then** implement

This is "harness-first workflow" - know how you'll verify before you build.

**Example:**
```
❌ Traditional: Write auth code → test it manually → hope it works

✓ ACF: Define "auth works when tokens validate and sessions persist"
       → Write test harness
       → Implement auth
       → Run harness
```

### 2. Treat every CHECKPOINT as a self-contained contract

A fresh agent should be able to resume without:
- Reverse-engineering intent from code
- Reading chat history
- Guessing what verification steps to run
- Asking the previous developer

Everything needed is **in the contract** (CHECKPOINT.md).

**This means:**
- MANIFEST tells you what exists and how to verify it
- CONTEXT tells you why decisions were made
- STATUS tells you what's done and what's next
- LOG tells you what happened when

### 3. Keep collaboration low-friction under pressure

When things are urgent, you need **minimal but strict rules**:
- Required sections (STATUS, HARNESS, CONTEXT, MANIFEST, LOG)
- Required fields (VALID, LIFECYCLE)
- Rooted paths
- LOG timestamps

Everything else is **optional**. The framework doesn't dictate your process beyond the essentials.

**The balance:**
- Strict where it matters (contract structure, verification)
- Flexible where it doesn't (scratch work, notes, personal process)

## The Philosophy in Action

**Traditional approach:**
```
Write code → hope it works → debug → maybe document → hand off (maybe?)
```

**ACF approach:**
```
Define success criteria
  → design harness
  → write code
  → verify
  → document
  → hand off with confidence
```

## Why These Principles Matter

**Harness-first** prevents:
- "It works on my machine" handoffs
- Validation theater ("looks good to me" without testing)
- Unclear success criteria

**Self-contained contracts** prevent:
- Context loss between agents
- Dependency fog (what do I need?)
- History drift (reading entire ancestor tree)

**Low-friction rules** prevent:
- Analysis paralysis (too many choices)
- Framework bloat (unnecessary ceremony)
- Tool lock-in (works without special software)

## The Core Insight

The framework makes the **invisible visible**:
- **Intent** (why this approach?)
- **Verification** (how do we know it works?)
- **Decisions** (what choices were made?)
- **Timeline** (what happened when?)

Without ACF, these live in:
- Chat logs (lost over time)
- People's heads (unavailable when they leave)
- Code comments (incomplete, scattered)
- Tribal knowledge (unwritten, undocumented)

With ACF, they live in:
- CHECKPOINT.md (one file, explicit, versioned)
