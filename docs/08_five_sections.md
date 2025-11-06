# Bite 8: The Five Required Sections

Every `CHECKPOINT.md` file MUST have these five sections in this exact order:

```markdown
# STATUS
# HARNESS
# CONTEXT
# MANIFEST
# LOG
```

**What each section does:**

1. **STATUS** - "What's happening right now?"
   - Context recap (summary of the situation)
   - Success criteria (how you know you're done)
   - Exit conditions (when to stop)
   - Current risks/blockers

2. **HARNESS** - "How do I verify this works?"
   - Commands to run (tests, builds, checks)
   - Expected outputs
   - What passing looks like

3. **CONTEXT** - "Why did I make these decisions?"
   - Design decisions
   - Alternatives considered
   - Rationale and trade-offs

4. **MANIFEST** - "What did I create and what do I depend on?"
   - MANIFEST LEDGER (list of outputs)
   - Dependencies
   - Artifact inventory

5. **LOG** - "What happened when?"
   - Timestamped history (ISO 8601 format)
   - Major actions and decisions
   - Who did what

Think of these as **chapters in your work notebook** - each has a specific job.

**Why these specific sections?**

Each one prevents a specific problem:
- STATUS prevents "goal fog" (wandering without clear success)
- HARNESS prevents "validation theater" (claiming done without proof)
- CONTEXT prevents "decision amnesia" (forgetting why you chose this approach)
- MANIFEST prevents "dependency fog" (unclear what depends on what)
- LOG prevents "history drift" (losing the story of what happened)
