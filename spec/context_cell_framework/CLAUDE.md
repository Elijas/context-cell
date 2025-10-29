# Context Cell Framework Maintenance Guidelines

This document is for maintainers working on the Context Cell framework specifications.

## Important Context

**These specifications are public-facing and LLM-facing.** They are loaded into AI agent system prompts via `cell spec` and read by developers learning the framework. Content must be:

- **Crisp**: No fluff, every sentence adds value
- **Polished**: No typos, clear language, professional tone
- **Understandable**: LLMs and humans should grasp concepts immediately

## Modifying Framework Specifications

When editing any numbered specification files (01-99), follow these steps:

### 1. Search for Related Content

```bash
# Find all mentions of the concept you're changing
grep -r "concept_name" spec/context_cell_framework/
```

### 2. Verify Consistency

- Check that changes don't contradict other sections
- Ensure terminology remains consistent across all files
- Verify examples still work with new changes

### 3. Update All References

If a concept appears in multiple files:
- Update the main definition first
- Update all references to match
- Check examples that use the concept

### 4. Update 99_quick_reference.md

**CRITICAL**: The quick reference must stay synchronized with detailed specs.

When you change:
- **Command syntax** → Update Commands section
- **CELL.md structure** → Update Required Files section
- **Path conventions** → Update Path Conventions section
- **Workflow patterns** → Update Workflow Patterns section
- **Naming conventions** → Update Work Cell Naming section
- **File organization** → Update File Organization section

The quick reference appears at the END of `cell spec` output as a consolidated cheat sheet for agents who already understand the framework.

### 5. Test Changes

If possible:
- Run `cell spec` to verify output looks correct
- Check that examples in documentation actually work
- Validate against real work cells if applicable

## Writing Standards

Follow any relevant writing guidelines (that don't contradict the CLAUDE.md file you're reading right now) in `(project_root)/spec/_internal/CLAUDE.md`, with special emphasis on:

### LLM-Optimized Language

- Use explicit, unambiguous terms
- Avoid pronouns when nouns are clearer
- Make relationships explicit ("X depends on Y" not "it needs that")
- Use consistent terminology (never vary terms for same concept)

### Structure

- Mandatory sections > optional sections (eliminates ambiguity)
- Examples for every abstract concept
- Quantitative guidance when possible ("5-10 sentences" not "brief")
- Clear error messages and what to do about them

### Command Documentation

Every command needs:
- Purpose (one sentence)
- Required parameters (explicit about what's mandatory)
- Optional parameters (with defaults)
- Usage examples (common patterns)
- Path symbol support (`@project`, `.`)

## Common Pitfalls

❌ **Vague**: "Orient to understand context"
✅ **Specific**: "Run `cell orient .` to show ancestry, peers, and children with DISCOVERY sections"

❌ **Ambiguous**: "Update your work cell"
✅ **Explicit**: "Update CELL.md sections and set work_complete: true when done"

❌ **Missing context**: "Use @project for paths"
✅ **Complete**: "Use `@project/path/to/file` for PROJECT_ROOT paths. Never use bare paths like `path/to/file`."

## Why This Matters

These specifications are:
1. **Loaded on every agent run** - Bloat wastes tokens
2. **Read by AI agents** - Ambiguity causes confusion
3. **Public documentation** - Represents project quality
4. **Training material** - Teaches correct patterns

Poor specifications lead to agents that don't follow the framework correctly.

## Questions?

See parent guidelines in `(project_root)/spec/_internal/CLAUDE.md` for general spec writing principles (only the ones that don't contradict the `CLAUDE.md` file you're reading right now).
