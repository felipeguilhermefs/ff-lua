-- Imports
local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local binarysearch = require("ff.search.binarysearch")

-- Suite definitions
local TestBinarySearch = {}

-- Scenarios: binary search behavior
function TestBinarySearch:testArrayInput_Returns_IndexOfMatchingValue()
	-- Given: an Array stores integers 1 through 6 in ascending order.
	local a = Array.new({ 1, 2, 3, 4, 5, 6 })

	-- When: search for each stored integer and for absent value 7.
	-- Then: stored integers map to their one-based indexes; 7 has no match.
	lu.assertEquals(binarysearch(a, 1), 1)
	lu.assertEquals(binarysearch(a, 2), 2)
	lu.assertEquals(binarysearch(a, 3), 3)
	lu.assertEquals(binarysearch(a, 4), 4)
	lu.assertEquals(binarysearch(a, 5), 5)
	lu.assertEquals(binarysearch(a, 6), 6)
	lu.assertNil(binarysearch(a, 7))
end

function TestBinarySearch:testTableArrayInput_Returns_IndexOfMatchingValue()
	-- Given: a plain table stores integers 6 through 1 in descending order.
	local a = { 6, 5, 4, 3, 2, 1 }

	local cmp = Comparator.reverse(Comparator.natural)

	-- When: search with the reverse comparator for each stored integer and 7.
	-- Then: indexes follow table order and absent value 7 has no match.
	lu.assertEquals(binarysearch(a, 6, cmp), 1)
	lu.assertEquals(binarysearch(a, 5, cmp), 2)
	lu.assertEquals(binarysearch(a, 4, cmp), 3)
	lu.assertEquals(binarysearch(a, 3, cmp), 4)
	lu.assertEquals(binarysearch(a, 2, cmp), 5)
	lu.assertEquals(binarysearch(a, 1, cmp), 6)
	lu.assertNil(binarysearch(a, 7, cmp))
end

-- Suite map
return { TestBinarySearch = TestBinarySearch }
