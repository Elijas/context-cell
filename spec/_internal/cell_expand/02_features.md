# feature_001

Running `cell expand @project` prints the absolute path to project root.

Project root is the directory containing `cellproject.toml`, found by walking up from current directory.

Output is single line with absolute path, no trailing slash, no additional whitespace.

**Test**: Create test hierarchy with `cellproject.toml` at root. Run `cell expand @project` from various subdirectories. Verify output is correct absolute path to project root.

# feature_002

Running `cell expand @project/subpath` expands to absolute path.

The `@project` prefix is replaced with project root path, then `/subpath` is appended.

Output format: `/absolute/path/to/project/root/subpath`

**Test**: Create test hierarchy with `cellproject.toml`. Run `cell expand @project/cell_v1_01` from various locations. Verify output is correct absolute path with `@project` expanded.

# feature_003

Paths not starting with `@project` pass through unchanged.

Absolute paths (starting with `/`), relative paths, and any other format output exactly as provided.

**Test**: Run `cell expand /usr/local/bin` and verify output is `/usr/local/bin`. Run `cell expand relative/path` and verify output is `relative/path`. Run `cell expand ./foo/bar` and verify output is `@this/foo/bar`.

# feature_004

Missing path argument causes error.

Exit code 1 with stderr message: "Missing PATH argument"

**Test**: Run `cell expand` with no arguments. Verify exit code 1 and correct error message on stderr.

# feature_005

Using `@project` symbol when no `cellproject.toml` exists causes error.

Exit code 1 with stderr message: "No cellproject.toml found in directory hierarchy"

**Test**: Create temporary directory without `cellproject.toml`. Run `cell expand @project` from that directory. Verify exit code 1 and correct error message.

# feature_006

Non-`@project` paths work even without `cellproject.toml`.

Since these paths don't require project root lookup, they succeed and pass through unchanged.

**Test**: Create temporary directory without `cellproject.toml`. Run `cell expand /absolute/path` and `cell expand relative/path`. Verify both succeed with exit code 0 and output unchanged paths.

# feature_007

`@project` expansion works from any subdirectory depth.

Project root discovery walks up arbitrary number of parent directories until `cellproject.toml` found.

**Test**: Create hierarchy with `cellproject.toml` at root and deeply nested subdirectories (5+ levels). Run `cell expand @project` from deepest subdirectory. Verify correct project root path returned.

# feature_008

`@project` with complex subpaths preserves path structure.

Paths like `@project/a/b/c/d.txt` expand correctly with all path components preserved.

**Test**: Run `cell expand @project/auth_v1_01/testing_v1_02/_outputs/results.json`. Verify full path structure preserved in expansion.

# feature_009

Help flag shows usage information.

`cell expand --help` or `cell expand -h` displays usage information and exits with code 0.

**Test**: Run `cell expand --help`. Verify exit code 0 and help text appears containing usage information, path formats, and examples.

# feature_010

Shell command substitution integration works correctly.

Output format (no trailing newline issues, no extra whitespace) is suitable for use with `$(cell expand ...)` in shell commands.

**Test**: Run `cd $(cell expand @project)` and verify directory change succeeds. Run `ls $(cell expand @project)` and verify command executes successfully. Confirm no whitespace issues cause command failures.
