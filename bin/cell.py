#!/usr/bin/env python3
"""
Context Cell CLI - main dispatcher for cell commands
"""
import subprocess
import sys
from pathlib import Path


def orient(*args):
    """Show work cell structure via _cell_orient.sh with all arguments passed through

    Usage:
        cell orient [args...]  - Show work cell structure with optional arguments
    """
    # Handle help flag
    if args and args[0] in ["--help", "-h"]:
        # Let the script handle help
        pass

    # Get the directory where this script is located (resolve symlinks)
    script_dir = Path(__file__).resolve().parent
    orient_path = script_dir / "_cell_orient.sh"

    if not orient_path.exists():
        print(
            f"Error: _cell_orient.sh not found at {orient_path}", file=sys.stderr
        )
        sys.exit(1)

    # Execute _cell_orient.sh with all arguments
    try:
        result = subprocess.run([str(orient_path)] + list(args), check=False)
        sys.exit(result.returncode)
    except Exception as e:
        print(f"Error running orient: {e}", file=sys.stderr)
        sys.exit(1)


def validate(*args):
    """Validate work cell structure via _cell_validate.sh with all arguments passed through

    Usage:
        cell validate [args...]  - Validate work cell structure and metadata
    """
    # Handle help flag
    if args and args[0] in ["--help", "-h"]:
        # Let the script handle help
        pass

    # Get the directory where this script is located (resolve symlinks)
    script_dir = Path(__file__).resolve().parent
    validate_path = script_dir / "_cell_validate.sh"

    if not validate_path.exists():
        print(
            f"Error: _cell_validate.sh not found at {validate_path}", file=sys.stderr
        )
        sys.exit(1)

    # Execute _cell_validate.sh with all arguments
    try:
        result = subprocess.run([str(validate_path)] + list(args), check=False)
        sys.exit(result.returncode)
    except Exception as e:
        print(f"Error running validate: {e}", file=sys.stderr)
        sys.exit(1)


def claude(*args):
    """Launch Claude via claude_launcher.sh with all arguments passed through

    Usage:
        cell claude [args...]  - Launch Claude with optional arguments
    """
    # Handle help flag (only --help, let -h pass through to claude_launcher)
    if args and args[0] == "--help":
        print(claude.__doc__)
        return

    # Get the directory where this script is located (resolve symlinks)
    script_dir = Path(__file__).resolve().parent
    launcher_path = script_dir / "claude_launcher.sh"

    if not launcher_path.exists():
        print(
            f"Error: claude_launcher.sh not found at {launcher_path}", file=sys.stderr
        )
        sys.exit(1)

    # Execute claude_launcher.sh with all arguments
    try:
        result = subprocess.run([str(launcher_path)] + list(args), check=False)
        sys.exit(result.returncode)
    except Exception as e:
        print(f"Error launching claude: {e}", file=sys.stderr)
        sys.exit(1)


def spec(*args):
    """Output complete Context Cell framework specification via _cell_spec.sh

    Usage:
        cell spec [args...]  - Output complete framework specification
    """
    # Handle help flag
    if args and args[0] in ["--help", "-h"]:
        # Let the script handle help
        pass

    # Get the directory where this script is located (resolve symlinks)
    script_dir = Path(__file__).resolve().parent
    spec_path = script_dir / "_cell_spec.sh"

    if not spec_path.exists():
        print(
            f"Error: _cell_spec.sh not found at {spec_path}", file=sys.stderr
        )
        sys.exit(1)

    # Execute _cell_spec.sh with all arguments
    try:
        result = subprocess.run([str(spec_path)] + list(args), check=False)
        sys.exit(result.returncode)
    except Exception as e:
        print(f"Error running spec: {e}", file=sys.stderr)
        sys.exit(1)


def expand(*args):
    """Expand @root path symbol via _cell_expand.sh

    Usage:
        cell expand <path>  - Expand @root symbols to absolute paths
    """
    # Handle help flag
    if args and args[0] in ["--help", "-h"]:
        # Let the script handle help
        pass

    # Get the directory where this script is located (resolve symlinks)
    script_dir = Path(__file__).resolve().parent
    expand_path = script_dir / "_cell_expand.sh"

    if not expand_path.exists():
        print(
            f"Error: _cell_expand.sh not found at {expand_path}", file=sys.stderr
        )
        sys.exit(1)

    # Execute _cell_expand.sh with all arguments
    try:
        result = subprocess.run([str(expand_path)] + list(args), check=False)
        sys.exit(result.returncode)
    except Exception as e:
        print(f"Error running expand: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) == 1 or sys.argv[1] in ["--help", "-h", "help"]:
        # Default: show help
        print("Usage: cell [COMMAND] [args...]")
        print()
        print("Commands:")
        print("  orient [flags...] PATH    - Show work cell structure with composable flags")
        print("  validate PATH             - Validate work cell structure and metadata")
        print("  claude [...]              - Launch Claude via claude_launcher.sh")
        print("  spec [--path P]           - Output complete framework specification")
        print("  expand <path>             - Expand @root path symbol to absolute path")
        print()
        print("Use 'cell COMMAND --help' for more information on a command.")
    elif sys.argv[1] == "orient":
        # Pass all remaining arguments to orient
        orient(*sys.argv[2:])
    elif sys.argv[1] == "validate":
        # Pass all remaining arguments to validate
        validate(*sys.argv[2:])
    elif sys.argv[1] == "claude":
        # Pass all arguments after 'claude' to the launcher
        claude(*sys.argv[2:])
    elif sys.argv[1] == "spec":
        # Pass all arguments after 'spec' to spec
        spec(*sys.argv[2:])
    elif sys.argv[1] == "expand":
        # Pass all arguments after 'expand' to expand
        expand(*sys.argv[2:])
    else:
        print(f"Unknown command: {sys.argv[1]}")
        print()
        print("Usage: cell [COMMAND] [args...]")
        print()
        print("Use 'cell --help' for more information.")
