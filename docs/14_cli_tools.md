# Bite 14: CLI Tools (The `acft` Commands)

**Important**: The framework is **just files and conventions**. You could do everything with a text editor and mkdir.

But ACF provides a **command-line toolkit** called `acft` (Agent Checkpoints Framework Toolchain) as a **convenience layer**, especially for AI agents.

Think of `acft` as **guardrails and shortcuts** - it helps you:
- Avoid YAML syntax errors in frontmatter
- Get LOG timestamps in the right ISO 8601 format
- Not forget required sections or structure rules
- Emit events for automation

**The real contract is:**
- Directory structure
- `CHECKPOINT.md` with required sections
- Rooted paths (::THIS/, ::PROJECT/, ::WORK/)
- The MANIFEST LEDGER
- The LOG format

**The `acft` tools just help enforce that contract.**

## Key Commands

**Navigation & Inspection:**
- `acft orient ::THIS` - "Where am I? What's the status?" Shows the current CHECKPOINT's state, validity, latest LOG entry, and MANIFEST preview.

**Creating Work:**
- `acft new auth_v1_01` - Creates a new CHECKPOINT with the correct structure and seeds the template.

**Quality Control:**
- `acft validate ::THIS` - "Is my CHECKPOINT.md well-formed?" Checks structure, naming, required sections, rooted paths.
- `acft verify --record` - "Does the harness actually run?" Executes the commands listed in MANIFEST and records outcomes.

**Finishing Up:**
- `acft close --status true --signal pass` - "I'm done and it works!" Updates frontmatter, adds LOG entry, emits events.

## Why These Exist

Instead of manually remembering every rule, `acft` codifies them. It's especially helpful for AI agents who might forget formatting details or structural requirements.

**The typical flow:**
1. `acft new` → create CHECKPOINT
2. `acft orient` → check status while working
3. `acft validate` → check structure before closing
4. `acft verify --record` → run the harness
5. `acft close` → mark as done

But you could skip all of this and just edit files directly - the framework will still work as long as you follow the conventions.
