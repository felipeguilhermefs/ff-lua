local lu = require("luaunit")
local Comparator = require("ff.func.comparator")
local Heap = require("ff.collections.heap")

local function iterableWithNilValue()
	return setmetatable({}, {
		__pairs = function()
			local yielded = false
			return function()
				if not yielded then
					yielded = true
					return 1, nil
				end
			end
		end,
	})
end

local function orderedIterable(values)
	return setmetatable({}, {
		__pairs = function()
			local index = 0
			return function()
				index = index + 1
				if values[index] ~= nil then
					return index, values[index]
				end
			end
		end,
	})
end

local function snapshot(heap)
	local values = {}
	for index, value in pairs(heap) do
		values[index] = value
	end
	return values
end

local TestHeapClear = {}
local TestHeapConcat = {}
local TestHeapContains = {}
local TestHeapDrain = {}
local TestHeapEmpty = {}
local TestHeapEq = {}
local TestHeapFull = {}
local TestHeapIndexOf = {}
local TestHeapIsHeap = {}
local TestHeapLen = {}
local TestHeapNew = {}
local TestHeapNewIndex = {}
local TestHeapNewMax = {}
local TestHeapNewMin = {}
local TestHeapPairs = {}
local TestHeapPeek = {}
local TestHeapPop = {}
local TestHeapPush = {}
local TestHeapPushAll = {}
local TestHeapTostring = {}

function TestHeapClear:testClearedBoundedHeapKeepsCapacityLimit()
	local heap = Heap.newMax(nil, 2)
	heap:pushAll({ 1, 2 })

	heap:clear()

	lu.assertFalse(heap:full())
	lu.assertTrue(heap:push(3))
	lu.assertTrue(heap:push(4))
	lu.assertEquals(heap:peek(), 4)
	lu.assertFalse(heap:push(5))
	lu.assertTrue(heap:full())
end

function TestHeapClear:testClearsEntriesAndAllowsReuse()
	local heap = Heap.new({ 2, 1, 3 })

	heap:clear()

	lu.assertTrue(heap:empty())
	lu.assertEquals(#heap, 0)
	lu.assertNil(heap:peek())
	lu.assertNil(heap:pop())
	lu.assertTrue(heap:push(4))
	lu.assertEquals(heap:peek(), 4)
end

function TestHeapConcat:testAcceptsHeapAndNilOperandsAsIterable()
	local source = Heap.new({ 1, 3 })
	local joinedHeap = source .. Heap.new({ 2, 4 })
	local joinedNil = source .. nil

	lu.assertEquals(#joinedHeap, 4)
	lu.assertEquals({ joinedHeap:pop(), joinedHeap:pop(), joinedHeap:pop(), joinedHeap:pop() }, { 1, 2, 3, 4 })
	lu.assertEquals({ joinedNil:pop(), joinedNil:pop() }, { 1, 3 })
	lu.assertEquals(snapshot(source), { 1, 3 })
end

function TestHeapConcat:testCombinesIterableWithoutMutatingEitherOperand()
	local source = Heap.new({ 10, 30 })
	local values = { 20, 40 }
	local joined = source .. values

	lu.assertNotIs(joined, source)
	lu.assertEquals(#source, 2)
	lu.assertEquals(values, { 20, 40 })
	lu.assertEquals({ joined:pop(), joined:pop(), joined:pop(), joined:pop() }, { 10, 20, 30, 40 })
end

function TestHeapConcat:testPreservesPriorityAndLeftCapacity()
	local source = Heap.newMax({ 2, 4 }, 3)
	local joined = source .. orderedIterable({ 1, 9 })

	lu.assertEquals(#joined, 3)
	lu.assertTrue(joined:full())
	lu.assertEquals({ joined:pop(), joined:pop(), joined:pop() }, { 4, 2, 1 })
	lu.assertEquals({ source:pop(), source:pop() }, { 4, 2 })
end

function TestHeapConcat:testRejectsNonTableOperands()
	local heap = Heap.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = heap .. "value"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = heap .. 42
	end)
end

function TestHeapContains:testFindsValuesWithoutConsumingHeap()
	local heap = Heap.new({ 10, 20, 30, 20 })
	local before = snapshot(heap)

	lu.assertTrue(heap:contains(10))
	lu.assertTrue(heap:contains(20))
	lu.assertTrue(heap:contains(30))
	lu.assertFalse(heap:contains(99))
	lu.assertEquals(snapshot(heap), before)
	lu.assertEquals(#heap, 4)
end

function TestHeapContains:testRejectsNilAndValuesIncomparableByDefaultComparator()
	local heap = Heap.new({ 10 })

	lu.assertErrorMsgContains("value should not be nil", function()
		heap:contains(nil)
	end)
	lu.assertErrorMsgContains("attempt to compare string with number", function()
		heap:contains("10")
	end)
end

function TestHeapContains:testUsesEqualityWhenComparatorConsidersObjectsEquivalent()
	local function byPriority(left, right)
		return Comparator.natural(left.priority, right.priority)
	end
	local stored = { priority = 1, name = "stored" }
	local equivalent = { priority = 1, name = "other" }
	local heap = Heap.new({ stored }, byPriority)

	lu.assertTrue(heap:contains(stored))
	lu.assertFalse(heap:contains(equivalent))
end

function TestHeapDrain:testDrainsInPriorityOrderAndRemovesEachYieldedValue()
	local heap = Heap.new({ 4, 1, 3, 2 })
	local nextValue = heap:drain()

	lu.assertEquals(nextValue(), 1)
	lu.assertEquals(#heap, 3)
	lu.assertEquals(nextValue(), 2)
	lu.assertEquals(nextValue(), 3)
	lu.assertEquals(nextValue(), 4)
	lu.assertNil(nextValue())
	lu.assertTrue(heap:empty())
end

function TestHeapDrain:testDrainsMaxHeapInDescendingPriorityOrder()
	local heap = Heap.newMax({ 4, 1, 3, 2 })
	local drained = {}

	for value in heap:drain() do
		table.insert(drained, value)
	end

	lu.assertEquals(drained, { 4, 3, 2, 1 })
	lu.assertTrue(heap:empty())
end

function TestHeapDrain:testEmptyDrainYieldsNoValues()
	local heap = Heap.new()
	local nextValue = heap:drain()

	lu.assertNil(nextValue())
	lu.assertTrue(heap:empty())
end

function TestHeapEmpty:testTracksPushPopAndClearTransitions()
	local heap = Heap.new()

	lu.assertTrue(heap:empty())
	heap:push(1)
	lu.assertFalse(heap:empty())
	heap:pop()
	lu.assertTrue(heap:empty())
	heap:push(2)
	heap:clear()
	lu.assertTrue(heap:empty())
end

function TestHeapEq:testComparesHeapStructureAndRejectsOtherTypes()
	local heap = Heap.new(orderedIterable({ 1, 2, 3 }))

	lu.assertTrue(heap == Heap.new(orderedIterable({ 1, 2, 3 })))
	lu.assertFalse(heap == Heap.new(orderedIterable({ 1, 2, 4 })))
	lu.assertFalse(heap == Heap.new(orderedIterable({ 1, 2 })))
	lu.assertFalse(heap == {})
	lu.assertFalse(heap == nil)
	lu.assertFalse(heap == 42)
end

function TestHeapEq:testDifferentLevelOrdersWithSameValuesAreNotEqual()
	local first = Heap.new(orderedIterable({ 1, 2, 3, 4, 5 }))
	local second = Heap.new(orderedIterable({ 1, 3, 2, 5, 4 }))

	lu.assertEquals(snapshot(first), { 1, 2, 3, 4, 5 })
	lu.assertEquals(snapshot(second), { 1, 3, 2, 5, 4 })
	lu.assertFalse(first == second)
end

function TestHeapEq:testEmptyHeapsCompareEqual()
	lu.assertTrue(Heap.new() == Heap.new())
end

function TestHeapFull:testBoundedHeapTracksCapacityAfterPushPopAndClear()
	local heap = Heap.new(nil, nil, 2)

	lu.assertFalse(heap:full())
	heap:push(1)
	lu.assertFalse(heap:full())
	heap:push(2)
	lu.assertTrue(heap:full())
	heap:pop()
	lu.assertFalse(heap:full())
	heap:push(3)
	lu.assertTrue(heap:full())
	heap:clear()
	lu.assertFalse(heap:full())
end

function TestHeapFull:testConstructorAtCapacityReportsFull()
	local heap = Heap.new({ 2, 1 }, nil, 2)

	lu.assertTrue(heap:full())
end

function TestHeapFull:testUnboundedHeapNeverReportsFull()
	local heap = Heap.new()

	lu.assertFalse(heap:full())
	heap:push(1)
	lu.assertFalse(heap:full())
	heap:push(2)
	lu.assertFalse(heap:full())
end

function TestHeapIndexOf:testFindsObjectByIdentityNotComparatorEquivalence()
	local function byPriority(left, right)
		return Comparator.natural(left.priority, right.priority)
	end
	local stored = { priority = 2, name = "stored" }
	local equivalent = { priority = 2, name = "other" }
	local heap = Heap.new({ { priority = 1 }, stored, { priority = 3 } }, byPriority)
	local index = heap:indexOf(stored)

	lu.assertNotNil(index)
	lu.assertEquals(snapshot(heap)[index], stored)
	lu.assertNil(heap:indexOf(equivalent))
end

function TestHeapIndexOf:testFindsOneOfDuplicateValues()
	local heap = Heap.new({ 4, 2, 2, 3 })
	local values = snapshot(heap)
	local index = heap:indexOf(2)

	lu.assertNotNil(index)
	lu.assertEquals(values[index], 2)
end

function TestHeapIndexOf:testFindsValuesAndReturnsNilWhenMissing()
	local heap = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })
	local values = snapshot(heap)

	for _, value in ipairs({ 10, 20, 30, 40, 50, 60, 70 }) do
		local index = heap:indexOf(value)
		lu.assertNotNil(index)
		lu.assertEquals(values[index], value)
	end
	lu.assertNil(heap:indexOf(5))
	lu.assertNil(heap:indexOf(25))
	lu.assertNil(heap:indexOf(99))
	lu.assertNil(Heap.new():indexOf(10))
end

function TestHeapIndexOf:testRejectsNilAndInvalidStartingIndexes()
	local heap = Heap.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("value should not be nil", function()
		heap:indexOf(nil)
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		heap:indexOf(10, "bad")
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		heap:indexOf(10, false)
	end)
	lu.assertErrorMsgContains("index should be positive", function()
		heap:indexOf(10, 0)
	end)
	lu.assertErrorMsgContains("index should be positive", function()
		heap:indexOf(10, -1)
	end)
	lu.assertErrorMsgContains("index should be an integer", function()
		heap:indexOf(10, 1.5)
	end)
	lu.assertErrorMsgContains("index should be an integer", function()
		heap:indexOf(10, math.huge)
	end)
	lu.assertErrorMsgContains("index should be positive", function()
		heap:indexOf(10, 0 / 0)
	end)
end

function TestHeapIndexOf:testSearchesMaxHeapValues()
	local heap = Heap.newMax({ 100, 80, 90, 40, 50, 60, 70 })
	local values = snapshot(heap)

	for _, value in ipairs({ 100, 80, 90, 40, 50, 60, 70 }) do
		local index = heap:indexOf(value)
		lu.assertNotNil(index)
		lu.assertEquals(values[index], value)
	end
	lu.assertNil(heap:indexOf(110))
	lu.assertNil(heap:indexOf(85))
end

function TestHeapIndexOf:testSearchesOnlyRequestedSubtree()
	local heap = Heap.new({ 1, 2, 3, 4, 5, 6, 7 })
	local values = snapshot(heap)

	lu.assertEquals(heap:indexOf(values[4], 2), 4)
	lu.assertNil(heap:indexOf(values[3], 2))
	lu.assertNil(heap:indexOf(values[2], 4))
	lu.assertNil(heap:indexOf(1, 100))
end

function TestHeapIsHeap:testRecognizesHeapVariantsAndRejectsOtherValues()
	lu.assertTrue(Heap.isHeap(Heap.new()))
	lu.assertTrue(Heap.isHeap(Heap.newMin()))
	lu.assertTrue(Heap.isHeap(Heap.newMax()))
	lu.assertFalse(Heap.isHeap({}))
	lu.assertFalse(Heap.isHeap(setmetatable({}, {})))
	lu.assertFalse(Heap.isHeap(nil))
	lu.assertFalse(Heap.isHeap(false))
	lu.assertFalse(Heap.isHeap("heap"))
	lu.assertFalse(Heap.isHeap(123))
end

function TestHeapLen:testTracksPushPopClearAndEmptyHeap()
	local heap = Heap.new()

	lu.assertEquals(#heap, 0)
	heap:push(1)
	heap:push(2)
	lu.assertEquals(#heap, 2)
	heap:pop()
	lu.assertEquals(#heap, 1)
	heap:clear()
	lu.assertEquals(#heap, 0)
end

function TestHeapNew:testBuildsHeapFromAssociativeValues()
	local heap = Heap.new({ third = 3, first = 1, second = 2 })

	lu.assertEquals(#heap, 3)
	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop() }, { 1, 2, 3 })
end

function TestHeapNew:testBuildsHeapFromIterableUsingCustomComparator()
	local heap = Heap.new({ 2, 5, 1, 4, 3 }, Comparator.reverse(Comparator.natural))

	lu.assertEquals(#heap, 5)
	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop() }, { 5, 4, 3, 2, 1 })
end

function TestHeapNew:testBuildsHeapFromIterableWithinCapacity()
	local heap = Heap.new(orderedIterable({ 3, 1, 2, 0 }), nil, 2)

	lu.assertEquals(#heap, 2)
	lu.assertTrue(heap:full())
	lu.assertEquals({ heap:pop(), heap:pop() }, { 1, 3 })
end

function TestHeapNew:testCopiesHeapIterable()
	local source = Heap.new({ 3, 1, 2 })
	local copy = Heap.new(source)

	lu.assertFalse(rawequal(copy, source))
	lu.assertEquals({ copy:pop(), copy:pop(), copy:pop() }, { 1, 2, 3 })
	lu.assertEquals({ source:pop(), source:pop(), source:pop() }, { 1, 2, 3 })
end

function TestHeapNew:testCreatesEmptyHeapWhenArgumentsAreOmitted()
	local heap = Heap.new()

	lu.assertTrue(Heap.isHeap(heap))
	lu.assertTrue(heap:empty())
	lu.assertEquals(#heap, 0)
	lu.assertNil(heap:peek())
end

function TestHeapNew:testRejectsInvalidCapacityValues()
	lu.assertErrorMsgContains("capacity should be a number", Heap.new, nil, nil, "bad")
	lu.assertErrorMsgContains("capacity should be positive", Heap.new, nil, nil, 0)
	lu.assertErrorMsgContains("capacity should be positive", Heap.new, nil, nil, -1)
	lu.assertErrorMsgContains("capacity should be positive", Heap.new, nil, nil, 0 / 0)
	lu.assertErrorMsgContains("capacity should be an integer", Heap.new, nil, nil, 1.5)
	lu.assertErrorMsgContains("capacity should be an integer", Heap.new, nil, nil, math.huge)
end

function TestHeapNew:testRejectsInvalidComparator()
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, "bad")
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, true)
end

function TestHeapNew:testRejectsInvalidIterableAndNilValues()
	lu.assertErrorMsgContains("iterable should be a table", Heap.new, "not a table")
	lu.assertErrorMsgContains("value should not be nil", Heap.new, iterableWithNilValue())
end

function TestHeapNewIndex:testRejectsAddingPropertiesAndShadowingMethods()
	local heap = Heap.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		heap.extra = "value"
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		heap[1] = 10
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		heap.peek = function() end
	end)
end

function TestHeapNewMax:testCreatesMaxHeapAndHonorsCapacity()
	local heap = Heap.newMax(orderedIterable({ 2, 5, 1, 4, 3 }), 3)

	lu.assertEquals(#heap, 3)
	lu.assertTrue(heap:full())
	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop() }, { 5, 2, 1 })
end

function TestHeapNewMax:testRejectsInvalidCapacity()
	lu.assertErrorMsgContains("capacity should be a number", Heap.newMax, nil, "bad")
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMax, nil, 0)
	lu.assertErrorMsgContains("capacity should be an integer", Heap.newMax, nil, 1.5)
end

function TestHeapNewMin:testCreatesMinHeapAndHonorsCapacity()
	local heap = Heap.newMin(orderedIterable({ 2, 5, 1, 4, 3 }), 3)

	lu.assertEquals(#heap, 3)
	lu.assertTrue(heap:full())
	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop() }, { 1, 2, 5 })
end

function TestHeapNewMin:testRejectsInvalidCapacity()
	lu.assertErrorMsgContains("capacity should be a number", Heap.newMin, nil, "bad")
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMin, nil, -1)
	lu.assertErrorMsgContains("capacity should be an integer", Heap.newMin, nil, 1.5)
end

function TestHeapPairs:testEmptyHeapYieldsNoEntries()
	local count = 0
	for _ in pairs(Heap.new()) do
		count = count + 1
	end
	lu.assertEquals(count, 0)
end

function TestHeapPairs:testIteratesLevelOrderWithoutConsumingHeap()
	local heap = Heap.new(orderedIterable({ 10, 30, 20, 50, 40 }))
	local keys = {}
	local values = {}

	for key, value in pairs(heap) do
		table.insert(keys, key)
		table.insert(values, value)
	end

	lu.assertEquals(keys, { 1, 2, 3, 4, 5 })
	lu.assertEquals(values, { 10, 30, 20, 50, 40 })
	lu.assertEquals(heap:peek(), 10)
	lu.assertEquals(#heap, 5)
end

function TestHeapPairs:testRepeatedIterationReturnsSameEntries()
	local heap = Heap.new(orderedIterable({ 10, 20, 30 }))

	lu.assertEquals(snapshot(heap), { 10, 20, 30 })
	lu.assertEquals(snapshot(heap), { 10, 20, 30 })
	lu.assertEquals(#heap, 3)
end

function TestHeapPeek:testReturnsHighestPriorityValueWithoutRemovingIt()
	local heap = Heap.new({ 4, 2, 3 })

	lu.assertEquals(heap:peek(), 2)
	lu.assertEquals(heap:peek(), 2)
	lu.assertEquals(#heap, 3)
	lu.assertEquals(heap:pop(), 2)
end

function TestHeapPeek:testReturnsNilWhenEmptyAndAfterLastPop()
	local heap = Heap.new()

	lu.assertNil(heap:peek())
	heap:push(1)
	heap:pop()
	lu.assertNil(heap:peek())
end

function TestHeapPeek:testUsesMaxPriorityForMaxHeap()
	lu.assertEquals(Heap.newMax({ 4, 2, 3 }):peek(), 4)
end

function TestHeapPop:testConsumesValuesInAscendingPriorityOrder()
	local heap = Heap.new({ 4, 5, 1, 3, 2 })

	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop() }, { 1, 2, 3, 4, 5 })
	lu.assertTrue(heap:empty())
	lu.assertNil(heap:pop())
end

function TestHeapPop:testConsumesDuplicateValuesWithoutLosingEntries()
	local heap = Heap.new({ 5, 5, 2, 8, 2, 5, 8 })

	lu.assertEquals(
		{ heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop() },
		{ 2, 2, 5, 5, 5, 8, 8 }
	)
	lu.assertEquals(#heap, 0)
end

function TestHeapPop:testReturnsNilWhenEmpty()
	local heap = Heap.new()

	lu.assertNil(heap:pop())
	lu.assertTrue(heap:empty())
	lu.assertEquals(#heap, 0)
end

function TestHeapPop:testUsesDescendingPriorityForMaxHeap()
	local heap = Heap.newMax({ 5, 7, 9, 6, 8 })

	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop() }, { 9, 8, 7, 6, 5 })
	lu.assertNil(heap:pop())
end

function TestHeapPush:testAddsValuesAndMaintainsPriorityOrder()
	local heap = Heap.new()

	lu.assertTrue(heap:push(4))
	lu.assertEquals(heap:peek(), 4)
	lu.assertTrue(heap:push(5))
	lu.assertTrue(heap:push(1))
	lu.assertEquals(heap:peek(), 1)
	lu.assertTrue(heap:push(3))
	lu.assertEquals(#heap, 4)
	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop(), heap:pop() }, { 1, 3, 4, 5 })
end

function TestHeapPush:testRejectsNilEvenWhenHeapIsAtCapacity()
	local heap = Heap.new(nil, nil, 1)
	heap:push(1)

	lu.assertErrorMsgContains("value should not be nil", function()
		heap:push(nil)
	end)
	lu.assertEquals(#heap, 1)
end

function TestHeapPush:testRejectsPushAtCapacityWithoutChangingContents()
	local heap = Heap.new({ 1, 3 }, nil, 2)

	lu.assertFalse(heap:push(0))
	lu.assertEquals(snapshot(heap), { 1, 3 })
	heap:pop()
	lu.assertTrue(heap:push(2))
	lu.assertEquals({ heap:pop(), heap:pop() }, { 2, 3 })
end

function TestHeapPush:testUsesMaxPriorityWhenConfigured()
	local heap = Heap.newMax()

	heap:push(2)
	heap:push(5)
	heap:push(3)
	lu.assertEquals(heap:peek(), 5)
end

function TestHeapPushAll:testAcceptsAssociativeTableValues()
	local heap = Heap.new()
	heap:pushAll({ high = 3, low = 1, middle = 2 })

	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop() }, { 1, 2, 3 })
end

function TestHeapPushAll:testAcceptsOtherHeapAsIterable()
	local heap = Heap.new({ 1 })
	heap:pushAll(Heap.new({ 3, 2 }))

	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop() }, { 1, 2, 3 })
end

function TestHeapPushAll:testAddsAllValuesAndPreservesExistingEntries()
	local heap = Heap.new({ 10, 20 })

	heap:pushAll({ 50, 30, 40, 5 })

	lu.assertEquals(#heap, 6)
	lu.assertEquals(
		{ heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop() },
		{ 5, 10, 20, 30, 40, 50 }
	)
end

function TestHeapPushAll:testEmptyIterableLeavesHeapUnchanged()
	local heap = Heap.new({ 1, 2, 3 })
	local before = snapshot(heap)

	heap:pushAll({})

	lu.assertEquals(snapshot(heap), before)
	lu.assertEquals(#heap, 3)
end

function TestHeapPushAll:testRejectsInvalidIterableNilValuesAndSelfInsertion()
	local heap = Heap.new({ 4, 1, 3, 2 })
	local before = snapshot(heap)

	lu.assertErrorMsgContains("iterable should be a table", function()
		heap:pushAll(nil)
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		heap:pushAll("not a table")
	end)
	lu.assertErrorMsgContains("value should not be nil", function()
		heap:pushAll(iterableWithNilValue())
	end)
	lu.assertErrorMsgContains("iterable should not be self", function()
		heap:pushAll(heap)
	end)
	lu.assertEquals(snapshot(heap), before)
end

function TestHeapPushAll:testStopsAtCapacityAndKeepsHighestPriorityAcceptedValues()
	local heap = Heap.new(nil, nil, 2)
	heap:pushAll(orderedIterable({ 3, 1, 2, 0 }))

	lu.assertTrue(heap:full())
	lu.assertEquals({ heap:pop(), heap:pop() }, { 1, 3 })
end

function TestHeapPushAll:testUsesCustomComparatorWhenMerging()
	local heap = Heap.newMax({ 1, 4 })
	heap:pushAll({ 2, 5, 3 })

	lu.assertEquals({ heap:pop(), heap:pop(), heap:pop(), heap:pop(), heap:pop() }, { 5, 4, 3, 2, 1 })
end

function TestHeapTostring:testFormatsEmptyAndPopulatedHeaps()
	lu.assertEquals(tostring(Heap.new()), "[  ]")
	lu.assertEquals(tostring(Heap.new(orderedIterable({ 1, 2, 3 }))), "[ 1, 2, 3 ]")
end

return {
	TestHeapClear = TestHeapClear,
	TestHeapConcat = TestHeapConcat,
	TestHeapContains = TestHeapContains,
	TestHeapDrain = TestHeapDrain,
	TestHeapEmpty = TestHeapEmpty,
	TestHeapEq = TestHeapEq,
	TestHeapFull = TestHeapFull,
	TestHeapIndexOf = TestHeapIndexOf,
	TestHeapIsHeap = TestHeapIsHeap,
	TestHeapLen = TestHeapLen,
	TestHeapNew = TestHeapNew,
	TestHeapNewIndex = TestHeapNewIndex,
	TestHeapNewMax = TestHeapNewMax,
	TestHeapNewMin = TestHeapNewMin,
	TestHeapPairs = TestHeapPairs,
	TestHeapPeek = TestHeapPeek,
	TestHeapPop = TestHeapPop,
	TestHeapPush = TestHeapPush,
	TestHeapPushAll = TestHeapPushAll,
	TestHeapTostring = TestHeapTostring,
}
