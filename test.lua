require("luarocks.loader")

local fmt = string.format
local append = table.insert
local unpack = table.unpack

local function loadrockspec(filename)
	if filename == nil or filename == "" then
		error("missing rockspec file name")
	end

	-- Load rockspec in a sandbox — it assigns globals like build, package, etc.
	local env = {}

	local load, err = loadfile(filename, "t", env)
	if load == nil or err then
		error(fmt("could not load rockspec %s: %s.", filename, err))
	end

	load()

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

local rockspec = loadrockspec(arg and arg[1])

local function checkversion(dependencies)
	local rmajor, rminor

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

	local cmajor, cminor = _VERSION:match("Lua (%d+)%.(%d+)")
	cmajor, cminor = tonumber(cmajor), tonumber(cminor)

	if cmajor < rmajor or (cmajor == rmajor and cminor < rminor) then
		error(fmt("rockspec requires Lua %d.%d or higher. Current version: %s", rmajor, rminor, _VERSION))
	end
end

checkversion(rockspec.dependencies)

local lu = require("luaunit")

for module, srcpath in pairs(rockspec.build.modules) do
	package.preload[module] = function()
		return dofile(srcpath)
	end
end

for _, srcpath in pairs(rockspec.build.modules) do
	local testpath = srcpath:gsub("%.lua$", "_test.lua")
	dofile(testpath)
end

local luargs = {}
for i = 2, #arg do
	append(luargs, arg[i])
end
os.exit(lu.LuaUnit.run(unpack(luargs)))
