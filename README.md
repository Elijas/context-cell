# Agent Checkpoints Framework

**AI agents can write code. But can they finish projects?**

The moment an agent loses context or hits an error, everything falls apart. Half-finished work, forgotten requirements, "it works" that means "I ran it once."

## The problem

Agents can't pause and resume. They can't hand off work cleanly. They can't verify their own output. So projects stall, context gets lost, and quality becomes a guess.

## The solution

**Checkpoints**—structured pause points with built-in quality gates. A contract that makes resumption possible.

Every checkpoint answers:

- What did we build?
- How do we know it works?
- What happens next?

## What you get

- **Real completion**: Success is defined upfront, not guessed at the end
- **Clean handoffs**: Any agent can resume without archaeology
- **Automatic verification**: Quality gates run themselves
- **Parallel work**: Multiple agents collaborate without collisions
- **Full audit trail**: Every decision and change is recorded

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
2. AI expands them into structured CHECKPOINT.md
3. You skim to verify the AI understood correctly

The structured format is the _output_ of AI work, not a burden on humans. You guide direction, the AI maintains the contract.

### Why do the CHECKPOINT.md sections overlap?

**It's intentional redundancy.** Each section describes the same work from a different angle:

- **STATUS** (operator) - "What's alive right now"
- **HARNESS** (gatekeeper) - "Can I trust this handoff?"
- **CONTEXT** (designer) - "Why this approach?"
- **MANIFEST** (consumer) - "How do I run/verify this?"
- **LOG** (historian) - "What actually happened when"

For AI→AI handoffs, this redundancy provides error correction. For human reviewers, **seeing the same work from three perspectives reveals conceptual misalignment**—when the AI describes the approach differently in STATUS vs CONTEXT vs MANIFEST, you catch where it misunderstood your intent.

Think of it like pilot checklists: saying the same thing three ways catches mistakes that single-source truth would miss.

### Should I skip this framework if I have only one simple task for Claude?

**It depends.** Skip it for truly throwaway work. But use it when you want to build on the work later, reference it in the future, or need polished output rather than quick answers.

The checkpoint structure changes how Claude approaches even single tasks:

- **Reusable context** - Future agents can continue the work without you repeating yourself (or trying to remember) and without them wandering around searching for clues (or guessing incorrectly)
- **Professional output** - The structure triggers Claude to produce well-structured, complete artifacts instead of throwaway responses

Same time investment: disposable chat log vs permanently useful output.

## Further reading

- [**Advanced Context Engineering for Coding Agents**](https://www.youtube.com/watch?v=IS_y40zY-hc) - Dex Horthy's talk on spec-first development: bad research → thousands of bad lines, bad plans → hundreds. Review where it matters.

---

**Status**: Early prototype. Not ready for public use yet. If you're building serious agent workflows, [reach out](https://github.com/elijas/agent-checkpoints/issues).
