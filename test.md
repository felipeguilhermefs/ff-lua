# `test.lua` Review

## Purpose

`test.lua` is the LuaUnit entry point used by the LuaRocks test command. It checks for Lua 5.5+, loads package modules from the local source tree using the rockspec module map, discovers colocated test files, loads them, then runs LuaUnit once. Its comments describe this as preventing installed-rock drift during development.

## Execution flow

1. Attempts `require("luarocks.loader")` under `pcall`. Failure is ignored so the runner can continue with manual paths.
2. If `HOME` exists, prepends user-local LuaRocks Lua and C module paths. These paths are specifically for Lua 5.5.
3. Parses `_VERSION` and errors when runtime is older than Lua 5.5 or version parsing fails.
4. Loads `luaunit`.
5. Runs `ls *.rockspec` through `io.popen`, reads the first returned filename, and loads that file with `loadfile(..., "t", env)`. The rockspec is evaluated in a separate environment; `build.modules` is returned.
6. Registers each rockspec module in `package.preload`. Requiring the module runs `dofile` on its source path, so tests use checked-out files rather than installed module copies.
7. Maps each module source path ending in `.lua` to a sibling `_test.lua`, including only files that can be opened.
8. `pcall(dofile, file)` loads each discovered test file. Load errors are printed and recorded; loading continues.
9. Calls `lu.LuaUnit.run(table.unpack(arg or {}))` once and passes its result to `os.exit`. LuaUnit receives command-line options such as `-f` and `-s`.

## Findings

### Medium: fallback paths contradict the declared Lua version range

The guard and rockspec accept Lua 5.5 and newer, but manual fallback paths are fixed to `lua/5.5` and `.so`. On a newer Lua version, when LuaRocks loader does not make `luaunit` available, the fallback searches the wrong version directory; `.so` is also platform-specific. This can prevent valid runtimes from running tests.

**Improvement:** derive Lua path suffix from the active runtime and account for platform C-module extensions, or rely on LuaRocks' loader and emit a clear dependency error when it is unavailable.

### Medium: runner depends on shell and current working directory

The `ls *.rockspec` subprocess assumes a shell, Unix-style command behavior, and execution from the repository root. `dofile(srcpath)` and test discovery also use paths relative to the current directory. Running `test.lua` from another directory can silently discover nothing or fail to load files. `io.popen` may also be unavailable in restricted Lua builds.

**Improvement:** avoid shell-based file discovery; resolve paths from the script's own location (for example, using `debug.getinfo`) or have the build tool pass the rockspec path explicitly. Fail clearly if invocation is outside a supported layout.

### Medium: multiple rockspec selection is unspecified

The shell glob may return multiple files, but the runner reads only the first line. Which rockspec is first can depend on environment and filesystem sorting. A stale or unrelated rockspec may drive both preload registration and test discovery.

**Improvement:** require exactly one matching rockspec, or accept an explicit rockspec filename from the caller.

### Low: ordering is nondeterministic

Modules are registered and tests discovered by iterating `build.modules` with `pairs`, so test files load in unspecified order. The Makefile also passes LuaUnit's shuffle option (`-s`), further varying execution order. Shuffling can expose order-dependent tests, but nondeterministic load order can make debugging and output harder to reproduce.

**Improvement:** sort module names or source paths before loading. Keep shuffle as an explicit CI/developer option, and allow a reproducible seed if the LuaUnit version supports it.

### Low: errors in test loading are split across stderr and LuaUnit output

Load failures are written to stderr, while test results come from LuaUnit. The summary only gives a count; individual filenames appear in preceding error messages. Include failed paths in the final summary for easier log scanning.

## Strengths

- Uses the rockspec module map as one source for local module preloading and colocated test discovery.
- Keeps installed versions from masking local source changes during development.
- Continues loading other test files after one fails, which can expose more failures in one run.
- Performs the Lua version check before loading LuaUnit or project tests.
- Forwards LuaUnit command-line arguments instead of hard-coding runner options.

## Suggested priority

1. Make rockspec and source paths independent of the shell and current working directory.
2. Support Lua 5.6+ in fallback dependency paths.
3. Require exactly one rockspec or accept an explicit rockspec path.
4. Sort discovery and include failed test paths in the final load-error summary.
