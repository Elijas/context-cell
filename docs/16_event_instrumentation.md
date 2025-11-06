# Bite 16: Event Instrumentation (The Automation Layer)

CHECKPOINTs can emit **structured events** that automation can listen to. This is optional but powerful.

## What's an Event?

When important things happen, `acft` commands write JSON to an event log:
- `CHECKPOINT_CREATED` - New CHECKPOINT was created
- `HARNESS_EXECUTED` - Harness ran (with pass/fail status)
- `CHECKPOINT_VERIFIED` - VALID flag was flipped
- `CHECKPOINT_CLOSED` - Work marked complete
- `MANIFEST_UPDATED` - Deliverables changed

**Example event:**
```json
{
  "TYPE": "HARNESS_EXECUTED",
  "CHECKPOINT_PATH": "::WORK/auth_v1_02",
  "TIMESTAMP": "2025-02-10T14:32:00Z",
  "PAYLOAD": {
    "STATUS": "pass",
    "LOG_PATH": "::WORK/logs/auth_v1_02/harness_20250210_143200.log"
  }
}
```

## Why Events Exist

They let **automation react** without polling files:
- A **sentinel** notices `CHECKPOINT_CREATED` and runs validation
- A **verifier** sees `CHECKPOINT_CLOSED` and checks if harness actually ran
- An **auditor** finds quiet CHECKPOINTs and flags them for review

**The key insight:** Events make ACF **observable**. Without them, you'd have to constantly scan directories to notice changes.

## Where Events Live

Events are written to `::WORK/checkpoints_events.log` (append-only, newline-delimited JSON).

Commands that emit events:
- `acft new` → emits `CHECKPOINT_CREATED`
- `acft verify --record` → emits `HARNESS_EXECUTED`
- `acft close` → emits `CHECKPOINT_VERIFIED` (and `CHECKPOINT_CLOSED` when setting VALID to true)
- `acft manifest --emit` → emits `MANIFEST_UPDATED`

## Streaming Events

You can listen to the event stream:
```bash
acft events tail --follow
acft events tail --types HARNESS_EXECUTED,CHECKPOINT_CLOSED
```

## Important Notes

**The framework still works without events** - they're not required for the core contract. But they make automation much easier:
- **Without events:** Poll directories, check file timestamps, parse CHECKPOINTs repeatedly
- **With events:** Subscribe to the event stream, react immediately

**Events are for machines, LOG is for humans.** The LOG in `CHECKPOINT.md` is the narrative audit trail. Events are structured data for automation.

## Example Automation

A simple sentinel script:
```bash
acft events tail --types CHECKPOINT_CREATED --follow | while read event; do
  checkpoint=$(echo $event | jq -r '.CHECKPOINT_PATH')
  acft validate $checkpoint
done
```

This automatically validates every new CHECKPOINT as it's created.
