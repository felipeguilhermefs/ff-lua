local lu = require("luaunit")
local permutations = require("permutations")

-----------------------------------------------------------------------------
---Helper method to collect the permutations in a array
---
---@param iter  Iterator<number, any>
---
---@return table<any>
-----------------------------------------------------------------------------
local function collect(iter)
	local res = {}
	for value in iter do
		table.insert(res, value)
	end
	return res
end

function TestString()
	local expected = {
		"bca",
		"cba",
		"cab",
		"acb",
		"bac",
		"abc",
	}
	local index = 1
	for value in permutations("abc") do
		lu.assertEquals(value, expected[index])
		index = index + 1
	end
end

function TestEmptyString()
	local p = collect(permutations(""))
	lu.assertEquals(#p, 1)
	lu.assertEquals(p[1], "")
end

function TestArray()
	local expected = {
		{ 2, 3, 1 },
		{ 3, 2, 1 },
		{ 3, 1, 2 },
		{ 1, 3, 2 },
		{ 2, 1, 3 },
		{ 1, 2, 3 },
	}
	local index = 1
	for value in permutations({ 1, 2, 3 }) do
		lu.assertEquals(value, expected[index])
		index = index + 1
	end
end

function TestEmptyArray()
	local p = collect(permutations({}))
	lu.assertEquals(#p, 1)
	lu.assertEquals(#p[1], 0)
end

function Test4Elements()
	local p = collect(permutations({ 1, 2, 3, 4 }))
	lu.assertEquals(24, #p)
end

function TestNil()
	lu.assertError(permutations, nil)
end

os.exit(lu.LuaUnit.run())
