# Issue: Agents sometimes don't seek context without nudging

Agents sometimes don't proactively use `cell orient` to understand work context before starting tasks.

## Current Workaround

Manually prompt agents with explicit orientation instructions:

```bash
c -y "Run 'cell orient --ABSTRACT .' as the first step to orient yourself and then read CELL.md to resume work on this work cell. Before starting acknowledge everything is clear or ask questions. You can also use 'cell orient --help' to further browse summaries if needed before doing the task to gather more context.

After you've completed the tasks in the work cell task scope, be sure to thoroughly update your own CELL.md and your parent's CELL.md (be mindful of the volume when updating the parent).

If you need to run actual Python code, be sure to check @root/RUNTIME_FAQ.md for environment-specific guidance.
"
```

> [!NOTE]
> The RUNTIME_FAQ.md is just an example of a pattern to provide runtime execution guidance that agents may need to reference during work.
