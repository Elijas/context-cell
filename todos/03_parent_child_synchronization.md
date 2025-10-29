# Issue: Parent cells don't know when child work completes

When launching child agents in separate windows with `cell claude`, the parent has no notification mechanism for child completion status.

## Current Workaround

Manually prompt with delegation instructions:

```bash
Launch the work cell we created.

Here's how to launch the agent to work on it (don't use Claude's native Task tool, use cell claude instead):

`cd testing_v1_01 && cell claude -y --window-title "testing_v1_01" "Work in the current cell. Test JWT validation."`

Note that starting this opens a new window, the bash command is non-blocking.
Note that you can make the prompt as long as you need to clearly describe the task to the agent.
```

## Potential Solution

Implement synchronization using polling checks for sentinel files (e.g., `/tmp/DONE-123.null`) that indicate when child work completes.
