-- The test suite is driven by **LuaUnit** via `test.lua`. It runs in a clean single pass, preloading all `ff.*` modules directly from the local `src/` tree to prevent installed-rock drift during development.

-- test.lua: Test runner for ff-lua (requires Lua 5.5+)

-------------------------------------------------------------------------------
-- Phase 1: LuaRocks bootstrap
-- Load the LuaRocks loader so `require("luaunit")` resolves from installed
-- rocks for the active Lua runtime and platform.
-------------------------------------------------------------------------------
require("luarocks.loader")

-------------------------------------------------------------------------------
-- Phase 2: Lua 5.5 version guard
-- Parse _VERSION and abort early if runtime is below Lua 5.5.
-- Prevents cryptic failures from missing 5.5 features later.
-------------------------------------------------------------------------------
local major, minor = _VERSION:match("Lua (%d+)%.(%d+)")
if not major or tonumber(major) < 5 or (tonumber(major) == 5 and tonumber(minor) < 5) then
	error("ff-lua requires Lua 5.5 or higher. Current version: " .. _VERSION)
end

local lu = require("luaunit")

-------------------------------------------------------------------------------
-- Phase 4: Parses the .rockspec file (valid Lua) to extract build.modules.
-- Used by both preload registration and test discovery to keep test.lua in
-- exact sync with the rockspec — the single source of truth for module names.
-------------------------------------------------------------------------------
local function load_rockspec_modules()
	local handle = assert(io.popen("ls *.rockspec 2>/dev/null"), "could not list rockspec files")
	local rockspec_file = handle:read("*l")
	handle:close()

	assert(rockspec_file, "no .rockspec file found in the current directory")

	-- Load rockspec in a sandbox — it assigns globals like build, package, etc.
	local env = {}
	local load_rockspec, err = loadfile(rockspec_file, "t", env)
	assert(load_rockspec, "could not load rockspec " .. rockspec_file .. ": " .. tostring(err))

	load_rockspec()

	local modules = env.build and env.build.modules
	assert(next(modules) ~= nil, "rockspec " .. rockspec_file .. " has no build.modules entries")

	return modules
end

local rockspec_modules = load_rockspec_modules()

-------------------------------------------------------------------------------
-- Phase 4: Register package.preload from rockspec
-- Maps each rockspec module name (e.g. "ff.collections.array") to a preload
-- that loads the source file directly via dofile. Keeps
-- require("ff.collections.array") working against local sources without
-- installation.
-------------------------------------------------------------------------------
for modname, srcpath in pairs(rockspec_modules) do
	package.preload[modname] = function()
		return dofile(srcpath)
	end
end

-------------------------------------------------------------------------------
-- Phase 5: Discover test files from rockspec
-- Derives colocated test file paths from the rockspec build.modules table.
-- Each module "src/<path>/<name>.lua" maps to "src/<path>/<name>_test.lua".
-------------------------------------------------------------------------------
local function discover_tests(modules)
	local files = {}
	if not modules then
		return files
	end

	for _, srcpath in pairs(modules) do
		local testpath = srcpath:gsub("%.lua$", "_test.lua")
		local fh = io.open(testpath)
		if fh then
			fh:close()
			files[#files + 1] = testpath
		end
	end

	assert(#files > 0, "no test files discovered from rockspec modules; expected colocated *_test.lua files")

	return files
end

local test_files = discover_tests(rockspec_modules)

-------------------------------------------------------------------------------
-- Phase 6: Load all test files
-- dofile executes each file in the current Lua state, populating the global
-- namespace with Test* tables.
-------------------------------------------------------------------------------
for _, file in ipairs(test_files) do
	dofile(file)
end

-------------------------------------------------------------------------------
-- Phase 7: Execute
-- Invoke a single consolidated test run across all loaded Test* tables.
-- CLI args (e.g. -v, --pattern) are forwarded via table.unpack(arg).
-------------------------------------------------------------------------------
os.exit(lu.LuaUnit.run(table.unpack(arg or {})))
