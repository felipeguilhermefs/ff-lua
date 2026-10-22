-- Imports
local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local quickselect = require("ff.search.quickselect")

-- Suite definitions
local TestQuickSelect = {}

-- Scenarios: selection behavior
function TestQuickSelect:testArrayInput_Returns_ValueAtRequestedRank()
	-- Given: an Array stores integers 1 through 6 in ascending order.
	local a = Array.new({ 1, 2, 3, 4, 5, 6 })

	-- When: request ranks 1 through 6, then rank 7.
	-- Then: each valid rank returns its matching value; rank 7 returns nil.
	lu.assertEquals(quickselect(a, 1), 1)
	lu.assertEquals(quickselect(a, 2), 2)
	lu.assertEquals(quickselect(a, 3), 3)
	lu.assertEquals(quickselect(a, 4), 4)
	lu.assertEquals(quickselect(a, 5), 5)
	lu.assertEquals(quickselect(a, 6), 6)
	lu.assertNil(quickselect(a, 7))
end

function TestQuickSelect:testTableArrayInput_Returns_ValueAtRequestedRank()
	-- Given: a plain table stores integers 6 through 1 in descending order.
	local a = { 6, 5, 4, 3, 2, 1 }

	local cmp = Comparator.reverse(Comparator.natural)

	-- When: request each rank with the reverse comparator, then rank 7.
	-- Then: results follow comparator order; rank 7 returns nil.
	lu.assertEquals(quickselect(a, 6, cmp), 1)
	lu.assertEquals(quickselect(a, 5, cmp), 2)
	lu.assertEquals(quickselect(a, 4, cmp), 3)
	lu.assertEquals(quickselect(a, 3, cmp), 4)
	lu.assertEquals(quickselect(a, 2, cmp), 5)
	lu.assertEquals(quickselect(a, 1, cmp), 6)
	lu.assertNil(quickselect(a, 7, cmp))
end

-- Suite map
return { TestQuickSelect = TestQuickSelect }
