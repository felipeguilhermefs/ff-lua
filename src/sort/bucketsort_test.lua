local lu = require("luaunit")
local Array = require("ff.collections.array")
local bucketsort = require("ff.sort.bucketsort")

local TestBucketSort = {}

function TestBucketSort:testArrayInput_ReturnsValuesInAscendingOrder()
	local a = Array.new({ 2, 6, 3, 4, 5, 1 })

	bucketsort(a)

	lu.assertEquals(a:get(1), 1)
	lu.assertEquals(a:get(2), 2)
	lu.assertEquals(a:get(3), 3)
	lu.assertEquals(a:get(4), 4)
	lu.assertEquals(a:get(5), 5)
	lu.assertEquals(a:get(6), 6)

	a = Array.new({ -2, -6, 3, -4, 5, 1 })

	bucketsort(a)

	lu.assertEquals(a:get(1), -6)
	lu.assertEquals(a:get(2), -4)
	lu.assertEquals(a:get(3), -2)
	lu.assertEquals(a:get(4), 1)
	lu.assertEquals(a:get(5), 3)
	lu.assertEquals(a:get(6), 5)
end

return { TestBucketSort = TestBucketSort }
