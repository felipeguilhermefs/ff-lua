-- Imports
local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local quicksort = require("ff.sort.quicksort")

-- Suite definitions
local TestQuickSort = {}

-- Scenarios: quick sort behavior
function TestQuickSort:testArrayInput_Sorts_ValuesInAscendingOrder()
	-- Given: an Array contains six unsorted integers for natural ordering.
	local a = Array.new({ 2, 6, 3, 4, 5, 1 })

	-- When: sort the Array with the default comparator.
	quicksort(a)

	-- Then: iteration by index yields integers 1 through 6.
	lu.assertEquals(a:get(1), 1)
	lu.assertEquals(a:get(2), 2)
	lu.assertEquals(a:get(3), 3)
	lu.assertEquals(a:get(4), 4)
	lu.assertEquals(a:get(5), 5)
	lu.assertEquals(a:get(6), 6)
end

function TestQuickSort:testArrayInput_Sorts_ValuesByReverseComparator()
	-- Given: an Array contains six unsorted integers for reverse ordering.
	local a = Array.new({ 2, 6, 3, 4, 5, 1 })

	-- When: sort the Array using the reversed natural comparator.
	quicksort(a, Comparator.reverse(Comparator.natural))

	-- Then: descending order places 6 at index 1 and 1 at index 6.
	lu.assertEquals(a:get(6), 1)
	lu.assertEquals(a:get(5), 2)
	lu.assertEquals(a:get(4), 3)
	lu.assertEquals(a:get(3), 4)
	lu.assertEquals(a:get(2), 5)
	lu.assertEquals(a:get(1), 6)
end

function TestQuickSort:testTableArrayInput_Sorts_ValuesInAscendingOrder()
	-- Given: a plain table contains six unsorted integers for natural ordering.
	local a = { 2, 6, 3, 4, 5, 1 }

	-- When: sort the table with the default comparator.
	quicksort(a)

	-- Then: the table equals the ascending sequence from 1 through 6.
	lu.assertEquals(a, { 1, 2, 3, 4, 5, 6 })
end

function TestQuickSort:testTableArrayInput_Sorts_ValuesByReverseComparator()
	-- Given: a plain table contains six unsorted integers for reverse ordering.
	local a = { 2, 6, 3, 4, 5, 1 }

	-- When: sort the table using the reversed natural comparator.
	quicksort(a, Comparator.reverse(Comparator.natural))

	-- Then: the table equals the descending sequence from 6 through 1.
	lu.assertEquals(a, { 6, 5, 4, 3, 2, 1 })
end

-- Suite map
return { TestQuickSort = TestQuickSort }
