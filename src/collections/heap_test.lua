local lu = require("luaunit")
local Comparator = require("ff.func.comparator")
local Heap = require("ff.collections.heap")

local append = table.insert

local function entriesByIndex(heap)
	local entries = {}
	for index, value in pairs(heap) do
		entries[index] = value
	end
	return entries
end

local TestHeap = {}

function TestHeap:testTypeGuard_RecognizesHeapsAndRejectsOtherValues()
	local h = Heap.new()

	lu.assertTrue(Heap.isHeap(h))
	lu.assertTrue(Heap.isHeap(Heap.newMin()))
	lu.assertTrue(Heap.isHeap(Heap.newMax()))
	lu.assertFalse(Heap.isHeap({}))
	lu.assertFalse(Heap.isHeap(nil))
	lu.assertFalse(Heap.isHeap("heap"))
	lu.assertFalse(Heap.isHeap(123))
end

function TestHeap:testEmptyConstructor_CreatesEmptyHeap()
	local h = Heap.new()

	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())
end

function TestHeap:testConstructor_OrdersIterableValuesByPriority()
	local h = Heap.new({ 30, 10, 20 })

	lu.assertEquals(#h, 3)
	lu.assertEquals(h:peek(), 10)
	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 30)
	lu.assertTrue(h:empty())
end

function TestHeap:testComparatorConstructor_UsesRequestedPriority()
	local h = Heap.new(nil, Comparator.reverse(Comparator.natural))
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)

	h:push(10)
	h:push(30)
	h:push(20)

	lu.assertEquals(h:peek(), 30)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 10)
	lu.assertTrue(h:empty())
end

function TestHeap:testComparatorConstructor_OrdersInitialValuesByPriority()
	local h = Heap.new({ 10, 30, 20 }, Comparator.reverse(Comparator.natural))

	lu.assertEquals(#h, 3)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 10)
end

function TestHeap:testCapacityConstructors_CreateEmptyBoundedHeaps()
	local h = Heap.new(nil, nil, 5)

	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertFalse(h:full())

	local minH = Heap.newMin(nil, 5)
	lu.assertTrue(minH:empty())
	lu.assertEquals(#minH, 0)
	lu.assertFalse(minH:full())

	local maxH = Heap.newMax(nil, 5)
	lu.assertTrue(maxH:empty())
	lu.assertEquals(#maxH, 0)
	lu.assertFalse(maxH:full())
end

function TestHeap:testCapacityConstructors_LoadInitialValuesWithinLimit()
	local h = Heap.new({ 10, 20, 30 }, nil, 5)

	lu.assertEquals(#h, 3)
	lu.assertFalse(h:full())

	local h3 = Heap.new({ 10, 20, 30, 40, 50 }, nil, 3)
	lu.assertEquals(#h3, 3)
	lu.assertTrue(h3:full())

	local minH = Heap.newMin({ 5, 3, 8 }, 5)
	lu.assertEquals(#minH, 3)
	lu.assertFalse(minH:full())

	local maxH = Heap.newMax({ 5, 3, 8 }, 3)
	lu.assertEquals(#maxH, 3)
	lu.assertTrue(maxH:full())
end

function TestHeap:testConstructors_RejectInvalidComparatorAndCapacity()
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, "a")
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, true)
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, -1)
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, 0)
	lu.assertErrorMsgContains("capacity should be a number", Heap.new, nil, nil, "a")
	lu.assertErrorMsgContains("capacity should be positive", Heap.new, nil, nil, -1)
	lu.assertErrorMsgContains("capacity should be positive", Heap.new, nil, nil, 0)
	lu.assertErrorMsgContains("capacity should be a number", Heap.newMin, nil, "a")
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMin, nil, 0)
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMin, nil, -1)
	lu.assertErrorMsgContains("capacity should be a number", Heap.newMax, nil, "a")
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMax, nil, 0)
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMax, nil, -1)
end

function TestHeap:testMinAndMaxConstructors_ProduceExpectedPriorityOrder()
	local minH = Heap.newMin({ 5, 3, 8, 1 })

	lu.assertEquals(#minH, 4)
	lu.assertEquals(minH:pop(), 1)
	lu.assertEquals(minH:pop(), 3)
	lu.assertEquals(minH:pop(), 5)
	lu.assertEquals(minH:pop(), 8)
	lu.assertNil(minH:pop())

	local maxH = Heap.newMax({ 5, 3, 8, 1 })
	lu.assertEquals(#maxH, 4)
	lu.assertEquals(maxH:pop(), 8)
	lu.assertEquals(maxH:pop(), 5)
	lu.assertEquals(maxH:pop(), 3)
	lu.assertEquals(maxH:pop(), 1)
	lu.assertNil(maxH:pop())
end

function TestHeap:testContains_FindsStoredValuesWithoutConsumingHeap()
	local h = Heap.new()

	lu.assertFalse(h:contains(1))

	h:push(10)
	h:push(20)
	h:push(30)

	lu.assertTrue(h:contains(10))
	lu.assertTrue(h:contains(20))
	lu.assertTrue(h:contains(30))
	lu.assertFalse(h:contains(99))
	lu.assertEquals(#h, 3)
	lu.assertEquals(h:peek(), 10)

	h:pop()

	lu.assertFalse(h:contains(10))
	lu.assertTrue(h:contains(20))
	lu.assertTrue(h:contains(30))
end

function TestHeap:testContains_RejectsNilAndIncomparableValues()
	local h = Heap.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		h:contains(nil)
	end)

	h:push(10)

	lu.assertErrorMsgContains("attempt to compare string with number", function()
		h:contains("10")
	end)
end

function TestHeap:testIteration_YieldsHeapValuesInLevelOrder()
	local h = Heap.new()

	h:push("b")
	h:push("d")
	h:push("c")
	h:push("a")

	local keys = {}
	local res = {}
	for i, item in pairs(h) do
		append(keys, i)
		append(res, item)
	end

	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertFalse(h:empty())
	lu.assertEquals(#h, 4)
	lu.assertEquals(h:peek(), "a")
end

function TestHeap:testEmptyHeapIteration_YieldsNoValues()
	local h = Heap.new()

	local count = 0

	for _ in pairs(h) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestHeap:testRepeatedIteration_PreservesHeapContents()
	local h = Heap.new({ 10, 20, 30 })

	local firstRun = {}

	for _, item in pairs(h) do
		append(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(h) do
		append(secondRun, item)
	end

	lu.assertEquals(firstRun, { 10, 20, 30 })
	lu.assertEquals(secondRun, { 10, 20, 30 })
	lu.assertEquals(#h, 3)
end

function TestHeap:testIteration_YieldsValuesInLevelOrder()
	local h = Heap.new()

	h:push(10)
	h:push(30)
	h:push(20)
	h:push(50)
	h:push(40)

	local levelOrder = {}
	for _, item in pairs(h) do
		append(levelOrder, item)
	end

	lu.assertEquals(levelOrder, { 10, 30, 20, 50, 40 })
	lu.assertEquals(#h, 5)
end

function TestHeap:testIndexOf_FindsStoredValuesAndReturnsNilForMissingValues()
	local h = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })
	local entries = entriesByIndex(h)

	lu.assertEquals(h:indexOf(10), 1)

	for _, val in ipairs({ 10, 20, 30, 40, 50, 60, 70 }) do
		local idx = h:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(entries[idx], val)
	end

	lu.assertNil(h:indexOf(5))

	lu.assertNil(h:indexOf(25))
	lu.assertNil(h:indexOf(99))

	lu.assertNil(Heap.new():indexOf(10))
end

function TestHeap:testIndexOf_SearchesOnlyRequestedSubtree()
	local h = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })

	local leftVal = 20

	local idx = h:indexOf(leftVal, 2)

	lu.assertEquals(idx, 2)

	if #h >= 4 then
		local childVal = 40
		lu.assertEquals(h:indexOf(childVal, 2), 4)
	end

	local rightVal = 30
	lu.assertNil(h:indexOf(rightVal, 2))

	lu.assertNil(h:indexOf(10, 100))
end

function TestHeap:testMaxHeapIndexOf_FindsValuesAndRejectsValuesOutsideHeap()
	local maxH = Heap.newMax({ 70, 60, 50, 40, 30, 20, 10 })
	local entries = entriesByIndex(maxH)

	lu.assertEquals(maxH:indexOf(70), 1)

	for _, val in ipairs({ 70, 60, 50, 40, 30, 20, 10 }) do
		local idx = maxH:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(entries[idx], val)
	end

	lu.assertNil(maxH:indexOf(100))

	lu.assertNil(maxH:indexOf(25))
	lu.assertNil(maxH:indexOf(0))
end

function TestHeap:testMaxHeapIndexOf_SearchesOnlyRequestedSubtree()
	local maxH = Heap.newMax({ 100, 80, 90, 40, 50, 60, 70 })

	local leftVal = 80
	local rightVal = 90

	lu.assertEquals(maxH:indexOf(leftVal, 1), 2)
	lu.assertEquals(maxH:indexOf(rightVal, 1), 3)

	lu.assertEquals(maxH:indexOf(leftVal, 2), 2)
	if #maxH >= 4 then
		local childVal = 40
		lu.assertEquals(maxH:indexOf(childVal, 2), 4)
	end

	lu.assertNil(maxH:indexOf(rightVal, 2))
end

function TestHeap:testMaxHeapIndexOf_FindsDuplicateValues()
	local maxH = Heap.newMax({ 50, 40, 40, 30, 20, 20, 10 })
	local entries = entriesByIndex(maxH)

	for _, val in ipairs({ 50, 40, 30, 20, 10 }) do
		local idx = maxH:indexOf(val)

		lu.assertNotNil(idx)
		lu.assertEquals(entries[idx], val)
	end
end

function TestHeap:testIndexOf_FindsObjectValuesWithEqualPriority()
	local function cmp(a, b)
		return Comparator.natural(a.priority, b.priority)
	end

	local h = Heap.new(nil, cmp)
	local a = { priority = 10, name = "A" }
	local b = { priority = 10, name = "B" }
	local c = { priority = 10, name = "C" }

	h:push(a)
	h:push(b)

	lu.assertEquals(h:indexOf(a), 1)
	lu.assertEquals(h:indexOf(b), 2)
	lu.assertNil(h:indexOf(c))
	lu.assertFalse(h:contains(c))
end

function TestHeap:testMaxHeapIndexOf_FindsObjectValuesWithEqualPriority()
	local function maxObjCmp(a, b)
		return Comparator.reverse(Comparator.natural)(a.priority, b.priority)
	end

	local h = Heap.new(nil, maxObjCmp)
	local a = { priority = 50, name = "A" }
	local b = { priority = 50, name = "B" }
	local c = { priority = 20, name = "C" }
	local d = { priority = 50, name = "D" }

	h:push(a)
	h:push(b)
	h:push(c)

	lu.assertEquals(h:indexOf(a), 1)
	lu.assertEquals(h:indexOf(b), 2)
	lu.assertEquals(h:indexOf(c), 3)
	lu.assertNil(h:indexOf(d))
	lu.assertFalse(h:contains(d))
end

function TestHeap:testIndexOf_RejectsNilValuesAndInvalidStartIndexes()
	local h = Heap.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("value should not be nil", function()
		h:indexOf(nil)
	end)

	lu.assertErrorMsgContains("index should be a number", function()
		h:indexOf(10, "bad")
	end)

	lu.assertErrorMsgContains("index should be positive", function()
		h:indexOf(10, 0)
	end)

	lu.assertErrorMsgContains("index should be positive", function()
		h:indexOf(10, -1)
	end)
end

function TestHeap:testUnboundedHeaps_NeverReportFull()
	local h = Heap.new()

	local fullBefore = h:full()
	h:push(1)
	local fullAfter1 = h:full()
	h:push(2)
	local fullAfter2 = h:full()

	lu.assertFalse(fullBefore)
	lu.assertFalse(fullAfter1)
	lu.assertFalse(fullAfter2)

	local minH = Heap.newMin()
	local maxH = Heap.newMax()

	lu.assertFalse(minH:full())
	lu.assertFalse(maxH:full())
end

function TestHeap:testBoundedHeap_ReportsNotFullBelowCapacity()
	local h = Heap.new(nil, nil, 3)

	lu.assertFalse(h:full())

	h:push(1)
	h:push(2)

	lu.assertFalse(h:full())
end

function TestHeap:testBoundedHeap_ReportsFullAtCapacity()
	local h = Heap.new(nil, nil, 2)

	h:push(1)
	h:push(2)

	lu.assertTrue(h:full())
end

function TestHeap:testRemovingValuesOrClearing_MakesCapacityAvailable()
	local h = Heap.new(nil, nil, 2)
	h:push(1)
	h:push(2)
	lu.assertTrue(h:full())

	h:pop()

	lu.assertFalse(h:full())

	h:push(3)

	lu.assertTrue(h:full())

	h:clear()

	lu.assertFalse(h:full())
	lu.assertEquals(#h, 0)
end

function TestHeap:testFullHeap_RejectsPush()
	local h = Heap.new(nil, nil, 3)

	h:push("a")
	h:push("b")
	h:push("c")

	lu.assertTrue(h:full())
	lu.assertFalse(h:push("d"))
end

function TestHeap:testPush_MaintainsSmallestValueAtHeapRoot()
	local h = Heap.new()

	h:push(4)

	lu.assertEquals(h:peek(), 4)

	h:push(5)

	lu.assertEquals(h:peek(), 4)

	h:push(1)

	lu.assertEquals(h:peek(), 1)

	h:push(3)

	lu.assertEquals(h:peek(), 1)
end

function TestHeap:testPush_RejectsNilValues()
	local h = Heap.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		h:push(nil)
	end)
end

function TestHeap:testPop_ReturnsValuesInAscendingPriorityOrder()
	local h = Heap.new()

	h:push(4)
	h:push(5)
	h:push(1)
	h:push(3)
	h:push(2)

	lu.assertEquals(h:pop(), 1)
	lu.assertEquals(h:pop(), 2)
	lu.assertEquals(h:pop(), 3)
	lu.assertEquals(h:pop(), 4)
	lu.assertEquals(h:pop(), 5)
	lu.assertNil(h:pop())
end

function TestHeap:testEmptyHeapPopAndPeek_ReturnNil()
	local h = Heap.new()

	lu.assertNil(h:pop())
	lu.assertNil(h:peek())
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
end

function TestHeap:testPopAndClear_UpdateEmptyStateAndAllowReuse()
	local h = Heap.new()
	lu.assertTrue(h:empty())

	h:push(2)
	h:push(3)
	h:pop()
	h:pop()

	lu.assertTrue(h:empty())

	h:push(10)
	h:push(20)
	h:clear()

	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())

	h:push(42)

	lu.assertEquals(#h, 1)
	lu.assertEquals(h:peek(), 42)
	lu.assertEquals(h:pop(), 42)
	lu.assertTrue(h:empty())
end

function TestHeap:testPop_PreservesDuplicateValues()
	local h = Heap.new()

	h:push(5)
	h:push(5)
	h:push(2)
	h:push(8)
	h:push(2)
	h:push(5)
	h:push(8)

	lu.assertEquals(#h, 7)
	lu.assertEquals(h:pop(), 2)
	lu.assertEquals(h:pop(), 2)
	lu.assertEquals(h:pop(), 5)
	lu.assertEquals(h:pop(), 5)
	lu.assertEquals(h:pop(), 5)
	lu.assertEquals(h:pop(), 8)
	lu.assertEquals(h:pop(), 8)
	lu.assertNil(h:pop())
end

function TestHeap:testMaxHeapPop_ReturnsValuesInDescendingPriorityOrder()
	local h = Heap.newMax({ 5, 7, 9 })

	h:push(6)
	h:push(8)
	h:push(7)

	lu.assertEquals(h:pop(), 9)
	lu.assertEquals(h:pop(), 8)
	lu.assertEquals(h:pop(), 7)
	lu.assertEquals(h:pop(), 7)
	lu.assertEquals(h:pop(), 6)
	lu.assertEquals(h:pop(), 5)
	lu.assertNil(h:pop())
end

function TestHeap:testHeap_OrdersStringValuesByNaturalPriority()
	local h = Heap.new()

	h:push("b")
	h:push("e")
	h:push("c")
	h:push("a")
	h:push("d")

	lu.assertEquals(h:pop(), "a")
	lu.assertEquals(h:pop(), "b")
	lu.assertEquals(h:pop(), "c")
	lu.assertEquals(h:pop(), "d")
	lu.assertEquals(h:pop(), "e")
	lu.assertNil(h:pop())
end

function TestHeap:testHeap_UsesCustomComparatorForObjectPriority()
	local function max(a, b)
		if a.priority < b.priority then
			return Comparator.greater
		end

		if a.priority > b.priority then
			return Comparator.less
		end

		return Comparator.equal
	end

	local function obj(priority, value)
		return { priority = priority, value = value }
	end

	local h = Heap.new({ obj(5, "a"), obj(7, "b"), obj(9, "c") }, max)

	h:push(obj(6, true))
	h:push(obj(8, false))

	lu.assertEquals(h:pop(), { priority = 9, value = "c" })
	lu.assertEquals(h:pop(), { priority = 8, value = false })
	lu.assertEquals(h:pop(), { priority = 7, value = "b" })
	lu.assertEquals(h:pop(), { priority = 6, value = true })
	lu.assertEquals(h:pop(), { priority = 5, value = "a" })
	lu.assertNil(h:pop())
end

function TestHeap:testDrain_YieldsValuesInAscendingPriorityOrderAndEmptiesHeap()
	local h = Heap.new()

	h:push("b")
	h:push("d")
	h:push("c")
	h:push("a")

	local res = {}
	for item in h:drain() do
		append(res, item)
	end

	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())
end

function TestHeap:testMaxHeapDrain_YieldsValuesInDescendingPriorityOrder()
	local h = Heap.newMax({ 10, 50, 30, 20, 40 })

	local res = {}

	for item in h:drain() do
		append(res, item)
	end

	lu.assertEquals(res, { 50, 40, 30, 20, 10 })
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
end

function TestHeap:testEmptyHeapDrain_YieldsNoValues()
	local h = Heap.new()

	local count = 0

	for _ in h:drain() do
		count = count + 1
	end

	lu.assertEquals(count, 0)
	lu.assertTrue(h:empty())
end

function TestHeap:testBoundedHeap_RejectsPushAtCapacityAndAcceptsAfterPop()
	local h = Heap.new(nil, nil, 2)

	lu.assertTrue(h:push(10))
	lu.assertEquals(#h, 1)
	lu.assertFalse(h:full())

	lu.assertTrue(h:push(20))
	lu.assertEquals(#h, 2)
	lu.assertTrue(h:full())

	lu.assertFalse(h:push(30))
	lu.assertEquals(#h, 2)

	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(#h, 1)
	lu.assertFalse(h:full())

	lu.assertTrue(h:push(30))
	lu.assertEquals(#h, 2)
	lu.assertTrue(h:full())
end

function TestHeap:testConcat_AppendsValuesFromIterableCollections()
	local h = Heap.new() .. { 10, 20, 30 }
	lu.assertEquals(#h, 3)

	h = h .. nil

	lu.assertEquals(#h, 3)

	local ll = require("ff.collections.linkedlist").new()
	ll:pushBack(40)
	ll:pushBack(50)
	ll:pushBack(60)
	h = h .. ll

	lu.assertEquals(#h, 6)
	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 40)
	lu.assertEquals(h:pop(), 50)
	lu.assertEquals(h:pop(), 60)
end

function TestHeap:testConcat_RejectsNonTableValues()
	local h = Heap.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		h = h .. "not a table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		h = h .. 42
	end)
end

function TestHeap:testHeapsWithSameValues_CompareEqual()
	local h1 = Heap.new({ 1, 2, 3 })
	local h2 = Heap.new({ 1, 2, 3 })
	local h3 = Heap.new({ 1, 2, 4 })
	local h4 = Heap.new({ 1, 2 })

	lu.assertTrue(h1 == h2)
	lu.assertFalse(h1 == h3)
	lu.assertFalse(h1 == h4)
	lu.assertFalse(h1 == {})
	lu.assertFalse(h1 == nil)
	lu.assertFalse(h1 == 42)
end

function TestHeap:testEmptyHeaps_CompareEqual()
	local h1 = Heap.new()
	local h2 = Heap.new()

	lu.assertTrue(h1 == h2)
end

function TestHeap:testLength_TracksPushPopAndClearOperations()
	local h = Heap.new()
	lu.assertEquals(#h, 0)

	h:push(10)
	h:push(20)
	h:push(30)

	lu.assertEquals(#h, 3)

	h:pop()

	lu.assertEquals(#h, 2)

	h:clear()

	lu.assertEquals(#h, 0)
end

function TestHeap:testToString_FormatsHeapValues()
	local h = Heap.new({ 1, 2, 3 })

	local str = tostring(h)

	lu.assertStrContains(str, "1")
	lu.assertStrContains(str, "2")
	lu.assertStrContains(str, "3")
	lu.assertStrContains(str, "[")
	lu.assertStrContains(str, "]")
end

function TestHeap:testToString_FormatsEmptyHeap()
	local h = Heap.new()

	local str = tostring(h)

	lu.assertEquals(str, "[  ]")
end

function TestHeap:testNewPropertiesAndMethods_CannotBeAddedOrReplaced()
	local h = Heap.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.foo = "bar"
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h[1] = 99
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.peek = function() end
	end)
end

function TestHeap:testConcat_CreatesNewHeapAndPushAllMutates()
	local source = Heap.new({ 1 })
	local joined = source .. { 2 }
	lu.assertNotIs(joined, source)
	lu.assertEquals(#source, 1)
	lu.assertEquals(#joined, 2)
	source:pushAll({ 3 })
	lu.assertEquals(#source, 2)
end

function TestHeap:testPushAllRejectsNil()
	local collection = Heap.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		collection:pushAll(nil)
	end)
end

return { TestHeap = TestHeap }
