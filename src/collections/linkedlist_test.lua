local lu = require("luaunit")
local LinkedList = require("linkedlist")

function TestIsLinkedList()
	lu.assertTrue(LinkedList.isLinkedList(LinkedList.new()))
	lu.assertFalse(LinkedList.isLinkedList({}))
	lu.assertFalse(LinkedList.isLinkedList(nil))
	lu.assertFalse(LinkedList.isLinkedList("linkedlist"))
	lu.assertFalse(LinkedList.isLinkedList(123))
end

function TestConstructorEmpty()
	local ll = LinkedList.new()
	lu.assertTrue(ll:empty())
	lu.assertEquals(0, #ll)
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())
	lu.assertNil(ll:popFront())
	lu.assertNil(ll:popBack())
end

function TestConstructorWithIterable()
	local ll = LinkedList.new({ 10, 20, 30 })
	lu.assertEquals(3, #ll)
	lu.assertEquals(10, ll:peekFront())
	lu.assertEquals(30, ll:peekBack())
	lu.assertEquals(10, ll:popFront())
	lu.assertEquals(20, ll:popFront())
	lu.assertEquals(30, ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestConstructorWithLinkedList()
	local ll1 = LinkedList.new({ 1, 2, 3 })
	local ll2 = LinkedList.new(ll1)
	lu.assertEquals(3, #ll2)
	lu.assertTrue(ll1 == ll2)
end

function TestConstructorValidation()
	lu.assertError(LinkedList.new, "invalid")
	lu.assertError(LinkedList.new, 123)
	lu.assertError(LinkedList.new, true)
end

function TestEmptyAndClear()
	local ll = LinkedList.new()
	lu.assertTrue(ll:empty())

	ll:pushFront(1)
	lu.assertFalse(ll:empty())

	ll:clear()
	lu.assertTrue(ll:empty())
	lu.assertEquals(0, #ll)
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())

	ll:pushBack(2)
	ll:pushBack(3)
	lu.assertFalse(ll:empty())

	ll:popFront()
	ll:popBack()
	lu.assertTrue(ll:empty())
	lu.assertEquals(0, #ll)

	-- Verify list works after being cleared
	ll:pushBack(99)
	lu.assertEquals(1, #ll)
	lu.assertEquals(99, ll:peekFront())
	lu.assertEquals(99, ll:peekBack())
	lu.assertEquals(99, ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestLen()
	local ll = LinkedList.new()
	lu.assertEquals(0, #ll)

	ll:pushFront(1)
	lu.assertEquals(1, #ll)

	ll:pushBack(2)
	lu.assertEquals(2, #ll)

	ll:popFront()
	lu.assertEquals(1, #ll)

	ll:popBack()
	lu.assertEquals(0, #ll)

	-- Pop on empty keeps len 0
	ll:popFront()
	lu.assertEquals(0, #ll)
	ll:popBack()
	lu.assertEquals(0, #ll)
end

function TestPushFrontAndPopFront()
	local ll = LinkedList.new()

	ll:pushFront(1)
	ll:pushFront(2)
	ll:pushFront(3)

	lu.assertEquals(3, #ll)
	lu.assertEquals(3, ll:popFront())
	lu.assertEquals(2, ll:popFront())
	lu.assertEquals(1, ll:popFront())
	lu.assertNil(ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestPushBackAndPopBack()
	local ll = LinkedList.new()

	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	lu.assertEquals(3, #ll)
	lu.assertEquals(3, ll:popBack())
	lu.assertEquals(2, ll:popBack())
	lu.assertEquals(1, ll:popBack())
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestPushFrontAndPopBack()
	local ll = LinkedList.new()

	ll:pushFront(1)
	ll:pushFront(2)
	ll:pushFront(3)

	lu.assertEquals(1, ll:popBack())
	lu.assertEquals(2, ll:popBack())
	lu.assertEquals(3, ll:popBack())
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestPushBackAndPopFront()
	local ll = LinkedList.new()

	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	lu.assertEquals(1, ll:popFront())
	lu.assertEquals(2, ll:popFront())
	lu.assertEquals(3, ll:popFront())
	lu.assertNil(ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestPeekFrontAndPeekBack()
	local ll = LinkedList.new()
	lu.assertNil(ll:peekFront())
	lu.assertNil(ll:peekBack())

	ll:pushFront(10)
	lu.assertEquals(10, ll:peekFront())
	lu.assertEquals(10, ll:peekBack())
	lu.assertEquals(1, #ll)

	ll:pushBack(20)
	lu.assertEquals(10, ll:peekFront())
	lu.assertEquals(20, ll:peekBack())
	lu.assertEquals(2, #ll)

	ll:pushFront(5)
	lu.assertEquals(5, ll:peekFront())
	lu.assertEquals(20, ll:peekBack())
	lu.assertEquals(3, #ll)
end

function TestContains()
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
	lu.assertEquals(3, #ll)
	lu.assertEquals(10, ll:peekFront())

	lu.assertError(function()
		ll:contains(nil)
	end)
end

function TestReverse()
	local ll = LinkedList.new()

	-- Reverse empty list
	lu.assertEquals(ll, ll:reverse())
	lu.assertTrue(ll:empty())

	-- Reverse single element
	ll:pushBack(1)
	ll:reverse()
	lu.assertEquals(1, #ll)
	lu.assertEquals(1, ll:peekFront())
	lu.assertEquals(1, ll:peekBack())

	-- Reverse multiple elements
	ll:pushBack(2)
	ll:pushBack(3)
	ll:pushBack(4)
	-- list is [1, 2, 3, 4]

	ll:reverse()
	-- list should now be [4, 3, 2, 1]
	lu.assertEquals(4, #ll)
	lu.assertEquals(4, ll:peekFront())
	lu.assertEquals(1, ll:peekBack())

	-- Check forward traversal
	local forward = {}
	for _, v in pairs(ll) do
		table.insert(forward, v)
	end
	lu.assertEquals({ 4, 3, 2, 1 }, forward)

	-- Check popBack works correctly (backward links intact)
	lu.assertEquals(1, ll:popBack())
	lu.assertEquals(2, ll:popBack())
	lu.assertEquals(3, ll:popBack())
	lu.assertEquals(4, ll:popBack())
	lu.assertNil(ll:popBack())
	lu.assertTrue(ll:empty())
end

function TestConcat()
	local ll = LinkedList.new() .. { 10, 20, 30 }
	lu.assertEquals(3, #ll)

	ll = ll .. nil
	lu.assertEquals(3, #ll)

	local other = LinkedList.new()
	other:pushBack(40)
	other:pushBack(50)
	other:pushBack(60)

	ll = ll .. other

	local tm = require("treemap").new()
	tm[70] = 70

	ll = ll .. tm

	local stack = require("stack").new()
	stack:push(80)

	ll = ll .. stack

	lu.assertEquals(8, #ll)
	lu.assertEquals(10, ll:popFront())
	lu.assertEquals(20, ll:popFront())
	lu.assertEquals(30, ll:popFront())
	lu.assertEquals(40, ll:popFront())
	lu.assertEquals(50, ll:popFront())
	lu.assertEquals(60, ll:popFront())
	lu.assertEquals(70, ll:popFront())
	lu.assertEquals(80, ll:popFront())
	lu.assertTrue(ll:empty())
end

function TestConcatValidation()
	local ll = LinkedList.new()
	lu.assertError(function()
		ll = ll .. "not a table"
	end)
	lu.assertError(function()
		ll = ll .. 42
	end)
	lu.assertError(function()
		ll = ll .. true
	end)
end

function TestEquality()
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

function TestEqualityEmpty()
	local ll1 = LinkedList.new()
	local ll2 = LinkedList.new()
	lu.assertTrue(ll1 == ll2)
end

function TestIterator()
	local ll = LinkedList.new({ 10, 20, 30 })

	local indices = {}
	local values = {}
	for idx, val in pairs(ll) do
		table.insert(indices, idx)
		table.insert(values, val)
	end

	lu.assertEquals({ 1, 2, 3 }, indices)
	lu.assertEquals({ 10, 20, 30 }, values)
	-- Iterator must not consume or modify the list
	lu.assertEquals(3, #ll)
end

function TestIteratorEmpty()
	local ll = LinkedList.new()
	local count = 0
	for _ in pairs(ll) do
		count = count + 1
	end
	lu.assertEquals(0, count)
end

function TestToString()
	local ll = LinkedList.new({ 1, 2, 3 })
	lu.assertEquals("[ 1 -> 2 -> 3 ]", tostring(ll))
end

function TestToStringEmpty()
	local ll = LinkedList.new()
	lu.assertEquals("[  ]", tostring(ll))
end

function TestPushValidation()
	local ll = LinkedList.new()
	lu.assertError(function()
		ll:pushFront(nil)
	end)
	lu.assertError(function()
		ll:pushBack(nil)
	end)
end

os.exit(lu.LuaUnit.run())
