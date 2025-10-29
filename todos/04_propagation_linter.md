# Issue: Need propagation linter for work cell consistency

No automated validation to ensure work cell state is consistent and propagated to parent cells.

## Current Workaround

Manually prompt agents with investigation instructions:

```bash
"Don't edit anything, you'll just be doing investigative work.

Can you run through all current work cells including all descendant (child, grandchild) work cells and list them all with status:
1. pending / in progress / done
2. Internal work inside the cell is fully reflected in CELL.md or not
3. Results were propagated to the parent CELL.md (except pending or in-progress tasks of course)

Just give me the report, no need to edit anything."
```
