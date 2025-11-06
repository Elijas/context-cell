# Naming Convention for AI Agents

## Pattern

```
{name}_v{version}_{step}
```

## Components

### name
- What you're working on
- Descriptive, snake_case
- Examples: `auth`, `database_migration`, `api_refactor`

### version
- Major version number
- Format: `v1`, `v2`, `v3`, etc.
- Bump for major changes or restarts

### step
- Sequential step within version
- Format: `01`, `02`, `03`, etc. (zero-padded, two digits)
- Bump for every successor in same version

## Examples

```
auth_v1_01          # First step, version 1
auth_v1_02          # Second step, version 1
auth_v1_03          # Third step, version 1
auth_v2_01          # Major change, new version
database_v1_01      # Different work stream
database_v1_02      # Continues database work
```

## When to Bump

### Bump Step (same version)
- Continuing same approach
- Iterating on same work
- Small changes or fixes
- Example: `v1_01` → `v1_02` → `v1_03`

### Bump Version (new version)
- Major change in approach
- Restarting from scratch
- Significant pivot
- Example: `v1_03` → `v2_01`

## Rules

1. **Sequential steps**: Never skip step numbers
   - ✓ `v1_01` → `v1_02` → `v1_03`
   - ✗ `v1_01` → `v1_03` (skipped 02)

2. **Zero-padded**: Always use two digits for steps
   - ✓ `v1_01`, `v1_02`
   - ✗ `v1_1`, `v1_2`

3. **One active per name_version**: Only one active CHECKPOINT for `{name}_v{version}`
   - ✓ `auth_v1_03` active, `auth_v1_02` superseded
   - ✗ Both `auth_v1_02` and `auth_v1_03` active

4. **Document abandoned steps**: If you skip a step, log why in LOG
   - Example: Created `v1_02` but it failed, so `v1_03` is the successor to `v1_01`

## Naming Relationships

```
auth_v1_01 (LIFECYCLE: superseded)
  ↓
auth_v1_02 (LIFECYCLE: superseded)
  ↓
auth_v1_03 (LIFECYCLE: active)

auth_v2_01 (LIFECYCLE: active, different approach)
```

## Common Patterns

**Linear progression:**
```
feature_v1_01 → feature_v1_02 → feature_v1_03
```

**Version bump:**
```
feature_v1_05 → feature_v2_01 (major change)
```

**Parallel exploration (different names):**
```
approach_a_v1_01
approach_b_v1_01
```

**Consolidation:**
```
approach_a_v1_03 (superseded)
approach_b_v1_02 (superseded)
  ↓
unified_v1_01 (SUPERSEDES: [approach_a, approach_b])
```

## Directory Naming

The CHECKPOINT directory name MUST match this pattern:

```bash
# Correct
auth_v1_01/
database_migration_v2_03/

# Wrong
auth_v1/              # Missing step
auth-v1-01/           # Wrong separators
authV1_01/            # Wrong version format
auth_1_01/            # Missing 'v' prefix
```

## Validation

The `acft validate` command checks:
- Directory name matches `{name}_v{version}_{step}` pattern
- Version is numeric
- Step is two-digit zero-padded number

## Why This Matters

1. **Visible timeline**: See progression without opening files
2. **Unambiguous ordering**: `v1_02` clearly follows `v1_01`
3. **Version tracking**: See when approach changed (`v1` → `v2`)
4. **Automation friendly**: Tools can parse and sort by name

Name encodes history, making navigation and understanding easier.
