# Event Instrumentation for AI Agents

## Core Concept

Events = structured JSON signals for automation. Optional but enables observability.

**Location:** `::WORK/checkpoints_events.log` (append-only, newline-delimited JSON)

## Event Types

| Event | Emitted By | When | Payload |
|-------|-----------|------|---------|
| `CHECKPOINT_CREATED` | `acft new` | New CHECKPOINT scaffolded | `DELEGATE_OF`, `TAGS` |
| `HARNESS_EXECUTED` | `acft verify --record` | Harness ran | `STATUS`, `COMMANDS`, `LOG_PATH` |
| `CHECKPOINT_VERIFIED` | `acft close` | VALID/SIGNAL changed | `VALID`, `SIGNAL`, `MESSAGE` |
| `CHECKPOINT_CLOSED` | `acft close` | VALID set to true | (minimal payload) |
| `MANIFEST_UPDATED` | `acft manifest --emit` | Deliverables changed | `MODE`, `ISSUES`, `SEVERITY` |

## Event Schema

```json
{
  "TYPE": "EVENT_NAME",
  "CHECKPOINT_PATH": "::WORK/branch_v1_01",
  "ACTOR": "agent-name",
  "TIMESTAMP": "2025-02-10T14:32:00Z",
  "PAYLOAD": {
    // event-specific fields
  }
}
```

## Rules for Agents

1. **Events are optional** - Framework works without them
2. **Use `--record` and `--emit` flags** - These trigger event emission
3. **Events ≠ LOG** - Events are for machines, LOG is for humans
4. **Emission failure = hard error** - If event can't be written, command must fail
5. **Always use rooted paths** - In event payloads and LOG entries

## When to Emit Events

**Emit when:**
- Creating CHECKPOINTs (`acft new`)
- Running harnesses (`acft verify --record`)
- Closing work (`acft close`)
- Updating deliverables (`acft manifest --emit`)

**Don't emit when:**
- Making minor edits to CHECKPOINT.md
- Adding LOG entries manually
- Updating STATUS or CONTEXT sections
- Routine file operations

## Automation Hooks

Events enable three types of automation:

**Sentinel** - Listens to `CHECKPOINT_CREATED`, runs validation:
```bash
acft events tail --types CHECKPOINT_CREATED --follow | \
  jq -r '.CHECKPOINT_PATH' | \
  xargs -I{} acft validate {}
```

**Verifier** - Listens to `CHECKPOINT_CLOSED`, checks harness ran:
```bash
acft events tail --types CHECKPOINT_CLOSED --follow | \
  jq -r '.CHECKPOINT_PATH' | \
  xargs -I{} acft orient {} --sections MANIFEST
```

**Auditor** - Periodically checks for stale CHECKPOINTs:
```bash
acft manifest --mode full --json --emit
```

## Critical: LOG_PATH Requirement

`HARNESS_EXECUTED` events MUST include `LOG_PATH` field pointing to harness output:
```json
{
  "TYPE": "HARNESS_EXECUTED",
  "PAYLOAD": {
    "STATUS": "pass",
    "LOG_PATH": "::WORK/logs/auth_v1_02/harness_20250210_143200.log"
  }
}
```

This lets auditors replay verification steps.

## Event Extension Process

Before adding new event types:
1. Document which failure mode it addresses
2. Define required payload fields
3. List all producing commands
4. List all consuming automation
5. Update FRAMEWORK_SPEC.md and CLI_REFERENCE.md

Never emit undocumented event types.

## Agent Decision Tree

```
Should I emit an event?
├─ Using acft command with --record or --emit flag?
│  └─> YES (automatic)
│
├─ Manually editing CHECKPOINT.md?
│  └─> NO (events are for commands, not manual edits)
│
└─ Running harness or closing work?
   └─> USE acft commands (they emit automatically)
```

## Key Insight

Events make CHECKPOINTs **observable without polling**. Instead of scanning directories for changes, automation subscribes to the event stream and reacts immediately.

But the framework's core contract (files + conventions) works with or without events.
