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
-- 4. Module-Scoped Test Discovery: Runs every suite returned by one colocated
-- test module, or all test modules when no module name is supplied.
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

-----------------------------------------------------------------------------
---Loads and validates the rockspec manifest in an isolated environment.
---
---We load the rockspec into an empty sandbox table (`env`) to capture these
---declarations without polluting the global environment `_G`.
---
---@param filename string Path to the .rockspec file.
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

local rockspec_path = arg and arg[1]
local selected_module = arg and arg[2]
if rockspec_path == nil or rockspec_path == "" or selected_module == "" or (arg and arg[3] ~= nil) then
	error("usage: lua test.lua <rockspec> [module]")
end

local rockspec = loadrockspec(rockspec_path)
if selected_module and rockspec.build.modules[selected_module] == nil then
	error(fmt("module '%s' not found in rockspec %s", selected_module, rockspec_path))
end

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
-- Discover and load modular test suites
-----------------------------------------------------------------------------

-- Convention: each source file in `src/` has its corresponding test file
-- alongside it with a `_test.lua` suffix (e.g., `array.lua` -> `array_test.lua`).
-- Each test module returns a map from suite name to suite table. Empty test
-- modules return an empty map.
local suites = {}
local suite_sources = {}

local function register_suite(name, suite, testpath)
	if type(name) ~= "string" or not name:match("^Test") then
		error(fmt("invalid test suite name in %s: %s", testpath, tostring(name)))
	end

	if type(suite) ~= "table" then
		error(fmt("test suite %s in %s should return a table", name, testpath))
	end

	if suite_sources[name] then
		error(fmt("duplicate test suite name '%s' in %s (already declared in %s)", name, testpath, suite_sources[name]))
	end

	suite_sources[name] = testpath
	append(suites, { name, suite })
end

local modules_to_test = {}
for module, srcpath in pairs(rockspec.build.modules) do
	if selected_module == nil or module == selected_module then
		append(modules_to_test, { module, srcpath })
	end
end
table.sort(modules_to_test, function(a, b)
	return a[1] < b[1]
end)

for _, module_entry in ipairs(modules_to_test) do
	local testpath = module_entry[2]:gsub("%.lua$", "_test.lua")
	local chunk, err = loadfile(testpath)
	if chunk == nil then
		error(fmt("could not load test file %s: %s", testpath, err))
	end

	local suite_map = chunk()
	if type(suite_map) ~= "table" then
		error(fmt("test file %s should return a suite map", testpath))
	end

	for name, suite in pairs(suite_map) do
		register_suite(name, suite, testpath)
	end
end

table.sort(suites, function(a, b)
	return a[1] < b[1]
end)

-----------------------------------------------------------------------------
-- Test execution
-----------------------------------------------------------------------------

-- Run explicitly registered instances so LuaUnit never needs to inspect _G.
local exitcode = lu.LuaUnit.new():runSuiteByInstancesNoCmdLineParsing(suites)
os.exit(exitcode)
