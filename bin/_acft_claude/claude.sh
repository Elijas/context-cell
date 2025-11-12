#!/bin/bash

# Claude Launcher
# A wrapper script for launching Claude CLI with various configurations

# Ensure acft command is available
if ! command -v acft >/dev/null 2>&1; then
  echo "Error: 'acft' command not found in PATH" >&2
  echo "Please ensure the ACFT framework is properly installed and in your PATH" >&2
  exit 1
fi

# Resolve key paths relative to this script for downstream tooling reuse
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"

# Load optional .env file from the same directory
# Note: Variables already set in the environment will be preserved
if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a  # Automatically export all variables
  source "$SCRIPT_DIR/.env"
  set +a
fi

# Run prelaunch hook if configured
if [ -n "$ACFT_CLAUDE_PRELAUNCH_HOOK" ]; then
  echo "Running prelaunch hook: $ACFT_CLAUDE_PRELAUNCH_HOOK" >&2
  eval "$ACFT_CLAUDE_PRELAUNCH_HOOK"
  hook_exit_code=$?
  if [ $hook_exit_code -ne 0 ]; then
    echo "Error: Prelaunch hook failed with exit code $hook_exit_code" >&2
    exit 1
  fi
fi

# Determine the command name for help text
# Uses ACFT_PARENT_CMD env var if set, otherwise falls back to script name
CMD_NAME="${ACFT_PARENT_CMD:-$(basename "$0")}"

# Help function
show_help() {
  cat << EOF
Usage: ${CMD_NAME} [OPTIONS] [ARGUMENTS]

A wrapper script for launching Claude CLI with various configurations.

OPTIONS:
  --help                         Show this help message and exit

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

  Non-Interactive Mode:
  --print                        Print response and exit (non-interactive)
  --output-format FORMAT         Output format: text, json, or stream-json (requires --print)
  --input-format FORMAT          Input format: text or stream-json (requires --print)

  Window Options:
  -w, --window                   Open in new Ghostty window
  --window-title TITLE           Open in new window with specified title

  Framework Prompt:
  -n, --disable-framework        Disable ACFT framework features

  Settings:
  --merge-settings JSON          Merge additional settings (deep merges with base settings)

  Other Claude Flags:
  All other flags (e.g., --continue, --resume, --fork-session) are passed through to Claude

EXAMPLES:
  ${CMD_NAME}                            # Launch Claude with default settings
  ${CMD_NAME} -h -w                      # Launch Haiku in new window
  ${CMD_NAME} -st                        # Launch Sonnet with thinking (combined flags)
  ${CMD_NAME} --window-title "My Project"  # Launch in titled window
  ${CMD_NAME} --with-permission-checks   # Launch with permission checks enabled
  ${CMD_NAME} how are you                # Multiple words automatically joined into single prompt
  ${CMD_NAME} --print "what is 2+2?"     # Non-interactive mode
  ${CMD_NAME} --print --output-format json "summarize this"  # JSON output
  ${CMD_NAME} --continue                 # Continue most recent conversation

NOTES:
  - Single-letter flags can be combined (e.g., -st for sonnet + thinking)
  - Opening in a new window requires Ghostty terminal
  - All non-option arguments are automatically joined into a single prompt
  - Quotes are optional: "foo bar" and foo bar both work
  - Unknown flags are passed through to Claude CLI

CONFIGURATION:
  - ACFT_CLAUDE_PRELAUNCH_HOOK: Run a command before launching Claude
    Example: export ACFT_CLAUDE_PRELAUNCH_HOOK="echo 'Launching Claude...'"
EOF
  exit 0
}

# Debug flag - set to true to print the full claude command before execution
DEBUG=false

# Defaults
open_new_window=false
dangerously=true
model="sonnet"
thinking="true"
window_title=""
passthrough_args=()  # Arguments to pass through to Claude
append_mode="enabled"
merge_settings_json=""  # Additional settings to merge

# Expand combined single-letter flags (e.g., -st becomes -s -t)
expanded_args=()
for arg in "$@"; do
  if [[ $arg =~ ^-[a-z]{2,}$ ]]; then
    # This is a combined flag like -st
    # Extract each letter and add as separate flag
    for ((i=1; i<${#arg}; i++)); do
      expanded_args+=("-${arg:$i:1}")
    done
  else
    expanded_args+=("$arg")
  fi
done

# Reset positional parameters with expanded args
set -- "${expanded_args[@]}"

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --help)
      show_help
      ;;
    -d|--dangerously-skip-permissions)
      dangerously=true
      shift
      ;;
    -p|--with-permission-checks)
      dangerously=false
      shift
      ;;
    --print|--output-format|--input-format|--include-partial-messages|--replay-user-messages|--continue|--resume|--fork-session|--mcp-config|--system-prompt|--append-system-prompt|--permission-mode|--fallback-model|--settings|--add-dir|--ide|--strict-mcp-config|--session-id|--agents|--setting-sources|--plugin-dir)
      # Pass through to Claude with its argument if it takes one
      passthrough_args+=("$1")
      if [[ $1 == --resume ]] && [[ -n $2 && $2 != -* ]]; then
        # --resume can optionally take an argument
        passthrough_args+=("$2")
        shift 2
      elif [[ $1 == --continue || $1 == --print || $1 == --include-partial-messages || $1 == --replay-user-messages || $1 == --fork-session || $1 == --ide || $1 == --strict-mcp-config ]]; then
        # These flags take no arguments
        shift
      elif [[ -n $2 && $2 != -* ]]; then
        # Flag takes an argument
        passthrough_args+=("$2")
        shift 2
      else
        shift
      fi
      ;;
    --allowedTools|--allowed-tools|--disallowedTools|--disallowed-tools)
      # These can take multiple arguments
      passthrough_args+=("$1")
      shift
      while [[ -n $1 && $1 != -* ]]; do
        passthrough_args+=("$1")
        shift
      done
      ;;
    -w|--window)
      open_new_window=true
      shift
      ;;
    -h|--haiku)
      model="haiku"
      thinking="false"
      shift
      ;;
    -s|--sonnet)
      model="sonnet"
      thinking="true"
      shift
      ;;
    -o|--opus)
      model="opus"
      thinking="true"
      shift
      ;;
    -t|--thinking)
      thinking="true"
      shift
      ;;
    -f|--fast)
      thinking="false"
      shift
      ;;
    -n|--disable-framework)
      append_mode="disabled"
      shift
      ;;
    --merge-settings)
      if [[ -n $2 && $2 != -* ]]; then
        merge_settings_json="$2"
        shift 2
      else
        echo "Error: --merge-settings requires a JSON argument" >&2
        exit 1
      fi
      ;;
    --window-title)
      if [[ -n $2 && $2 != -* ]]; then
        window_title="$2"
        open_new_window=true
        shift 2
      else
        echo "Error: --window-title requires an argument" >&2
        exit 1
      fi
      ;;
    -*)
      # Unknown flag - pass through to Claude
      passthrough_args+=("$1")
      shift
      ;;
    *)
      # End of options, break to handle remaining arguments
      break
      ;;
  esac
done

# Determine whether we should append the framework specification prompt
# Default is enabled; only disabled if -n flag is used
should_append_spec=true

if [ "$append_mode" = "disabled" ]; then
  should_append_spec=false
fi

framework_spec_prompt=""
if [ "$should_append_spec" = true ]; then
  framework_spec_prompt="$("$SCRIPT_DIR/get-framework-spec.sh")"
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# Validate that ::PROJECT and ::WORK can be expanded before proceeding
if [ "$should_append_spec" = true ]; then
  validation_errors=""

  if ! acft expand ::PROJECT >/dev/null 2>&1; then
    validation_errors="${validation_errors}Error: Failed to expand ::PROJECT\n"
  fi

  if ! acft expand ::WORK >/dev/null 2>&1; then
    validation_errors="${validation_errors}Error: Failed to expand ::WORK\n"
  fi

  if [ -n "$validation_errors" ]; then
    echo -e "$validation_errors" >&2
    echo "Cannot launch Claude in this directory. The ACFT framework is not properly initialized." >&2
    echo "" >&2
    echo "You have two options:" >&2
    echo "" >&2
    echo "  1. Initialize the ACFT framework in this directory:" >&2
    echo "     Run: acft init" >&2
    echo "     (Or manually create checkpoints_project.toml and checkpoints_work.toml in appropriate locations)" >&2
    echo "" >&2
    echo "  2. Launch Claude without ACFT framework awareness:" >&2
    echo "     Use: ${CMD_NAME} --disable-framework (or -n)" >&2
    echo "     This runs Claude in vanilla mode without framework-specific features" >&2
    exit 1
  fi
fi

# Build the command array
cmd_args=()

# Add dangerously-skip-permissions if needed
if [ "$dangerously" = true ]; then
  cmd_args+=("--dangerously-skip-permissions")
fi

# Add model
cmd_args+=("--model" "$model")

# Build combined settings JSON
print_roots=false
settings_json=""

# Determine what settings we need
has_thinking=false
has_hooks=false

if [ -n "$thinking" ]; then
  has_thinking=true
fi

if [ -n "$framework_spec_prompt" ]; then
  cmd_args+=("--append-system-prompt" "$framework_spec_prompt")
  has_hooks=true
  print_roots=true
fi

# Build JSON based on what we need
if [ "$has_thinking" = true ] && [ "$has_hooks" = true ]; then
  sessionstart_hook_path="$SCRIPT_DIR/sessionstart-context.sh"
  settings_json="{\"alwaysThinkingEnabled\": $thinking, \"hooks\":{\"SessionStart\":[{\"hooks\":[{\"type\":\"command\",\"command\":\"$sessionstart_hook_path\"}]}]}}"
elif [ "$has_thinking" = true ]; then
  settings_json="{\"alwaysThinkingEnabled\": $thinking}"
elif [ "$has_hooks" = true ]; then
  sessionstart_hook_path="$SCRIPT_DIR/sessionstart-context.sh"
  settings_json="{\"hooks\":{\"SessionStart\":[{\"hooks\":[{\"type\":\"command\",\"command\":\"$sessionstart_hook_path\"}]}]}}"
fi

# Merge additional settings if provided
if [ -n "$merge_settings_json" ]; then
  if command -v jq >/dev/null 2>&1; then
    if [ -n "$settings_json" ]; then
      # Deep merge: base settings + additional settings
      settings_json=$(echo "$settings_json" "$merge_settings_json" | jq -s '
        def deep_merge:
          reduce .[] as $item ({};
            . * $item |
            to_entries |
            group_by(.key) |
            map(
              if (.[0].value | type) == "object" and (length > 1) and ((.[1].value | type) == "object")
              then {key: .[0].key, value: ([.[].value] | deep_merge)}
              else .[-1]
              end
            ) |
            from_entries
          );
        deep_merge
      ')
    else
      # No base settings, just use the merge settings
      settings_json="$merge_settings_json"
    fi
  else
    echo "Warning: jq not installed, cannot merge settings. Using base settings only." >&2
  fi
fi

# Add combined settings if we have any
if [ -n "$settings_json" ]; then
  cmd_args+=("--settings" "$settings_json")
fi

# Add passthrough arguments (e.g., --print, --continue, etc.)
cmd_args+=("${passthrough_args[@]}")

# Process remaining arguments - join all into single prompt
remaining_args=()
if [ $# -gt 0 ]; then
  # Join all remaining arguments with spaces into a single prompt
  remaining_args=("$*")
fi

# Handle remaining arguments
if [ "$print_roots" = true ]; then
  "$SCRIPT_DIR/sessionstart-context.sh" --short
fi

if [ "$open_new_window" = true ]; then
  # Open in new Ghostty window
  # Build the full claude command as a string
  claude_cmd="claude"
  for arg in "${cmd_args[@]}"; do
    # Use printf %q to properly escape for shell
    escaped_arg=$(printf %q "$arg")
    claude_cmd="$claude_cmd $escaped_arg"
  done

  # Add remaining arguments
  for arg in "${remaining_args[@]}"; do
    escaped_arg=$(printf %q "$arg")
    claude_cmd="$claude_cmd $escaped_arg"
  done

  # Add exec $SHELL to keep terminal open
  claude_cmd="$claude_cmd; exec \\$SHELL"

  # Build Ghostty arguments
  ghostty_args=("--working-directory=$PWD")
  if [ -n "$window_title" ]; then
    ghostty_args+=("--title=$window_title")
  fi
  ghostty_args+=("-e" "sh" "-c" "$claude_cmd")

  # Debug output
  if [ "$DEBUG" = true ]; then
    echo "[DEBUG] Opening new Ghostty window with command:" >&2
    echo "[DEBUG] $claude_cmd" >&2
  fi

  # Open Ghostty with the command
  open -na ghostty --args "${ghostty_args[@]}"
else
  # Add any remaining arguments as-is
  cmd_args+=("${remaining_args[@]}")

  # Debug output
  if [ "$DEBUG" = true ]; then
    echo "[DEBUG] Executing claude command:" >&2
    printf "[DEBUG] claude" >&2
    for arg in "${cmd_args[@]}"; do
      printf " %q" "$arg" >&2
    done
    printf "\n" >&2
  fi

  # Execute - always call claude directly
  claude "${cmd_args[@]}"
fi
