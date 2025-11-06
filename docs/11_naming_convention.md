# Bite 11: Naming Convention (Version Control for Work)

CHECKPOINTs follow a specific naming pattern:

```
{name}_v{version}_{step}
```

**Examples:**
- `auth_v1_01` - First attempt at auth
- `auth_v1_02` - Second step, same version
- `auth_v2_01` - Major change, new version

**The parts:**

- **name** - What you're working on (`auth`, `database`, `api_refactor`)
- **v{version}** - Major version number (`v1`, `v2`, `v3`)
- **{step}** - Sequential step within version (`01`, `02`, `03`)

**When to bump:**

- **Step** - Every successor in same version (`v1_01` → `v1_02`)
- **Version** - Major change or restart (`v1_03` → `v2_01`)

**Why:**

The naming **encodes history**. You can see at a glance:
- `auth_v1_01` came before `auth_v1_02`
- `auth_v2_01` is a major change from v1
- Multiple v1 steps show iteration

Think of it like **git commit history in folder names** - the timeline is visible without opening any files.

**Important rules:**

- Steps are **sequential** - don't skip numbers
- Only **one active CHECKPOINT** per `{name}_v{version}` at a time
- Use **zero-padded** step numbers (`01`, `02`, not `1`, `2`)
