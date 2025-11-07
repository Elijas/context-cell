# Agent Checkpoints Framework

**A control plane for human-supervised agent work.**

Agents propose. Humans approve. Agents execute. Humans verify.

This framework makes that loop efficient.

## The problem

The classic principal-agent failure mode:

```
Human: "build X"
Agent: *does 2 hours of work in wrong direction*
Human: "no, that's not what I wanted"
```

Wasted tokens. Wasted time. Agents can't be redirected cheaply because they don't declare intent upfront—they just execute and hope you'll approve afterward.

## The solution

**Checkpoints**: agents declare what they'll build before building it.

The framework forces a cycle:

1. **Agent proposes** (STATUS, HARNESS, MANIFEST)
2. **Human reviews** (approve or redirect—cheaply, before execution)
3. **Agent executes and logs** (can't silently drift)

Think of it like **pull requests for agent work**. Agents can't merge until you approve the plan.

This optimizes **human verification throughput**, not agent speed. The constraint isn't "how fast can the agent work?"—it's "how fast can you spot when the agent is off-track and redirect it?"

## What you get

- **Catch mistakes early**: Agent says "I'll build this API," you say "that endpoint exists" before it writes 500 lines
- **Fast verification**: Agent documents "run these commands," you check in 2 minutes instead of reading code
- **Resume without archaeology**: Come back weeks later, STATUS → MANIFEST → LOG tells you exactly where things stand
- **Audit decisions**: When something breaks, LOG shows what the agent was thinking
- **Supervise at scale**: Each checkpoint is self-contained—review multiple agents without context-switching hell

> **Side effect**: Building primitives for human supervision (state snapshots, dependency tracking, audit trails) accidentally enabled autonomous agent coordination. We solved context management; got DAG execution for free.

## Alternative perspectives on ACF

The supervision model scales beyond single-agent tasks. **If you think in terms of...**

**Git workflow for agent work**
- Checkpoints = commits (discrete units of work)
- Delegates = feature branches (scoped sub-tasks)
- Successors = advancing the main branch
- LOG = commit history with rationale

**LLM context hygiene ("new task = new chat")**
- Checkpoints = context boundaries that survive sessions
- Resume work without replaying entire conversation history
- Explicit contracts replace implicit shared state
- Branch explorations without polluting the main thread

**Infrastructure as Code workflow**
- `terraform plan` → review → `terraform apply`
- ACF: agent proposes → human reviews → agent executes
- State drift detection: did ARTIFACTS match MANIFEST?
- Rollback or pivot without destroying history

**Autonomous long-horizon agents**
- Execute over a DAG of dependent tasks
- Resume from any checkpoint after interruption or failure
- Pivot when requirements change (without losing history)
- Restart individual branches (version bump) while preserving context
- Coordinate parallel work streams without shared state conflicts

## What's in this repo

The framework is structured markdown. No vendor lock-in.

- **`docs/`** - Start here: step-by-step intro
- **`spec/`** - Reference docs
- **`bin/`** - Optional CLI tools
- **`prompts/`** - Agent onboarding materials
- **`dev/`** - Maintainer tooling

## FAQ

### Do I write the checkpoints?

**No—agents do.** Your workflow:

1. Write normal instructions
2. Agent expands into structured checkpoint (proposes plan)
3. You skim: did it understand? (approve/redirect)

You steer. Agent documents.

### Why do sections overlap?

**Redundancy catches agent mistakes.** If STATUS says one thing but CONTEXT describes something else, the agent misunderstood you—and you catch it _before execution_.

Like pilot checklists: saying things multiple ways prevents silent drift.

### When should I skip this?

**Throwaway work.** Quick questions. One-off experiments.

**Use it when:**

- You'll build on this later
- You need to verify the agent understood correctly
- Multiple agents will touch related work
- You might resume after days/weeks

## Further reading

[**Advanced Context Engineering for Coding Agents**](https://www.youtube.com/watch?v=IS_y40zY-hc) - Dex Horthy on spec-first development: bad research → thousands of bad lines, bad plans → hundreds. Review where it matters.

---

**Status**: Early experimental prototype. Expect rough edges. Building serious agent workflows? [Reach out](https://github.com/elijas/agent-checkpoints/issues).
