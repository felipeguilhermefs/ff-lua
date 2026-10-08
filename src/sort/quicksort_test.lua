local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local quicksort = require("ff.sort.quicksort")

TestQuickSort = {}

function TestQuickSort:testArray()
	local a = Array.new({ 2, 6, 3, 4, 5, 1 })

	quicksort(a)

	lu.assertEquals(a:get(1), 1)
	lu.assertEquals(a:get(2), 2)
	lu.assertEquals(a:get(3), 3)
	lu.assertEquals(a:get(4), 4)
	lu.assertEquals(a:get(5), 5)
	lu.assertEquals(a:get(6), 6)

	quicksort(a, Comparator.reverse(Comparator.natural))

	lu.assertEquals(a:get(6), 1)
	lu.assertEquals(a:get(5), 2)
	lu.assertEquals(a:get(4), 3)
	lu.assertEquals(a:get(3), 4)
	lu.assertEquals(a:get(2), 5)
	lu.assertEquals(a:get(1), 6)
end

function TestQuickSort:testTableArray()
	local a = { 2, 6, 3, 4, 5, 1 }

	quicksort(a)

	lu.assertEquals(a, { 1, 2, 3, 4, 5, 6 })

	quicksort(a, Comparator.reverse(Comparator.natural))

	lu.assertEquals(a, { 6, 5, 4, 3, 2, 1 })
end

