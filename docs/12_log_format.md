# Bite 12: LOG Format (The Audit Trail)

The LOG section keeps a **timestamped history** of everything that happened:

```markdown
# LOG

**2025-11-03T14:30:00Z** - [Claude] Created CHECKPOINT
- Initialized from user directive to implement auth module
- Created initial structure with stub sections

**2025-11-03T15:45:00Z** - [Claude] Defined harness
- Added test commands to HARNESS section
- Documented expected outputs

**2025-11-03T17:20:00Z** - [Claude] Ran harness
- All tests passed
- See ::THIS/LOGS/harness_20251103_172000.log
```

**The format:**

- **Timestamps**: ISO 8601 UTC format (`YYYY-MM-DDTHH:MM:SSZ`)
- **Actor**: Who did it (`[Claude]`, `[Human Name]`, `[System]`)
- **Action**: What happened (brief description)
- **Details**: Bullet points with specifics (optional but recommended)

**When to log:**

- Creating CHECKPOINT
- Major decisions
- Running harness
- Discovering blockers
- Scope changes (cite the source: Slack, ticket, transcript, etc.)
- Closing CHECKPOINT

**Why ISO 8601 UTC?**

Because `2025-11-03T17:20:00Z` is unambiguous - everyone knows exactly when something happened, no matter their timezone.

Think of it as **commit messages for your work** - future you (or someone else) can see exactly what happened when.
