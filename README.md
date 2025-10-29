# Context Cell: Context Management for Complex AI Projects

**When AI writes your code, the prompts you throw away are more valuable than the code you keep. That 2-hour conversation where you figured out _what_ to build? That's your source code now. The implementation is just the compiled artifact.**

You're *compiling the JAR and deleting the Java source*.

Context Cell makes this paradigm concrete: `CELL.md` files are first-class artifacts. Code is secondary.

> Context management for complex AI projects. Organize work into versioned cells (research → planning → parallel execution) that prevent agents from losing context.

Or, more formally:

> Context Cell is a hierarchical work organization framework for AI agents. It uses versioned "work cells" (folders) with state synchronization to organize complex work into manageable, trackable units.

Please note before using the framework:

> [!NOTE]
> **Early Stage**: Context Cell is successfully used in production across different projects. Read [spec/context_cell_framework](spec/context_cell_framework) in full before using—grasping the fundamentals is key to getting AI agents to work with the framework effectively.

---

## The Paradigm

AI coding agents hit three walls:

- **Bad research** → 1000s of bad lines (agent misunderstands the codebase)
- **Bad plan** → 100s of bad lines (approach is wrong)
- **Bad code** → bad lines (implementation bugs)

The hierarchy of impact is inverted. Understanding context matters more than writing code. Planning matters more than implementation.

Traditional workflow: shout at agent for 2 hours, commit code, throw away prompts. The conversation where you figured out the problem? Gone. The research that mapped the codebase? Deleted. The plan that caught architectural issues early? Lost.

**Context Cell makes specs structural, not ephemeral.**

---

## The Core Mechanism

Work cells are folders (`{branch}_v{version}_{step}`). Each contains:

- **`CELL.md`** — The source code (research, plan, implementation log, memory of what changed and why)
- **Working files** — Scratch code, tests, experiments, deliverables
- **Nested cells** — Complex subtasks delegated to subagents with their own context boundaries

```
rate_limit_v1_01/ (./CELL.md)         # research: map existing API endpoints
  endpoints_v1_01/ (./CELL.md)        #   nested: catalog all routes
  flow_v1_01/ (./CELL.md)             #   nested: trace request handling
rate_limit_v1_02/ (./CELL.md)         # planning: design rate limit strategy
rate_limit_v1_03/ (./CELL.md)         # execution: build middleware
  redis_v1_01/ (./CELL.md)            #   nested: setup Redis connection
  algorithm_v1_01/ (./CELL.md)        #   nested: implement token bucket
```

**Complex features span MANY cells** — research → planning → multiple execution cells → nested subtasks. Not one cell per feature. Each cell is a discrete context boundary.

---

## CELL.md: The Information Hierarchy

Every `CELL.md` has strict structure mirroring human vision:

```markdown
---
work_complete: true
---

# `DISCOVERY`

One line: what is this cell for?

# `ABSTRACT`

5-10 dense sentences: objectives, approach, results, metrics, next steps.

# `FULL_RATIONALE`

Detailed: why does this work exist? What context led here?

# `FULL_IMPLEMENTATION`

Detailed: what was done? How? Technical decisions, blockers, outputs.

# `LOG`

- 2025-01-01T10:00:00Z: Started context mapping
```

**The hierarchy mirrors human vision:**

- **`DISCOVERY`** — Peripheral: scan distant work cells (one-line summaries)
- **`ABSTRACT`** — Related: understand directly related cells (parents/peers/children)
- **`FULL_*`** — Focused: work on this specific cell (full context)

This isn't arbitrary. It's how you keep context under 40% utilization while maintaining full navigability.

---

## How AI Agents Navigate Context

AI agents use `cell orient PATH` to algorithmically extract work structure:

```bash
cell orient .                    # Shows ancestry/peers/children with `DISCOVERY` sections
cell orient --ABSTRACT .         # Shows ancestry/peers/children with `ABSTRACT` sections
```

The tool is intelligent about scope—shows only direct ancestry, direct peers, and direct children. Agents browse further from any vantage point by changing paths.

**How agents understand work:**

1. **Current cell**: Read full `CELL.md` (research, plan, implementation)
2. **Related cells**: Automated summary concatenation (`DISCOVERY` or `ABSTRACT` sections of parents/peers/children)
3. **Navigate**: Move to any cell, repeat

Agents don't read entire codebases. They read compressed context at the right fidelity level.

---

## Why This Works

**Research cells exist** (`rate_limit_v1_01`): Map context before implementation. Agents read parent cell's `ABSTRACT` to understand what was learned. Bad research is caught before it generates 1000s of bad lines.

**Planning cells exist** (`rate_limit_v1_02`): Reviewed before writing code. 200 lines of plan reviewed by humans vs 2000 lines of code reviewed by humans. Bad plans are caught before they generate 100s of bad lines.

**Execution cells are small** (`rate_limit_v1_03`): Focused, reference their plan. `CELL.md` documents what changed, why, and how—whether editing existing code or generating new code. Bad code is isolated to specific cells.

**Context explosion prevented**: Complex tasks delegate to nested cells. Parent doesn't carry burden of entire exploration—subagent does, returns summary to `ABSTRACT`.

**Specs survive**: Code may change. `CELL.md` documents survive. When you restart (`v1_03` → `v2_01`), you add `DETAILED_DEPRECATION_POSTMORTEM` to old version documenting what failed and why. Learnings preserved. You're keeping the Java source, not just the JAR.

---

## The Workflow Pattern

Agents don't "write code once and stop." They continuously cycle:

- **Orient** → Understand context using `cell orient`
- **Navigate** → `cd` to target work cell
- **Start** → Create or enter work cell
- **Work** → Make changes, edit code, run tests
- **Update** → Document in `CELL.md`, mark `work_complete: true` when done
- **Create** → Spawn next cell for next phase
- **Repeat**

Version/step progression:

- `v1_01` → `v1_02` → `v1_03` — Sequential progress
- `v1_03` → `v2_01` — Restart when approach fails (with documentation of **what failed** in the `v1_03`'s `CELL.md`)
- `parent_v1_01/child_v1_01` — Nested subagent contexts

Path conventions enforce clarity:

- `@root/path/to/file` — Project root (marked by `cellproject.toml`)
- Explicit prefixes eliminate ambiguity, paths stay valid when cells reorganize

---

## Installation

```bash
# Install Context Cell
git clone https://github.com/elijas/context-cell.git ~/context-cell
mkdir -p ~/bin && ln -s ~/context-cell/bin/cell ~/bin/cell
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# Add Context Cell to your project
cd /your/project && touch cellproject.toml

# Launch Context Cell-aware Claude Code
cd /your/project && cell claude
```

**Why `cell claude`?** When launched inside a folder with `cellproject.toml`, it automatically injects the framework specification (`cell spec` output) into the agent's system context. The agent understands Context Cell concepts natively—work cells, `CELL.md` structure, navigation commands—without you explaining them.

AI agents use `cell` commands to navigate. Both humans and AI agents read `CELL.md` files—it's the central point for storing context in relation to the rest of the system.

---

> [!TIP]
> **Experimental Patterns**: The `todos/` folder contains experimental workflow patterns and prompts that have proven useful in production but haven't been incorporated into the core framework yet. Check there for ideas on agent orientation, delegation, and work cell validation.

---

_Inspired by [Dex's "Advanced Context Engineering for Coding Agents"](https://www.youtube.com/watch?v=IS_y40zY-hc) talk on making specs first-class artifacts in AI development._
