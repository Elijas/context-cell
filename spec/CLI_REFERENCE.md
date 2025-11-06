# AGENT CHECKPOINTS FRAMEWORK (ACF) - CLI Reference

This guide documents the recommended CLI surface for working inside an ACF work hierarchy. Commands live in `{PROJECT_ROOT}/bin` (exposed as `::PROJECT/bin`) by default; feel free to re-implement them in another language or location as long as they preserve the behavior described below and remain on `$PATH`.

> **Toolchain note:** `acft` = Agent Checkpoints Framework Toolchain. Commands are designed to run in sequence across the harness-first workflow (orient -> specify -> build -> verify), so each step emits the signal the next one expects.

## 1. Command Summary

| Command              | Purpose                                                 | Key options                                                                                                          | Notes                                                                                                                                                                                    |
| -------------------- | ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `acft orient ::THIS` | View ancestry -> peers -> children with quick signals   | `--json`, `--sections SEC1,SEC2`, `--depth N`                                                                        | Default output surfaces `VALID`, `LIFECYCLE`, MANIFEST LEDGER preview, and latest LOG timestamp; use explicit roots (`::THIS`, `::WORK/...`) instead of `.` for unambiguous transcripts. |
| `acft new NAME`      | Scaffold a CHECKPOINT and emit events                   | `--delegate-of PATH`, `--tags`, `--no-open`                                                                          | Seeds `CHECKPOINT.md` with `VALID: false`, `LIFECYCLE: active`; emits `CHECKPOINT_CREATED`.                                                                                              |
| `acft close`         | Flip `VALID`/`LIFECYCLE`, record LOG entry, emit events | `--path PATH`, `--status {true,false}`, `--signal {pass,fail,blocked,pending}`, `--message MSG`, `--lifecycle STATE` | Updates frontmatter, writes LOG, emits `CHECKPOINT_VERIFIED` (and `CHECKPOINT_CLOSED` when status becomes true).                                                                         |
| `acft validate`      | Enforce naming, front matter, section ordering, roots   | `--strict`, `--fix-relative-paths` (future)                                                                          | Structural lint; today it reports issues; `--fix-relative-paths` will auto-rewrite once shipping.                                                                                        |
| `acft manifest`      | Sweep for harness failure modes                         | `--mode {quick,full}`, `--json`, `--emit`                                                                            | Detects the 13 failure modes in `FRAMEWORK_SPEC.md` §7; `--emit` appends `MANIFEST_UPDATED`.                                                                                             |
| `acft verify`        | Execute the harness recorded in MANIFEST                | `--dry-run`, `--section SECTION`, `--record`                                                                         | Runs documented commands sequentially; `--record` emits `HARNESS_EXECUTED` (command fails if the emitter cannot append).                                                                 |
| `acft expand`        | Expand `::PROJECT/`, `::WORK/`, `::THIS/` anchors       | —                                                                                                                    | Backed by `_acft_expand.sh`; convenient for scripting and navigation.                                                                                                                    |
| `acft spec`          | Print the published documentation                       | `--doc {guide,foundation,prompt}`, `--path PATH`                                                                     | Handy for quick reference.                                                                                                                                                               |
| `acft events tail`   | Stream event log for automation                         | `--since TIMESTAMP`, `--follow`, `--types a,b`                                                                       | Emits newline-delimited JSON for sentinels/verifiers.                                                                                                                                    |
| `acft claude`        | Launch a delegate agent inside the current CHECKPOINT   | accepts pass-through args                                                                                            | Wraps `claude_launcher.sh`; log invocation and outcomes in both LOGs.                                                                                                                    |

`VALID` reflects handoff readiness: set it to `true` only when the harness has run (or a credible blocker contract is logged) and the next agent can trust the deliverables. Keep it `false` whenever `LIFECYCLE` is `superseded` or `archived`.

## 2. Detailed Behavior

### 2.1 `acft orient`

- **Input**: rooted path to the target CHECKPOINT (`::THIS` for the current shell, `::WORK/branch_v1_02` for siblings), plus optional flags.
- **Output**: default table that highlights ancestry/peers/children, `VALID`, `LIFECYCLE`, latest LOG timestamp, first sentence of `STATUS`, and a collapsed MANIFEST LEDGER preview. `--sections` inlines full section text; `--json` returns the machine-readable form.
- **Usage examples**:
  - `acft orient ::THIS`
  - `acft orient ::WORK/write_prompt_v1_01 --json --sections HARNESS,MANIFEST --depth 2`

### 2.2 `acft new`

- **Purpose**: create a new CHECKPOINT with the correct scaffold and emit a discoverable event.
- **Behavior**:
  - Validates requested name against `{branch}_v{version}_{step}`.
  - Creates directory, seeds `CHECKPOINT.md` template with frontmatter + required sections (defaulting to `VALID: false`, `LIFECYCLE: active`), and optional `STAGE/`.
  - Writes a LOG entry noting creation intent (unless `--no-open`).
  - Emits a `CHECKPOINT_CREATED` event to stdout (JSON) and appends to the event log.
- **Usage examples**:
  - `acft new auth_v3_01`
  - `acft new filters_v2_04 --delegate-of ::WORK/parent_v2_03 --tags spike`

### 2.3 `acft close`

- **Purpose**: flip `VALID`, append a LOG entry, and emit status events.
- **Behavior**:
  - Defaults to the current CHECKPOINT; `--path` accepts rooted paths.
  - Updates YAML frontmatter `VALID`, `SIGNAL`, and `LIFECYCLE` (when provided).
  - Inserts LOG entry summarizing why the status changed (customizable via `--message`).
  - When setting `--status true`, confirm the MANIFEST LEDGER lists rooted deliverables and that the harness ran (or log the credible blocker contract instead of flipping the flag).
  - Emits `CHECKPOINT_VERIFIED`; if setting `true`, also emits `CHECKPOINT_CLOSED`.
- **Usage examples**:
  - `acft close --status true --message "Handoff to ::WORK/auth_v3_02"`
  - `acft close --status false --path ::WORK/auth_v3_01 --message "Harness blocked on credentials"`
  - `acft close --status false --lifecycle superseded --message "Superseded by ::WORK/auth_v3_05"`

### 2.4 `acft validate`

- **Checks**:
  1. Directory name matches `{branch}_v{version}_{step}` pattern.
  2. `CHECKPOINT.md` exists, readable, uses YAML front matter with `VALID` and `LIFECYCLE`.
  3. `LIFECYCLE` is one of `active`, `superseded`, `archived`; keep `VALID: false` when not `active`.
  4. Required sections exist exactly once and in the right order.
- 5. No bare or relative paths (`../`, `./ARTIFACTS`). Today the command surfaces these for manual fix; `--fix-relative-paths` will provide an auto-rewrite once implemented.
- 6. Warn when `STAGE/` holds leftover staging assets at closure; missing `STAGE/` is acceptable and does not fail validation.
- 7. Additional warnings (missing context recap, empty sections) without failing unless `--strict` is set.
- `--fix-relative-paths` is a planned flag; note the issue, repair paths manually, and rerun validation until the enhancement ships. `--emit` is also planned; for now the command keeps output local.
- **Usage examples**:
  - `acft validate`
  - `acft validate --strict`

### 2.5 `acft manifest`

- **Purpose**: run lightweight heuristics for the failure catalog:
  - Missing harness (MANIFEST lacks commands or recorded outcomes)
  - Stale contract (HARNESS/STATUS disagree with `ARTIFACTS/` or recent LOG entries)
  - Missing MANIFEST LEDGER when `VALID: true`, or ledger entries lacking rooted `::THIS/ARTIFACTS` paths
  - Unrooted references (bare paths, `../`, `./ARTIFACTS`)
  - Relative-path bleed (references to sibling CHECKPOINTS via `../`)
  - Timeline gaps (notable changes without corresponding LOG entries)
  - Orphaned successors/delegates (child directories without cross-links)
  - Version drift (multiple active CHECKPOINTS sharing branch+version)
  - Scope shock (LOG pivot with no directive linked)
  - History drift (STATUS missing inherited context recap)
  - Dependency fog (dependencies lacking status or rooted links)
  - Goal fog (no measurable success/exit criteria)
  - Validation theater (`VALID: true` without a recent `HARNESS_EXECUTED` event and only "manual review" wording)
- **Mode options**:
  - `--mode quick` (default): check current CHECKPOINT only.
  - `--mode full`: walk descendants.
  - `--json`: machine-readable output.
  - `--emit`: append a `MANIFEST_UPDATED` event with summary payload.

### 2.6 `acft verify`

- **Goal**: execute the verification steps listed in `MANIFEST`. Expect commands to be tagged (e.g., `Harness:` fenced block or bullet list).
- **Behavior**:
  - Parse documented commands.
  - Execute them sequentially.
  - Fail fast on errors and report which step failed.
  - Record outcomes (pass/fail) so the agent can log them.
  - Persist command output under `::WORK/logs/{checkpoint}/harness_{timestamp}.log` (or an equivalent rooted path) and surface that location via the required `LOG_PATH` payload field.
  - `--record` emits a `HARNESS_EXECUTED` event including pass/fail and command log; the command exits non-zero if the emitter helper cannot append to the event log.
- **Options**:
  - `--dry-run` (print commands without running).
  - `--section SECTION` (run a subset if multiple harness blocks exist).

### 2.7 `acft expand`

- **Behavior**: expands path prefixes to absolute paths, leaving absolute paths untouched.
- **Usage examples**:
  - `acft expand ::PROJECT`
  - `cd $(acft expand ::WORK/write_prompt_v1_01)`

### 2.8 `acft spec`

- **Purpose**: print the published documentation.
- **Doc selectors**:
  - `--doc guide` -> `FRAMEWORK_SPEC.md`
  - `--doc foundation` -> `FRAMEWORK_FOUNDATION.md`
  - `--doc prompt` -> `SYSTEM_PROMPT.md`
  - `--path PATH` -> custom file
- **Usage examples**:
  - `acft spec`
  - `acft spec --doc foundation`

### 2.9 `acft events tail`

- **Purpose**: provide a streaming interface for downstream automation.
- **Behavior**:
  - Reads the event log (default location: `::WORK/checkpoints_events.log`).
  - Filters by `--types` when provided.
  - `--since` supports ISO 8601 timestamps or relative durations (e.g., `-1h`).
  - `--follow` keeps the stream open (like `tail -f`).
- **Usage examples**:
  - `acft events tail --since -10m`
  - `acft events tail --types CHECKPOINT_CREATED,HARNESS_EXECUTED --follow`

### 2.10 `acft claude`

- **Purpose**: launch a helper agent. Current script (`claude_launcher.sh`) already handles credentials, context injection, and logging instructions.
- **Expectations**:
  - Use inside delegate CHECKPOINTS or when launching a helper from the parent.
  - Record invocation and summary in `# LOG`.
  - Capture exit status or key findings in `MANIFEST`.

## 3. Implementation Notes

- **Path discovery**: reuse the helper functions from the existing scripts (`find_project_root`, `find_work_root`, etc.). Keep behavior consistent across commands.
- **Output format**: defaults for humans; use `--json` for automation.
- **Safety**: commands that modify files (`--fix-relative-paths` (future), other auto-fixes) should be explicit opt-in.
- **Event emission**: funnel all events through the shared emitter helper so stdout and the log stay in sync; add regression tests that simulate append failures.
- **Extensibility**: if you introduce new commands, add them here and update `SYSTEM_PROMPT.md` / `FRAMEWORK_SPEC.md` as needed.

## 4. Future Automation Hooks

- **Sentinel**: subscribe to `CHECKPOINT_CREATED`, `MANIFEST_UPDATED`, and `CHECKPOINT_VERIFIED` events, then run `acft orient ::WORK/path --json` and `acft validate ::WORK/path --strict` (event emission will land once the `--emit` flag is implemented).
- **Verifier**: react to `CHECKPOINT_CLOSED` and `HARNESS_EXECUTED` events; reopen CHECKPOINTS lacking a fresh harness run and log the action.
- **Auditor**: periodically consume the event log to find quiescent CHECKPOINTS, then execute `acft manifest --mode full --json --emit` across the work hierarchy.

## 5. Event Stream (JSON)

- **Location**: `::WORK/checkpoints_events.log` (append-only, newline-delimited JSON). Commands also print the event to stdout for piping.
- **Schema**:
  ```json
  {
    "TYPE": "CHECKPOINT_CREATED",
    "CHECKPOINT_PATH": "::WORK/auth_v3_01",
    "ACTOR": "codex-main",
    "TIMESTAMP": "2025-02-10T14:32:00Z",
    "PAYLOAD": {
      "DELEGATE_OF": "::WORK/auth_v2_07",
      "TAGS": ["spike"]
    }
  }
  ```
- **Canonical `type` values**:
  - `CHECKPOINT_CREATED` (payload may include `DELEGATE_OF`, `TAGS`)
  - `HARNESS_EXECUTED` (payload includes `STATUS`, `COMMANDS`, `LOG_PATH`)
  - `CHECKPOINT_VERIFIED` (payload includes `VALID`, `SIGNAL`, `MESSAGE`)
  - `CHECKPOINT_CLOSED`
  - `MANIFEST_UPDATED` (payload includes `MODE`, `ISSUES`, `SEVERITY`)
- **Guidelines**:
  - Keep payloads concise; prefer rooted paths and identifiers over raw blobs.
  - Use the shared emitter helper to print events and atomically append to the log; treat any append failure as a hard error and surface it to the caller.
  - Downstream automation treats the log as authoritative. If a command cannot emit (e.g., stdout redirected), it must fail loudly rather than proceed silently.
  - When extending the schema, follow the Event Extension Process (see below) and update this reference plus `FRAMEWORK_FOUNDATION.md` with the rationale.

The CLI surface above keeps the framework thin but effective. It mirrors the harness manual, helps agents stay on rails, and acts as the integration point for any future multi-agent orchestration you want to experiment with.

## 6. Event Extension Release Checklist

1. Link the proposal to a documented failure mode and attach it to the originating CHECKPOINT.
2. Define the new event (name, trigger, required payload fields) and update the emitter helper tests.
3. List every producing command/script and ensure they abort if emission fails.
4. Enumerate downstream consumers (sentinel/verifier jobs, dashboards) and ship their updates in the same change.
5. Provide rollout/backfill steps plus a rollback plan if emitters misbehave.
6. Update `FRAMEWORK_SPEC.md`, `FRAMEWORK_FOUNDATION.md`, and `SYSTEM_PROMPT.md`/`CLI_REFERENCE.md` as needed, noting the change in `# LOG`.
7. Confirm documentation and tests merged before enabling the new type in production.
