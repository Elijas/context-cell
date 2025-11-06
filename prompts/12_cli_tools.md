# CLI Tools for AI Agents

## Core Principle

**The framework is files and conventions, not tools.** You can edit everything manually.

`acft` commands are convenience wrappers that:
- Enforce structure automatically
- Format timestamps correctly
- Validate frontmatter YAML
- Emit events for automation
- Reduce cognitive load

## Command Reference

### Navigation
```bash
acft orient ::THIS              # Show current CHECKPOINT status
acft orient ::WORK/auth_v1_02   # Inspect any CHECKPOINT
```

### Creation
```bash
acft new branch_v1_01           # Scaffold new CHECKPOINT
acft new branch_v1_02 --delegate-of ::WORK/parent_v1_01
```

### Validation
```bash
acft validate ::THIS            # Check structure
acft verify --record            # Run harness, emit HARNESS_EXECUTED event
acft manifest --mode full       # Check for 13 failure modes
```

### Closing
```bash
acft close --status true --signal pass    # Mark valid
acft close --status false --signal blocked --message "Need credentials"
```

### Path Expansion
```bash
acft expand ::PROJECT/src/app.py    # Resolve to absolute path
cd $(acft expand ::WORK/auth_v1_01)
```

## Critical Rules for Agents

1. **You can skip the tools** - Just maintain the file structure and conventions
2. **Tools help avoid errors** - Use them when convenient (YAML formatting, timestamps)
3. **Events matter for automation** - `--record` and `--emit` flags trigger downstream systems
4. **The contract is files, not commands** - A CHECKPOINT with no CLI history is still valid if it follows the spec

## When to Use CLI vs Manual

**Use CLI when:**
- Creating new CHECKPOINTs (reduces template errors)
- Running harnesses (`acft verify` captures outcomes)
- Closing work (ensures event emission)

**Manual editing is fine for:**
- Updating STATUS, CONTEXT, LOG
- Tweaking frontmatter
- Adding MANIFEST entries
- Day-to-day work

The framework enforces the contract through structure, not tooling.
