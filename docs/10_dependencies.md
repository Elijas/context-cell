# Bite 10: Dependencies (What You Need)

Every CHECKPOINT needs to declare **what it depends on**. This goes in the MANIFEST section, right after the MANIFEST LEDGER:

```markdown
# MANIFEST

## MANIFEST LEDGER
[your outputs here]

## Dependencies

### CHECKPOINT DEPENDENCIES
- ::WORK/auth_v2_01/CHECKPOINT.md (LIFECYCLE: active, VALID: true)
  Status: ready
  Purpose: Provides authentication functions we call

### SYSTEM DEPENDENCIES
- Python 3.11+
- PostgreSQL 14
- AWS credentials (read access to bucket xyz)
```

**Two types of dependencies:**

1. **CHECKPOINT DEPENDENCIES** - Other CHECKPOINTs you need
   - List with rooted paths
   - Include their LIFECYCLE and VALID status
   - Note if they're ready, pending, or blocked

2. **SYSTEM DEPENDENCIES** - External requirements
   - Software versions (Python, databases, etc.)
   - Services (APIs, cloud resources)
   - Credentials and access needs

**Why this matters:**

Without explicit dependencies, you get **"dependency fog"** - work fails mysteriously because needed inputs aren't available. Declaring them up front makes blockers visible.

Think of it as **declaring your ingredients** before you start cooking.
