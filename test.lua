require("luarocks.loader")

local lu = require("luaunit")

local fmt = string.format
local append = table.insert
local unpack = table.unpack

local major, minor = _VERSION:match("Lua (%d+)%.(%d+)")
if not major or tonumber(major) < 5 or (tonumber(major) == 5 and tonumber(minor) < 5) then
	error("ff-lua requires Lua 5.5 or higher. Current version: " .. _VERSION)
end

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

	return env
end

local rockspec = loadrockspec(arg and arg[1])

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
