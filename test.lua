-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- This test suite powered by [LuaUnit](https://github.com/bluebird75/luaunit).
--
-- 4 Characteristics:
--
-- 1. Rockspec-Driven: Runner reads the project rockspec in an isolated sandbox.
--
-- 2. Version Enforcement: Lua interpreter checked against declared minimum
-- version.
--
-- 3. Dynamic Preload: Modules mapped in the rockspec are preloaded, so tests
-- run against source tree and does not require installing.
--
-- 4. Automatic Test Discovery: Discovers and loads test suites colocated with
-- source files.
--
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- Enable LuaRocks module resolution so installed dependencies (such as
-- luaunit) can be loaded via require().
require("luarocks.loader")

-----------------------------------------------------------------------------
-- Cache function references
-----------------------------------------------------------------------------

-- String
local fmt = string.format

-- Table
local append = table.insert
local unpack = table.unpack

-----------------------------------------------------------------------------
---Loads and validates the rockspec manifest in an isolated environment.
---
---We load the rockspec into an empty sandbox table (`env`) to capture these
---declarations without polluting the global environment `_G`.
---
---@param filename string Path to the .rockspec file.
---
---@return table env Table containing the parsed rockspec declarations.
-----------------------------------------------------------------------------
local function loadrockspec(filename)
	if filename == nil or filename == "" then
		error("missing rockspec file name")
	end

	-- Isolated environment table to capture rockspec globals
	local env = {}

	-- Load the rockspec chunk in text-only mode ("t") using env as its _ENV
	local load, err = loadfile(filename, "t", env)
	if load == nil or err then
		error(fmt("could not load rockspec %s: %s.", filename, err))
	end

	-- Execute the rockspec chunk to populate the env table
	load()

	-- Validate structural requirements needed by this test harness
	if type(env.build) ~= "table" then
		error(fmt("rockspec '%s' has no 'build' table", filename))
	end

	if type(env.build.modules) ~= "table" then
		error(fmt("rockspec '%s' has no 'build.modules' table", filename))
	end

	if next(env.build.modules) == nil then
		error(fmt("rockspec %s has no build.modules entries", filename))
	end

	if type(env.dependencies) ~= "table" then
		error(fmt("rockspec '%s' has no 'dependencies' table", filename))
	end

	if next(env.dependencies) == nil then
		error(fmt("rockspec %s has no dependency entries", filename))
	end

	return env
end

-- Read the rockspec file passed as the first command-line argument
local rockspec = loadrockspec(arg and arg[1])

-----------------------------------------------------------------------------
---Validates that the host Lua runtime satisfies the version required by the rockspec.
---
---Extracts the minimum version requirement (e.g., 'lua >= 5.5') declared in
---the rockspec dependencies and compares it with the running interpreter's
---`_VERSION`. This fails fast with a clear error before incompatible syntax
---or runtime differences cause obscure test failures.
---
---@param dependencies table Array of dependency strings from the rockspec.
-----------------------------------------------------------------------------
local function checkversion(dependencies)
	local rmajor, rminor

	-- Find the minimum Lua version constraint declaration
	for _, dependency in ipairs(dependencies) do
		rmajor, rminor = dependency:match("^%s*lua%s*>=%s*(%d+)%.(%d+)")
		if rmajor then
			break
		end
	end

	if not rmajor then
		error("rockspec must declare a Lua minimum version as 'lua >= major.minor'")
	end

	rmajor, rminor = tonumber(rmajor), tonumber(rminor)

	-- Parse the current running Lua version from _VERSION ("Lua <major>.<minor>")
	local cmajor, cminor = _VERSION:match("Lua (%d+)%.(%d+)")
	cmajor, cminor = tonumber(cmajor), tonumber(cminor)

	-- Assert current version meets or exceeds the minimum required version
	if cmajor < rmajor or (cmajor == rmajor and cminor < rminor) then
		error(fmt("rockspec requires Lua %d.%d or higher. Current version: %s", rmajor, rminor, _VERSION))
	end
end

-- Verify Lua runtime compatibility before running tests
checkversion(rockspec.dependencies)

-----------------------------------------------------------------------------
-- Framework setup & dynamic module preloading
-----------------------------------------------------------------------------

local lu = require("luaunit")

-- Register each module from rockspec.build.modules into package.preload.
-- This maps the canonical module name (e.g., "ff.collections.array") to its
-- local file path (e.g., "src/collections/array.lua"), allowing tests to
-- require modules normally without installing the package or altering package.path.
for module, srcpath in pairs(rockspec.build.modules) do
	package.preload[module] = function()
		return dofile(srcpath)
	end
end

-----------------------------------------------------------------------------
-- Discover and load test suites
-----------------------------------------------------------------------------

-- Convention: each source file in `src/` has its corresponding test file
-- alongside it with a `_test.lua` suffix (e.g., `array.lua` -> `array_test.lua`).
-- Executing dofile() loads the test functions into global scope for LuaUnit.
for _, srcpath in pairs(rockspec.build.modules) do
	local testpath = srcpath:gsub("%.lua$", "_test.lua")
	dofile(testpath)
end

-----------------------------------------------------------------------------
-- Test execution & CLI argument forwarding
-----------------------------------------------------------------------------

-- Collect command-line arguments beyond arg[1] (which is the rockspec path)
-- to forward to LuaUnit (e.g., -v for verbose, -f for failure-fast, or filters).
local luargs = {}
for i = 2, #arg do
	append(luargs, arg[i])
end

-- Execute the test suite and pass the exit code to the OS for CI/build tracking
os.exit(lu.LuaUnit.run(unpack(luargs)))
