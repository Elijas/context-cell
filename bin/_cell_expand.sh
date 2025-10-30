#!/bin/bash

# cell expand - Expand @project and @tree path symbols to absolute paths
# Expands @project to PROJECT_ROOT (the directory containing cellproject.toml)
# Expands @tree to TREE_ROOT (the directory containing celltree.toml, or project root if not found)

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

# Function to find celltree.toml by walking up directory tree
# Falls back to project root if not found
find_work_root() {
    local current_dir="$1"
    local project_root="$2"

    # Walk up the directory tree
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/celltree.toml" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done

    # Check root directory as well
    if [ -f "/celltree.toml" ]; then
        echo "/"
        return 0
    fi

    # Fall back to project root if celltree.toml not found
    echo "$project_root"
    return 0
}

# Help function
show_help() {
  cat << 'EOF'
Usage: cell expand PATH

Expand @project and @tree path symbols to absolute paths.

The @project symbol expands to PROJECT_ROOT (the directory containing
cellproject.toml). The @tree symbol expands to TREE_ROOT (the directory
containing celltree.toml, or project root if celltree.toml doesn't exist).

PATH FORMATS:
  @project              -> /absolute/path/to/project/root
  @project/subpath      -> /absolute/path/to/project/root/subpath
  @tree              -> /absolute/path/to/work/root
  @tree/subpath      -> /absolute/path/to/work/root/subpath
  /absolute/path     -> /absolute/path (unchanged)
  relative/path      -> relative/path (unchanged)

EXAMPLES:
  cell expand @project                        # Print project root
  cell expand @tree                        # Print work root
  cell expand @project/execution              # Expand to absolute path
  cell expand @tree/grado_v1_01            # Expand work cell path
  cd $(cell expand @tree/grado_v1_01)      # Navigate using expansion
  cat $(cell expand @project/schemas/spec.json)  # Read file using expansion

COMMON PATTERNS:
  cd $(cell expand @project/foo/bar)          # Navigate relative to root
  cd $(cell expand @tree/cell_v1_01)       # Navigate to work cell
  ls $(cell expand @tree)                  # List work root directory
  find $(cell expand @project) -name "*.py"   # Search from root

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

    # Handle @project and @tree symbol expansion
    if [ "$path_arg" = "@project" ]; then
        # Find project root from current directory
        local project_root=$(find_project_root "$(pwd)")
        if [ -z "$project_root" ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        echo "$project_root"
    elif [[ "$path_arg" == @project/* ]]; then
        # Handle @project/subpath syntax
        local project_root=$(find_project_root "$(pwd)")
        if [ -z "$project_root" ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        # Replace @project with actual root path
        echo "${project_root}/${path_arg#@project/}"
    elif [ "$path_arg" = "@tree" ]; then
        # Find work root from current directory
        local project_root=$(find_project_root "$(pwd)")
        if [ -z "$project_root" ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        local work_root=$(find_work_root "$(pwd)" "$project_root")
        echo "$work_root"
    elif [[ "$path_arg" == @tree/* ]]; then
        # Handle @tree/subpath syntax
        local project_root=$(find_project_root "$(pwd)")
        if [ -z "$project_root" ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        local work_root=$(find_work_root "$(pwd)" "$project_root")
        # Replace @tree with actual work root path
        echo "${work_root}/${path_arg#@tree/}"
    else
        # No @project or @tree symbol, return path unchanged
        echo "$path_arg"
    fi
}

# Execute main
main "$@"
