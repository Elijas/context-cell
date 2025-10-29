#!/bin/bash

# cell spec - Output complete Context Cell framework specification
# Provides all detailed framework explanation in a single output, eliminating the need for additional navigation

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

# Show help
show_help() {
  cat << 'EOF'
Usage: cell spec [OPTIONS]

Concatenate all files from the Context Cell framework specification directory
in alphabetical order. This command provides all the detailed framework
explanation in a single output, eliminating the need for additional navigation.

OPTIONS:
  --path PATH              Path to directory containing files to concatenate
                          Default: Dynamically resolved relative to script location
                          Supports @root symbol for CELL_PROJECT_ROOT
  --project-root PATH      Context Cell project root path to include in output
                          Supports @root symbol for CELL_PROJECT_ROOT
  --help                  Show this help message

EXAMPLES:
  cell spec                                        # Use default path
  cell spec --path /custom/path                    # Use custom path
  cell spec --path @root/spec                      # Use @root symbol
  cell spec --project-root @root                   # Include project root in output

EXIT CODES:
  0 - Success
  1 - Error (directory doesn't exist, no files found, etc.)
EOF
  exit 0
}

# Main function
main() {
    # Get the canonical (symlink-resolved) path of this script
    local script_path="$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")"
    local script_dir="$(dirname "$script_path")"

    # Default path: relative to script location
    local target_path="$script_dir/../spec/context_cell_framework"
    local custom_path_provided=false
    local project_root=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                ;;
            --path)
                if [ -z "$2" ]; then
                    echo "Error: --path requires an argument" >&2
                    exit 1
                fi
                target_path="$2"
                custom_path_provided=true
                shift 2
                ;;
            --project-root)
                if [ -z "$2" ]; then
                    echo "Error: --project-root requires an argument" >&2
                    exit 1
                fi
                project_root="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
    done

    # Handle @root symbol expansion for --path
    if [ "$target_path" = "@root" ]; then
        # Find project root from current directory
        local temp_root=$(find_project_root "$(pwd)")
        if [ $? -ne 0 ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        target_path="$temp_root"
        custom_path_provided=true
    elif [[ "$target_path" == @root/* ]]; then
        # Handle @root/subpath syntax
        local temp_root=$(find_project_root "$(pwd)")
        if [ $? -ne 0 ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        # Replace @root with actual root path
        target_path="${temp_root}/${target_path#@root/}"
        custom_path_provided=true
    fi

    # Handle @root symbol expansion for --project-root
    if [ -n "$project_root" ]; then
        if [ "$project_root" = "@root" ]; then
            # Find project root from current directory
            local temp_root=$(find_project_root "$(pwd)")
            if [ $? -ne 0 ]; then
                echo "Error: No cellproject.toml found in directory hierarchy" >&2
                exit 1
            fi
            project_root="$temp_root"
        elif [[ "$project_root" == @root/* ]]; then
            # Handle @root/subpath syntax
            local temp_root=$(find_project_root "$(pwd)")
            if [ $? -ne 0 ]; then
                echo "Error: No cellproject.toml found in directory hierarchy" >&2
                exit 1
            fi
            # Replace @root with actual root path
            project_root="${temp_root}/${project_root#@root/}"
        fi
    fi

    # Resolve target_path to canonical path if not custom
    if [ "$custom_path_provided" = false ]; then
        target_path="$(cd "$target_path" 2>/dev/null && pwd -P)"
        if [ $? -ne 0 ]; then
            echo "Error: Default directory does not exist: $target_path" >&2
            exit 1
        fi
    fi

    # Check if directory exists
    if [ ! -d "$target_path" ]; then
        echo "Error: Directory does not exist: $target_path" >&2
        exit 1
    fi

    # Find all files (not directories) in the target path, sort alphabetically
    # Exclude CLAUDE.md (maintenance guidelines, not part of spec)
    local files=()
    while IFS= read -r -d '' file; do
        local basename="$(basename "$file")"
        if [ "$basename" != "CLAUDE.md" ]; then
            files+=("$file")
        fi
    done < <(find "$target_path" -maxdepth 1 -type f -print0 | sort -z)

    # Check if any files were found
    if [ ${#files[@]} -eq 0 ]; then
        echo "Error: No files found in directory: $target_path" >&2
        exit 1
    fi

    # Output opening tag
    echo "<CONTEXT_CELL_SPECIFICATION>"

    # Concatenate and output all files
    for file in "${files[@]}"; do
        cat "$file"
        # Add a newline between files if the file doesn't end with one
        if [ -n "$(tail -c 1 "$file")" ]; then
            echo
        fi
    done

    # Output closing tag
    echo "</CONTEXT_CELL_SPECIFICATION>"

    # Add project root information if provided
    if [ -n "$project_root" ]; then
        echo

        # Get current working directory (symlinked)
        local pwd_symlinked="$(pwd)"

        # Get current working directory (resolved)
        local pwd_resolved="$(pwd -P)"

        # Get resolved project root
        local project_root_resolved="$(cd "$project_root" 2>/dev/null && pwd -P)"

        # Always show project root
        echo "You're operating in Context Cell project at (CELL_PROJECT_ROOT): $project_root"

        # Show project root resolved path if different
        if [ "$project_root" != "$project_root_resolved" ]; then
            echo "Project root (CELL_PROJECT_ROOT, resolved): $project_root_resolved"
        fi

        # Show @root symbol explanation
        echo "@root is CELL_PROJECT_ROOT"
        echo "@root expands to $project_root"
        echo "Example: @root/execution expands to ${project_root}/execution"

        # Show working directory information
        if [ "$pwd_symlinked" != "$pwd_resolved" ]; then
            echo "Working directory (WORK_CELL_ROOT, symlinked): $pwd_symlinked"
            echo "Working directory (WORK_CELL_ROOT, resolved): $pwd_resolved"
        fi
    fi
}

# Execute main
main "$@"
