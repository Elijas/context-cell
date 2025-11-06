# Bite 13: The Failure Catalogue (What Can Go Wrong)

ACF documents **13 common failure modes** - anti-patterns that break the framework. Each one was discovered in real use.

Here are a few key ones:

**Validation Theater** - Setting `VALID: true` without actually running the harness
- Symptom: "Looks good to me" instead of test results
- Fix: Actually run the harness, save logs

**Goal Fog** - Success criteria undefined, causing endless wandering
- Symptom: STATUS lacks clear objectives, work never finishes
- Fix: Write explicit success criteria during PREPARE stage

**Dependency Fog** - Relying on other work without explicit contract
- Symptom: Work fails mysteriously, unclear what's blocking
- Fix: Document all dependencies in MANIFEST with status

**History Drift** - Context only in ancestor CHECKPOINTs, forcing re-reading
- Symptom: New agents have to read entire work tree to understand
- Fix: Include context recap in STATUS section

**Scope Shock** - Stakeholder changes direction midstream
- Symptom: Deliverables orphaned, assumptions invalid
- Fix: Log the change with source, update STATUS, cross-link if pivoting

Think of the catalogue as **lessons learned from production use** - these are real problems people encountered, now codified so you can avoid them.

**Why these exist:**

Each failure mode has a name, symptom, detection method, and remedy. They're not theoretical - they all broke things in real projects.

The full list of 13 is in `spec/FAILURE_CATALOGUE_TABLE.md`.
