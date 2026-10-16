-- Imports
local lu = require("luaunit")
local Comparator = require("ff.func.comparator")
local Heap = require("ff.collections.heap")

-- Test helpers
local function entriesByIndex(heap)
	local entries = {}
	for index, value in pairs(heap) do
		entries[index] = value
	end
	return entries
end

-- Suite definitions
local TestHeap = {}

-- Scenarios: construction and type recognition

function TestHeap:testTypeGuardRecognizesHeapsAndRejectsOtherValues()
	-- Given: candidates include min/max Heaps, a table, and scalars.
	local h = Heap.new()

	-- When: check each candidate with Heap.isHeap.
	-- Then: only Heap instances return true.
	lu.assertTrue(Heap.isHeap(h))
	lu.assertTrue(Heap.isHeap(Heap.newMin()))
	lu.assertTrue(Heap.isHeap(Heap.newMax()))
	lu.assertFalse(Heap.isHeap({}))
	lu.assertFalse(Heap.isHeap(nil))
	lu.assertFalse(Heap.isHeap("heap"))
	lu.assertFalse(Heap.isHeap(123))
end

function TestHeap:testEmptyConstructorCreatesEmptyHeap()
	-- Given: construction receives no values.

	-- When: call Heap.new without arguments.
	local h = Heap.new()

	-- Then: the Heap is empty, has length zero, and returns nil from peek and pop.
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())
end

function TestHeap:testConstructorOrdersIterableValuesByPriority()
	-- Given: the iterable is { 30, 10, 20 }, not priority-ordered.

	-- When: initialize a Heap from those values.
	local h = Heap.new({ 30, 10, 20 })

	-- Then: peek and successive pops follow ascending priority.
	lu.assertEquals(#h, 3)
	lu.assertEquals(h:peek(), 10)
	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 30)
	lu.assertTrue(h:empty())
end

function TestHeap:testComparatorConstructorUsesRequestedPriority()
	-- Given: an empty Heap constructed with reverse-order comparator.
	local h = Heap.new(nil, Comparator.reverse(Comparator.natural))
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)

	-- When: push values 10, 30, and 20.
	h:push(10)
	h:push(30)
	h:push(20)

	-- Then: peek and successive pops return values in descending priority order.
	lu.assertEquals(h:peek(), 30)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 10)
	lu.assertTrue(h:empty())
end

function TestHeap:testComparatorConstructorOrdersInitialValuesByPriority()
	-- Given: initial values { 10, 30, 20 } use a reverse comparator.

	-- When: initialize the Heap with both inputs.
	local h = Heap.new({ 10, 30, 20 }, Comparator.reverse(Comparator.natural))

	-- Then: successive pops follow descending priority.
	lu.assertEquals(#h, 3)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 10)
end

function TestHeap:testCapacityConstructorsCreateEmptyBoundedHeaps()
	-- Given: capacity 5 is supplied without initial values.

	-- When: construct the standard, min, and max Heap variants.
	local h = Heap.new(nil, nil, 5)

	-- Then: each Heap is empty, length zero, and not full.
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

function TestHeap:testCapacityConstructorsLoadInitialValuesWithinLimit()
	-- Given: three initial values fit within capacity 5.

	-- When: initialize each Heap variant with those values.
	local h = Heap.new({ 10, 20, 30 }, nil, 5)

	-- Then: each contains all values and remains below capacity.
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

function TestHeap:testConstructorsRejectInvalidComparatorAndCapacity()
	-- Given: constructor inputs include invalid comparators and capacities.
	-- When: pass each invalid combination to a Heap constructor.
	-- Then: errors identify the invalid comparator or capacity.
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

function TestHeap:testMinAndMaxConstructorsProduceExpectedPriorityOrder()
	-- Given: both constructors receive the same unordered values.

	-- When: construct each Heap type and pop all values.
	local minH = Heap.newMin({ 5, 3, 8, 1 })

	-- Then: min-heap removals ascend; max-heap removals descend.
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

-- Scenarios: reads and inspection

function TestHeap:testContainsFindsStoredValuesWithoutConsumingHeap()
	-- Given: an empty Heap.
	local h = Heap.new()

	-- When: check membership of absent value 1.
	-- Then: contains returns false.
	lu.assertFalse(h:contains(1))

	-- When: push 10, 20, and 30 into the Heap.
	h:push(10)
	h:push(20)
	h:push(30)

	-- Then: contains finds all stored values without consuming elements.
	lu.assertTrue(h:contains(10))
	lu.assertTrue(h:contains(20))
	lu.assertTrue(h:contains(30))
	lu.assertFalse(h:contains(99))
	lu.assertEquals(#h, 3)
	lu.assertEquals(h:peek(), 10)

	-- When: pop the smallest element 10.
	h:pop()

	-- Then: popped element is no longer contained while others remain.
	lu.assertFalse(h:contains(10))
	lu.assertTrue(h:contains(20))
	lu.assertTrue(h:contains(30))
end

function TestHeap:testContainsRejectsNilAndIncomparableValues()
	-- Given: an empty Heap.
	local h = Heap.new()

	-- When: query nil value.
	-- Then: validation error is raised.
	lu.assertErrorMsgContains("value should not be nil", function()
		h:contains(nil)
	end)

	-- When: push 10 and query with incomparable string "10".
	h:push(10)

	-- Then: comparison error is raised.
	lu.assertErrorMsgContains("attempt to compare string with number", function()
		h:contains("10")
	end)
end

function TestHeap:testIterationYieldsHeapValuesInLevelOrder()
	-- Given: the Heap starts empty and receives b, d, c, and a.
	local h = Heap.new()

	-- When: push those values, then collect index-value pairs with pairs.
	h:push("b")
	h:push("d")
	h:push("c")
	h:push("a")

	local keys = {}
	local res = {}
	for i, item in pairs(h) do
		table.insert(keys, i)
		table.insert(res, item)
	end

	-- Then: indexes are sequential, values expose level order, and Heap remains intact.
	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertFalse(h:empty())
	lu.assertEquals(#h, 4)
	lu.assertEquals(h:peek(), "a")
end

function TestHeap:testIterationOfEmptyHeapYieldsNoValues()
	-- Given: the Heap has no entries.
	local h = Heap.new()

	local count = 0

	-- When: count values yielded by pairs.
	for _ in pairs(h) do
		count = count + 1
	end

	-- Then: the iterator yields zero values.
	lu.assertEquals(count, 0)
end

function TestHeap:testRepeatedIterationPreservesHeapContents()
	-- Given: the Heap contains 10, 20, and 30 for two non-consuming traversals.
	local h = Heap.new({ 10, 20, 30 })

	local firstRun = {}

	-- When: collect values in two pairs traversals.
	for _, item in pairs(h) do
		table.insert(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(h) do
		table.insert(secondRun, item)
	end

	-- Then: both results match and the Heap length is unchanged.
	lu.assertEquals(firstRun, { 10, 20, 30 })
	lu.assertEquals(secondRun, { 10, 20, 30 })
	lu.assertEquals(#h, 3)
end

function TestHeap:testIterationYieldsValuesInLevelOrder()
	-- Given: the Heap starts empty and receives 10, 30, 20, 50, and 40.
	local h = Heap.new()

	-- When: push the values and collect index-value pairs with pairs.
	h:push(10)
	h:push(30)
	h:push(20)
	h:push(50)
	h:push(40)

	-- Root to leaf level-order: root(10), left(30), right(20), left.left(50), left.right(40)
	local levelOrder = {}
	for _, item in pairs(h) do
		table.insert(levelOrder, item)
	end

	-- Then: collected entries expose the resulting level-order layout.
	lu.assertEquals(levelOrder, { 10, 30, 20, 50, 40 })
	lu.assertEquals(#h, 5)
end

function TestHeap:testIndexOfFindsStoredValuesAndReturnsNilForMissingValues()
	-- Given: the Heap contains seven values and one queried value is absent.
	local h = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })
	local entries = entriesByIndex(h)

	-- Root element is at index 1

	-- When: search for each requested value with indexOf.
	-- Then: stored values have indexes; the absent value returns nil.
	lu.assertEquals(h:indexOf(10), 1)

	-- Every existing value returns a public heap index.
	for _, val in ipairs({ 10, 20, 30, 40, 50, 60, 70 }) do
		local idx = h:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(entries[idx], val)
	end

	-- Smaller than root (pruned immediately)
	lu.assertNil(h:indexOf(5))

	-- Greater than root but not in heap
	lu.assertNil(h:indexOf(25))
	lu.assertNil(h:indexOf(99))

	-- Empty heap
	lu.assertNil(Heap.new():indexOf(10))
end

function TestHeap:testIndexOfSearchesOnlyRequestedSubtree()
	-- Given: distinct values occupy the root and child subtrees.
	local h = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })

	-- Searching starting from left child (index 2) finds elements in that subtree
	local leftVal = 20

	-- When: search from the root and a selected subtree index.
	local idx = h:indexOf(leftVal, 2)

	-- Then: each search is limited to nodes beneath its start index.
	lu.assertEquals(idx, 2)

	-- Value at child index 4 belongs to the requested subtree.
	if #h >= 4 then
		local childVal = 40
		lu.assertEquals(h:indexOf(childVal, 2), 4)
	end

	-- Value at right child index 3 is outside the requested left subtree.
	local rightVal = 30
	lu.assertNil(h:indexOf(rightVal, 2))

	-- Searching beyond heap bounds returns nil
	lu.assertNil(h:indexOf(10, 100))
end

function TestHeap:testMaxHeapIndexOfFindsValuesAndRejectsValuesOutsideHeap()
	-- Given: the max-heap stores 10 through 70 and an absent value is queried.
	local maxH = Heap.newMax({ 70, 60, 50, 40, 30, 20, 10 })
	local entries = entriesByIndex(maxH)

	-- Root is max element (index 1)

	-- When: search for stored and absent values.
	-- Then: stored values have indexes; the absent value has no match.
	lu.assertEquals(maxH:indexOf(70), 1)

	-- Every existing value returns a public heap index.
	for _, val in ipairs({ 70, 60, 50, 40, 30, 20, 10 }) do
		local idx = maxH:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(entries[idx], val)
	end

	-- Larger than root (pruned immediately)
	lu.assertNil(maxH:indexOf(100))

	-- Smaller than root but not in heap
	lu.assertNil(maxH:indexOf(25))
	lu.assertNil(maxH:indexOf(0))
end

function TestHeap:testMaxHeapIndexOfSearchesOnlyRequestedSubtree()
	-- Given: the max-heap root and child subtrees contain distinct values.
	local maxH = Heap.newMax({ 100, 80, 90, 40, 50, 60, 70 })

	local leftVal = 80
	local rightVal = 90

	-- Search starting at root finds both

	-- When: search from the root and a selected subtree.
	-- Then: results include matches reachable from each start only.
	lu.assertEquals(maxH:indexOf(leftVal, 1), 2)
	lu.assertEquals(maxH:indexOf(rightVal, 1), 3)

	-- Search starting at left subtree finds leftVal and its descendants
	lu.assertEquals(maxH:indexOf(leftVal, 2), 2)
	if #maxH >= 4 then
		local childVal = 40
		lu.assertEquals(maxH:indexOf(childVal, 2), 4)
	end

	-- Search starting at left subtree does NOT find rightVal (disjoint subtree)
	lu.assertNil(maxH:indexOf(rightVal, 2))
end

function TestHeap:testMaxHeapIndexOfFindsDuplicateValues()
	-- Given: the max-heap stores the same value at multiple indexes.
	local maxH = Heap.newMax({ 50, 40, 40, 30, 20, 20, 10 })
	local entries = entriesByIndex(maxH)

	-- When: locate that repeated value with indexOf.
	for _, val in ipairs({ 50, 40, 30, 20, 10 }) do
		local idx = maxH:indexOf(val)

		-- Then: a matching index is returned.
		lu.assertNotNil(idx)
		lu.assertEquals(entries[idx], val)
	end
end

function TestHeap:testIndexOfFindsObjectValuesWithEqualPriority()
	-- Given: objects share priority but have distinct identities.
	local function cmp(a, b)
		return Comparator.natural(a.priority, b.priority)
	end

	local h = Heap.new(nil, cmp)
	local a = { priority = 10, name = "A" }
	local b = { priority = 10, name = "B" }
	local c = { priority = 10, name = "C" }

	-- When: push both objects, then locate each object reference.
	h:push(a)
	h:push(b)

	-- Then: min-heap indexOf finds each object by identity.
	lu.assertEquals(h:indexOf(a), 1)
	lu.assertEquals(h:indexOf(b), 2)
	lu.assertNil(h:indexOf(c))
	lu.assertFalse(h:contains(c))
end

function TestHeap:testMaxHeapIndexOfFindsObjectValuesWithEqualPriority()
	-- Given: max-heap objects share priority but have distinct identities.
	local function maxObjCmp(a, b)
		return Comparator.reverse(Comparator.natural)(a.priority, b.priority)
	end

	local h = Heap.new(nil, maxObjCmp)
	local a = { priority = 50, name = "A" }
	local b = { priority = 50, name = "B" }
	local c = { priority = 20, name = "C" }
	local d = { priority = 50, name = "D" }

	-- When: push both max-heap objects, then locate each reference.
	h:push(a)
	h:push(b)
	h:push(c)

	-- Then: max-heap indexOf finds each object by identity.
	lu.assertEquals(h:indexOf(a), 1)
	lu.assertEquals(h:indexOf(b), 2)
	lu.assertEquals(h:indexOf(c), 3)
	lu.assertNil(h:indexOf(d))
	lu.assertFalse(h:contains(d))
end

function TestHeap:testIndexOfRejectsNilValuesAndInvalidStartIndexes()
	-- Given: the Heap contains three values; nil and invalid start indexes are queried.
	local h = Heap.new({ 10, 20, 30 })

	-- When: search for nil and use invalid starting indexes.
	-- Then: indexOf raises validation errors for those arguments.
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

function TestHeap:testUnboundedHeapsNeverReportFull()
	-- Given: an unbounded Heap.
	local h = Heap.new()

	-- When: check fullness initially and after pushes.
	local fullBefore = h:full()
	h:push(1)
	local fullAfter1 = h:full()
	h:push(2)
	local fullAfter2 = h:full()

	-- Then: full returns false at every step.
	lu.assertFalse(fullBefore)
	lu.assertFalse(fullAfter1)
	lu.assertFalse(fullAfter2)

	-- When: check min and max constructor variants.
	local minH = Heap.newMin()
	local maxH = Heap.newMax()

	-- Then: neither min nor max heap reports full.
	lu.assertFalse(minH:full())
	lu.assertFalse(maxH:full())
end

function TestHeap:testBoundedHeapReportsNotFullBelowCapacity()
	-- Given: a bounded Heap with capacity 3.
	local h = Heap.new(nil, nil, 3)

	-- When: check fullness initially.
	-- Then: full returns false.
	lu.assertFalse(h:full())

	-- When: push values below capacity.
	h:push(1)
	h:push(2)

	-- Then: full remains false.
	lu.assertFalse(h:full())
end

function TestHeap:testBoundedHeapReportsFullAtCapacity()
	-- Given: the Heap has a fixed capacity.
	local h = Heap.new(nil, nil, 2)

	-- When: insert exactly that many values.
	h:push(1)
	h:push(2)

	-- Then: full returns true.
	lu.assertTrue(h:full())
end

function TestHeap:testRemovingValuesOrClearingMakesCapacityAvailable()
	-- Given: a bounded Heap with capacity 2, filled to capacity.
	local h = Heap.new(nil, nil, 2)
	h:push(1)
	h:push(2)
	lu.assertTrue(h:full())

	-- When: pop one element.
	h:pop()

	-- Then: heap is no longer full.
	lu.assertFalse(h:full())

	-- When: push another element.
	h:push(3)

	-- Then: heap becomes full again.
	lu.assertTrue(h:full())

	-- When: clear the heap.
	h:clear()

	-- Then: heap is empty and capacity is restored.
	lu.assertFalse(h:full())
	lu.assertEquals(#h, 0)
end

function TestHeap:testFullHeapRejectsPush()
	-- Given: a Heap has capacity 3 and starts empty.
	local h = Heap.new(nil, nil, 3)

	-- When: push a, b, and c, then attempt d.
	h:push("a")
	h:push("b")
	h:push("c")

	-- Then: full returns true and the fourth push returns false.
	lu.assertTrue(h:full())
	lu.assertFalse(h:push("d"))
end

-- Scenarios: state changes

function TestHeap:testPushMaintainsSmallestValueAtHeapRoot()
	-- Given: an empty min-heap.
	local h = Heap.new()

	-- When: push 4.
	h:push(4)

	-- Then: root is 4.
	lu.assertEquals(h:peek(), 4)

	-- When: push larger value 5.
	h:push(5)

	-- Then: root remains 4.
	lu.assertEquals(h:peek(), 4)

	-- When: push smaller value 1.
	h:push(1)

	-- Then: root updates to 1.
	lu.assertEquals(h:peek(), 1)

	-- When: push 3.
	h:push(3)

	-- Then: root remains 1.
	lu.assertEquals(h:peek(), 1)
end

function TestHeap:testPushRejectsNilValues()
	-- Given: the min-heap is empty before a nil push.
	local h = Heap.new()

	-- When: push nil.
	-- Then: push reports that values cannot be nil.
	lu.assertErrorMsgContains("value should not be nil", function()
		h:push(nil)
	end)
end

function TestHeap:testPopReturnsValuesInAscendingPriorityOrder()
	-- Given: the min-heap starts empty and will receive 4, 5, 1, 3, and 2.
	local h = Heap.new()

	-- When: push the values, then pop until no entries remain.
	h:push(4)
	h:push(5)
	h:push(1)
	h:push(3)
	h:push(2)

	-- Then: pops return 1 through 5 in ascending order, then nil.
	lu.assertEquals(h:pop(), 1)
	lu.assertEquals(h:pop(), 2)
	lu.assertEquals(h:pop(), 3)
	lu.assertEquals(h:pop(), 4)
	lu.assertEquals(h:pop(), 5)
	lu.assertNil(h:pop())
end

function TestHeap:testPopAndPeekOnEmptyHeapReturnNil()
	-- Given: an empty Heap is queried through pop and peek.
	local h = Heap.new()

	-- When: call pop and peek.
	-- Then: both methods return nil; Heap remains empty with length zero.
	lu.assertNil(h:pop())
	lu.assertNil(h:peek())
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
end

function TestHeap:testPopAndClearUpdateEmptyStateAndAllowReuse()
	-- Given: an empty Heap.
	local h = Heap.new()
	lu.assertTrue(h:empty())

	-- When: push two values and pop them both.
	h:push(2)
	h:push(3)
	h:pop()
	h:pop()

	-- Then: the heap returns to empty.
	lu.assertTrue(h:empty())

	-- When: push two values and clear the heap.
	h:push(10)
	h:push(20)
	h:clear()

	-- Then: the heap is empty with length zero and nil peek.
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())

	-- When: push value 42 into the cleared heap.
	h:push(42)

	-- Then: heap functions normally after clear.
	lu.assertEquals(#h, 1)
	lu.assertEquals(h:peek(), 42)
	lu.assertEquals(h:pop(), 42)
	lu.assertTrue(h:empty())
end

function TestHeap:testPopPreservesDuplicateValues()
	-- Given: the Heap starts empty and will receive repeated 2, 5, and 8 values.
	local h = Heap.new()

	-- When: push the values, then pop every entry.
	h:push(5)
	h:push(5)
	h:push(2)
	h:push(8)
	h:push(2)
	h:push(5)
	h:push(8)

	-- Then: each repeated value is returned exactly as many times as inserted.
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

function TestHeap:testMaxHeapPopsValuesInDescendingPriorityOrder()
	-- Given: a max-heap starts with 5, 7, and 9.
	local h = Heap.newMax({ 5, 7, 9 })

	-- When: push 6, 8, and another 7, then pop every entry.
	h:push(6)
	h:push(8)
	h:push(7)

	-- Then: pops return 9, 8, 7, 7, 6, 5, then nil.
	lu.assertEquals(h:pop(), 9)
	lu.assertEquals(h:pop(), 8)
	lu.assertEquals(h:pop(), 7)
	lu.assertEquals(h:pop(), 7)
	lu.assertEquals(h:pop(), 6)
	lu.assertEquals(h:pop(), 5)
	lu.assertNil(h:pop())
end

function TestHeap:testHeapOrdersStringValuesByNaturalPriority()
	-- Given: the Heap starts empty and will receive b, e, c, a, and d.
	local h = Heap.new()

	-- When: push each string, then pop every entry.
	h:push("b")
	h:push("e")
	h:push("c")
	h:push("a")
	h:push("d")

	-- Then: pops return the strings in alphabetical order.
	lu.assertEquals(h:pop(), "a")
	lu.assertEquals(h:pop(), "b")
	lu.assertEquals(h:pop(), "c")
	lu.assertEquals(h:pop(), "d")
	lu.assertEquals(h:pop(), "e")
	lu.assertNil(h:pop())
end

function TestHeap:testHeapUsesCustomComparatorForObjectPriority()
	-- Given: objects use a custom comparator on priority; initial priorities are 5, 7, and 9.
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

	-- When: push priorities 6 and 8, then pop all objects.
	h:push(obj(6, true))
	h:push(obj(8, false))

	-- Then: objects return in descending priority order with payloads intact.
	lu.assertEquals(h:pop(), { priority = 9, value = "c" })
	lu.assertEquals(h:pop(), { priority = 8, value = false })
	lu.assertEquals(h:pop(), { priority = 7, value = "b" })
	lu.assertEquals(h:pop(), { priority = 6, value = true })
	lu.assertEquals(h:pop(), { priority = 5, value = "a" })
	lu.assertNil(h:pop())
end

function TestHeap:testDrainYieldsValuesInAscendingPriorityOrderAndEmptiesHeap()
	-- Given: the min-heap starts empty and will receive b, d, c, and a.
	local h = Heap.new()

	-- When: push the strings, then collect items from drain.
	h:push("b")
	h:push("d")
	h:push("c")
	h:push("a")

	local res = {}
	for item in h:drain() do
		table.insert(res, item)
	end

	-- Drain yields in priority order (min-to-max)

	-- Then: drain yields a through d in order and leaves Heap empty.
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())
end

function TestHeap:testMaxHeapDrainYieldsValuesInDescendingPriorityOrder()
	-- Given: the max-heap contains five values.
	local h = Heap.newMax({ 10, 50, 30, 20, 40 })

	local res = {}

	-- When: collect items from drain.
	for item in h:drain() do
		table.insert(res, item)
	end

	-- Max-heap drain yields descending order

	-- Then: values descend by priority.
	lu.assertEquals(res, { 50, 40, 30, 20, 10 })
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
end

function TestHeap:testDrainOnEmptyHeapYieldsNoValues()
	-- Given: the Heap contains no values and is observed through drain.
	local h = Heap.new()

	local count = 0

	-- When: count values from drain.
	for _ in h:drain() do
		count = count + 1
	end

	-- Then: drain yields nothing and the Heap remains empty.
	lu.assertEquals(count, 0)
	lu.assertTrue(h:empty())
end

function TestHeap:testBoundedHeapRejectsPushAtCapacityAndAcceptsAfterPop()
	-- Given: capacity is 2 and the Heap begins empty; values 10 and another item will fill it.
	local h = Heap.new(nil, nil, 2)

	-- When: push to capacity, try another push, pop once, and retry.
	-- Then: overflow is rejected; push succeeds after pop frees a slot.
	lu.assertTrue(h:push(10))
	lu.assertEquals(#h, 1)
	lu.assertFalse(h:full())

	lu.assertTrue(h:push(20))
	lu.assertEquals(#h, 2)
	lu.assertTrue(h:full())

	-- Pushing to full heap returns false and does not modify heap
	lu.assertFalse(h:push(30))
	lu.assertEquals(#h, 2)

	-- Popping makes room
	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(#h, 1)
	lu.assertFalse(h:full())

	lu.assertTrue(h:push(30))
	lu.assertEquals(#h, 2)
	lu.assertTrue(h:full())
end

-- Scenarios: metamethods and formatting

function TestHeap:testConcatAppendsValuesFromIterableCollections()
	-- Given: a Heap initialized with { 10, 20, 30 }.
	local h = Heap.new() .. { 10, 20, 30 }
	lu.assertEquals(#h, 3)

	-- When: concatenate with nil.
	h = h .. nil

	-- Then: length remains 3.
	lu.assertEquals(#h, 3)

	-- When: concatenate with a LinkedList containing 40, 50, 60.
	local ll = require("ff.collections.linkedlist").new()
	ll:pushBack(40)
	ll:pushBack(50)
	ll:pushBack(60)
	h = h .. ll

	-- Then: length becomes 6 and pops yield all values in priority order.
	lu.assertEquals(#h, 6)
	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 40)
	lu.assertEquals(h:pop(), 50)
	lu.assertEquals(h:pop(), 60)
end

function TestHeap:testConcatRejectsNonTableValues()
	-- Given: the Heap is empty before string and number operands are tried.
	local h = Heap.new()

	-- When: concatenate values that are not tables.
	-- Then: each operand raises the iterable type error.
	lu.assertErrorMsgContains("iterable should be a table", function()
		h = h .. "not a table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		h = h .. 42
	end)
end

function TestHeap:testHeapsWithSameValuesCompareEqual()
	-- Given: Heaps match, differ by one value, or have different lengths.
	local h1 = Heap.new({ 1, 2, 3 })
	local h2 = Heap.new({ 1, 2, 3 })
	local h3 = Heap.new({ 1, 2, 4 })
	local h4 = Heap.new({ 1, 2 })

	-- Boolean assertions here intentionally exercise Heap.__eq.

	-- When: compare each Heap with the first, including a plain table.
	-- Then: only matching Heap contents compare equal.
	lu.assertTrue(h1 == h2)
	lu.assertFalse(h1 == h3)
	lu.assertFalse(h1 == h4)
	lu.assertFalse(h1 == {})
	lu.assertFalse(h1 == nil)
	lu.assertFalse(h1 == 42)
end

function TestHeap:testEmptyHeapsCompareEqual()
	-- Given: both Heaps contain no values.
	local h1 = Heap.new()
	local h2 = Heap.new()
	-- This assertion exercises Heap.__eq; assertEquals compares table structure.

	-- When: compare the empty Heaps with ==.
	-- Then: equality returns true.
	lu.assertTrue(h1 == h2)
end

function TestHeap:testLengthTracksPushPopAndClearOperations()
	-- Given: an empty Heap.
	local h = Heap.new()
	lu.assertEquals(#h, 0)

	-- When: push three values.
	h:push(10)
	h:push(20)
	h:push(30)

	-- Then: length increases to 3.
	lu.assertEquals(#h, 3)

	-- When: pop one value.
	h:pop()

	-- Then: length decreases to 2.
	lu.assertEquals(#h, 2)

	-- When: clear the heap.
	h:clear()

	-- Then: length resets to 0.
	lu.assertEquals(#h, 0)
end

function TestHeap:testToStringFormatsHeapValues()
	-- Given: the Heap contains three values.
	local h = Heap.new({ 1, 2, 3 })

	-- When: format the populated Heap with tostring.
	local str = tostring(h)

	-- Then: formatted text includes each stored value.
	lu.assertStrContains(str, "1")
	lu.assertStrContains(str, "2")
	lu.assertStrContains(str, "3")
	lu.assertStrContains(str, "[")
	lu.assertStrContains(str, "]")
end

function TestHeap:testToStringFormatsEmptyHeap()
	-- Given: an empty Heap is prepared for text formatting.
	local h = Heap.new()

	-- When: format the empty Heap with tostring.
	local str = tostring(h)

	-- Then: formatted text represents an empty Heap.
	lu.assertEquals(str, "[  ]")
end

function TestHeap:testNewPropertiesAndMethodsCannotBeAddedOrReplaced()
	-- Given: a Heap defines its public methods and has no added fields.
	local h = Heap.new()

	-- disallow adding properties

	-- When: assign a property, numeric key, function, and replacement method.
	-- Then: every assignment raises the property-protection error.
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.peek = function() end
	end)
end

-- Suite map
return { TestHeap = TestHeap }
