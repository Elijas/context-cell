# Workflow Patterns and State Management

## Workflow Steps Overview

Workflow has six steps: ORIENT_STEP → NAVIGATE_STEP → START_STEP → WORK_STEP → UPDATE_STEP → CREATE_STEP

ORIENT_STEP: Understand context before starting work
NAVIGATE_STEP: Change directory to target work cell
START_STEP: Create or enter work cell
WORK_STEP: Make changes, update CELL.md periodically
UPDATE_STEP: Update CELL.md, mark work_complete when done
CREATE_STEP: Create new work cell for next phase

## Continue Pattern: Sequential Step Progression

CONTINUE_PATTERN: Increment step number for sequential progress in same approach.

When to use: Making progress on same work without fundamental changes.

Example: `auth_v1_01` → `auth_v1_02` → `auth_v1_03`

```bash
mkdir auth_v1_02 && cd auth_v1_02

cat > CELL.md << 'EOF'
---
work_complete: false
---

# DISCOVERY

Add JWT token refresh logic

# ABSTRACT

Continuing auth work from auth_v1_01, implementing token refresh endpoint...

# FULL_RATIONALE

Continuing from auth_v1_01 which implemented basic JWT authentication. Need to add refresh token functionality to improve user experience by avoiding frequent re-authentication.

# FULL_IMPLEMENTATION

Building on JWT implementation from previous step. Adding refresh token logic to allow tokens to be renewed without full re-authentication.

## Approach

Using refresh tokens stored securely...

# LOG

- 2025-01-01T12:00:00Z: Created work cell
EOF
```

## Restart Pattern: Version Increment for Fresh Start

RESTART_PATTERN: Increment version number when work becomes messy.

When to use: Dead ends, bug accumulation, structural issues require fresh start.

Example: `auth_v1_03` → `auth_v2_01`

```bash
mkdir auth_v2_01 && cd auth_v2_01

cat > CELL.md << 'EOF'
---
work_complete: false
---

# DISCOVERY

Implement JWT authentication (v2 restart)

# ABSTRACT

Restarting auth work. v1 deprecated due to architectural issues with token storage. Using secure httpOnly cookies instead of localStorage based on v1 learnings.

# FULL_RATIONALE

v1 deprecated due to security vulnerability: localStorage tokens exposed to XSS attacks. Learned from v1 that token storage mechanism needs to be fundamental design decision, not afterthought.

# FULL_IMPLEMENTATION

Clean implementation addressing issues from v1. Using different approach to token management.

## Approach

Using secure httpOnly cookies to prevent XSS attacks...

# LOG

- 2025-01-02T00:00:00Z: Created v2 after v1 deprecation
EOF
```

Old versions remain for historical reference. Add detailed deprecation post-mortem to old version's CELL.md (see 02_cell_format.md for format).

## Delegate Pattern: Nested Work Cell for Subagent Tasks

DELEGATE_PATTERN: Create nested work cell under current directory for subagent task.

When to use: Subtask can be worked on independently by another agent.

Example: `auth_v1_01/testing_v1_01`

```bash
cd auth_v1_01
mkdir testing_v1_01 && cd testing_v1_01

cat > CELL.md << 'EOF'
---
work_complete: false
---

# DISCOVERY

Test JWT token validation logic

# ABSTRACT

Subagent task: validate JWT tokens are correctly verified, including expiration and signature checks...

# FULL_RATIONALE

Parent cell: auth_v1_01. Delegated testing task to ensure JWT validation logic is robust before deployment. Critical to verify all edge cases are handled correctly.

# FULL_IMPLEMENTATION

Testing comprehensive JWT validation scenarios including:
- Valid tokens
- Expired tokens
- Invalid signatures
- Malformed tokens

## Test Coverage

Writing unit tests for all validation paths...

# LOG

- 2025-01-01T10:00:00Z: Created subagent work cell
EOF
```

Launch subagent with `cell claude --window-title "testing_v1_01" "..."`

## Independent Pattern: Parallel Work Branch Creation

INDEPENDENT_PATTERN: Create new branch for parallel work unrelated to current branch.

When to use: Starting completely new line of work unrelated to current work.

Example: Starting `api_v1_01` while working on `auth_v1_03`

```bash
mkdir api_v1_01 && cd api_v1_01

cat > CELL.md << 'EOF'
---
work_complete: false
---

# DISCOVERY

Design RESTful API endpoints

# ABSTRACT

Starting API design work, defining endpoints for user management and data access...

# FULL_RATIONALE

Independent from auth work. Starting parallel branch to design API while auth is being implemented. API design can proceed independently and will integrate with auth once both are complete.

# FULL_IMPLEMENTATION

Designing RESTful API structure for the application.

## Endpoints

Defining CRUD operations for primary resources...

## Design Principles

Following REST conventions, versioned API...

# LOG

- 2025-01-01T14:00:00Z: Created work cell
EOF
```
