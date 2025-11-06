# Bite 4: Rooted Paths (The Addressing System)

You'll see special path prefixes everywhere in ACF:

```
::THIS/ARTIFACTS/output.txt
::PROJECT/shared/config.json
::WORK/auth_v2_01/results.md
```

**Why not just use `../` or `./`?**

Because when you move directories or copy work to different locations, relative paths **break**.

**What each prefix means:**

- `::THIS/` - "Files produced inside my current CHECKPOINT"
- `::PROJECT/` - "At the root of this repository" (where project files live)
- `::WORK/` - "In the CHECKPOINTs directory" (where all checkpoints live)

**How the system knows where these are:**

Two marker files define the boundaries:

- `checkpoints_project.toml` - Marks the repo root
- `checkpoints_work.toml` - Marks the CHECKPOINTs directory

These files are empty (for now) but use `.toml` extension so config can be added later.

These prefixes stay **stable** even when you reorganize folders. The automated tools know how to resolve them.

Think of them like **coordinates on a map** instead of directions like "turn left."
