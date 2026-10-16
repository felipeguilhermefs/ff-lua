-- Imports
local lu = require("luaunit")
local permutations = require("ff.iter.permutations")

-- Test helpers
local function collect(iter)
	local res = {}
	for value in iter do
		table.insert(res, value)
	end
	return res
end

-- Suite definitions
local TestPermutations = {}

-- Scenarios: permutation behavior
function TestPermutations:testStringInputYieldsEveryPermutation()
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

function TestPermutations:testEmptyStringYieldsOneEmptyPermutation()
	local p = collect(permutations(""))
	lu.assertEquals(#p, 1)
	lu.assertEquals(p[1], "")
end

function TestPermutations:testArrayInputYieldsEveryPermutation()
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

function TestPermutations:testEmptyArrayYieldsOneEmptyPermutation()
	local p = collect(permutations({}))
	lu.assertEquals(#p, 1)
	lu.assertEquals(#p[1], 0)
end

function TestPermutations:testFourElementInputYieldsTwentyFourPermutations()
	local p = collect(permutations({ 1, 2, 3, 4 }))
	lu.assertEquals(#p, 24)
end

function TestPermutations:testNilInputRaisesValidationError()
	lu.assertErrorMsgContains("Only arrays and strings are accepted", permutations, nil)
end

-- Suite map
return { TestPermutations = TestPermutations }
