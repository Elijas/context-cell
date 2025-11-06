#!/bin/bash
# Extract framework specification for Claude system prompt
#
# This is extracted into a separate script (rather than inlined in claude.sh) to enable
# comprehensive testing of bash argument safety. See tests/claude/test_bash_roundtrip.sh
# for tests that verify the framework spec content round-trips identically through bash
# argument handling without corruption.
#
# Used by: claude.sh
# Tested by: tests/claude/test_bash_roundtrip.sh

set -euo pipefail

# Get framework specification
framework_spec_prompt="$(acft spec --full 2>&1)"
if [ $? -ne 0 ]; then
  echo "Error: Failed to get framework specification from 'acft spec --full'" >&2
  echo "$framework_spec_prompt" >&2
  exit 1
fi

# Verify we got meaningful output (at least 100 lines)
line_count=$(echo "$framework_spec_prompt" | wc -l | tr -d ' ')
if [ "$line_count" -lt 100 ]; then
  echo "Error: 'acft spec --full' returned only $line_count lines (expected at least 100)" >&2
  echo "The framework specification appears to be incomplete or corrupted" >&2
  exit 1
fi

# Output the spec
echo "$framework_spec_prompt"
