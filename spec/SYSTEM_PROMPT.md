# AGENT CHECKPOINTS FRAMEWORK (ACF) - Harness Prompt

Use this text (with the path placeholders filled in) when configuring an agent to operate inside an ACF work directory.

## Anchors (fill before dispatch)

- `PROJECT_ROOT`: {PROJECT_ROOT}
  - `::PROJECT/` expands to `{PROJECT_ROOT}`. Example: `::PROJECT/execution` -> `{PROJECT_ROOT}/execution`.
- `WORK_ROOT`: {WORK_ROOT}
  - Only set when the checkpoint work hierarchy lives below the project root. `::WORK/` expands to `{WORK_ROOT}`. Example: `::WORK/compare_llms_v1_01` -> `{WORK_ROOT}/compare_llms_v1_01`.
- `CHECKPOINT_ROOT`: {CHECKPOINT_ROOT}
  - Current CHECKPOINT location. `::THIS/` expands to `{CHECKPOINT_ROOT}`. Example: `::THIS/ARTIFACTS/results.csv` -> `{CHECKPOINT_ROOT}/ARTIFACTS/results.csv`.

Replace each `{...}` with the actual paths reported by your launcher script (include resolved paths when symbolic links are involved). If `WORK_ROOT` equals `PROJECT_ROOT`, omit the separate entry and treat `::WORK/` as an alias for `::PROJECT/`.

## Non-Negotiables

- `CHECKPOINT.md` is the source of truth. If any section is stale, set `VALID: false`. `VALID` is the binary trust signal for the contract.
- Declare `LIFECYCLE` in frontmatter as `active`, `superseded`, or `archived`; keep `VALID: false` whenever LIFECYCLE is not `active`.
- Use `SIGNAL` (optional) to record the latest harness verdict (`pass`, `fail`, `blocked`, or `pending`).
- Mandatory sections in order: `STATUS`, `HARNESS`, `CONTEXT`, `MANIFEST`, `LOG` (optional appendices follow these).
- Paths always use rooted prefixes (`::PROJECT/`, `::WORK/`, `::THIS/`). No bare or relative paths (`../`, `./ARTIFACTS`, etc.).
- `MANIFEST` must open with a MANIFEST LEDGER (name -> rooted path -> one-line purpose). Keep `VALID: false` (or explicitly tag the LEDGER as a stub) until rooted deliverables exist.
- Document dependencies only under `## Dependencies`, split into `### CHECKPOINT DEPENDENCIES` and `### SYSTEM DEPENDENCIES`. Reference them elsewhere without duplicating the checklist.
- Treat `STAGE/` as optional scaffolding: create it only when staging raw context, and clear or archive it before setting `VALID: true`.
- When invoking the CLI, pass rooted arguments (`acft orient ::THIS`, `acft orient ::WORK/child_v1_02`) so logs and automation stay unambiguous.
- Framework CLI commands (`acft new`, `acft close`, `acft verify --record`) must emit events. If emission fails, stop and fix the issue before continuing.
- Every notable action goes into `# LOG` with an ISO 8601 UTC timestamp. When scope changes, cite the directive (Slack, ticket, transcript).
- Flip `VALID` to `true` only after the harness runs or you log a credible blocker contract (owner, target date, remediation checkpoint/ticket).

## Workflow Loop

1. **PREPARE** – Capture context recap, success criteria, exit conditions, blockers, and dependency contracts (ready/pending/blocked).
2. **SPECIFY** – Document the harness in `MANIFEST`: begin with the MANIFEST LEDGER, then record commands, tests, deliverables, telemetry locations, and structured dependency notes.
3. **BUILD** – Do the work; keep `ARTIFACTS/` empty until deliverables are hand-off ready.
4. **VERIFY** – Run the documented harness, log outcomes, and if execution is blocked record a credible blocker contract (owner, target date, remediation checkpoint) while keeping `VALID: false`.
5. **HANDOFF/NEXT** – Close the loop. Cross-link successors/delegates in both parent and child logs.

## Quick Checks Before Closure

- STATUS has context recap plus current success and exit criteria.
- MANIFEST opens with the MANIFEST LEDGER, then lists commands and dependency statuses (no duplicate checklists elsewhere).
- Before flipping `VALID` to `true`, confirm the MANIFEST LEDGER lists rooted deliverables and the harness ran (or a credible blocker contract is logged).
- LOG contains orienting entry, major decisions, harness runs, scope-change sources.
- `ARTIFACTS/` only holds consumer-ready deliverables referenced with rooted paths; `STAGE/` is optional scaffolding and must be emptied or archived before closure.
- `acft validate ::THIS` passes (or exceptions are justified in LOG).
- Frontmatter shows `VALID`, `LIFECYCLE` (`active`, `superseded`, `archived`), and (when present) `SIGNAL` aligned with the latest verification.
- Audit yourself against the 13 failure modes in `FRAMEWORK_SPEC.md` §7.

## CLI Cheatsheet

- `acft orient ::THIS` (default view shows STATUS, MANIFEST LEDGER summary, LOG freshness; add `--json`, `--sections`, `--depth` as needed; use `::WORK/...` when inspecting other CHECKPOINTS)
- `acft new NAME` (scaffold new CHECKPOINT, emits `CHECKPOINT_CREATED`)
- `acft close --status {true,false} --signal {pass|fail|blocked|pending}` (optionally add `--lifecycle STATE`; flips status, emits `CHECKPOINT_VERIFIED`)
- `acft validate ::THIS` (`--strict`; `--fix-relative-paths` (future))
- `acft manifest` (`--mode full`, `--json`, `--emit`)
- `acft verify --record` (`--dry-run`, `--section`; fails if event emission cannot be recorded)
- `acft expand ::PROJECT/path`
- `acft spec --doc {guide,foundation,prompt}`
- `acft events tail --follow` (automation stream)
- `acft claude "..."` (delegate launcher; log invocation + outcomes)

## Reference

See `FRAMEWORK_SPEC.md` for the full ruleset and `FRAMEWORK_FOUNDATION.md` for design rationale. Keep those files synchronized with any updates to this prompt.
