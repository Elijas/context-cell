#!/bin/bash

# Sanity check: acft must be available for this hook to work
if ! command -v acft >/dev/null 2>&1; then
  echo 'acft command not found. Cannot generate sessionstart context.' >&2
  exit 1
fi

# Build commands array in execution order
COMMANDS=()

# 1. Path expansions first (agent needs to know where things are)
if [ -f "CHECKPOINT.md" ]; then
  COMMANDS+=("acft expand ::PROJECT ::WORK ::THIS")
else
  COMMANDS+=("acft expand ::PROJECT ::WORK")
fi

# 2. Full checkpoint file (complete context for the current checkpoint)
if [ -f "CHECKPOINT.md" ]; then
  COMMANDS+=("cat \$(acft expand ::THIS)/CHECKPOINT.md")
fi

# 3. Child CHECKPOINT status summary (critical for coordinators)
if ls */CHECKPOINT.md 2>/dev/null | grep -q .; then
  COMMANDS+=('echo "=== Child Checkpoints ===" && for dir in */CHECKPOINT.md; do [ -f "$dir" ] && echo "$(dirname "$dir"): $(grep "^VALID:\|^SIGNAL:\|^LIFECYCLE:" "$dir" | tr "\n" " ")"; done')
fi

# 5. Directory listings for quick navigation
if [ -f "../CHECKPOINT.md" ]; then
  COMMANDS+=("ls -1AF ..")
fi
COMMANDS+=("ls -1AF")

# Check for --short flag
SHORT_MODE=false
if [ "$1" = "--short" ]; then
  SHORT_MODE=true
fi

# Function to truncate output if longer than 5 lines
truncate_output() {
  local output="$1"
  local line_count=$(echo "$output" | wc -l | tr -d ' ')

  if [ "$line_count" -le 5 ]; then
    echo "$output"
  else
    local first=$(echo "$output" | sed -n '1p')
    local second=$(echo "$output" | sed -n '2p')
    local before_last=$(echo "$output" | sed -n "$((line_count - 1))p")
    local last=$(echo "$output" | sed -n "${line_count}p")
    local hidden=$((line_count - 4))

    echo "$first"
    echo "$second"
    echo "[$hidden lines hidden...]"
    echo "$before_last"
    echo "$last"
  fi
}

# Function to build bash_output tag with optional truncation
build_output() {
  local cmd="$1"
  local output=$(eval "$2" 2>&1)

  if [ "$SHORT_MODE" = true ]; then
    local truncated=$(truncate_output "$output")
    echo "<bash_output command=\"$cmd\">"
    echo "$truncated"
    echo "</bash_output>"
  else
    echo "<bash_output command=\"$cmd\">"
    echo "$output"
    echo "</bash_output>"
  fi
}

# Build context
CONTEXT="<sessionstart_context>

<!-- ACF SessionStart Context -->
<!-- Provides checkpoint orientation: paths, status summary, child checkpoints, and directory structure -->
<!-- All commands use ACF framework tools and conventions -->

"

for command in "${COMMANDS[@]}"; do
  CONTEXT+="$(build_output "$command" "$command")"
  CONTEXT+="

"
done

CONTEXT+="</sessionstart_context>"

cat << EOF
$CONTEXT
EOF
exit 0
