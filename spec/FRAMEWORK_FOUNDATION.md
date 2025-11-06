# AGENT CHECKPOINTS FRAMEWORK (ACF) - Foundation Notes

These notes capture the reasoning, trade-offs, and “Chesterton fences” behind the harness manual. Keep them alongside the public-facing agent guide so future contributors know why the rules exist before refactoring.

## 1. Dexter Horthy’s Lens

- The quote that anchors this framework: design the back-pressure harness before implementation. Everything else is downstream of the question “How will the model know it is working?”
- The PREPARE → SPECIFY → BUILD → VERIFY → HANDOFF loop is the concrete form of that advice. Removing any stage weakens the feedback system that keeps agent work aligned over long timelines.

## 2. Why a Single Shared Manual

- Humans and LLM agents execute the same contract. Two divergent specs would drift and introduce contradictions. The current agent guide is terse enough for both audiences while preserving one source of truth.
- When agents need role-specific nudges (e.g., dedicated verifier), those can be layered as automation on top of the shared harness rather than hard-coding new rule sets.

## 3. Storage & Versioning Foundations

- Plain text plus Markdown keeps the framework portable. Everything lives as files you can grep, diff, or version without bespoke databases, query languages, or clients getting in the way.
- Git remains the versioning substrate. Branches mirror workstreams, merge conflicts surface where the real disagreement lives, and decades of tooling make history inspection cheap.
- Directory hierarchy sets memory scope. Context travels with the tree, so `auth_v3/` stays sandboxed from `auth_v1/` experiments unless a human (or agent) links them on purpose.
- Explicit branch, version, and step naming encode lineage. `foo_v1_02` immediately signals ancestry and obsolescence so third-level deprecated work falls out of view without extra bookkeeping.
- Markdown with YAML frontmatter sits on the human-machine seam. Humans read it fluently, automation parses it reliably, and no translation layer drifts out of sync.
- The framework is coordination infrastructure, not automation magic. Conventions, rooted paths, and ledgers provide rails; CLIs and scripts just shave keystrokes when available.
- Expose complexity rather than hide it. When every assumption and artifact sits in an inspectable file, debugging opaque state is no longer part of the job.

## 4. Rooted Path Prefixes

- `::PROJECT/`, `::WORK/`, `::THIS/` exist because the previous implementation of this framework broke when they relied on `../` or bare paths. The prefixes encode intent (“repo asset”, “sibling CHECKPOINT”, “local output”) and remain stable across moves or when content is reused in a different directory.
- Hash-based IDs were considered and rejected: they destroy readability, require registry tooling, and don’t prevent the underlying problem (updating references when substance changes). Rooted prefixes are the minimum structure that keeps references unambiguous while keeping the project itself portable across different systems (i.e. no global paths).

## 5. Required Sections Context

- `CHECKPOINT.md` stays authoritative because each required section serves a distinct need: `STATUS` captures the rolling recap, success criteria, and outstanding risks; `HARNESS` ties work to the canonical deliverables; `CONTEXT` records decisions and alternatives; `MANIFEST` enumerates artifacts and dependencies; `LOG` logs the audit trail with ISO 8601 timestamps so history never relies on memory.
- `MANIFEST` documents the harness and dependency contracts, and the MANIFEST LEDGER sits at the top so observability tools (and humans) jump straight to the outputs instead of spelunking through `ARTIFACTS/` manually.
- Structured dependency checklists stay consolidated in `MANIFEST -> ## Dependencies`; STATUS or CONTEXT should reference the ledger rather than clone it, which keeps automation and humans aligned.
- Treat `STAGE/` as optional scaffolding: create it only when raw context needs a temporary parking spot, and clear or archive it before setting `VALID: true`.
- Treat the MANIFEST LEDGER as the contract for deliverables: leave it clearly tagged as a stub while `VALID: false`, and never flip `VALID` to `true` until the ledger lists rooted deliverables or you have logged a credible blocker contract.
- Credible blockers must name an owner, a target date, and the remediation CHECKPOINT/ticket so successors understand why the harness has not run yet and how resolution will be tracked.
- `STATUS` must start with the context recap, success criteria, and exit conditions so successors avoid rereading the entire work hierarchy. This combats history drift and goal fog.
- `LOG` cites the triggering directive (Slack, transcript, ticket, doc) whenever scope pivots so stakeholders can trace why work changes direction.
- Frontmatter keys (`VALID`, `LIFECYCLE`, optional `SIGNAL`) give automation and humans the binary contract gate that prevents stale hand-offs.

## 6. Failure Catalogue

- Each row exists because we saw it in attempts to use an earlier version of the framework in a production setting. Removing them invites regression:
  - **Scope shock** keeps midstream stakeholder pivots from being silent.
  - **History drift** forces context recaps so successors are not forced to re-ingest thousands of words.
  - **Dependency fog** requires explicit upstream/sibling statuses, preventing hidden blockers.
  - **Goal fog** closes the gap where success criteria were implicit and CHECKPOINTS simply “kept working.”
- The 13 entries stay in lockstep across `FRAMEWORK_SPEC.md` §7, the agent prompt, and the CLI reference; update all three surfaces together so frontline agents and automation see the same catalogue.
- The canonical table lives in `FAILURE_CATALOGUE_TABLE.md`; other manuals include it via the `<!-- failure-catalogue:start -->` markers so edits happen in one place.
- Systems automation carries some detection load, but human reviews should still sample for the high-signal subset (missing harness, stale contract, validation theater) before closing work.
- If a new anti-pattern appears, add it here first, then update the agent guide. Treat this file as the living “why” behind the rules.

## 7. Multi-Agent Considerations

- The framework intentionally does not prescribe fixed agent roles. Instead, it relies on clear harness checkpoints that any human or model agent can execute.
- If teams need dedicated Sentinels/Verifiers, wire them to the existing checkpoints (e.g., run `acft orient` on new CHECKPOINTS, re-run the harness before closure). Do not proliferate bespoke prompts unless a real gap emerges.
- Treat these guardrails as coordination infrastructure. They organize parallel work, but skilled operators still own judgment and escalation rather than expecting automation to conjure outcomes.

## 8. CLI Surface

- The CLI tools are thin wrappers around the harness checkpoints: `acft orient`, `acft validate`, `acft manifest`, `acft expand`, `acft spec`, `acft verify`, and `acft claude`. They align with the workflow phases and failure catalogue.
- Rooted arguments (`acft orient ::THIS`, `acft orient ::WORK/child_v1_02`) keep transcripts and automation unambiguous; the bare `.` shorthand exists only for legacy ergonomics.
- `CLI_REFERENCE.md` documents expected behavior, flags, and automation hooks. Any new command or significant change should be recorded there and reflected in the agent guide/system prompt.
- These commands are optional ergonomics. The framework still works with `mkdir`, `cat`, and a text editor; CLI wrappers just clear boilerplate and reduce typos for humans and agents alike.

## 9. Event Instrumentation

- Manual “I just did X” logging proved unreliable (agents forget, wording varies, automation cannot parse). Instead, mutate-path commands must emit structured events so sentinels/verifiers react without bloating the working prompt.
- The event schema is intentionally tiny—`TYPE`, `CHECKPOINT_PATH`, `ACTOR`, `TIMESTAMP`, `PAYLOAD`—because richer buses turned into bespoke log formats that nobody consumed. Keep it small, JSON, newline-delimited.
- Commands that change CHECKPOINT state (`acft new`, `acft close`, `acft verify --record`, future `acft sync`) are responsible for emitting the event. The agent already ran the command, so the signal costs nothing extra and never competes with task context.
- A shared emitter helper prints the JSON and atomically appends to the log; if that append fails, the parent command must exit non-zero so silent drift never enters the system.
- Canonical event types (keep this ordering aligned with `FRAMEWORK_SPEC.md` and `CLI_REFERENCE.md`): `CHECKPOINT_CREATED`, `HARNESS_EXECUTED`, `CHECKPOINT_VERIFIED`, `CHECKPOINT_CLOSED`, `MANIFEST_UPDATED`. Add more only when a failure mode demands it; each extra type increases ingestion burden on automation.
- `HARNESS_EXECUTED` events always include `LOG_PATH`; store harness logs under `::WORK/logs/{checkpoint}/harness_{timestamp}.log` (or equivalent rooted paths) so verifiers can replay execution.
- A lightweight watcher (or pipeline step) subscribes to the event stream and launches harness tasks (`acft validate`, `acft manifest --mode quick`, delegated audits) on demand. This keeps the framework reactive without fusing filesystem watchers into every tooling setup.
- Sentinels consume `CHECKPOINT_CREATED`/`MANIFEST_UPDATED`/`CHECKPOINT_VERIFIED`, Verifiers watch for `CHECKPOINT_CLOSED` vs `HARNESS_EXECUTED`, Auditors mine the log for silence. Add new automation roles only after proving an event gap exists.
- If a future change proposes removing the event layer, insist on an equally deterministic mechanism for triggering sentinels. Silent mutation is how the previous project archive drifted; the fence is here to prevent a repeat.

## 10. Event Extension Process

- New event types must justify themselves by tying directly to a documented failure mode. Avoid ad-hoc telemetry that automation cannot consume.
- Draft proposals with the checklist below and log them in the originating CHECKPOINT before implementation:
  - Failure mode being addressed (link to `FRAMEWORK_SPEC.md` §7 entry or new addition).
  - Proposed event name and trigger conditions (what command emits it, when, and why existing events are insufficient).
  - Minimum payload schema (required fields, rooted paths, example JSON).
  - Producing commands / scripts and any flags or options added.
  - Downstream consumers and required updates (sentinel/verifier jobs, dashboards, alerting).
  - Rollout and backfill plan (how to migrate historical data or handle mixed deployments).
  - Testing expectations (unit/integration coverage, simulated failure of the emitter helper).
  - Documentation updates (SYSTEM_PROMPT, CLI_REFERENCE, FRAMEWORK_SPEC) and ownership for each change.
  - Sign-off and follow-up (who approves, when to review impact).
- Do not merge CLI changes that emit undocumented event types; the proposal should land alongside the code or the change should be rolled back immediately.

## 11. Consolidation Philosophy

- We let exploratory CHECKPOINTS proliferate as long as the authoritative deliverable is easy to find. The MANIFEST LEDGER + `SUPERSEDES`/`SUPERSEDED_BY` pattern lets a final “unified” CHECKPOINT absorb context while older CHECKPOINTS become optional background.
- Copying key source snippets into the unified CHECKPOINT (under `STAGE/` or directly in `ARTIFACTS/`) avoids the chained-reading trap that plagued earlier archives. Future readers can stop at the merged CHECKPOINT; historians still have the originals.
- Resist the urge to delete history. Instead, mark superseded CHECKPOINTS clearly and ensure the successor is self-sufficient. This mirrors code refactors where old modules stay in revision history but new entry points carry forward the business logic.
- Any proposal to short-cut the merge (e.g., “just link to both plans forever”) should answer how new agents maintain velocity without rereading everything. If that answer is weak, consolidate.

## 12. Chesterton’s Fences

- Before removing a rule or section, ask which failure mode it prevented and whether the environment has changed. Most guardrails were added because they broke in production once already.
- Changes to the agent guide should reference this foundation file in `# LOG`, explaining what fence is being moved and why the original constraint is no longer needed.

## 13. Incremental History

- Checkpoints advance by incrementing steps or versions; overwriting past directories destroys the audit chain and disconnects automation triggers.
- Delegations and successors must cross-link in frontmatter and LOG entries so lineage stays machine and human readable.

## 14. Stewardship Notes

- Keep production documentation lean but aligned. When rules evolve, bump the version marker, update companion docs together, and log the change in the checkpoint that carried the work.
- Treat `_thinking/` artifacts as historical context rather than binding law; the v2.1 manuals are authoritative.
