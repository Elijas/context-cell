# CHECKPOINT Structure for AI Agents

## Directory Pattern

```
{name}_v{version}_{step}/
├── CHECKPOINT.md          ← Your control panel
├── ARTIFACTS/             ← Deliverables go here
├── STAGE/                 ← Scratch space (clear before closing)
└── LOGS/                  ← Harness execution logs
```

## CHECKPOINT.md Sections

You MUST include all five sections:

1. **STATUS** - Current state, success criteria, risks
2. **HARNESS** - Commands to verify your work
3. **CONTEXT** - Decisions and alternatives
4. **MANIFEST** - Ledger of what you created + dependencies
5. **LOG** - Timestamped history (ISO 8601)

## Frontmatter

```yaml
---
VALID: false          # Set true only after harness passes
LIFECYCLE: active     # active|superseded|archived
---
```

## Critical Rules

- Use rooted paths: `::THIS/ARTIFACTS/foo.py` not `./ARTIFACTS/foo.py`
- Never set VALID:true until harness runs clean
- Log every significant action with timestamp and actor
- MANIFEST ledger is the contract - keep it current

## When Creating a CHECKPOINT

1. Make the directory with proper naming
2. Create CHECKPOINT.md with all five sections
3. Start with VALID:false, LIFECYCLE:active
4. Fill STATUS with context and success criteria first
5. Define HARNESS before you start building

## When Closing a CHECKPOINT

1. Run the harness
2. Update MANIFEST with final outputs
3. Clear or archive STAGE/
4. Set VALID:true only if harness passed
5. Add final LOG entry
