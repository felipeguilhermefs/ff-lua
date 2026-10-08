local lu = require("luaunit")
local permutations = require("ff.iter.permutations")

TestPermutations = {}

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

function TestPermutations:testString()
	local expected = {
		"abc",
		"bac",
		"cab",
		"acb",
		"bca",
		"cba",
	}
	local index = 1
	for value in permutations("abc") do
		lu.assertEquals(value, expected[index])
		index = index + 1
	end
end

function TestPermutations:testEmptyString()
	local p = collect(permutations(""))
	lu.assertEquals(#p, 1)
	lu.assertEquals(p[1], "")
end

function TestPermutations:testArray()
	local expected = {
		{ 1, 2, 3 },
		{ 2, 1, 3 },
		{ 3, 1, 2 },
		{ 1, 3, 2 },
		{ 2, 3, 1 },
		{ 3, 2, 1 },
	}
	local index = 1
	for value in permutations({ 1, 2, 3 }) do
		lu.assertEquals(value, expected[index])
		index = index + 1
	end
end

function TestPermutations:testEmptyArray()
	local p = collect(permutations({}))
	lu.assertEquals(#p, 1)
	lu.assertEquals(#p[1], 0)
end

function TestPermutations:test4Elements()
	local p = collect(permutations({ 1, 2, 3, 4 }))
	lu.assertEquals(24, #p)
end

function TestPermutations:testNil()
	lu.assertErrorMsgContains("Only arrays and strings are accepted", permutations, nil)
end

