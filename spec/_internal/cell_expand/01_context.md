# context

`cell expand` expands `@root` path symbols to absolute paths.

The `@root` symbol expands to CELL_PROJECT_ROOT (the directory containing `cellproject.toml`).

Path formats:
- `@root` → `/absolute/path/to/project/root`
- `@root/subpath` → `/absolute/path/to/project/root/subpath`
- `/absolute/path` → `/absolute/path` (unchanged)
- `relative/path` → `relative/path` (unchanged)

Paths without `@root` symbols pass through unchanged.

# context

Project root is found by walking up directory tree from current directory looking for `cellproject.toml` file.

If `cellproject.toml` not found after reaching filesystem root (`/`), command exits with error code 1 and message: "No cellproject.toml found in directory hierarchy"

# context

Command takes exactly one required argument: the path to expand.

Missing path argument causes exit code 1 with error message: "Missing PATH argument"

# context

The `@root` symbol is consistent across all Context Cell commands and CELL.md file references:
- `cell orient @root` - Orient from project root
- `cell validate @root` - Validate project root
- `cell expand @root/foo` - Expand path relative to root
- File references in CELL.md: `@root/path/to/file.ext`

# context

Exit codes:
- `0` - Success (path expanded or passed through)
- `1` - Error (missing path argument, or @root symbol used but no cellproject.toml found)
