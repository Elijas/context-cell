# Specification Writing Guidelines

This document describes how to write specifications inside the \_internal/ folder.

## File Organization

Organize specifications into numbered files that build knowledge incrementally:

- **Numbered files suggest reading order**: Lower-numbered files typically contain foundational concepts, higher-numbered files build on them
- **README.md**: Overview with documentation structure and quick start guide
- **Context files** (01_context.md, 02_cell_format.md, etc.): Core knowledge to understand the system
- **Features file** (last numbered file): Testable behaviors for validation

Example structure:

```
my_feature/
├── README.md           # Overview, documentation structure, quick start
├── 01_context.md       # Foundational context
├── 02_more_context.md  # Additional context building on foundations
└── 03_features.md      # Testable features validating the system
```

## Context Sections

Use `# context` headings to separate distinct pieces of knowledge:

```markdown
# context

Context Cell is a hierarchical work organization framework for AI agents.

# context

Work cells are folders with specific naming: `{branch}_v{version}_{step}`

# context

Project root is marked by `projectroot.toml` file at repository root.
```

Each context block should be self-contained and focus on one concept.

## Feature Sections

Use `# feature_NNN` headings for testable behaviors:

````markdown
# feature_001

Agent orients before starting work by running both:

```bash
cell tree .
cell abstract .
```
````

This shows structure with one-line DISCOVERY sections and full ABSTRACT sections to understand context.

**Test**: Launch agent with task. Verify it runs both commands before making changes.

# feature_002

Agent navigates to target work cell directory before starting work.

```bash
cd path/to/work_cell
```

**Test**: Launch agent with task in specific cell. Verify it changes to that directory.

````

Features should include:
- Clear description of the behavior
- Code examples or command examples when applicable
- **Test** section describing how to verify the behavior

## LLM-Friendly Design Principles

When designing specifications for AI agents, prioritize clarity and eliminate ambiguity:

**Make sections mandatory when possible:**

Optional sections create ambiguity about where information belongs. If two sections might overlap, make both mandatory with clear distinctions.

❌ Bad (creates ambiguity):
```markdown
# FULL_CONTEXT
All context goes here

# ORIGIN (optional)
Why this work exists
```

✅ Good (clear separation):
```markdown
# FULL_RATIONALE
Why we're doing this: upstream requests, problem discovery, strategic decisions, prior art

# FULL_IMPLEMENTATION
What and how we're doing it: technical details, approach, results, blockers
```

**Use "Common subsections" pattern over examples:**

Examples can be too prescriptive. The "Common subsections" pattern shows what's typical without forcing rigid structure.

❌ Bad (too prescriptive):
```markdown
# FULL_RATIONALE

Example: "Upstream request from product team: users reporting 30% cart abandonment..."
```

✅ Good (flexible guidance):
```markdown
# FULL_RATIONALE

Common subsections: Upstream Request, Problem Discovery, Prior Art, Alternatives Considered, Strategic Decisions.

Be thorough, don't hold back on volume.
```

**Name sections by intent, not by content type:**

Clear names make purpose obvious without needing explanation.

- FULL_RATIONALE > ORIGIN (clearer why it exists)
- FULL_IMPLEMENTATION > FULL_CONTEXT (clearer what goes there)
- DISCOVERY > TITLE (clearer it's about finding/describing)

**Use FULL_ prefix to establish hierarchy:**

The FULL_ prefix makes the relationship between summary and detail sections explicit.

- ABSTRACT = compressed summary (5-10 sentences)
- FULL_RATIONALE = expanded "why" details
- FULL_IMPLEMENTATION = expanded "what/how" details

## Writing Style

**Be specific and actionable:**

❌ Bad (vague):
```markdown
# ABSTRACT

Information-dense summary...
````

✅ Good (specific):

```markdown
# ABSTRACT

Information-dense summary: objectives, approach, expected outcomes, what was done, how, results, blockers, next steps.
Use specific metrics, concrete tech names, references, quantified results.
Typically 5-10 sentences; fewer if trivial, more if complex.
```

**Provide concrete examples:**

Every abstract concept should have a concrete example showing what it looks like in practice.

**Use structured lists for options:**

When describing choices or components, use clear bullet points:

```markdown
Components:

- **Branch**: short, lowercase, underscores for multi-word (e.g., `input_validation`, `auth`)
- **Version**: v1, v2, v3 (increment for fundamental rethinking/restart)
- **Step**: 01, 02, 03 (two digits, sequential progress within version)
```

**Include quantitative guidance:**

When relevant, specify quantities:

- "Typically 5-10 sentences; fewer if trivial, more if complex"
- "Must appear within first 10 lines of CELL.md"
- "Two digits, sequential progress"

## Modifying Specifications

When changing or updating specification files, always check for contradictions:

1. **Search for related content**: Use grep/search to find all mentions of the concept being changed
2. **Verify consistency**: Ensure changes don't contradict other parts of the spec
3. **Update all references**: If a concept appears in multiple files, update all instances
4. **Check features align with context**: Changes to context files may require updating feature tests

Example workflow:

```bash
# Changing "scope completion" concept
grep -r "work_complete" spec/
# Review all matches, update consistently across files

# But also don't shy away from manually reading files too, after the changes in heuristic spots
```

**Why this matters:**

- Contradictions confuse both humans and AI agents reading the specs
- Specs form a knowledge graph - broken consistency breaks the graph
- Features must align with context or tests will be invalid

## README Structure

Every spec directory should have a README.md with this structure:

```markdown
# [Feature Name] Specification

Brief description of what this is.

## Documentation Structure

**Context (knowledge to understand):**

- [01_context.md](01_context.md) - Brief description
- [02_more_context.md](02_more_context.md) - Brief description

**Features (testable behaviors):**

- [03_features.md](03_features.md) - Testable behaviors for validation

**Note**: Files are numbered to create a narrative flow. Lower-numbered files typically introduce foundational concepts, while higher-numbered files can build upon them. This creates an incremental knowledge-building experience.

## Quick Start

1. Read context files to understand the system
2. Review features.md to understand expected behaviors
3. Test by verifying feature compliance
```

## Anti-Patterns

Avoid these common mistakes:

❌ **Vague placeholders**: "Information-dense summary..." tells readers nothing
❌ **Mixing context and features**: Keep foundational knowledge separate from testable behaviors
❌ **Missing test guidance**: Features without **Test** sections aren't verifiable
❌ **Abstract without concrete**: Every abstract concept needs a concrete example
