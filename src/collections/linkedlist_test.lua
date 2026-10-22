-- Imports
local lu = require("luaunit")
local LinkedList = require("ff.collections.linkedlist")

-- Suite definitions
local TestLinkedList = {}

-- Scenarios: construction and type recognition

function TestLinkedList:testTypeGuard_Recognizes_LinkedListsAndRejectsOtherValues()
	-- Given: candidates include a LinkedList, a table, and scalar values.
	-- When: check each candidate with LinkedList.isLinkedList.
	-- Then: only the LinkedList instance returns true.
	lu.assertTrue(LinkedList.isLinkedList(LinkedList.new()))
	lu.assertFalse(LinkedList.isLinkedList({}))
	lu.assertFalse(LinkedList.isLinkedList(nil))
	lu.assertFalse(LinkedList.isLinkedList("linkedlist"))
	lu.assertFalse(LinkedList.isLinkedList(123))
end

function TestLinkedList:testEmptyConstructor_Creates_EmptyLinkedList()
	-- Given: construction receives no values.

	-- When: call LinkedList.new without arguments.
	local ll = LinkedList.new()

	-- Then: the list reports empty, has length zero, and both ends return nil.
	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())
	lu.assertNil(ll:popFront())
	lu.assertNil(ll:popBack())
end

function TestLinkedList:testConstructor_Preserves_IterableOrder()
	-- Given: the iterable is { 10, 20, 30 }.

	-- When: initialize a LinkedList from that table.
	local ll = LinkedList.new({ 10, 20, 30 })

	-- Then: endpoints and successive front removals follow 10, 20, 30.
	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:peekFront(), 10)
	lu.assertEquals(ll:peekBack(), 30)
	lu.assertEquals(ll:popFront(), 10)
	lu.assertEquals(ll:popFront(), 20)
	lu.assertEquals(ll:popFront(), 30)
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testConstructor_CopiesValues_FromAnotherLinkedList()
	-- Given: the source list contains 1, 2, and 3.
	local ll1 = LinkedList.new({ 1, 2, 3 })

	-- When: initialize another LinkedList from the source.
	local ll2 = LinkedList.new(ll1)

	-- Then: both lists contain equal values and compare equal.
	lu.assertEquals(#ll2, 3)
	-- This assertion exercises LinkedList.__eq; assertEquals compares table structure.
	lu.assertTrue(ll1 == ll2)
end

function TestLinkedList:testConstructor_Rejects_NonTableIterables()
	-- Given: constructor inputs include a string, number, and boolean.
	-- When: pass each scalar as the iterable.
	-- Then: each call reports that iterable must be a table.
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, "invalid")
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, 123)
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, true)
end

-- Scenarios: reads and inspection

function TestLinkedList:testEndpointPeeks_Return_ValuesAtBothEnds()
	-- Given: an empty LinkedList.
	local ll = LinkedList.new()

	-- When: peek endpoints of the empty list.
	-- Then: both front and back return nil.
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())

	-- When: push 10 to the front.
	ll:pushFront(10)

	-- Then: both front and back return 10 with length 1.
	lu.assertEquals(ll:peekFront(), 10)
	lu.assertEquals(ll:peekBack(), 10)
	lu.assertEquals(#ll, 1)

	-- When: push 20 to the back.
	ll:pushBack(20)

	-- Then: front remains 10 and back becomes 20 with length 2.
	lu.assertEquals(ll:peekFront(), 10)
	lu.assertEquals(ll:peekBack(), 20)
	lu.assertEquals(#ll, 2)

	-- When: push 5 to the front.
	ll:pushFront(5)

	-- Then: front updates to 5 and back remains 20 with length 3.
	lu.assertEquals(ll:peekFront(), 5)
	lu.assertEquals(ll:peekBack(), 20)
	lu.assertEquals(#ll, 3)
end

function TestLinkedList:testContains_ReportsStoredValues_AndRejectsMissingValuesWithoutMutation()
	-- Given: an empty LinkedList.
	local ll = LinkedList.new()

	-- When: check membership of absent value 10.
	-- Then: contains returns false.
	lu.assertFalse(ll:contains(10))

	-- When: push 10, 20, and 30 into the list.
	ll:pushBack(10)
	ll:pushBack(20)
	ll:pushBack(30)

	-- Then: contains finds stored values, rejects absent and wrong-type values, and preserves list state.
	lu.assertTrue(ll:contains(10))
	lu.assertTrue(ll:contains(20))
	lu.assertTrue(ll:contains(30))
	lu.assertFalse(ll:contains(40))
	lu.assertFalse(ll:contains("10"))
	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:peekFront(), 10)
end

function TestLinkedList:testContains_Rejects_NilValues()
	-- Given: nil is queried against an empty LinkedList.
	local ll = LinkedList.new()

	-- When: check membership of nil.
	-- Then: contains reports that values cannot be nil.
	lu.assertErrorMsgContains("value should not be nil", function()
		ll:contains(nil)
	end)
end

function TestLinkedList:testIteration_Yields_OneBasedIndexesAndValues()
	-- Given: indexes 1 through 3 contain 10, 20, and 30.
	local ll = LinkedList.new({ 10, 20, 30 })

	local indices = {}
	local values = {}

	-- When: collect each index-value pair from pairs.
	for idx, val in pairs(ll) do
		table.insert(indices, idx)
		table.insert(values, val)
	end

	-- Then: collected indexes and values preserve insertion order; list length stays 3.
	lu.assertEquals(indices, { 1, 2, 3 })
	lu.assertEquals(values, { 10, 20, 30 })
	-- Iterator must not consume or modify the list
	lu.assertEquals(#ll, 3)
end

function TestLinkedList:testEmptyLinkedListIteration_Yields_NoValues()
	-- Given: the LinkedList contains no nodes.
	local ll = LinkedList.new()
	local count = 0

	-- When: count values yielded by pairs.
	for _ in pairs(ll) do
		count = count + 1
	end

	-- Then: the iterator yields zero values.
	lu.assertEquals(count, 0)
end

-- Scenarios: state changes

function TestLinkedList:testClear_Empties_LinkedListAndAllowsReuse()
	-- Given: an empty LinkedList.
	local ll = LinkedList.new()
	lu.assertTrue(ll:empty())

	-- When: push 1 and clear the list.
	ll:pushFront(1)
	ll:clear()

	-- Then: list is empty with length 0 and endpoints are nil.
	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())

	-- When: push values 2 and 3, then pop both ends.
	ll:pushBack(2)
	ll:pushBack(3)
	ll:popFront()
	ll:popBack()

	-- Then: list returns to empty with length 0.
	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)

	-- When: push 99 to the back of the cleared list.
	ll:pushBack(99)

	-- Then: list functions normally after clear and reuse.
	lu.assertEquals(#ll, 1)
	lu.assertEquals(ll:peekFront(), 99)
	lu.assertEquals(ll:peekBack(), 99)
	lu.assertEquals(ll:popFront(), 99)
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testFrontInsertionAndRemoval_Preserve_LifoOrder()
	-- Given: an empty list will receive 1, 2, and 3 at the front.
	local ll = LinkedList.new()

	-- When: push values at the front, then remove them from the front.
	ll:pushFront(1)
	ll:pushFront(2)
	ll:pushFront(3)

	-- Then: front removals return 3, 2, 1, then nil.
	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:popFront(), 3)
	lu.assertEquals(ll:popFront(), 2)
	lu.assertEquals(ll:popFront(), 1)
	lu.assertNil(ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testBackInsertionAndRemoval_Preserve_LifoOrder()
	-- Given: an empty list will receive 1, 2, and 3 at the back.
	local ll = LinkedList.new()

	-- When: append values at the back, then remove them from the back.
	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	-- Then: back removals return 3, 2, 1, then nil.
	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:popBack(), 3)
	lu.assertEquals(ll:popBack(), 2)
	lu.assertEquals(ll:popBack(), 1)
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testFrontInsertionAndBackRemoval_Preserve_OppositeOrder()
	-- Given: an empty list receives 1, 2, and 3 at the front.
	local ll = LinkedList.new()

	-- When: push at the front, then remove from the back.
	ll:pushFront(1)
	ll:pushFront(2)
	ll:pushFront(3)

	-- Then: back removals return 1, 2, 3, then nil.
	lu.assertEquals(ll:popBack(), 1)
	lu.assertEquals(ll:popBack(), 2)
	lu.assertEquals(ll:popBack(), 3)
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testBackInsertionAndFrontRemoval_Preserve_FifoOrder()
	-- Given: an empty list receives 1, 2, and 3 at the back.
	local ll = LinkedList.new()

	-- When: append at the back, then remove from the front.
	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	-- Then: front removals return 1, 2, 3, then nil.
	lu.assertEquals(ll:popFront(), 1)
	lu.assertEquals(ll:popFront(), 2)
	lu.assertEquals(ll:popFront(), 3)
	lu.assertNil(ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testReverse_Swaps_TraversalAndEndpointOrder()
	-- Given: an empty LinkedList.
	local ll = LinkedList.new()

	-- When: reverse an empty list.
	-- Then: returns the list and remains empty.
	lu.assertEquals(ll:reverse(), ll)
	lu.assertTrue(ll:empty())

	-- When: push 1 and reverse single-element list.
	ll:pushBack(1)
	ll:reverse()

	-- Then: endpoints remain 1 with length 1.
	lu.assertEquals(#ll, 1)
	lu.assertEquals(ll:peekFront(), 1)
	lu.assertEquals(ll:peekBack(), 1)

	-- When: push 2, 3, 4 and reverse the four-element list.
	ll:pushBack(2)
	ll:pushBack(3)
	ll:pushBack(4)
	ll:reverse()

	-- Then: endpoints, traversal, and backward removals reflect reversed order.
	lu.assertEquals(#ll, 4)
	lu.assertEquals(ll:peekFront(), 4)
	lu.assertEquals(ll:peekBack(), 1)
	local forward = {}
	for _, v in pairs(ll) do
		table.insert(forward, v)
	end
	lu.assertEquals(forward, { 4, 3, 2, 1 })
	lu.assertEquals(ll:popBack(), 1)
	lu.assertEquals(ll:popBack(), 2)
	lu.assertEquals(ll:popBack(), 3)
	lu.assertEquals(ll:popBack(), 4)
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testPushOperations_Reject_NilValues()
	-- Given: front and back nil pushes target an empty LinkedList.
	local ll = LinkedList.new()

	-- When: attempt to push nil at the front and back of the list.
	-- Then: both operations report that entries cannot be nil.
	lu.assertErrorMsgContains("entry should not be nil", function()
		ll:pushFront(nil)
	end)
	lu.assertErrorMsgContains("entry should not be nil", function()
		ll:pushBack(nil)
	end)
end

-- Scenarios: metamethods and formatting

function TestLinkedList:testLength_Tracks_InsertionAndRemovalAtBothEnds()
	-- Given: an empty LinkedList.
	local ll = LinkedList.new()
	lu.assertEquals(#ll, 0)

	-- When: push 1 to the front and 2 to the back.
	ll:pushFront(1)
	ll:pushBack(2)

	-- Then: length increases to 2.
	lu.assertEquals(#ll, 2)

	-- When: pop one element from each end.
	ll:popFront()
	ll:popBack()

	-- Then: length decreases to 0.
	lu.assertEquals(#ll, 0)

	-- When: pop while already empty.
	ll:popFront()
	ll:popBack()

	-- Then: length remains 0.
	lu.assertEquals(#ll, 0)
end

function TestLinkedList:testConcat_Appends_ValuesFromMultipleIterableTypes()
	-- Given: an empty list plus a LinkedList, TreeMap, and Stack with values 40-80.
	local ll = LinkedList.new()
	local other = LinkedList.new({ 40, 50, 60 })
	local tm = require("ff.collections.treemap").new()
	tm:put(70, 70)
	local stack = require("ff.collections.stack").new()
	stack:push(80)

	-- When: concatenate { 10, 20, 30 }, nil, then each collection.
	ll = ll .. { 10, 20, 30 }
	ll = ll .. nil
	ll = ll .. other

	ll = ll .. tm

	ll = ll .. stack

	-- Then: removals return all eight appended values in order.
	lu.assertEquals(#ll, 8)
	lu.assertEquals(ll:popFront(), 10)
	lu.assertEquals(ll:popFront(), 20)
	lu.assertEquals(ll:popFront(), 30)
	lu.assertEquals(ll:popFront(), 40)
	lu.assertEquals(ll:popFront(), 50)
	lu.assertEquals(ll:popFront(), 60)
	lu.assertEquals(ll:popFront(), 70)
	lu.assertEquals(ll:popFront(), 80)
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testConcat_Rejects_NonTableValues()
	-- Given: non-table operands are concatenated with an empty LinkedList.
	local ll = LinkedList.new()

	-- When: concatenate the linked list with a non-table value.
	-- Then: each operand raises the iterable type error.
	lu.assertErrorMsgContains("iterable should be a table", function()
		ll = ll .. "not a table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		ll = ll .. 42
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		ll = ll .. true
	end)
end

function TestLinkedList:testListsWithSameValues_Compare_Equal()
	-- Given: lists match, differ in one value, or have different lengths.
	local ll1 = LinkedList.new({ 1, 2, 3 })
	local ll2 = LinkedList.new({ 1, 2, 3 })
	local ll3 = LinkedList.new({ 1, 2, 4 })
	local ll4 = LinkedList.new({ 1, 2 })

	-- Boolean assertions here intentionally exercise LinkedList.__eq.

	-- When: compare each list against ll1, including non-list values.
	-- Then: only identical LinkedList contents compare equal.
	lu.assertTrue(ll1 == ll2)
	lu.assertFalse(ll1 == ll3)
	lu.assertFalse(ll1 == ll4)
	lu.assertFalse(ll1 == {})
	lu.assertFalse(ll1 == nil)
	lu.assertFalse(ll1 == 42)
	lu.assertFalse(ll1 == "123")
end

function TestLinkedList:testEmptyLinkedLists_Compare_Equal()
	-- Given: both LinkedLists contain no nodes.
	local ll1 = LinkedList.new()
	local ll2 = LinkedList.new()
	-- This assertion exercises LinkedList.__eq; assertEquals compares table structure.

	-- When: compare the empty lists with ==.
	-- Then: equality returns true.
	lu.assertTrue(ll1 == ll2)
end

function TestLinkedList:testToString_Formats_LinkedListInOrder()
	-- Given: the list contains 1, 2, and 3 from front to back.
	local ll = LinkedList.new({ 1, 2, 3 })

	-- When: format the list with tostring.
	-- Then: text is [ 1 -> 2 -> 3 ].
	lu.assertEquals(tostring(ll), "[ 1 -> 2 -> 3 ]")
end

function TestLinkedList:testToString_Formats_EmptyLinkedList()
	-- Given: the LinkedList has no nodes.
	local ll = LinkedList.new()

	-- When: format the empty list with tostring.
	-- Then: text is [  ].
	lu.assertEquals(tostring(ll), "[  ]")
end

function TestLinkedList:testNewPropertiesAndMethods_CannotBe_AddedOrReplaced()
	-- Given: a list contains 1, 2, and 3 and defines pushBack.
	local ll = LinkedList.new({ 1, 2, 3 })

	-- disallow adding properties

	-- When: assign a property, numeric key, function, and replacement pushBack method.
	-- Then: every assignment raises the property-protection error.
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to LinkedList", function()
		ll.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to LinkedList", function()
		ll[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to LinkedList", function()
		ll.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to LinkedList", function()
		ll.pushBack = function() end
	end)
end

-- Suite map
return { TestLinkedList = TestLinkedList }
