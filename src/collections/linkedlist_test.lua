local lu = require("luaunit")
local LinkedList = require("ff.collections.linkedlist")

TestLinkedList = {}

function TestLinkedList:testIsLinkedList()
	lu.assertTrue(LinkedList.isLinkedList(LinkedList.new()))
	lu.assertFalse(LinkedList.isLinkedList({}))
	lu.assertFalse(LinkedList.isLinkedList(nil))
	lu.assertFalse(LinkedList.isLinkedList("linkedlist"))
	lu.assertFalse(LinkedList.isLinkedList(123))
end

function TestLinkedList:testConstructorEmpty()
	local ll = LinkedList.new()
	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())
	lu.assertNil(ll:popFront())
	lu.assertNil(ll:popBack())
end

function TestLinkedList:testConstructorWithIterable()
	local ll = LinkedList.new({ 10, 20, 30 })
	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:peekFront(), 10)
	lu.assertEquals(ll:peekBack(), 30)
	lu.assertEquals(ll:popFront(), 10)
	lu.assertEquals(ll:popFront(), 20)
	lu.assertEquals(ll:popFront(), 30)
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testConstructorWithLinkedList()
	local ll1 = LinkedList.new({ 1, 2, 3 })
	local ll2 = LinkedList.new(ll1)
	lu.assertEquals(#ll2, 3)
	lu.assertEquals(ll1 == ll2, true)
end

function TestLinkedList:testConstructorValidation()
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, "invalid")
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, 123)
	lu.assertErrorMsgContains("iterable should be a table", LinkedList.new, true)
end

function TestLinkedList:testEmptyAndClear()
	local ll = LinkedList.new()
	lu.assertTrue(ll:empty())

	ll:pushFront(1)
	lu.assertFalse(ll:empty())

	ll:clear()
	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())

	ll:pushBack(2)
	ll:pushBack(3)
	lu.assertFalse(ll:empty())

	ll:popFront()
	ll:popBack()
	lu.assertTrue(ll:empty())
	lu.assertEquals(#ll, 0)

	-- Verify list works after being cleared
	ll:pushBack(99)
	lu.assertEquals(#ll, 1)
	lu.assertEquals(ll:peekFront(), 99)
	lu.assertEquals(ll:peekBack(), 99)
	lu.assertEquals(ll:popFront(), 99)
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testLen()
	local ll = LinkedList.new()
	lu.assertEquals(#ll, 0)

	ll:pushFront(1)
	lu.assertEquals(#ll, 1)

	ll:pushBack(2)
	lu.assertEquals(#ll, 2)

	ll:popFront()
	lu.assertEquals(#ll, 1)

	ll:popBack()
	lu.assertEquals(#ll, 0)

	-- Pop on empty keeps len 0
	ll:popFront()
	lu.assertEquals(#ll, 0)
	ll:popBack()
	lu.assertEquals(#ll, 0)
end

function TestLinkedList:testPushFrontAndPopFront()
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

function TestLinkedList:testPushBackAndPopBack()
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

function TestLinkedList:testPushFrontAndPopBack()
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

function TestLinkedList:testPushBackAndPopFront()
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

function TestLinkedList:testPeekFrontAndPeekBack()
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

function TestLinkedList:testContains()
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

	-- Contains should not consume or modify list
	lu.assertEquals(#ll, 3)
	lu.assertEquals(ll:peekFront(), 10)

	lu.assertErrorMsgContains("value should not be nil", function()
		ll:contains(nil)
	end)
end

function TestLinkedList:testReverse()
	local ll = LinkedList.new()

	-- Reverse empty list
	lu.assertEquals(ll:reverse(), ll)
	lu.assertTrue(ll:empty())

	-- Reverse single element
	ll:pushBack(1)
	ll:reverse()
	lu.assertEquals(#ll, 1)
	lu.assertEquals(ll:peekFront(), 1)
	lu.assertEquals(ll:peekBack(), 1)

	-- Reverse multiple elements
	ll:pushBack(2)
	ll:pushBack(3)
	ll:pushBack(4)
	-- list is [1, 2, 3, 4]

	ll:reverse()
	-- list should now be [4, 3, 2, 1]
	lu.assertEquals(#ll, 4)
	lu.assertEquals(ll:peekFront(), 4)
	lu.assertEquals(ll:peekBack(), 1)

	-- Check forward traversal
	local forward = {}
	for _, v in pairs(ll) do
		table.insert(forward, v)
	end
	lu.assertEquals(forward, { 4, 3, 2, 1 })

	-- Check popBack works correctly (backward links intact)
	lu.assertEquals(ll:popBack(), 1)
	lu.assertEquals(ll:popBack(), 2)
	lu.assertEquals(ll:popBack(), 3)
	lu.assertEquals(ll:popBack(), 4)
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestLinkedList:testConcat()
	local ll = LinkedList.new() .. { 10, 20, 30 }
	lu.assertEquals(#ll, 3)

	ll = ll .. nil
	lu.assertEquals(#ll, 3)

	local other = LinkedList.new()
	other:pushBack(40)
	other:pushBack(50)
	other:pushBack(60)

	ll = ll .. other

	local tm = require("ff.collections.treemap").new()
	tm:put(70, 70)

	ll = ll .. tm

	local stack = require("ff.collections.stack").new()
	stack:push(80)

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

function TestLinkedList:testConcatValidation()
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

function TestLinkedList:testEquality()
	local ll1 = LinkedList.new({ 1, 2, 3 })
	local ll2 = LinkedList.new({ 1, 2, 3 })
	local ll3 = LinkedList.new({ 1, 2, 4 })
	local ll4 = LinkedList.new({ 1, 2 })

	lu.assertEquals(ll1 == ll2, true)
	lu.assertEquals(ll1 == ll3, false)
	lu.assertEquals(ll1 == ll4, false)
	lu.assertEquals(ll1 == {}, false)
	lu.assertEquals(ll1 == nil, false)
	lu.assertEquals(ll1 == 42, false)
	lu.assertEquals(ll1 == "123", false)
end

function TestLinkedList:testEqualityEmpty()
	local ll1 = LinkedList.new()
	local ll2 = LinkedList.new()
	lu.assertEquals(ll1 == ll2, true)
end

function TestLinkedList:testIterator()
	local ll = LinkedList.new({ 10, 20, 30 })

	local indices = {}
	local values = {}
	for idx, val in pairs(ll) do
		table.insert(indices, idx)
		table.insert(values, val)
	end

	lu.assertEquals(indices, { 1, 2, 3 })
	lu.assertEquals(values, { 10, 20, 30 })
	-- Iterator must not consume or modify the list
	lu.assertEquals(#ll, 3)
end

function TestLinkedList:testIteratorEmpty()
	local ll = LinkedList.new()
	local count = 0
	for _ in pairs(ll) do
		count = count + 1
	end
	lu.assertEquals(count, 0)
end

function TestLinkedList:testToString()
	local ll = LinkedList.new({ 1, 2, 3 })
	lu.assertEquals(tostring(ll), "[ 1 -> 2 -> 3 ]")
end

function TestLinkedList:testToStringEmpty()
	local ll = LinkedList.new()
	lu.assertEquals(tostring(ll), "[  ]")
end

function TestLinkedList:testPushValidation()
	local ll = LinkedList.new()
	lu.assertErrorMsgContains("entry should not be nil", function()
		ll:pushFront(nil)
	end)
	lu.assertErrorMsgContains("entry should not be nil", function()
		ll:pushBack(nil)
	end)
end

function TestLinkedList:testNewIndexPreventsModifications()
	local ll = LinkedList.new({ 1, 2, 3 })

	-- disallow adding properties
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

