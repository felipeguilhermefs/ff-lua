-- The test suite is driven by **LuaUnit** via `test.lua`. It runs in a clean single pass, preloading all `ff.*` modules directly from the local `src/` tree to prevent installed-rock drift during development.

-- test.lua: Test runner for ff-lua (requires Lua 5.5+)

-------------------------------------------------------------------------------
-- Phase 1: LuaRocks bootstrap
-- Attempt to load the LuaRocks loader so `require("luaunit")` resolves from
-- installed rocks. If it fails (pcall), we fall back to manual path injection.
-------------------------------------------------------------------------------
pcall(require, "luarocks.loader")

-------------------------------------------------------------------------------
-- Phase 2: Fallback path injection
-- When $HOME is set, prepend the user-local LuaRocks tree to package.path
-- and package.cpath. Ensures luaunit (and any C libs) are findable even
-- without the LuaRocks loader active.
-------------------------------------------------------------------------------
local home = os.getenv("HOME") or ""
if home ~= "" then
	package.path = home
		.. "/.luarocks/share/lua/5.5/?.lua;"
		.. home
		.. "/.luarocks/share/lua/5.5/?/init.lua;"
		.. package.path
	package.cpath = home .. "/.luarocks/lib/lua/5.5/?.so;" .. package.cpath
end

-------------------------------------------------------------------------------
-- Phase 3: Lua 5.5 version guard
-- Parse _VERSION and abort early if runtime is below Lua 5.5.
-- Prevents cryptic failures from missing 5.5 features later.
-------------------------------------------------------------------------------
local major, minor = _VERSION:match("Lua (%d+)%.(%d+)")
if not major or tonumber(major) < 5 or (tonumber(major) == 5 and tonumber(minor) < 5) then
	error("ff-lua requires Lua 5.5 or higher. Current version: " .. _VERSION)
end

local lu = require("luaunit")

-------------------------------------------------------------------------------
-- Phase 4: Source path setup
-- Prepend every src/ subdirectory so bare short-name requires like
-- `require("array")` resolve to local source files, not installed rocks.
-------------------------------------------------------------------------------
package.path = "src/?.lua;src/aoc/?.lua;src/cache/?.lua;src/collections/?.lua;src/func/?.lua;src/graph/?.lua;src/iter/?.lua;src/math/?.lua;src/search/?.lua;src/sort/?.lua;src/test/?.lua;"
	.. package.path

-------------------------------------------------------------------------------
-- Phase 5: Preload map (ff.* namespace)
-- Register package.preload loaders for every ff.* namespaced module name,
-- mapping each to its short (bare) name. When test files do
-- `require("ff.func.comparator")`, this forces the local source to load
-- instead of a potentially stale installed rock.
--
-- Derives ff.* preloads from the directory structure so the map stays in
-- sync with the actual source tree automatically.
-- Uses io.popen (platform-dependent) — acceptable for a dev-only runner.
-------------------------------------------------------------------------------
local function build_preloads(dir)
	local handle = io.popen('find "' .. dir .. '" -name "*.lua" ! -name "*_test.lua" | sort')
	if handle then
		for path in handle:lines() do
			-- "src/collections/array.lua" -> module "ff.collections.array", short "array"
			local rel = path:match("^src/(.+)%.lua$")
			if rel then
				local modname = "ff." .. rel:gsub("/", ".")
				local shortname = rel:match("([^/]+)$")
				package.preload[modname] = function()
					return require(shortname)
				end
			end
		end
		handle:close()
	end
end

build_preloads("src")

-------------------------------------------------------------------------------
-- Phase 6: Auto-discover test files
-- Scan src/ tree for *_test.lua files at runtime instead of maintaining a
-- hardcoded list. New test files are picked up automatically.
-- Uses io.popen (platform-dependent) — acceptable for a dev-only runner.
-------------------------------------------------------------------------------
local function discover_tests(dir)
	local files = {}
	local handle = io.popen('find "' .. dir .. '" -name "*_test.lua" | sort')
	if handle then
		for line in handle:lines() do
			files[#files + 1] = line
		end
		handle:close()
	end
	return files
end

local test_files = discover_tests("src")

-------------------------------------------------------------------------------
-- Phase 7: Stub lu.LuaUnit.run and os.exit
-- Each test file calls `lu.LuaUnit.run()` + `os.exit()` at its tail so it
-- can run standalone. During centralized loading via dofile, those calls
-- would trigger premature runs or terminate the process. Replace them with
-- harmless no-ops, then restore after all files are loaded.
-------------------------------------------------------------------------------
local real_run = lu.LuaUnit.run
lu.LuaUnit.run = function()
	return 0
end

local real_exit = os.exit
os.exit = function() end

-------------------------------------------------------------------------------
-- Phase 8: Load all test files
-- dofile executes each file in the current Lua state, populating the global
-- namespace with Test* tables. The stubbed run/exit prevent side effects.
-------------------------------------------------------------------------------
for _, file in ipairs(test_files) do
	dofile(file)
end

-------------------------------------------------------------------------------
-- Phase 9: Restore originals and execute
-- Restore the real lu.LuaUnit.run and os.exit, then invoke a single
-- consolidated test run across all loaded Test* tables. CLI args (e.g.
-- -v, --pattern) are forwarded via table.unpack(arg).
-------------------------------------------------------------------------------
os.exit = real_exit
lu.LuaUnit.run = real_run

os.exit(lu.LuaUnit.run(table.unpack(arg or {})))
