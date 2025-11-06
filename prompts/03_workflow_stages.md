# Five-Stage Workflow for AI Agents

## The Loop

```
PREPARE → SPECIFY → BUILD → VERIFY → HANDOFF
```

Follow this sequence for every CHECKPOINT. Do not skip stages.

## 1. PREPARE - Gather Context

**Before you do anything else:**
- Read the triggering directive (what am I being asked to do?)
- Read upstream CHECKPOINT.md files (what do I depend on?)
- Collect relevant context (code, docs, prior work)
- Fill CONTEXT section with decisions and alternatives
- Stage raw materials in STAGE/ if needed

**Exit check:** Can I explain the problem space clearly?

## 2. SPECIFY - Define Success

**Critical stage - do NOT skip:**
- Write explicit success criteria in STATUS
- Define the harness (verification commands) in HARNESS
- List expected deliverables in MANIFEST (preliminary OK)
- Document exit conditions in STATUS
- Identify risks in STATUS

**Exit check:** Do I know how to verify this will work?

### Non-Negotiable Rule
**Never start BUILD without defining the harness.** If you can't describe how to verify success, you're not ready to build.

## 3. BUILD - Execute Implementation

**Now you can actually work:**
- Implement the solution
- Create artifacts in ARTIFACTS/
- Update MANIFEST as you create files
- Use rooted paths (::THIS/, ::PROJECT/, etc.)
- Log significant actions in LOG with timestamps

**Exit check:** Have I created what the success criteria describe?

## 4. VERIFY - Run the Harness

**Prove your work is correct:**
- Execute every command listed in HARNESS
- Save outputs to LOGS/
- Compare actual vs expected results
- Update STATUS with results
- Log the verification run

**Exit check:** Did the harness pass?

### If Verification Fails
- Document failures in STATUS
- Identify blockers with owner and date
- Do NOT set VALID:true
- Return to BUILD or SPECIFY as needed

## 5. HANDOFF - Close the CHECKPOINT

**Final cleanup:**
- Review all five sections for completeness
- Finalize MANIFEST ledger
- Clear STAGE/ directory
- Set VALID:true (only if harness passed)
- Add final LOG entry

**Exit check:** Can someone else pick this up without asking me questions?

## Common Mistakes to Avoid

❌ Starting BUILD before defining harness
❌ Setting VALID:true without running harness
❌ Skipping VERIFY stage
❌ Empty MANIFEST when VALID:true
❌ No LOG entries

✅ Follow stages in order
✅ Define harness before building
✅ Run harness before closing
✅ Log everything with timestamps
✅ Use rooted paths

## When to Loop Back

- Harness fails → return to BUILD
- Requirements unclear → return to PREPARE
- Success criteria wrong → return to SPECIFY
- Blocker discovered → document and potentially fork

**Always log why you're returning to an earlier stage.**
