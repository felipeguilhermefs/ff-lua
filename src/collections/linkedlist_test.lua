local lu = require("luaunit")
local LinkedList = require("linkedlist")

function TestEmpty()
	local ll = LinkedList.new()

	lu.assertTrue(ll:empty())

	ll:pushFront(1)
	lu.assertFalse(ll:empty())

	ll:clear()
	lu.assertTrue(ll:empty())

	ll:pushBack(2)
	ll:pushBack(3)
	lu.assertFalse(ll:empty())

	ll:popFront()
	ll:popBack()
	lu.assertTrue(ll:empty())
end

function TestFront()
	local ll = LinkedList.new()

	ll:pushFront(1)
	ll:pushFront(2)
	ll:pushFront(3)

	lu.assertEquals(3, ll:popFront())
	lu.assertEquals(2, ll:popFront())
	lu.assertEquals(1, ll:popFront())
	lu.assertNil(ll:popFront())

	ll:pushFront(1)
	ll:pushFront(2)
	ll:pushFront(3)

	lu.assertEquals(1, ll:popBack())
	lu.assertEquals(2, ll:popBack())
	lu.assertEquals(3, ll:popBack())
	lu.assertNil(ll:popBack())
end

function TestBack()
	local ll = LinkedList.new()

	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	lu.assertEquals(1, ll:popFront())
	lu.assertEquals(2, ll:popFront())
	lu.assertEquals(3, ll:popFront())
	lu.assertNil(ll:popFront())

	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	lu.assertEquals(3, ll:popBack())
	lu.assertEquals(2, ll:popBack())
	lu.assertEquals(1, ll:popBack())
	lu.assertNil(ll:popBack())
end

function TestReverse()
	local ll = LinkedList.new()

	ll:pushBack(1)
	ll:pushBack(2)
	ll:pushBack(3)

	ll:reverse()

	lu.assertEquals(1, ll:popBack())
	lu.assertEquals(2, ll:popBack())
	lu.assertEquals(3, ll:popBack())
	lu.assertNil(ll:popBack())
end

os.exit(lu.LuaUnit.run())
