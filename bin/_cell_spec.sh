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
                          Supports @project symbol for PROJECT_ROOT
  --project-root PATH      Context Cell project root path to include in output
                          Supports @project symbol for PROJECT_ROOT
  --help                  Show this help message

EXAMPLES:
  cell spec                                        # Use default path
  cell spec --path /custom/path                    # Use custom path
  cell spec --path @project/spec                      # Use @project symbol
  cell spec --project-root @project                   # Include project root in output

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

    # Handle @project symbol expansion for --path
    if [ "$target_path" = "@project" ]; then
        # Find project root from current directory
        local temp_root=$(find_project_root "$(pwd)")
        if [ $? -ne 0 ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        target_path="$temp_root"
        custom_path_provided=true
    elif [[ "$target_path" == @project/* ]]; then
        # Handle @project/subpath syntax
        local temp_root=$(find_project_root "$(pwd)")
        if [ $? -ne 0 ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        # Replace @project with actual root path
        target_path="${temp_root}/${target_path#@project/}"
        custom_path_provided=true
    fi

    # Handle @project symbol expansion for --project-root
    if [ -n "$project_root" ]; then
        if [ "$project_root" = "@project" ]; then
            # Find project root from current directory
            local temp_root=$(find_project_root "$(pwd)")
            if [ $? -ne 0 ]; then
                echo "Error: No cellproject.toml found in directory hierarchy" >&2
                exit 1
            fi
            project_root="$temp_root"
        elif [[ "$project_root" == @project/* ]]; then
            # Handle @project/subpath syntax
            local temp_root=$(find_project_root "$(pwd)")
            if [ $? -ne 0 ]; then
                echo "Error: No cellproject.toml found in directory hierarchy" >&2
                exit 1
            fi
            # Replace @project with actual root path
            project_root="${temp_root}/${project_root#@project/}"
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
    echo "<CONTEXT_CELL_FRAMEWORK_SPECIFICATION>"

    # Concatenate and output all files
    for file in "${files[@]}"; do
        cat "$file"
        # Add a newline between files if the file doesn't end with one
        if [ -n "$(tail -c 1 "$file")" ]; then
            echo
        fi
    done

    # Output closing tag
    echo "</CONTEXT_CELL_FRAMEWORK_SPECIFICATION>"

    # Add project root information if provided
    if [ -n "$project_root" ]; then
        echo

        # Get current working directory (symlinked)
        local pwd_symlinked="$(pwd)"

        # Get current working directory (resolved)
        local pwd_resolved="$(pwd -P)"

        # Get resolved project root
        local project_root_resolved="$(cd "$project_root" 2>/dev/null && pwd -P)"

        # Find work root
        local work_root=$(find_work_root "$pwd_symlinked" "$project_root")
        local work_root_resolved="$(cd "$work_root" 2>/dev/null && pwd -P)"

        # Always show project root
        echo "You're operating in Context Cell project at (PROJECT_ROOT): $project_root"

        # Show project root resolved path if different
        if [ "$project_root" != "$project_root_resolved" ]; then
            echo "Project root (PROJECT_ROOT, resolved): $project_root_resolved"
        fi

        # Show @project symbol explanation
        echo "@project is PROJECT_ROOT"
        echo "@project expands to $project_root"
        echo "Example: @project/execution expands to ${project_root}/execution"

        # Show @tree symbol explanation if different from @project
        if [ "$work_root" != "$project_root" ]; then
            echo ""
            echo "Work cells hierarchy root (TREE_ROOT): $work_root"
            if [ "$work_root" != "$work_root_resolved" ]; then
                echo "Work root (TREE_ROOT, resolved): $work_root_resolved"
            fi
            echo "@tree is TREE_ROOT"
            echo "@tree expands to $work_root"
            echo "Example: @tree/grado_v1_01 expands to ${work_root}/grado_v1_01"
        fi

        # Show current working directory (CELL_ROOT)
        echo ""
        echo "Current working directory (CELL_ROOT): $pwd_symlinked"
        if [ "$pwd_symlinked" != "$pwd_resolved" ]; then
            echo "Current working directory (CELL_ROOT, resolved): $pwd_resolved"
        fi
        echo "@this is CELL_ROOT"
        echo "@this expands to $pwd_symlinked"
        echo "Example: @this/_outputs/results.csv expands to ${pwd_symlinked}/_outputs/results.csv"
    fi
}

# Execute main
main "$@"
