# context

`cell expand` expands `@project` path symbols to absolute paths.

The `@project` symbol expands to PROJECT_ROOT (the directory containing `projectroot.toml`).

Path formats:
- `@project` → `/absolute/path/to/project/root`
- `@project/subpath` → `/absolute/path/to/project/root/subpath`
- `/absolute/path` → `/absolute/path` (unchanged)
- `relative/path` → `relative/path` (unchanged)

Paths without `@project` symbols pass through unchanged.

# context

Project root is found by walking up directory tree from current directory looking for `projectroot.toml` file.

If `projectroot.toml` not found after reaching filesystem root (`/`), command exits with error code 1 and message: "No projectroot.toml found in directory hierarchy"

# context

Command takes exactly one required argument: the path to expand.

Missing path argument causes exit code 1 with error message: "Missing PATH argument"

# context

The `@project` symbol is consistent across all Context Cell commands and CELL.md file references:
- `cell orient @project` - Orient from project root
- `cell validate @project` - Validate project root
- `cell expand @project/foo` - Expand path relative to root
- File references in CELL.md: `@project/path/to/file.ext`

# context

Exit codes:
- `0` - Success (path expanded or passed through)
- `1` - Error (missing path argument, or @project symbol used but no projectroot.toml found)
