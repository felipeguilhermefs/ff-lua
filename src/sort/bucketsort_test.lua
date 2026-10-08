local lu = require("luaunit")
local Array = require("ff.collections.array")
local bucketsort = require("ff.sort.bucketsort")

TestBucketSort = {}

function TestBucketSort:testArray()
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

function TestBucketSort:testTableArray()
	local a = { 2, 6, 3, 4, 5, 1 }

	bucketsort(a)

	lu.assertEquals(a, { 1, 2, 3, 4, 5, 6 })

	a = { -2, -6, 3, -4, 5, 1 }

	bucketsort(a, -6, 5)

	lu.assertEquals(a, { -6, -4, -2, 1, 3, 5 })
end

