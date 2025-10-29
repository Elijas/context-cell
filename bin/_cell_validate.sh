#!/bin/bash

# cell validate - Validate work cell structure and CELL.md format
# Checks naming convention, required files, and format compliance

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

# Validate work cell directory naming convention
validate_naming() {
    local dir_path="$1"
    local dir_name="$(basename "$dir_path")"

    # Check naming pattern: ^[a-z][a-z0-9_]*_v[0-9]+_[0-9]{2}$
    if [[ "$dir_name" =~ ^[a-z][a-z0-9_]*_v[0-9]+_[0-9]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Check if CELL.md exists and is readable
validate_cell_md_exists() {
    local dir_path="$1"
    local cell_md="$dir_path/CELL.md"

    if [ -f "$cell_md" ] && [ -r "$cell_md" ]; then
        return 0
    else
        return 1
    fi
}

# Validate YAML frontmatter format and work_complete field
validate_yaml_frontmatter() {
    local cell_md="$1"
    local first_line
    local in_frontmatter=false
    local found_closing=false
    local found_work_complete=false
    local line_num=0
    local work_complete_value=""

    # Read file line by line
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Check first line
        if [ $line_num -eq 1 ]; then
            if [ "$line" != "---" ]; then
                error_message="YAML frontmatter missing: first line must be '---'"
                return 1
            fi
            in_frontmatter=true
            continue
        fi

        # Look for closing delimiter
        if [ "$in_frontmatter" = true ] && [ "$line" = "---" ]; then
            found_closing=true
            break
        fi

        # Check for work_complete field
        if [ "$in_frontmatter" = true ] && [[ "$line" =~ ^work_complete:[[:space:]]* ]]; then
            found_work_complete=true
            work_complete_value=$(echo "$line" | awk -F: '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        fi
    done < "$cell_md"

    # Validate frontmatter structure
    if [ "$found_closing" = false ]; then
        error_message="YAML frontmatter malformed: missing closing '---' delimiter"
        return 1
    fi

    if [ "$found_work_complete" = false ]; then
        error_message="YAML frontmatter missing required field: work_complete"
        return 1
    fi

    # Validate work_complete value
    if [ "$work_complete_value" != "true" ] && [ "$work_complete_value" != "false" ]; then
        error_message="YAML frontmatter invalid: work_complete must be 'true' or 'false', got '$work_complete_value'"
        return 1
    fi

    return 0
}

# Extract section headings with line numbers
extract_sections() {
    local cell_md="$1"

    # Find all level-1 headings (# SECTION_NAME)
    grep -n "^# [A-Z]" "$cell_md" 2>/dev/null
}

# Validate all required sections are present
validate_sections_present() {
    local sections="$1"
    local required_sections=("DISCOVERY" "ABSTRACT" "FULL_RATIONALE" "FULL_IMPLEMENTATION" "LOG")
    local missing_sections=()

    # Check each required section
    for section in "${required_sections[@]}"; do
        if ! echo "$sections" | grep -q "^[0-9]*:# $section$"; then
            missing_sections+=("$section")
        fi
    done

    # Report missing sections
    if [ ${#missing_sections[@]} -gt 0 ]; then
        error_message="Missing required section(s): ${missing_sections[*]}"
        return 1
    fi

    return 0
}

# Validate sections appear in correct order
validate_sections_order() {
    local sections="$1"
    local expected_order=("DISCOVERY" "ABSTRACT" "FULL_RATIONALE" "FULL_IMPLEMENTATION" "LOG")
    local prev_line=0
    local out_of_order=()

    # Check each section appears after the previous one
    for section in "${expected_order[@]}"; do
        local line_info=$(echo "$sections" | grep "^[0-9]*:# $section$" | head -1)

        if [ -n "$line_info" ]; then
            local curr_line=$(echo "$line_info" | cut -d: -f1)

            if [ "$curr_line" -lt "$prev_line" ]; then
                out_of_order+=("$section")
            fi

            prev_line=$curr_line
        fi
    done

    # Report ordering issues
    if [ ${#out_of_order[@]} -gt 0 ]; then
        error_message="Section(s) out of order: ${out_of_order[*]}"
        return 1
    fi

    return 0
}

# Validate DISCOVERY section appears within first 12 lines
validate_discovery_position() {
    local cell_md="$1"

    # Find DISCOVERY line number
    local discovery_line=$(grep -n "^# DISCOVERY$" "$cell_md" | cut -d: -f1 | head -1)

    if [ -z "$discovery_line" ]; then
        # This should have been caught by validate_sections_present
        error_message="DISCOVERY section not found"
        return 1
    fi

    if [ "$discovery_line" -gt 12 ]; then
        error_message="DISCOVERY section must appear within first 12 lines (found at line $discovery_line)"
        return 1
    fi

    return 0
}

# Help function
show_help() {
  cat << 'EOF'
Usage: cell validate PATH

Validate work cell structure and CELL.md format compliance.

PATH (required):
  .                Current directory
  @root            Project root (first ancestral folder with cellproject.toml)
  path/to/cell     Specific work cell directory

VALIDATION RULES:
  1. Naming convention: {branch}_v{version}_{step}
     - Example: auth_v1_01
     - Must start with lowercase letter
     - Can contain lowercase letters, numbers, underscores
     - Must end with _v{number}_{two-digit-number}

  2. Required file: CELL.md must exist

  3. YAML frontmatter must contain work_complete field
     - Must start with --- on line 1
     - Must have closing --- delimiter
     - Must contain: work_complete: true or work_complete: false

  4. Required sections in strict order:
     - DISCOVERY (must appear within first 12 lines)
     - ABSTRACT
     - FULL_RATIONALE
     - FULL_IMPLEMENTATION
     - LOG

EXAMPLES:
  cell validate .                  # Validate current directory
  cell validate @root              # Validate project root
  cell validate path/to/cell       # Validate specific cell

EXIT CODES:
  0 - Valid work cell
  1 - Validation failed or error occurred (including missing path argument)
EOF
  exit 0
}

# Main function
main() {
    local path_arg=""
    local error_message=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                ;;
            @root)
                path_arg="@root"
                shift
                ;;
            -*)
                echo "Error: Unknown option: $1" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
            *)
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

    # Handle @root symbol: expand to project root before validating path
    if [ "$path_arg" = "@root" ]; then
        # Find project root from current directory
        local temp_root=$(find_project_root "$(pwd)")
        if [ -z "$temp_root" ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        path_arg="$temp_root"
    elif [[ "$path_arg" == @root/* ]]; then
        # Handle @root/subpath syntax
        local temp_root=$(find_project_root "$(pwd)")
        if [ -z "$temp_root" ]; then
            echo "Error: No cellproject.toml found in directory hierarchy" >&2
            exit 1
        fi
        # Replace @root with actual root path
        path_arg="${temp_root}/${path_arg#@root/}"
    fi

    # Resolve path
    local target_path=""
    if [ ! -e "$path_arg" ]; then
        echo "Error: Path does not exist: $path_arg" >&2
        exit 1
    fi
    if [ ! -d "$path_arg" ]; then
        echo "Error: Path is not a directory: $path_arg" >&2
        exit 1
    fi
    target_path=$(cd "$path_arg" && pwd)

    # Collect validation errors
    local errors=()
    local cell_name="$(basename "$target_path")"

    # Validate naming convention
    if ! validate_naming "$target_path"; then
        errors+=("Invalid naming convention: must match {branch}_v{version}_{step} (e.g., auth_v1_01)")
    fi

    # Validate CELL.md exists
    if ! validate_cell_md_exists "$target_path"; then
        errors+=("Missing required file: CELL.md")
        # Can't do further validation without CELL.md
    else
        local cell_md="$target_path/CELL.md"

        # Validate YAML frontmatter
        if ! validate_yaml_frontmatter "$cell_md"; then
            errors+=("$error_message")
        fi

        # Extract sections
        local sections=$(extract_sections "$cell_md")

        # Validate sections presence
        if ! validate_sections_present "$sections"; then
            errors+=("$error_message")
        fi

        # Validate sections order
        if ! validate_sections_order "$sections"; then
            errors+=("$error_message")
        fi

        # Validate DISCOVERY position
        if ! validate_discovery_position "$cell_md"; then
            errors+=("$error_message")
        fi
    fi

    # Output results
    if [ ${#errors[@]} -eq 0 ]; then
        echo "✓ $cell_name/ - Valid work cell"
        exit 0
    else
        for error in "${errors[@]}"; do
            echo "✗ $cell_name/ - $error"
        done
        exit 1
    fi
}

# Execute main
main "$@"
