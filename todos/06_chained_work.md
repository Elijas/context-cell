```
please scope your work with bite size chunks. If the current task has many complex steps feel free to organize the current cell as the parent coordinating cell and run child steps. once done come back to read the steps_to_follow. You can also use the steps_to_follow to launch child steps if you create
<steps_to_follow>
1. I'm assuming that everything is done. Don't continue with the next step if there are leftover decisions to be made or work is not yet done.
2. Identify the next step (and the corresponding work cell). If it doesn't exist, create the work cell in the appropriate place in the hierarchy.
3. Makes sure the targeted CELL.md of the next step is updated clearly regarding what was done preivously and what needs to be done next, with full context).
4. Launch the work as follows:
	Here's how to launch the agent to work on it (don't use Claude's native Task tool, use cell claude instead):

	`cd testing_v1_01 && cell claude -y --window-title "testing_v1_01" "Work in the current cell. Test JWT validation."`

	Note that starting this opens a new window, the bash command is non-blocking.
</steps_to_follow>
```
