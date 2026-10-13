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
---@param filepath string Path to the .rockspec file.
---
---@return table env Table containing the parsed rockspec declarations.
-----------------------------------------------------------------------------
local function loadRockspec(filepath)
	if filepath == nil or not filepath:match("rockspec$") then
		error(fmt("rockspec '%s' not found", filepath))
	end

	local env = {}

	-- Load the rockspec chunk in text-only mode ("t") using env as its _ENV
	local load, err = loadfile(filepath, "t", env)
	if load == nil or err then
		error(fmt("could not load rockspec %s: %s.", filepath, err))
	end

	-- Execute the rockspec chunk to populate the env table
	load()

	-- Validate structural requirements needed by this test harness
	if type(env.build) ~= "table" then
		error(fmt("rockspec '%s' has no 'build' table", filepath))
	end

	if type(env.build.modules) ~= "table" then
		error(fmt("rockspec '%s' has no 'build.modules' table", filepath))
	end

	if next(env.build.modules) == nil then
		error(fmt("rockspec '%s' has no build.modules entries", filepath))
	end

	if type(env.dependencies) ~= "table" then
		error(fmt("rockspec '%s' has no 'dependencies' table", filepath))
	end

	if next(env.dependencies) == nil then
		error(fmt("rockspec '%s' has no dependency entries", filepath))
	end

	return env
end

local rockspec = loadRockspec(arg and arg[1])

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
local function checkVersion(dependencies)
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
checkVersion(rockspec.dependencies)

-----------------------------------------------------------------------------
-- Framework setup & dynamic module preloading
-----------------------------------------------------------------------------

local lu = require("luaunit")

-----------------------------------------------------------------------------
---Register each module from rockspec.build.modules into package.preload.
---
-- This maps the canonical module name (e.g., "ff.collections.array") to its
-- local file path (e.g., "src/collections/array.lua"), allowing tests to
-- require modules normally without installing the package or altering package.path.
---
---@param modules table Map of module name to source file defined in the rockspec.
-----------------------------------------------------------------------------
local function registerModules(modules)
	for module, srcpath in pairs(modules) do
		package.preload[module] = function()
			return dofile(srcpath)
		end
	end
end

registerModules(rockspec.build.modules)

-----------------------------------------------------------------------------
-- Discover and load modular test suites
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
---Register each module from rockspec.build.modules into package.preload.
---
-- Convention: each source file in `src/` has its corresponding test file
-- alongside it with a `_test.lua` suffix (e.g., `array.lua` -> `array_test.lua`).
-- Each test module returns a map from suite name to suite table. Empty test
-- modules return an empty map.
---
---@param modules table Map of module name to source file defined in the rockspec.
---@param selectedModule string? Name of the module to test specifically.
---				 Test all if nothing is given.
---
---@return table Array with the loaded test suites.
-----------------------------------------------------------------------------
local function loadTestSuites(modules, selectedModule)
	-- Override modules with selected module if provided
	if selectedModule then
		local srcPath = modules[selectedModule]
		if srcPath == nil then
			error(fmt("module '%s' not found in rockspec", selectedModule))
		end

		modules = { [selectedModule] = srcPath }
	end

	local suites, registeredSuites = {}, {}

	for _, srcPath in pairs(modules) do
		local testPath = srcPath:gsub("%.lua$", "_test.lua")

		local testFile, err = loadfile(testPath)
		if testFile == nil then
			error(fmt("could not load test file %s: %s", testPath, err))
		end

		local testSuiteMap = testFile()
		if type(testSuiteMap) ~= "table" then
			error(fmt("test file %s should return a suite map", testPath))
		end

		for name, suite in pairs(testSuiteMap) do
			if type(name) ~= "string" or not name:match("^Test") then
				error(fmt("invalid test suite name in %s: %s", testPath, tostring(name)))
			end

			if type(suite) ~= "table" then
				error(fmt("test suite %s in %s should return a table class", name, testPath))
			end

			if registeredSuites[name] then
				error(
					fmt(
						"duplicate test suite name '%s' in %s (already declared in %s)",
						name,
						testPath,
						registeredSuites[name]
					)
				)
			end

			registeredSuites[name] = testPath
			append(suites, { name, suite })
		end
	end

	return suites
end

local testSuites = loadTestSuites(rockspec.build.modules, arg and arg[2])

-----------------------------------------------------------------------------
-- Test execution
-----------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
runner.shuffle = true
runner.verbosity = lu.VERBOSITY_VERBOSE

-- Run explicitly registered instances so LuaUnit never needs to inspect _G.
local exitcode = runner:runSuiteByInstancesNoCmdLineParsing(testSuites)
os.exit(exitcode)
