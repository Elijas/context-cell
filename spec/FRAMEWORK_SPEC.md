# AGENT CHECKPOINTS FRAMEWORK (ACF) - Harness Manual

## 1. North Star

- Design the harness before you write a line of implementation: define the success signal, instrumentation, and failure alarms so a model knows when it is on track.
- Treat every CHECKPOINT as a self-contained contract that a fresh agent can resume without reverse-engineering intent or verification steps.
- Keep collaboration low-friction under pressure: minimal but strict rules, everything else optional.

## 2. Ground Rules

- **Single source**: `CHECKPOINT.md` is authoritative; if anything is stale, set `VALID: false`.
- **Explicit primitives**: ACF keywords stay uppercase (`STATUS`, `MANIFEST`, `LOG`) so humans and automation can pattern match.
- **Rooted paths**: Use rooted prefixes (`::PROJECT/`, `::WORK/`, `::THIS/`); never rely on bare paths or `../`.
- **Incremental history**: Advance by incrementing steps (`_v1_01 -> _v1_02`) or bumping versions for restarts; never overwrite the past.
- **Audit trail**: LOG entries use ISO 8601 UTC timestamps and link to deliverables, decisions, or successor CHECKPOINTS.
- **Ledger gate**: `VALID: true` ships only with a populated MANIFEST LEDGER; keep `VALID: false` (or leave a clearly labeled stub) while deliverables are still forming.
- **Dependency ledger**: Structured dependency checklists live only under `MANIFEST -> ## Dependencies` (split into `### CHECKPOINT DEPENDENCIES` and `### SYSTEM DEPENDENCIES`); STATUS/CONTEXT may reference them narratively but never clone the list.
- **Tool independence**: No rule depends on a specific editor, model, or shell; automation may assist but cannot bypass the contract.

### 2.1 Token Casing

- CONTRACTUAL TOKENS stay uppercase. This includes section headings, YAML keys, path roots, MANIFEST LEDGER labels, dependency subheadings, and event names.
- Narrative prose, examples, and explanatory sentences use sentence case for readability.
- CLI command names remain lowercase to match the actual binaries (`acft orient`, `rg`, `git`), but their positional parameters follow the uppercase token rules.
- YAML values stay lowercase literals (`true`, `false`, `active`, `archived`, etc.) unless a rule explicitly calls for uppercase strings.

### 2.2 Naming

| Component | Rule                                                             | Example               | Notes                                                |
| --------- | ---------------------------------------------------------------- | --------------------- | ---------------------------------------------------- |
| branch    | Lowercase, `_` separators, describes a stable focus              | `auth`, `data_ingest` | Favor nouns/verbs that will make sense weeks later.  |
| version   | `v` + integer starting at `1`; bump for fundamental shifts       | `v1`, `v2`            | Reset step to `01` when version increments.          |
| step      | Two-digit counter per version (start at `01`, bump sequentially) | `_v1_01`, `_v1_02`    | Never skip numbers; document abandoned steps in LOG. |
| full name | `{branch}_v{version}_{step}`                                     | `auth_v2_03`          | Only one active thread per CHECKPOINT name.          |

### 2.3 Status Terms

- **Lifecycle field**: Frontmatter `LIFECYCLE` must be `active`, `superseded`, or `archived`; use the definitions below when setting it.
- **Active CHECKPOINT**: The latest version for a branch that has not been superseded; only one active CHECKPOINT exists per `{branch}_v{version}` at a time.
- **Successor**: The next CHECKPOINT that advances the same branch by incrementing the step or version (`auth_v1_02` succeeds `auth_v1_01`).
- **Delegate**: A child CHECKPOINT spun out to tackle a scoped sub-problem on behalf of its parent; it records `DELEGATE_OF` in frontmatter and reports back in LOG.
- **Child**: Umbrella term for either a successor or a delegate created from the current CHECKPOINT.
- **Superseded CHECKPOINT**: A predecessor that remains on disk for auditability but is no longer active because a successor replaced it. Superseded checkpoints always keep `VALID: false`.
- **Archived CHECKPOINT**: A closed CHECKPOINT with no planned successor; it documents final status and reasoning in LOG so future work starts a fresh branch and must set `VALID: false`.

### 2.4 Layout

- `CHECKPOINT.md` is mandatory and lives in the CHECKPOINT root.
- `ARTIFACTS/` contains only deliverables meant for others; keep it absent until you have something hand-off ready.
- Scratch work stays near `CHECKPOINT.md` (e.g., `STAGE/`, `notes/`). These directories are optional scaffolding, not contract deliverables. Avoid hiding deliverables in `ARTIFACTS/`.
- `STAGE/` lifecycle:
  - Create `STAGE/` only when you need temporary parking for raw inputs or excerpts you have not yet distilled into the contract.
  - Prune or archive its contents before setting `VALID: true`; remove the directory entirely if no staging assets remain.
  - Validators treat a missing `STAGE/` as healthy; flag a warning (not a failure) when closing with leftover staging debris.
- Do not park other CHECKPOINTS' outputs in this directory; link to them via rooted paths.

<comment>Relative-path bleed caused brittle hand-offs in legacy CHECKPOINTS; the detection commands below are mandatory when migrating old work.</comment>

### 2.5 Path Roots

| Marker                             | Prefix       | Purpose                                                                  |
| ---------------------------------- | ------------ | ------------------------------------------------------------------------ |
| `checkpoints_project.toml`         | `::PROJECT/` | Repository root: source code, docs, configs outside the checkpoint work. |
| `checkpoints_work.toml` (optional) | `::WORK/`    | CHECKPOINT work root: reference other CHECKPOINTS or their outputs.      |
| —                                  | `::THIS/`    | Current CHECKPOINT: files produced inside this CHECKPOINT.               |

- Add line numbers or anchors when helpful (`::PROJECT/src/app.py:42`, `::WORK/auth_v1_02/CHECKPOINT.md#MANIFEST`).
- Never reference `foo/bar.py` or `/foo/bar.py`.
- Before closing a legacy CHECKPOINT, run `rg "\.\./" -gCHECKPOINT.md` and `rg "\./ARTIFACTS" -gCHECKPOINT.md` to surface paths that must be rewritten with rooted prefixes.
- Pass rooted arguments to CLI commands (`acft orient ::THIS`, `acft orient ::WORK/branch_v1_02`) so transcripts, logs, and automation remain unambiguous.

<comment>This blueprint keeps `CHECKPOINT.md` aligned with the harness-first mindset: design questions, rationale, and verification pathways must be explicit.</comment>

## 3. `CHECKPOINT.md` Blueprint

### 3.1 Frontmatter

- Delimit YAML with `---` at the top of the file.
- Always include `VALID: false` or `VALID: true`.
  - `VALID` is the binary quality gate: set it to `true` only when the contract is trustworthy for a fresh agent; it is not a progress percentage.
  - Keep `VALID: false` if any required section is stale, incomplete, unverifiable, or if LIFECYCLE is not `active`.
- Declare `LIFECYCLE: <state>` with one of `active`, `superseded`, or `archived`.
  - `active`: current point of truth for the branch/version; work continues here.
  - `superseded`: preserved for history, replaced by a successor; `VALID` must be `false`.
  - `archived`: closed with no successor planned; LOG explains final status and `VALID` stays `false`.
- Add `SIGNAL: <state>` when you need to record the latest harness verdict (`pass`, `fail`, `blocked`, or `pending`); omit it if no verification has completed yet.
- Add optional keys (e.g., `DELEGATE_OF`, `SUPERSEDES`, `TAGS`, `OWNER`) when they clarify ownership or relationships.

Example frontmatter:

```yaml
---
VALID: false # Binary harness outcome
LIFECYCLE: active # active|superseded|archived
SIGNAL: pending # Optional: pass|fail|blocked|pending
---
```

While the MANIFEST LEDGER can be stubbed during active build work, never flip `VALID` to `true` until it lists rooted deliverables or you have documented a credible blocker contract.

### 3.2 Required Sections (in this order, uppercase)

| Section      | Purpose                                                          | Keep it current by...                                                                                                                                                                   |
| ------------ | ---------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `# STATUS`   | Rolling facts, risks, open questions discovered while working.   | Lead with a context recap (what we inherited, links), enumerate current success criteria and exit conditions, track open questions/risks, cite rooted paths, prune items once resolved. |
| `# HARNESS`  | 5-10 sentence executive summary for a new agent.                 | Lead with present status and headline findings, cite canonical outputs with rooted paths, and note active risks or follow-ups.                                                          |
| `# CONTEXT`  | Why this approach exists, alternatives considered, and evidence. | Tie decisions to data, cite upstream/downstream CHECKPOINTS, record rejected options.                                                                                                   |
| `# MANIFEST` | What exists now and how to validate or use it.                   | Open with a MANIFEST LEDGER (name, rooted path, one-line purpose), then document entry points, commands run (with outcomes), dependencies, and harness notes.                           |
| `# LOG`      | Chronological audit trail.                                       | Format entries as `- 2025-02-10T14:32:00Z - message`; include decisions, hand-offs, validation events.                                                                                  |

- Append optional headings only after `# LOG`; never insert extra sections between required ones.

### 3.3 MANIFEST -> ## Dependencies

Structured dependency checklists belong inside `MANIFEST -> ## Dependencies`. Reference them from STATUS or CONTEXT when the narrative demands it, but never duplicate the list elsewhere.

#### CHECKPOINT DEPENDENCIES

- Enumerate upstream CHECKPOINTS whose deliverables you consume.
- Link each dependency with rooted paths, record its `LIFECYCLE` (`active`, `superseded`, or `archived`), and track whether its contract is currently `VALID`.

#### SYSTEM DEPENDENCIES

- List external services, APIs, datasets, tooling, or credentials required to execute the harness.
- Document current availability, access instructions, and known risks or blockers.

- Update both dependency lists whenever status changes; LOG significant flips so automation can audit decisions.

<comment>Harness-first workflow emphasizes designing measurement, then specifying the contract, then building - mirroring Dexter's advice.</comment>

## 4. Harness-First Workflow

1. **PREPARE** - Define the question "How will we know this works?" before implementation.
   - Draft acceptance signals, metrics, or review checklists in STATUS.
   - Record blockers (credentials, data access) and plan mitigations before coding.
   - Summarize inherited context: which CHECKPOINTS delivered what, open risks, outstanding dependencies.
   - Write explicit success criteria and exit conditions so pivots are intentional, not accidental.
2. **SPECIFY** - Wire measurement and feedback into the CHECKPOINT contract.

   - Capture the harness design in MANIFEST (what to run, success criteria, telemetry targets).
   - Maintain the MANIFEST LEDGER in MANIFEST (deliverable name, rooted path, one-line purpose).
   - Note expected telemetry (logs, metrics, tests) and their locations.
   - Document dependency contracts in MANIFEST under `## Dependencies`, splitting into `### CHECKPOINT DEPENDENCIES` and `### SYSTEM DEPENDENCIES`. Use STATUS or CONTEXT to explain why dependencies exist, but keep the authoritative list in MANIFEST.

   Structured dependency lists belong in MANIFEST -> `## Dependencies`; reserve STATUS or CONTEXT for narrative rationale while keeping the canonical checklist in MANIFEST.

3. **BUILD** - Implement deliverables while keeping `ARTIFACTS/` empty until they are consumption ready.
   - Keep scratch work local; update STATUS and CONTEXT as new facts emerge.
4. **VERIFY** - Run the harness: commands, tests, reviews, manual checks.
   - Log outcomes with timestamps and link to deliverables.
   - If verification is blocked, record a credible blocker contract: name the owner, target date, and remediation CHECKPOINT or ticket. Keep `VALID: false` until the contract is satisfied or the harness actually runs.
5. **HANDOFF/NEXT** - Close the loop.
   - Set `VALID: true` only when another agent can resume without surprises.
   - If more work remains, create a successor or delegate CHECKPOINT, log cross-links in both parent and child, and carry forward context.

<comment>Clear logging expectations keep the audit load out of the HARNESS; most real-world resumption pain came from missing timelines.</comment>

## 5. Logging and Signals

- Begin every CHECKPOINT with an orienting LOG entry describing inherited scope or initial intent.
- When creating successors (CONTINUE), log the link in both CHECKPOINTS and carry forward relevant STATUS items.
- For restarts (RESTART), bump the version, explain the pivot in CONTEXT, log the retirement, and reference the new CHECKPOINT.
- Delegations must be cross-linked: parent LOG cites `::WORK/child/...`, child frontmatter sets `DELEGATE_OF`, child LOG reports outcomes back to parent.
- Use LOG for meaningful events only; omit trivial edits or automated commits.
- When scope changes midstream, add a LOG entry quoting or linking to the directive (Slack, transcript, issue) so future agents see the pivot trigger.
- Use CLI commands that emit structured events (`acft new`, `acft close`, `acft verify --record`) so sentinels can react automatically. Silent manual edits are prohibited.
- Treat emission failures as blockers: mutating commands must exit non-zero if they cannot append to the event log; retry only after fixing the underlying issue.

### 5.1 Event Stream

- Mutating commands print a JSON event and call the shared emitter helper to append it atomically to `::WORK/checkpoints_events.log`. If emission fails, the command must exit non-zero.
- Core event types:
  - `CHECKPOINT_CREATED` (payload includes `DELEGATE_OF`, `TAGS`)
  - `HARNESS_EXECUTED` (payload includes `STATUS`, `COMMANDS`, `LOG_PATH`; `STATUS` mirrors the command outcome code)
  - `CHECKPOINT_VERIFIED` (payload includes `VALID`, `SIGNAL`, `MESSAGE`)
  - `CHECKPOINT_CLOSED`
  - `MANIFEST_UPDATED` (optional helper when `ARTIFACTS/` contents change or `acft manifest --emit` runs)
- Store harness run logs under `::WORK/logs/{checkpoint}/harness_{timestamp}.log` (or equivalent rooted path) and surface the resolved path via the required `LOG_PATH` field so auditors can replay verification steps.
- Automation treats the event log as the trigger source for validation runs, auditors, and notifications.
- Sentinel automation listens for `CHECKPOINT_CREATED`, `CHECKPOINT_VERIFIED`, and `MANIFEST_UPDATED` events, Verifiers for `CHECKPOINT_CLOSED` vs `HARNESS_EXECUTED`, and Auditors for periods of inactivity. Expand the roster only after adding matching events.

<comment>Quality gate enforces that measurement actually ran - preventing the "manual review only" completions seen in pipeline_validation_v1_05.</comment>

### 5.2 Event Extension Process

- New event types must complete the Event Extension Process documented in `FRAMEWORK_FOUNDATION.md` before any CLI change merges.
- Each proposal names the failure mode it addresses, lists producers and consumers, defines required payload fields, and outlines rollout/backfill steps.
- Reject or back out CLI changes that emit undocumented event types; the log is the automation contract.

## 6. Manifest and Quality Gate

- `VALID: true` always ships with a populated MANIFEST LEDGER. While `VALID: false`, you may leave the LEDGER stubbed, but label its status so successors know deliverables are still forming.
- `ARTIFACTS/` lists only consumer-ready deliverables; document each item in MANIFEST with purpose and usage.
- Keep the MANIFEST LEDGER at the top of MANIFEST, mapping deliverable name -> rooted path -> one-line purpose. Update it whenever `ARTIFACTS/` changes and before flipping `VALID` to `true`.
- Reference every deliverable or dependency with rooted paths; confirm they resolve (use `acft expand` if unsure).
- Capture validation proof: commands executed, tests, reviewer sign-offs, or manual checks - with outcomes logged.
- Run `acft validate ::THIS` before closure; resolve failures or document exceptions in LOG.
- If verification cannot run (missing credentials, tools, data), record a credible blocker contract: name the owner, target date, and remediation CHECKPOINT or ticket. Keep `VALID: false` until the contract is satisfied or the harness actually runs.

### 6.1 Consolidation and Retirement

- When converging multiple exploratory CHECKPOINTS into a single authoritative deliverable:
  - Set `SUPERSEDES` in the consolidating CHECKPOINT’s frontmatter (e.g., `SUPERSEDES: ["::WORK/plan_a_v1_01", "::WORK/plan_b_v1_02"]`).
  - Predecessor CHECKPOINTS add `SUPERSEDED_BY` via `acft close --status false --lifecycle superseded --message "Superseded by ::WORK/unified_plan_v1_03"`.
  - Copy any required source material into the new CHECKPOINT (place raw inputs under `::THIS/STAGE/` or `_archive/`) so the deliverable in `ARTIFACTS/` stands alone.
  - Document the merge in `STATUS`/`CONTEXT`; MANIFEST LEDGER must list only the new deliverable.
  - Validate isolation: `acft orient ::THIS --sections HARNESS,MANIFEST` should not require readers to open the superseded CHECKPOINTS.
- Leave historical CHECKPOINTS intact for auditability but treat them as background; downstream work references the unified CHECKPOINT going forward.

<comment>Failure catalogue encodes lessons from work done in real projects; update it when new anti-patterns surface.</comment>

## 7. Failure Modes and Recovery

<!-- failure-catalogue:start (synced with FAILURE_CATALOGUE_TABLE.md; edit the table there) -->

{{#include FAILURE_CATALOGUE_TABLE.md}}

<!-- failure-catalogue:end -->

- When you update this table, also refresh `SYSTEM_PROMPT.md` and `CLI_REFERENCE.md` so frontline agents and tooling stay aligned.
- Treat every remediation as work: capture it in STATUS, explain the fix in CONTEXT or LOG, and keep `VALID: false` until the contract is trustworthy.
- When a pattern repeats across CHECKPOINTS, note it in STATUS and propose framework or tooling updates through the Stewardship process.
- If remediation requires risky cleanup or historical reconstruction, open a dedicated CHECKPOINT so the audit trail remains intact.

<comment>Toolkit serves as the quick-start surface for agents; keep it short and canonical.</comment>

## 8. Command Toolkit

| Goal                       | Command                                                                                     | Notes                                                                                                                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Inspect current CHECKPOINT | `acft orient ::THIS`                                                                        | Default view surfaces STATUS, MANIFEST LEDGER preview, and latest LOG entry; add `--sections HARNESS,MANIFEST` for deeper dives. Use `::WORK/...` when inspecting other CHECKPOINTS. |
| Create CHECKPOINT          | `acft new NAME`                                                                             | Scaffolds the CHECKPOINT, seeds `CHECKPOINT.md`, and emits `CHECKPOINT_CREATED`.                                                                                                     |
| Close / reopen CHECKPOINT  | `acft close --status {true,false} --signal {pass,fail,blocked,pending} [--lifecycle STATE]` | Updates frontmatter + LOG, emits `CHECKPOINT_VERIFIED` (and `CHECKPOINT_CLOSED` when setting `--status true`).                                                                       |
| Validate structure         | `acft validate ::THIS`                                                                      | Run before hand-off; LOG the result (pass/fail plus fixes).                                                                                                                          |
| MANIFEST sweep             | `acft manifest --mode {quick,full} [--emit]`                                                | Detects the 13 failure modes enumerated above; `--emit` appends a `MANIFEST_UPDATED` event.                                                                                          |
| Verify harness             | `acft verify --record`                                                                      | Executes MANIFEST commands in order; emits `HARNESS_EXECUTED` and records outcomes.                                                                                                  |
| Expand rooted path         | `acft expand ::PROJECT/path/to/file`                                                        | Use to feed other tooling or confirm anchors resolve.                                                                                                                                |
| View documentation         | `acft spec --doc {guide,foundation,prompt}`                                                 | Prints the published docs for quick reference; `guide` emits this specification.                                                                                                     |
| Stream events              | `acft events tail --follow`                                                                 | Subscribe to structured event output for automation.                                                                                                                                 |
| Launch delegate agent      | `acft claude "..."`                                                                         | Run inside the delegate CHECKPOINT; log invocation and outcomes in both LOGs.                                                                                                        |

## 9. Optional Assets and Conventions

- Use `AGENTS.md` to outline roles, escalation paths, or collaboration protocols when multiple agents share a CHECKPOINT.
- Keep checklists or scratchpads in clearly labeled files (`notes.md`, `STAGE/plan.txt`) so they remain discoverable yet distinct from deliverables.
- When external context is large, stage source material in `STAGE/` and cite it from STATUS using rooted paths, then prune or archive the staging material before closure.
- Remove or archive scratch assets once their information is captured in `CHECKPOINT.md`; `ARTIFACTS/` stays the durable interface.

<comment>Stewardship note reminds maintainers to revisit these comments, prune outdated guidance, and bump versions when rules change.</comment>

## 10. Stewardship

- This manual is the canonical reference. Update it when the framework evolves and bump the version in the title so agents know which rule set applies.
- Keep the manual lean: prefer tables and checklists, explain the "why" only when it affects behavior, and document major shifts in the LOG of the CHECKPOINT that produced the update.
