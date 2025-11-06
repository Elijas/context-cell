# Bite 9: The MANIFEST LEDGER (The Output Contract)

The **MANIFEST LEDGER** is a special table that MUST be the first thing in your MANIFEST section:

```markdown
# MANIFEST

## MANIFEST LEDGER

| Name | Path | Purpose |
|------|------|---------|
| auth_module.py | ::THIS/ARTIFACTS/auth_module.py | Authentication logic |
| config.json | ::THIS/ARTIFACTS/config.json | Configuration file |
| test_results.log | ::THIS/LOGS/tests_20251103.log | Test execution log |
```

**Why it exists:**

Without this ledger, people have to **dig through folders** to find what you created. The ledger is like a **table of contents for your outputs**.

**The rules:**

1. **Must be first** in MANIFEST section (before dependencies, before anything else)
2. **Use rooted paths** - always use the correct prefix:
   - Files in your CHECKPOINT → `::THIS/`
   - Files in other CHECKPOINTs → `::WORK/`
   - Project files (not in any CHECKPOINT) → `::PROJECT/`
3. **One line per output** - name, path, purpose
4. **Keep it updated** as you create artifacts

**During development:**

You can start with a stub:
```markdown
| Name | Path | Purpose |
|------|------|---------|
| (stub) | (stub) | (stub) |
```

But before setting `VALID: true`, this MUST list real outputs (or you have a documented permanent blocker).

Think of it as **signing your work** - you're declaring exactly what you delivered.
