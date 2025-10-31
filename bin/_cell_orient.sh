#!/bin/bash

# cell orient - View work cell hierarchy with configurable sections
# Shows vantage-based view: Ancestry → Peers → Children in XML format

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

# Function to find execution boundary
# Walks up from start_path toward root_path, looking for directory named "execution"
find_execution_boundary() {
    local start_path="$1"
    local root_path="$2"
    local current_dir="$start_path"

    # Walk up until we reach the root
    while [ "$current_dir" != "$root_path" ]; do
        # Break if we've reached the filesystem root to prevent infinite loop
        if [ "$current_dir" = "/" ]; then
            break
        fi

        local parent_dir="$(dirname "$current_dir")"

        # Check if parent contains a directory named "execution"
        if [ -d "$parent_dir/execution" ] && [ "$parent_dir/execution" != "$current_dir" ]; then
            # If we're currently in or below execution, return it
            if [[ "$current_dir" == "$parent_dir/execution"* ]]; then
                echo "$parent_dir/execution"
                return 0
            fi
        fi

        current_dir="$parent_dir"
    done

    # No execution boundary found, return root
    echo "$root_path"
    return 0
}

# Check if directory is a valid work cell
is_work_cell() {
    local dir_path="$1"
    local dir_name="$(basename "$dir_path")"

    # Check naming pattern: ^[a-z][a-z0-9_]*_v[0-9]+_[0-9]{2}$
    if ! [[ "$dir_name" =~ ^[a-z][a-z0-9_]*_v[0-9]+_[0-9]{2}$ ]]; then
        return 1
    fi

    # Check if CELL.md exists
    if [ ! -f "$dir_path/CELL.md" ]; then
        return 1
    fi

    # Check if CELL.md has YAML frontmatter with work_complete field
    if ! grep -q "^work_complete:" "$dir_path/CELL.md" 2>/dev/null; then
        return 1
    fi

    return 0
}

# Get work_complete status as true/false
get_work_complete_status() {
    local cell_path="$1"
    local cell_md="$cell_path/CELL.md"

    # Extract work_complete value from YAML frontmatter
    local value=$(awk '/^work_complete:/ {print $2; exit}' "$cell_md" 2>/dev/null)

    echo "$value"
}

# XML escape function
xml_escape() {
    local text="$1"
    # Escape XML special characters
    text="${text//&/&amp;}"
    text="${text//</&lt;}"
    text="${text//>/&gt;}"
    text="${text//\"/&quot;}"
    text="${text//\'/&apos;}"
    echo "$text"
}

# Extract DISCOVERY section (only first 12 lines for performance)
extract_discovery() {
    local cell_path="$1"
    local cell_md="$cell_path/CELL.md"

    # Read first 12 lines and extract the line after # DISCOVERY
    local discovery=$(head -n 12 "$cell_md" | awk '/^# DISCOVERY$/ {getline; while (length($0) == 0) getline; print; exit}')

    # Strip leading/trailing whitespace
    echo "$discovery" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Extract ABSTRACT section (full file read)
extract_abstract() {
    local cell_path="$1"
    local cell_md="$cell_path/CELL.md"

    # Extract everything between # ABSTRACT and the next # heading
    # Preserve blank lines for paragraph structure
    local abstract=$(awk '
        /^# ABSTRACT$/ { in_abstract=1; next }
        in_abstract && /^# [A-Z]/ { exit }
        in_abstract { print }
    ' "$cell_md")

    echo "$abstract"
}

# Get children of a directory
get_children() {
    local dir_path="$1"
    local children=()

    # Return empty array if directory doesn't exist
    if [ ! -d "$dir_path" ]; then
        echo ""
        return
    fi

    # List subdirectories
    for subdir in "$dir_path"/*; do
        # Skip if not a directory
        [ ! -d "$subdir" ] && continue

        # Skip hidden and special directories
        local basename="$(basename "$subdir")"
        [[ "$basename" =~ ^[._] ]] && continue

        # Check if it's a valid work cell
        if is_work_cell "$subdir"; then
            children+=("$subdir")
        fi
    done

    # Return sorted list
    printf '%s\n' "${children[@]}" | sort
}

# Build ancestry from boundary to start_path
build_ancestry() {
    local start_path="$1"
    local boundary_path="$2"
    local ancestry=()
    local current_dir="$start_path"

    # Build list from start_path up to boundary_path
    while [ "$current_dir" != "$boundary_path" ] && [ "$current_dir" != "/" ]; do
        if is_work_cell "$current_dir"; then
            # Prepend to array (reverse order)
            ancestry=("$current_dir" "${ancestry[@]}")
        fi
        current_dir="$(dirname "$current_dir")"
    done

    # Check if boundary itself is a work cell
    if [ "$current_dir" = "$boundary_path" ] && is_work_cell "$boundary_path"; then
        ancestry=("$boundary_path" "${ancestry[@]}")
    fi

    # Return ancestry
    printf '%s\n' "${ancestry[@]}"
}

# Get peers (siblings at same level)
get_peers() {
    local dir_path="$1"
    local parent_dir="$(dirname "$dir_path")"
    local peers=()

    # Get all children of parent
    local siblings=$(get_children "$parent_dir")

    # Filter out the current directory
    while IFS= read -r sibling; do
        if [ -n "$sibling" ] && [ "$sibling" != "$dir_path" ]; then
            peers+=("$sibling")
        fi
    done <<< "$siblings"

    # Return sorted list
    printf '%s\n' "${peers[@]}" | sort
}


# Convert absolute path to relative path with @project/@tree prefix
make_relative_path() {
    local abs_path="$1"
    local project_root="$2"
    local target_path="$3"
    local work_root="$4"

    # If path is the target_path, use .
    if [ "$abs_path" = "$target_path" ]; then
        echo "./CELL.md"
        return
    fi

    # If path is under target_path, use ./
    if [[ "$abs_path" == "$target_path"/* ]]; then
        local rel="${abs_path#$target_path/}"
        echo "./${rel}/CELL.md"
        return
    fi

    # If work_root != project_root and path is under work_root, use @tree
    if [ "$work_root" != "$project_root" ] && [[ "$abs_path" == "$work_root"/* ]]; then
        local rel="${abs_path#$work_root/}"
        echo "@tree/${rel}/CELL.md"
        return
    fi

    # If path IS work_root and work_root != project_root, use @tree
    if [ "$work_root" != "$project_root" ] && [ "$abs_path" = "$work_root" ]; then
        echo "@tree/CELL.md"
        return
    fi

    # Otherwise use @project
    local rel="${abs_path#$project_root/}"
    echo "@project/${rel}/CELL.md"
}

# Print a cell in XML format
print_cell() {
    local cell_path="$1"
    local show_discovery="$2"
    local show_abstract="$3"
    local project_root="$4"
    local target_path="$5"
    local indent="$6"
    local recursive="$7"  # Whether to recursively print children
    local work_root="$8"  # Work root for path resolution

    local cell_name="$(basename "$cell_path")"
    local status=$(get_work_complete_status "$cell_path")
    local rel_path=$(make_relative_path "$cell_path" "$project_root" "$target_path" "$work_root")

    # Escape for XML
    local escaped_name=$(xml_escape "$cell_name")
    local escaped_path=$(xml_escape "$rel_path")

    # Open cell tag
    echo "${indent}<cell name=\"${escaped_name}\" work_complete=\"${status}\" path=\"${escaped_path}\">"

    # Show sections based on flags
    if [ "$show_discovery" = true ]; then
        local discovery=$(extract_discovery "$cell_path")
        local escaped_discovery=$(xml_escape "$discovery")
        echo "${indent}  <discovery>${escaped_discovery}</discovery>"
    fi

    if [ "$show_abstract" = true ]; then
        echo "${indent}  <abstract>"
        local abstract=$(extract_abstract "$cell_path")
        # Output abstract line by line, escaping each line
        while IFS= read -r line; do
            local escaped_line=$(xml_escape "$line")
            echo "${indent}    ${escaped_line}"
        done <<< "$abstract"
        echo "${indent}  </abstract>"
    fi

    # Recursively print children if requested
    if [ "$recursive" = true ]; then
        local children=()
        while IFS= read -r line; do
            [ -n "$line" ] && children+=("$line")
        done < <(get_children "$cell_path" | sort)

        if [ ${#children[@]} -gt 0 ]; then
            echo "${indent}  <children>"
            for child in "${children[@]}"; do
                print_cell "$child" "$show_discovery" "$show_abstract" "$project_root" "$target_path" "${indent}    " "$recursive" "$work_root"
            done
            echo "${indent}  </children>"
        fi
    fi

    # Close cell tag
    echo "${indent}</cell>"
}

# Help function
show_help() {
  cat << 'EOF'
Usage: cell orient [OPTIONS] PATH

View work cell hierarchy from specified location's perspective in XML format.

SECTION FLAGS (what to show from CELL.md):
  --DISCOVERY              Include one-line DISCOVERY sections (default, fast)
  --ABSTRACT               Include full ABSTRACT sections (detailed)

  Can be combined: --DISCOVERY --ABSTRACT

RELATIONSHIP FLAGS (which cells to show):
  --self, -s               Include current cell in output
  --ancestors, -a          Include parent cells up to execution boundary
  --peers, -p              Include sibling cells at same level
  --children, -c           Include immediate child cells
  --descendants, -d        Include all descendant cells recursively

  Default (no flags): all except --self (full vantage view)

  Can be combined: -s -c includes both current cell and its children
  Note: --descendants includes ALL children recursively (--children shows only immediate)

PATH (required):
  Directory to orient from. Special values:
    .                  Current directory
    @project           Project root (cellproject.toml location)
    @project/subpath   Path from project root
    @tree              Work cells root (celltree.toml location)
    @tree/subpath      Path from work root

EXAMPLES:
  cell orient .                              # Quick overview from current location
  cell orient --self .                       # Include only current cell
  cell orient -s --ABSTRACT .                # Include current cell with abstract
  cell orient --ABSTRACT .                   # Detailed view with abstracts
  cell orient --DISCOVERY --ABSTRACT .       # Include both sections
  cell orient --peers .                      # Include only siblings
  cell orient --ancestors --children other/  # Include ancestry and children from other/
  cell orient -sac .                         # Include self, ancestors, and children
  cell orient --descendants .                # Include all descendants recursively
  cell orient --descendants --ABSTRACT .     # Full descendant tree with abstracts

EXIT CODES:
  0 - Success (even if no cells found)
  1 - Error (no cellproject.toml, invalid path, missing path argument, etc.)
EOF
  exit 0
}

# Main function
main() {
    # Default flags
    local show_discovery=false
    local show_abstract=false
    local show_self=false
    local show_ancestors=false
    local show_peers=false
    local show_children=false
    local show_descendants=false
    local path_arg=""
    local section_flags_set=false
    local relationship_flags_set=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                ;;
            --DISCOVERY)
                show_discovery=true
                section_flags_set=true
                shift
                ;;
            --ABSTRACT)
                show_abstract=true
                section_flags_set=true
                shift
                ;;
            --self|-s)
                show_self=true
                relationship_flags_set=true
                shift
                ;;
            --ancestors|-a)
                show_ancestors=true
                relationship_flags_set=true
                shift
                ;;
            --peers|-p)
                show_peers=true
                relationship_flags_set=true
                shift
                ;;
            --children|-c)
                show_children=true
                relationship_flags_set=true
                shift
                ;;
            --descendants|-d)
                show_descendants=true
                relationship_flags_set=true
                shift
                ;;
            -*)
                echo "Error: Unknown option: $1" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
            *)
                # Path argument
                path_arg="$1"
                shift
                ;;
        esac
    done

    # Verify path argument was provided
    if [ -z "$path_arg" ]; then
        echo "Error: Missing PATH argument" >&2
        echo "Use --help for usage information" >&2
        exit 1
    fi

    # Apply defaults if flags not set
    if [ "$section_flags_set" = false ]; then
        show_discovery=true
    fi

    # Handle descendants flag: implies show_children
    if [ "$show_descendants" = true ]; then
        show_children=true
    fi

    if [ "$relationship_flags_set" = false ]; then
        show_ancestors=true
        show_peers=true
        show_children=true
    fi

    # Handle @project and @tree symbols
    if [ "$path_arg" = "@project" ]; then
        # Use project root
        local temp_project_root=$(find_project_root "$(pwd)")
        if [ $? -ne 0 ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        path_arg="$temp_project_root"
    elif [[ "$path_arg" == @project/* ]]; then
        # Handle @project/subpath syntax - use literal project root
        local temp_root=$(find_project_root "$(pwd)")
        if [ $? -ne 0 ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        # Replace @project with actual root path
        path_arg="${temp_root}/${path_arg#@project/}"
    elif [ "$path_arg" = "@tree" ]; then
        # @tree: use work root (celltree.toml location, or project root if not found)
        local temp_project_root=$(find_project_root "$(pwd)")
        if [ $? -ne 0 ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        local temp_work_root=$(find_work_root "$(pwd)" "$temp_project_root")
        path_arg="$temp_work_root"
    elif [[ "$path_arg" == @tree/* ]]; then
        # Handle @tree/subpath syntax - use literal work root
        local temp_project_root=$(find_project_root "$(pwd)")
        if [ $? -ne 0 ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        local temp_work_root=$(find_work_root "$(pwd)" "$temp_project_root")
        # Replace @tree with actual work root path
        path_arg="${temp_work_root}/${path_arg#@tree/}"
    fi

    # Resolve path to absolute
    if [ ! -e "$path_arg" ]; then
        echo "Error: Path does not exist: $path_arg" >&2
        exit 1
    fi

    local target_path="$(cd "$path_arg" && pwd)"

    # Find project root
    local project_root=$(find_project_root "$target_path")
    if [ $? -ne 0 ]; then
        echo "Error: No cellproject.toml found in directory hierarchy" >&2
        exit 1
    fi

    # Find work root (falls back to project root if celltree.toml not found)
    local work_root=$(find_work_root "$target_path" "$project_root")

    # Verify path is within project
    if [[ ! "$target_path" =~ ^"$project_root" ]]; then
        echo "Error: Path is outside project root" >&2
        exit 1
    fi

    # If target_path is not a work cell, walk up to find one or use boundary/root
    if ! is_work_cell "$target_path"; then
        local original_target="$target_path"
        local current="$target_path"

        # Walk up to find parent work cell
        while [ "$current" != "$project_root" ] && [ "$current" != "/" ]; do
            current="$(dirname "$current")"
            if is_work_cell "$current"; then
                target_path="$current"
                break
            fi
        done

        # If still no work cell, try to find execution boundary
        if ! is_work_cell "$target_path"; then
            local boundary=$(find_execution_boundary "$original_target" "$project_root")
            if [ -d "$boundary" ]; then
                target_path="$boundary"
            else
                target_path="$project_root"
            fi
        fi
    fi

    # Find execution boundary
    local boundary=$(find_execution_boundary "$target_path" "$project_root")

    # Build data structures
    local self_cell=""
    local ancestors=()
    local peers=()
    local children=()

    if [ "$show_self" = true ]; then
        # Only set self_cell if target_path is actually a work cell
        if is_work_cell "$target_path"; then
            self_cell="$target_path"
        fi
    fi

    if [ "$show_ancestors" = true ]; then
        while IFS= read -r line; do
            [ -n "$line" ] && ancestors+=("$line")
        done < <(build_ancestry "$target_path" "$boundary")
    fi

    if [ "$show_peers" = true ]; then
        while IFS= read -r line; do
            [ -n "$line" ] && peers+=("$line")
        done < <(get_peers "$target_path")
    fi

    if [ "$show_children" = true ]; then
        while IFS= read -r line; do
            [ -n "$line" ] && children+=("$line")
        done < <(get_children "$target_path")
    fi

    # Check if we have any cells to display
    local total_cells=0
    [ -n "$self_cell" ] && total_cells=$((total_cells + 1))
    [ ${#ancestors[@]} -gt 0 ] && total_cells=$((total_cells + ${#ancestors[@]}))
    [ ${#peers[@]} -gt 0 ] && total_cells=$((total_cells + ${#peers[@]}))
    [ ${#children[@]} -gt 0 ] && total_cells=$((total_cells + ${#children[@]}))

    if [ $total_cells -eq 0 ]; then
        echo "<orient>"
        echo "  <message>No work cells found in current location</message>"
        echo "</orient>"
        exit 0
    fi

    # Compute relative path for display
    local display_path
    if [ "$target_path" = "$project_root" ]; then
        display_path="@project"
    elif [[ "$target_path" == "$project_root"/* ]]; then
        display_path="@project/${target_path#$project_root/}"
    else
        display_path="$target_path"
    fi

    # Print XML output
    local root_attr="@project → $(xml_escape "$project_root")"
    if [ "$work_root" != "$project_root" ]; then
        root_attr="${root_attr}, @tree → $(xml_escape "$work_root")"
    fi
    echo "<orient path=\"$(xml_escape "$display_path")\" expanded=\"$(xml_escape "$target_path")\" root=\"${root_attr}\">"
    echo ""

    # Print sections
    if [ -n "$self_cell" ] && [ "$show_self" = true ]; then
        echo "  <self>"
        print_cell "$self_cell" "$show_discovery" "$show_abstract" "$project_root" "$target_path" "    " "false" "$work_root"
        echo "  </self>"
        echo ""
    fi

    if [ ${#ancestors[@]} -gt 0 ] && [ "$show_ancestors" = true ]; then
        echo "  <ancestry>"
        for ancestor in "${ancestors[@]}"; do
            print_cell "$ancestor" "$show_discovery" "$show_abstract" "$project_root" "$target_path" "    " "false" "$work_root"
        done
        echo "  </ancestry>"
        echo ""
    fi

    if [ ${#peers[@]} -gt 0 ] && [ "$show_peers" = true ]; then
        echo "  <peers>"
        for peer in "${peers[@]}"; do
            print_cell "$peer" "$show_discovery" "$show_abstract" "$project_root" "$target_path" "    " "false" "$work_root"
        done
        echo "  </peers>"
        echo ""
    fi

    if [ ${#children[@]} -gt 0 ] && [ "$show_children" = true ]; then
        echo "  <children>"
        for child in "${children[@]}"; do
            # Pass show_descendants as recursive flag to enable nested children
            print_cell "$child" "$show_discovery" "$show_abstract" "$project_root" "$target_path" "    " "$show_descendants" "$work_root"
        done
        echo "  </children>"
    fi

    echo "</orient>"
}

# Execute main
main "$@"
