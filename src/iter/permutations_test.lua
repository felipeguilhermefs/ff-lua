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
function TestPermutations:testStringInput_Yields_EveryPermutation()
	-- Given: "abc" has six expected orderings.
	local expected = {
		"abc",
		"bac",
		"cab",
		"acb",
		"bca",
		"cba",
	}
	local index = 1

	-- When: iterate over permutations of "abc".
	for value in permutations("abc") do

		-- Then: each yielded string matches the next expected ordering.
		lu.assertEquals(value, expected[index])
		index = index + 1
	end
end

function TestPermutations:testEmptyString_Yields_OneEmptyPermutation()
	-- Given: the source string has no characters.
	-- When: collect the permutations generated from an empty string.
	local p = collect(permutations(""))

	-- Then: collection contains exactly one empty string.
	lu.assertEquals(#p, 1)
	lu.assertEquals(p[1], "")
end

function TestPermutations:testArrayInput_Yields_EveryPermutation()
	-- Given: the three-element input has six expected orderings.
	local expected = {
		{ 1, 2, 3 },
		{ 2, 1, 3 },
		{ 3, 1, 2 },
		{ 1, 3, 2 },
		{ 2, 3, 1 },
		{ 3, 2, 1 },
	}
	local index = 1

	-- When: iterate over permutations of the three values.
	for value in permutations({ 1, 2, 3 }) do

		-- Then: each yielded array matches the next expected ordering.
		lu.assertEquals(value, expected[index])
		index = index + 1
	end
end

function TestPermutations:testEmptyArray_Yields_OneEmptyPermutation()
	-- Given: the source array has no elements.
	-- When: collect the permutations generated from an empty array.
	local p = collect(permutations({}))

	-- Then: collection contains exactly one empty array.
	lu.assertEquals(#p, 1)
	lu.assertEquals(#p[1], 0)
end

function TestPermutations:testFourElementInput_Yields_TwentyFourPermutations()
	-- Given: the source array contains four distinct elements.
	-- When: collect every generated ordering.
	local p = collect(permutations({ 1, 2, 3, 4 }))

	-- Then: collection contains 24 orderings.
	lu.assertEquals(#p, 24)
end

function TestPermutations:testNilInput_Raises_ValidationError()
	-- Given: the source value is nil.
	-- When: pass nil to the permutations generator.
	-- Then: validation reports that only arrays and strings are accepted.
	lu.assertErrorMsgContains("Only arrays and strings are accepted", permutations, nil)
end

-- Suite map
return { TestPermutations = TestPermutations }
