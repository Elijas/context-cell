# feature_001

## Auto-Detection (Default Behavior)

By default (without any flags), the script **MUST**:

1. Automatically search for the nearest parent `projectroot.toml` file
2. If found:
   - Print the project root in this format:
     ```
     Project root (PROJECT_ROOT) [auto-detected]:
       <project_root_path>
     ```
   - Execute `cell spec` to capture the Context Cell framework specification
   - Validate that the output is between 400-1000 lines (inclusive)
     - If validation fails, print an error message showing the actual line count and exit with code 1
   - Pass the captured output to Claude via `--append-system-prompt`
   - Launch Claude from the current directory (without changing directory)
3. If NOT found:
   - Continue without Context Cell context (no error)
   - Launch Claude normally without the system prompt

## Force Mode: `-y|--context-cell` flag

When given the `-y|--context-cell` flag, the script **MUST**:

1. Force Context Cell mode (same as auto-detection when found)
2. If no `projectroot.toml` file is found, the script **MUST** crash with an error message

## Disable Mode: `-n|--no-context-cell` flag

When given the `-n|--no-context-cell` flag, the script **MUST**:

1. Skip Context Cell detection entirely
2. Launch Claude without any Context Cell context, even if inside a context-cell project
3. This is useful for running Claude without the context-cell system prompt when working in a context-cell project directory

**Test Cases**:

1. Launch script without flags from inside a context-cell project:

   - Should auto-detect and print "[auto-detected]"
   - Should load context-cell context
   - Should validate line count (400-1000 lines)

2. Launch script with `-y` flag from inside a context-cell project:

   - Should behave same as auto-detection but without "[auto-detected]" tag

3. Launch script with `-y` flag from outside a context-cell project:

   - Should crash with appropriate error message

4. Launch script with `-n` flag from inside a context-cell project:

   - Should NOT load context-cell context
   - Should launch Claude normally

5. Launch script without flags from outside a context-cell project:
   - Should NOT crash
   - Should launch Claude normally without context-cell context

# feature_002

Script provides comprehensive command-line interface with model selection, thinking mode, permissions, and window options.

```
Usage: claude_launcher.sh [OPTIONS] [ARGUMENTS]

A wrapper script for launching Claude CLI with various configurations.

OPTIONS:
  --help                         Show this help message and exit
  -y, --context-cell                Force enable Context Cell mode (auto-detected by default)
  -n, --no-context-cell             Disable Context Cell mode even when in a context-cell project

  Model Selection:
  -s, --sonnet                   Use Sonnet model (default, with thinking enabled)
  -o, --opus                     Use Opus model (with thinking enabled)
  -h, --haiku                    Use Haiku model (with thinking disabled)

  Thinking Mode:
  -t, --thinking                 Enable thinking mode
  -f, --fast                     Disable thinking mode (fast responses)

  Permissions:
  -d, --dangerously-skip-permissions  Skip permission checks (default)
  -p, --with-permission-checks   Enable permission checks

  Window Options:
  -w, --window                   Open in new Ghostty window
  --window-title TITLE           Open in new window with specified title

EXAMPLES:
  claude_launcher.sh              # Auto-detects context-cell project if in one
  claude_launcher.sh -h -w        # Launch Haiku in new window
  claude_launcher.sh -st          # Launch Sonnet with thinking (combined flags)
  claude_launcher.sh --window-title "My Project"  # Launch in titled window
  claude_launcher.sh -p           # Launch with permission checks enabled
  claude_launcher.sh -n "work without context-cell"  # Disable context-cell even if in project
  claude_launcher.sh how are you  # Multiple words automatically joined into single prompt

NOTES:
  - Context Cell mode is automatically enabled when inside a context-cell project (detected via projectroot.toml)
  - Use -n/--no-context-cell to disable auto-detection and run without context-cell context
  - Single-letter flags can be combined (e.g., -st for sonnet + thinking)
  - Opening in a new window requires Ghostty terminal
  - All non-option arguments are automatically joined into a single prompt
  - Quotes are optional: "foo bar" and foo bar both work
```

**Test**: Launch script with various flag combinations. Verify all options work as documented, flags can be combined, and multiple unquoted arguments are properly joined into a single prompt.
