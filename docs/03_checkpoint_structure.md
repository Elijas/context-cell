# Bite 3: What Does a CHECKPOINT Look Like?

A CHECKPOINT is just a **folder with a specific structure**:

```
my_feature_v1_01/
├── CHECKPOINT.md          ← The main document (required)
├── ARTIFACTS/             ← Your actual work outputs
├── STAGE/                 ← Temporary workspace (optional)
└── LOGS/                  ← Execution logs (optional)
```

**The star of the show is `CHECKPOINT.md`** - it contains required sections:
- **STATUS** - What's happening right now
- **HARNESS** - How to verify your work
- **CONTEXT** - Why you made decisions
- **MANIFEST** - List of what you created
- **LOG** - History of what happened when

Think of `CHECKPOINT.md` as the **control panel** for this piece of work.
