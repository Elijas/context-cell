# ACF Primitives Assessment

**Date:** 2025-01-07
**Context:** Convergent evolution discussion - comparing ACF's bottom-up approach vs HumanLayer's top-down approach

## The Convergent Evolution Hypothesis

If both systems are solving the same problem (agent context/handoffs/verification), the physics of the problem space will push toward similar solutions:

- HumanLayer strips away unnecessary opinions → finds core primitives
- ACF adds necessary structure → finds required patterns
- Both meet in the middle at the **actual optimal abstraction level**

The problem domain HAS an optimal shape. We're approaching it from opposite directions.

## Primitives Assessment

### What Seems Right ✅ (The Dorsal Fin)

**Rooted paths (`::PROJECT/`, `::WORK/`, `::THIS/`)**
- Solves real portability problem
- Minimal, clear semantics
- Discovered through pain (relative paths broke)
- **Verdict:** Core primitive, keeper

**VALID gate**
- Binary trust signal is clear
- Forces "is this hand-off ready?" question
- Simple, enforceable
- **Verdict:** Core primitive

**Harness-first workflow**
- "Design verification before implementation"
- Directly from Dex Horthy's insight
- Changes agent behavior (discovered through usage)
- **Verdict:** Load-bearing idea

### What Might Be Over-Engineered ❓ (Unnecessary Fins)

**5 required sections in specific order**
- STATUS, HARNESS, CONTEXT, MANIFEST, LOG
- Claims "intentional redundancy" but is it actually necessary?
- Could this be 2-3 sections instead of 5?
- **Question:** Might be ceremony creeping in

**Naming convention rigidity**
- `{branch}_v{version}_{step}` format
- Two-digit step counter, must start at 01
- **Question:** Is this solving a real problem or just... neat? Feels like premature structure

**The "multi-perspective" justification**
- "Seeing work from 3 angles reveals misalignment"
- **Question:** Is this proven through usage or theoretical? Pilot checklist analogy is compelling but needs validation

### What Might Be Missing 🤔 (Hidden Fins)

**Explicit success criteria format**
- Mentioned but not formalized
- "How do we know it works?" needs structure
- Might need to be first-class primitive

**Dependency contract**
- Lives in MANIFEST but feels ad-hoc
- Might need stronger primitives

## The Real Test

Dogfooding daily should reveal:

1. **Which parts do you actually USE?** (real primitives)
2. **Which parts do you SKIP or work around?** (false primitives)
3. **What do you wish existed?** (missing primitives)

## Hypothesis: True Primitives

The core might be:
- **Location independence** (rooted paths)
- **Trust signal** (VALID)
- **Verification contract** (harness)
- **Deliverable list** (manifest)
- **Audit trail** (log)

Everything else might be scaffolding that could simplify.

## The Biological Parallel

**Why dorsal fins and flippers exist:**
- **Dorsal fin:** Vertical stabilizer prevents rolling (like VALID gate prevents drift)
- **Flippers:** Control surfaces for steering (like rooted paths for navigation)
- **Streamlined body:** Minimizes drag (like minimal ceremony)

**Physics of agent context management:**
- Context needs persistence (like needing propulsion)
- Handoffs need verification (like needing stability)
- Dependencies need tracking (like needing steering)
- History needs auditability (like needing to not roll over)

**You can't skip the dorsal fin and still swim straight.**

Any solution that actually works must solve these problems. Whether you start complex (HumanLayer) or simple (ACF), you'll converge on features that address the underlying "physics" of the problem space.

## Next Steps

- Track what gets used vs skipped in daily usage
- Identify patterns where the framework fights you
- Look for missing primitives that keep getting reinvented
- Be willing to simplify if sections prove redundant
- Be willing to add structure if gaps keep appearing

The framework should feel like it's helping you swim, not like you're carrying extra weight.
