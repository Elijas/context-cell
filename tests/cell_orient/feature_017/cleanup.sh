#!/bin/bash

# Cleanup test structure for feature_017

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_ROOT="$SCRIPT_DIR/project_root"

echo "Cleaning up test structure..."

rm -rf "$TEST_ROOT"
rm -f /tmp/feature_017_stdout.txt /tmp/feature_017_stdout2.txt /tmp/feature_017_stdout3.txt

echo "Cleanup complete!"
