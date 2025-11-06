# ACFT Tooling Update Report

## Scope

- Replaced the legacy `acft` shim with a Python-based CLI that implements the full toolchain promised in `spec/CLI_REFERENCE.md`.
- Broke the CLI into module-per-command packages (`bin/_acft_<slug>/`) so each `acft` subcommand owns its handler; the Claude launcher script now lives alongside its module at `bin/_acft_claude/claude.sh`, and shared helpers remain in `_lib.py`.
- Preserved the existing `_claude.sh` delegate launcher; `acft claude …` now shells out to it after resolving context.

## Alignment Decisions

- **Root discovery** follows the spec’s rationale: walk upward for `checkpoints_project.toml`/`.git`, treat `checkpoints_work.toml` as an optional override, and infer `::THIS` only when a `CHECKPOINT.md` is on the path.
- **Event emission** flows through a shared `EventEmitter` so `new`, `close`, `verify --record`, and `manifest --emit` write JSON to both stdout and `::WORK/checkpoints_events.log`, failing hard on append errors per §5 of the spec.
- **CHECKPOINT parsing** enforces the section order, frontmatter keys, MANIFEST LEDGER placement, and LOG ISO timestamps that underpin the harness-first architecture described in `FRAMEWORK_FOUNDATION.md`.
- **Regression tests** live under `bin/tests/` with per-command pytest suites; they spin up ephemeral project/work trees in `/tmp` to prove CLI behavior without touching real checkpoints.

## Intentional Deviations (Documented for future spec updates)

1. `acft validate --json`

   - Provides machine-readable lint output so sentinels can enforce the same contract. The flag is opt-in and does not alter the human-facing defaults.

2. `acft new` template

   - Leaves `# LOG` empty and appends the creation entry programmatically (unless `--no-open`) so dry scaffolds truly start blank.
   - Does **not** auto-create `STAGE/`; teams can request it explicitly later without removing unused scaffolding.

3. Failure catalogue heuristics
   - Added best-effort detectors for all 13 failure modes. Each check encodes the underlying rationale (e.g., rooted paths, credible harness evidence). The messages surface context so humans can make the final call when heuristics land near the threshold.

## Smoke Checks

- `acft --help`
- `acft spec --doc prompt`
- `acft expand ::PROJECT ::WORK`
- `bin/tests/run_tests.sh` (pytest)

Harness execution, manifest sweeps, and checkpoint mutations were **not** exercised end-to-end because creating/editing checkpoints would violate the “bin/ only” instruction.
