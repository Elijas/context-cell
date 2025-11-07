# Agent Checkpoints Framework

**A coordination protocol for human-supervised agent work.**

This is not documentation—it's a harness that forces agents to declare intent before executing, then prove they delivered. Like Git coordinates code changes, ACF coordinates agent work.

## The problem

The classic principal-agent failure mode:

```
Human: "build X"
Agent: *does 2 hours of work in wrong direction*
Human: "no, that's not what I wanted"
```

Wasted tokens. Wasted time. Agents can't be redirected cheaply because they don't declare intent upfront—they just execute and hope you'll approve afterward.

## The solution

**Checkpoints**: proposals, progress reports, and handoff contracts.

The framework forces a cycle:

1. **Agent declares intent** (STATUS, HARNESS, MANIFEST)
2. **Human approves or redirects** (cheaply, before execution)
3. **Agent logs what actually happened** (can't silently drift)

This optimizes **human verification throughput**, not agent speed. The constraint isn't "how fast can the agent work?"—it's "how fast can a human spot when the agent is off-track and redirect it?"

## What you get

- **Back-pressure on agent work**: Agents must propose before executing—you catch wrong directions early
- **Steerable at scale**: You review declarations of intent, not hunt through outputs for what went wrong
- **Clean handoffs**: Any agent can resume without archaeology
- **Legible agent work**: Checkpoints make agent decisions inspectable and auditable
- **Parallel work**: Multiple agents collaborate without collisions

## What's in this repo

The framework is just structured markdown files. This means no lock-in to specific tools or agents.

- **`docs/`** - Start here: gentle step-by-step introduction for humans
- **`spec/`** - Reference documentation once you understand the basics
- **`bin/`** - Optional CLI helpers to reduce what you need to remember
- **`prompts/`** - AI agent onboarding (more technical, more examples)
- **`dev/`** - Maintainer tooling for this project

## FAQ

### Do I have to write CHECKPOINT.md files myself?

**No—that's the AI's job.** The human workflow is:

1. Write free-form instructions/questions
2. Agent expands them into structured CHECKPOINT.md (declares intent)
3. You skim to verify the agent understood correctly (approve/redirect)

The structured format is the _output_ of agent work, not a burden on humans. You steer direction, the agent maintains the contract.

### Why do the CHECKPOINT.md sections overlap?

**It's intentional redundancy for human verification.** Each section describes the same work from a different angle:

- **STATUS** (operator) - "What's alive right now"
- **HARNESS** (gatekeeper) - "Can I trust this handoff?"
- **CONTEXT** (designer) - "Why this approach?"
- **MANIFEST** (consumer) - "How do I run/verify this?"
- **LOG** (historian) - "What actually happened when"

**Seeing the same work from multiple perspectives reveals when the agent misunderstood your intent**—if STATUS says one thing but CONTEXT describes a different approach, you catch the conceptual misalignment before execution.

This is like pilot checklists: redundancy catches mistakes that single-source truth would miss. For agent→agent handoffs, it provides error correction. For human supervision, it accelerates the "does this agent understand what I want?" check.

### Should I skip this framework if I have only one simple task?

**It depends.** Skip it for truly throwaway work. But use it when you want to build on the work later, reference it in the future, or need to verify the agent understood correctly before executing.

The checkpoint structure changes how agents approach even single tasks:

- **Reusable handoffs** - Future agents can continue the work without you repeating yourself and without them wandering around searching for clues
- **Verifiable intent** - The structure forces agents to declare what they'll build before they build it—you catch misunderstandings early

Same time investment: disposable chat log vs steerable, resumable work.

## Further reading

- [**Advanced Context Engineering for Coding Agents**](https://www.youtube.com/watch?v=IS_y40zY-hc) - Dex Horthy's talk on spec-first development: bad research → thousands of bad lines, bad plans → hundreds. Review where it matters.

---

**Status**: Early prototype. Not ready for public use yet. If you're building serious agent workflows, [reach out](https://github.com/elijas/agent-checkpoints/issues).
