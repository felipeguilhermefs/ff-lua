local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local binarysearch = require("ff.search.binarysearch")

TestBinarySearch = {}

function TestBinarySearch:testArray()
	local a = Array.new({ 1, 2, 3, 4, 5, 6 })

	lu.assertEquals(binarysearch(a, 1), 1)
	lu.assertEquals(binarysearch(a, 2), 2)
	lu.assertEquals(binarysearch(a, 3), 3)
	lu.assertEquals(binarysearch(a, 4), 4)
	lu.assertEquals(binarysearch(a, 5), 5)
	lu.assertEquals(binarysearch(a, 6), 6)
	lu.assertNil(binarysearch(a, 7))
end

function TestBinarySearch:testTableArray()
	local a = { 6, 5, 4, 3, 2, 1 }

	local cmp = Comparator.reverse(Comparator.natural)

	lu.assertEquals(binarysearch(a, 6, cmp), 1)
	lu.assertEquals(binarysearch(a, 5, cmp), 2)
	lu.assertEquals(binarysearch(a, 4, cmp), 3)
	lu.assertEquals(binarysearch(a, 3, cmp), 4)
	lu.assertEquals(binarysearch(a, 2, cmp), 5)
	lu.assertEquals(binarysearch(a, 1, cmp), 6)
	lu.assertNil(binarysearch(a, 7, cmp))
end

