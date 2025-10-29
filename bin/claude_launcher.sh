#!/bin/bash

# Claude Launcher
# A wrapper script for launching Claude CLI with various configurations

# Function to find projectroot.toml by walking up directory tree
find_project_root() {
    local current_dir="$PWD"

    # Walk up the directory tree
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/projectroot.toml" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done

    # Check root directory as well
    if [ -f "/projectroot.toml" ]; then
        echo "/"
        return 0
    fi

    return 1
}

# Help function
show_help() {
  cat << EOF
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
EOF
  exit 0
}

# Defaults
open_new_window=false
dangerously=true
model="sonnet"
thinking="true"
window_title=""
cell_mode="auto"  # Can be: "auto", "force", or "disabled"

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
    -y|--context-cell)
      cell_mode="force"
      shift
      ;;
    -n|--no-context-cell)
      cell_mode="disabled"
      shift
      ;;
    -d|--dangerously-skip-permissions)
      dangerously=true
      shift
      ;;
    -p|--with-permission-checks)
      dangerously=false
      shift
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
      echo "Invalid option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
    *)
      # End of options, break to handle remaining arguments
      break
      ;;
  esac
done

# Handle Context Cell mode
project_root=""
if [ "$cell_mode" = "force" ]; then
  # Force context-cell mode - fail if not found
  if project_root=$(find_project_root); then
    echo "Project root (PROJECT_ROOT):"
    echo "  $project_root"
  else
    echo "Error: Could not find projectroot.toml in any parent directory" >&2
    exit 1
  fi
elif [ "$cell_mode" = "auto" ]; then
  # Auto-detect context-cell project
  if project_root=$(find_project_root); then
    echo "Project root (PROJECT_ROOT) [auto-detected]:"
    echo "  $project_root"
  else
    # Not in a context-cell project, continue without it
    cell_mode="disabled"
  fi
fi
# If disabled, do nothing

# Build the command array
cmd_args=()

# Add dangerously-skip-permissions if needed
if [ "$dangerously" = true ]; then
  cmd_args+=("--dangerously-skip-permissions")
fi

# Add model
cmd_args+=("--model" "$model")

# Add thinking settings if specified
if [ -n "$thinking" ]; then
  cmd_args+=("--settings" "{\"alwaysThinkingEnabled\": $thinking}")
fi

# Add Context Cell context if enabled (not disabled and project_root is set)
if [ "$cell_mode" != "disabled" ] && [ -n "$project_root" ]; then
  # Capture the output and validate line count
  cell_output=$(cell spec --project-root "$project_root")
  line_count=$(echo "$cell_output" | wc -l | tr -d ' ')

  if [ "$line_count" -lt 400 ] || [ "$line_count" -gt 1000 ]; then
    echo "Error: cell spec output has $line_count lines (expected 400-1000)" >&2
    exit 1
  fi

  cmd_args+=("--append-system-prompt" "$cell_output")
fi

# Process remaining arguments - join all into single prompt
remaining_args=()
if [ $# -gt 0 ]; then
  # Join all remaining arguments with spaces into a single prompt
  remaining_args=("$*")
fi

# Handle remaining arguments
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
  claude_cmd="$claude_cmd; exec \$SHELL"

  # Build Ghostty arguments
  ghostty_args=("--working-directory=$PWD")
  if [ -n "$window_title" ]; then
    ghostty_args+=("--title=$window_title")
  fi
  ghostty_args+=("-e" "sh" "-c" "$claude_cmd")

  # Open Ghostty with the command
  open -na ghostty --args "${ghostty_args[@]}"
else
  # Add any remaining arguments as-is
  cmd_args+=("${remaining_args[@]}")

  # Execute - always call claude directly
  claude "${cmd_args[@]}"
fi
