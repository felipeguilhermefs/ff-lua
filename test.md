# `test.lua` — Analysis Report

### What it does, step by step

| Lines | Phase | Purpose |
|-------|-------|---------|
| 1–4 | **LuaRocks bootstrap** | Attempts to load the LuaRocks loader so `require("luaunit")` can resolve from installed rocks. |
| 6–14 | **Fallback path injection** | If `$HOME` is set, prepends the user-local LuaRocks tree (`~/.luarocks/share/lua/5.5/`) to `package.path` and `package.cpath`. Ensures `luaunit` is findable even without the LuaRocks loader. |
| 16–19 | **Lua 5.5 version guard** | Parses `_VERSION`, errors if runtime is below Lua 5.5. |
| 21 | **LuaUnit require** | Loads the test framework. |
| 23–25 | **Source path setup** | Prepends every `src/` subdirectory to `package.path` so bare `require("array")`, `require("lru")`, etc. resolve to local source files. |
| 28–73 | **Preload map** | Registers `package.preload` loaders for all `ff.*` namespaced module names, mapping them to their short names. This ensures that when test files do `require("ff.func.comparator")`, the local source is loaded — not an installed rock. |
| 75–102 | **Test file list** | Hardcoded ordered list of all 26 test files. |
| 105–108 | **Stub `lu.LuaUnit.run`** | Replaces `run()` with a no-op returning 0. Each test file calls `lu.LuaUnit.run()` at its bottom for standalone execution; the stub prevents each `dofile` from triggering a premature suite run. |
| 110–111 | **Stub `os.exit`** | Same idea — prevents test files from exiting the process during load. |
| 113–115 | **Load all test files** | `dofile` executes each test file, which defines global `Test*` tables and registers test functions into the LuaUnit namespace. |
| 117–118 | **Restore originals** | Puts `os.exit` and `lu.LuaUnit.run` back. |
| 120 | **Single run** | Calls `lu.LuaUnit.run()` once with CLI args, exits with its return code. |

### Design rationale

The two-phase load-then-run design lets every test file work both standalone (`lua src/collections/array_test.lua`) and as part of the full suite (`lua test.lua` / `make test`). The preload map prevents "installed-rock drift" — a stale installed version of `ff-lua` being picked up instead of the working copy.

---

## 2. Bugs

### 2.1 Preload/rockspec desync (medium severity)

`test.lua` preloads 9 module aliases that **do not exist in the rockspec**:

| Preload key in `test.lua` | Present in rockspec? |
|---|---|
| `ff.func.empty` | ❌ |
| `ff.func.head` | ❌ |
| `ff.func.memoize` | ❌ |
| `ff.func.tail` | ❌ |
| `ff.math.factorial` | ❌ |
| `ff.math.fibonacci` | ❌ |
| `ff.math.max` | ❌ |
| `ff.math.min` | ❌ |
| `ff.math.trunc` | ❌ |

**Impact**: Tests pass against module names that consumers can't actually `require` from an installed rock. If a test file starts using `require("ff.math.max")`, it would pass locally but fail for users. This is a "false green" — tests are more permissive than the real package.

**Fix**: Either:
- **Remove** these phantom preloads from `test.lua`, or
- **Add** the missing aliases to the rockspec (if they're intended public API).

### 2.2 No bug: `graph.lua` has no tests (observation)

`ff.graph` is preloaded and shipped in the rockspec but has zero test coverage. Not a bug in `test.lua` per se, but the runner silently skips it since there's no `graph_test.lua`.

---

## 3. Possible Improvements

### 3.3 Protect `dofile` with `pcall` for better error reporting

If a single test file has a syntax error, the runner crashes without loading the rest. Wrapping in `pcall` gives clearer diagnostics and loads remaining files.

```lua
local failures = {}
for _, file in ipairs(test_files) do
    local ok, err = pcall(dofile, file)
    if not ok then
        io.stderr:write("ERROR loading " .. file .. ": " .. tostring(err) .. "\n")
        failures[#failures + 1] = file
    end
end

if #failures > 0 then
    io.stderr:write(#failures .. " test file(s) failed to load\n")
end
```

### 3.4 Use `table.pack`/unpack guard for `arg`

Line 120 does `table.unpack(arg or {})`. In Lua 5.5, `arg` is guaranteed for the main chunk, but adding a nil-safe guard is good hygiene and already done via `or {}`. No change needed, but `table.pack` could be used if args need count preservation:

```lua
-- Current (fine for this use case):
os.exit(lu.LuaUnit.run(table.unpack(arg or {})))
```

### 3.5 Add `package.path` for `src/graph/` consistency

Line 24 lists every subdirectory of `src/` explicitly. The `src/graph/` directory is included, but `src/test/` is also included. If new subdirectories are added under `src/`, they must be manually added here. This pairs with improvement 3.2 — a directory scan eliminates both problems.

---

## Summary

| Category | Item | Severity |
|----------|------|----------|
| 🐛 Bug | Preload/rockspec desync (9 phantom aliases) | Medium |
| 📝 Observation | `graph.lua` has no test coverage | Low |
| 🔧 Improvement | `pcall` wrapper around `dofile` | Low effort, low-medium value |
