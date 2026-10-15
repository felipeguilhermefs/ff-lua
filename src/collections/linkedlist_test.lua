local lu = require("luaunit")
local LinkedList = require("ff.collections.linkedlist")

local append = table.insert

local TestLinkedList = {}

function TestLinkedList:testTypeGuard_RecognizesLinkedListsAndRejectsOtherValues()
	lu.assertTrue(LinkedList.isLinkedList(LinkedList.new()))
	lu.assertFalse(LinkedList.isLinkedList({}))
	lu.assertFalse(LinkedList.isLinkedList(nil))
	lu.assertFalse(LinkedList.isLinkedList("linkedlist"))
	lu.assertFalse(LinkedList.isLinkedList(123))
end

function TestLinkedList:testEmptyConstructor_CreatesEmptyLinkedList()
	local ll = LinkedList.new()

	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())
	lu.assertNil(ll:popFront())
	lu.assertNil(ll:popBack())
end

function TestLinkedList:testConstructor_PreservesIterableOrder()
	local ll = LinkedList.new({ 10, 20, 30 })

	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:peekFront(), 10)
	lu.assertEquals(ll:peekBack(), 30)
	lu.assertEquals(ll:popFront(), 10)
	lu.assertEquals(ll:popFront(), 20)
	lu.assertEquals(ll:popFront(), 30)
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testConstructor_CopiesValuesFromAnotherLinkedList()
	local ll1 = LinkedList.new({ 1, 2, 3 })

	local ll2 = LinkedList.new(ll1)

	lu.assertEquals(#ll2, 3)
	lu.assertTrue(ll1 == ll2)
end

function TestLinkedList:testConstructor_RejectsNonTableIterables()
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, "invalid")
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, 123)
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, true)
end

function TestLinkedList:testEndpointPeeks_ReturnValuesAtBothEnds()
	local ll = LinkedList.new()

	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())

	ll:pushFront(10)

	lu.assertEquals(ll:peekFront(), 10)
	lu.assertEquals(ll:peekBack(), 10)
	lu.assertEquals(#ll, 1)

	ll:pushBack(20)

	lu.assertEquals(ll:peekFront(), 10)
	lu.assertEquals(ll:peekBack(), 20)
	lu.assertEquals(#ll, 2)

	ll:pushFront(5)

	lu.assertEquals(ll:peekFront(), 5)
	lu.assertEquals(ll:peekBack(), 20)
	lu.assertEquals(#ll, 3)
end

function TestLinkedList:testContains_ReportsStoredValuesAndRejectsMissingValuesWithoutMutation()
	local ll = LinkedList.new()

	lu.assertFalse(ll:contains(10))

	ll:pushBack(10)
	ll:pushBack(20)
	ll:pushBack(30)

	lu.assertTrue(ll:contains(10))
	lu.assertTrue(ll:contains(20))
	lu.assertTrue(ll:contains(30))
	lu.assertFalse(ll:contains(40))
	lu.assertFalse(ll:contains("10"))
	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:peekFront(), 10)
end

function TestLinkedList:testContains_RejectsNilValues()
	local ll = LinkedList.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		ll:contains(nil)
	end)
end

function TestLinkedList:testIteration_YieldsOneBasedIndexesAndValues()
	local ll = LinkedList.new({ 10, 20, 30 })

	local indices = {}
	local values = {}

	for idx, val in pairs(ll) do
		append(indices, idx)
		append(values, val)
	end

	lu.assertEquals(indices, { 1, 2, 3 })
	lu.assertEquals(values, { 10, 20, 30 })
	lu.assertEquals(#ll, 3)
end

function TestLinkedList:testEmptyLinkedListIteration_YieldsNoValues()
	local ll = LinkedList.new()
	local count = 0

	for _ in pairs(ll) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestLinkedList:testClear_EmptiesLinkedListAndAllowsReuse()
	local ll = LinkedList.new()
	lu.assertTrue(ll:empty())

	ll:pushFront(1)
	ll:clear()

	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())

	ll:pushBack(2)
	ll:pushBack(3)
	ll:popFront()
	ll:popBack()

	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)

	ll:pushBack(99)

	lu.assertEquals(#ll, 1)
	lu.assertEquals(ll:peekFront(), 99)
	lu.assertEquals(ll:peekBack(), 99)
	lu.assertEquals(ll:popFront(), 99)
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testFrontInsertionAndRemoval_PreserveLifoOrder()
	local ll = LinkedList.new()

	ll:pushFront(1)
	ll:pushFront(2)
	ll:pushFront(3)

	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:popFront(), 3)
	lu.assertEquals(ll:popFront(), 2)
	lu.assertEquals(ll:popFront(), 1)
	lu.assertNil(ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testBackInsertionAndRemoval_PreserveLifoOrder()
	local ll = LinkedList.new()

	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:popBack(), 3)
	lu.assertEquals(ll:popBack(), 2)
	lu.assertEquals(ll:popBack(), 1)
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testFrontInsertionAndBackRemoval_PreserveOppositeOrder()
	local ll = LinkedList.new()

	ll:pushFront(1)
	ll:pushFront(2)
	ll:pushFront(3)

	lu.assertEquals(ll:popBack(), 1)
	lu.assertEquals(ll:popBack(), 2)
	lu.assertEquals(ll:popBack(), 3)
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testBackInsertionAndFrontRemoval_PreserveFifoOrder()
	local ll = LinkedList.new()

	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	lu.assertEquals(ll:popFront(), 1)
	lu.assertEquals(ll:popFront(), 2)
	lu.assertEquals(ll:popFront(), 3)
	lu.assertNil(ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testReverse_SwapsTraversalAndEndpointOrder()
	local ll = LinkedList.new()

	lu.assertEquals(ll:reverse(), ll)
	lu.assertTrue(ll:empty())

	ll:pushBack(1)
	ll:reverse()

	lu.assertEquals(#ll, 1)
	lu.assertEquals(ll:peekFront(), 1)
	lu.assertEquals(ll:peekBack(), 1)

	ll:pushBack(2)
	ll:pushBack(3)
	ll:pushBack(4)
	ll:reverse()

	lu.assertEquals(#ll, 4)
	lu.assertEquals(ll:peekFront(), 4)
	lu.assertEquals(ll:peekBack(), 1)
	local forward = {}
	for _, v in pairs(ll) do
		append(forward, v)
	end
	lu.assertEquals(forward, { 4, 3, 2, 1 })
	lu.assertEquals(ll:popBack(), 1)
	lu.assertEquals(ll:popBack(), 2)
	lu.assertEquals(ll:popBack(), 3)
	lu.assertEquals(ll:popBack(), 4)
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testPushOperations_RejectNilValues()
	local ll = LinkedList.new()

	lu.assertErrorMsgContains("entry should not be nil", function()
		ll:pushFront(nil)
	end)
	lu.assertErrorMsgContains("entry should not be nil", function()
		ll:pushBack(nil)
	end)
end

function TestLinkedList:testLength_TracksInsertionAndRemovalAtBothEnds()
	local ll = LinkedList.new()
	lu.assertEquals(#ll, 0)

	ll:pushFront(1)
	ll:pushBack(2)

	lu.assertEquals(#ll, 2)

	ll:popFront()
	ll:popBack()

	lu.assertEquals(#ll, 0)

	ll:popFront()
	ll:popBack()

	lu.assertEquals(#ll, 0)
end

function TestLinkedList:testConcat_AppendsValuesFromMultipleIterableTypes()
	local ll = LinkedList.new()
	local other = LinkedList.new({ 40, 50, 60 })
	local tm = require("ff.collections.treemap").new()
	tm:put(70, 70)
	local stack = require("ff.collections.stack").new()
	stack:push(80)

	ll = ll .. { 10, 20, 30 }
	ll = ll .. nil
	ll = ll .. other

	ll = ll .. tm

	ll = ll .. stack

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

function TestLinkedList:testConcat_RejectsNonTableValues()
	local ll = LinkedList.new()

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

function TestLinkedList:testListsWithSameValues_CompareEqual()
	local ll1 = LinkedList.new({ 1, 2, 3 })
	local ll2 = LinkedList.new({ 1, 2, 3 })
	local ll3 = LinkedList.new({ 1, 2, 4 })
	local ll4 = LinkedList.new({ 1, 2 })

	lu.assertTrue(ll1 == ll2)
	lu.assertFalse(ll1 == ll3)
	lu.assertFalse(ll1 == ll4)
	lu.assertFalse(ll1 == {})
	lu.assertFalse(ll1 == nil)
	lu.assertFalse(ll1 == 42)
	lu.assertFalse(ll1 == "123")
end

function TestLinkedList:testEmptyLinkedLists_CompareEqual()
	local ll1 = LinkedList.new()
	local ll2 = LinkedList.new()

	lu.assertTrue(ll1 == ll2)
end

function TestLinkedList:testToString_FormatsLinkedListInOrder()
	local ll = LinkedList.new({ 1, 2, 3 })

	lu.assertEquals(tostring(ll), "[ 1 -> 2 -> 3 ]")
end

function TestLinkedList:testToString_FormatsEmptyLinkedList()
	local ll = LinkedList.new()

	lu.assertEquals(tostring(ll), "[  ]")
end

function TestLinkedList:testNewPropertiesAndMethods_CannotBeAddedOrReplaced()
	local ll = LinkedList.new({ 1, 2, 3 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to LinkedList", function()
		ll.foo = "bar"
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to LinkedList", function()
		ll[1] = 99
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to LinkedList", function()
		ll.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to LinkedList", function()
		ll.pushBack = function() end
	end)
end

return { TestLinkedList = TestLinkedList }
