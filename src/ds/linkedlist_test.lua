local lu = require("luaunit")
local LinkedList = require("linkedlist")

function TestEmpty()
	local ll = LinkedList()

	lu.assertTrue(ll.empty())

	ll.pushLeft(1)
	lu.assertFalse(ll.empty())

	ll.clear()
	lu.assertTrue(ll.empty())

	ll.pushRight(2)
	ll.pushRight(3)
	lu.assertFalse(ll.empty())

	ll.popLeft()
	ll.popRight()
	lu.assertTrue(ll.empty())
end

function TestLeft()
	local ll = LinkedList()

	ll.pushLeft(1)
	ll.pushLeft(2)
	ll.pushLeft(3)

	lu.assertEquals(3, ll.popLeft())
	lu.assertEquals(2, ll.popLeft())
	lu.assertEquals(1, ll.popLeft())
	lu.assertNil(ll.popLeft())

	ll.pushLeft(1)
	ll.pushLeft(2)
	ll.pushLeft(3)

	lu.assertEquals(1, ll.popRight())
	lu.assertEquals(2, ll.popRight())
	lu.assertEquals(3, ll.popRight())
	lu.assertNil(ll.popRight())
end

function TestRight()
	local ll = LinkedList()

	ll.pushRight(1)
	ll.pushRight(2)
	ll.pushRight(3)

	lu.assertEquals(1, ll.popLeft())
	lu.assertEquals(2, ll.popLeft())
	lu.assertEquals(3, ll.popLeft())
	lu.assertNil(ll.popLeft())

	ll.pushRight(1)
	ll.pushRight(2)
	ll.pushRight(3)

	lu.assertEquals(3, ll.popRight())
	lu.assertEquals(2, ll.popRight())
	lu.assertEquals(1, ll.popRight())
	lu.assertNil(ll.popRight())
end

function TestReverse()
	local ll = LinkedList()

	ll.pushRight(1)
	ll.pushRight(2)
	ll.pushRight(3)

	ll.reverse()

	lu.assertEquals(1, ll.popRight())
	lu.assertEquals(2, ll.popRight())
	lu.assertEquals(3, ll.popRight())
	lu.assertNil(ll.popRight())
end

os.exit(lu.LuaUnit.run())
