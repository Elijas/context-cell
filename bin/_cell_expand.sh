#!/bin/bash

# cell expand - Expand @root path symbol to absolute path
# Expands @root to CELL_PROJECT_ROOT (the directory containing cellproject.toml)

# Function to find cellproject.toml by walking up directory tree
find_project_root() {
    local current_dir="$1"

    # Walk up the directory tree
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/cellproject.toml" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done

    # Check root directory as well
    if [ -f "/cellproject.toml" ]; then
        echo "/"
        return 0
    fi

    return 1
}

# Help function
show_help() {
  cat << 'EOF'
Usage: cell expand PATH

Expand @root path symbol to absolute path.

The @root symbol expands to CELL_PROJECT_ROOT (the directory containing
cellproject.toml). This command is useful for converting symbolic paths
to absolute paths for use in scripts and commands.

PATH FORMATS:
  @root              -> /absolute/path/to/project/root
  @root/subpath      -> /absolute/path/to/project/root/subpath
  /absolute/path     -> /absolute/path (unchanged)
  relative/path      -> relative/path (unchanged)

EXAMPLES:
  cell expand @root                        # Print project root
  cell expand @root/execution              # Expand to absolute path
  cd $(cell expand @root/execution)        # Navigate using expansion
  cat $(cell expand @root/schemas/spec.json)  # Read file using expansion

COMMON PATTERNS:
  cd $(cell expand @root/foo/bar)          # Navigate relative to root
  ls $(cell expand @root)                  # List root directory
  find $(cell expand @root) -name "*.py"   # Search from root

EXIT CODES:
  0 - Success
  1 - Error (no cellproject.toml found, missing path argument)
EOF
  exit 0
}

# Main function
main() {
    # Parse arguments
    if [[ $# -eq 0 ]]; then
        echo "Error: Missing PATH argument" >&2
        echo "Use --help for usage information" >&2
        exit 1
    fi

    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
    fi

    local path_arg="$1"

    # Handle @root symbol expansion
    if [ "$path_arg" = "@root" ]; then
        # Find project root from current directory
        local project_root=$(find_project_root "$(pwd)")
        if [ -z "$project_root" ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        echo "$project_root"
    elif [[ "$path_arg" == @root/* ]]; then
        # Handle @root/subpath syntax
        local project_root=$(find_project_root "$(pwd)")
        if [ -z "$project_root" ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        # Replace @root with actual root path
        echo "${project_root}/${path_arg#@root/}"
    else
        # No @root symbol, return path unchanged
        echo "$path_arg"
    fi
}

# Execute main
main "$@"
