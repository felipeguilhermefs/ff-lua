local lu = require("luaunit")
local LinkedList = require("linkedlist")

function TestEmpty()
	local ll = LinkedList()

	lu.assertTrue(ll.empty())

	ll.prepend(1)
	lu.assertFalse(ll.empty())

	ll.clear()
	lu.assertTrue(ll.empty())

	ll.append(2)
	ll.append(3)
	lu.assertFalse(ll.empty())

	ll.drop()
	ll.pop()
	lu.assertTrue(ll.empty())
end

function TestHead()
	local ll = LinkedList()

	ll.prepend(1)
	ll.prepend(2)
	ll.prepend(3)

	lu.assertEquals(3, ll.drop())
	lu.assertEquals(2, ll.drop())
	lu.assertEquals(1, ll.drop())
	lu.assertNil(ll.drop())

	ll.prepend(1)
	ll.prepend(2)
	ll.prepend(3)

	lu.assertEquals(1, ll.pop())
	lu.assertEquals(2, ll.pop())
	lu.assertEquals(3, ll.pop())
	lu.assertNil(ll.pop())
end

function TestTail()
	local ll = LinkedList()

	ll.append(1)
	ll.append(2)
	ll.append(3)

	lu.assertEquals(1, ll.drop())
	lu.assertEquals(2, ll.drop())
	lu.assertEquals(3, ll.drop())
	lu.assertNil(ll.drop())

	ll.append(1)
	ll.append(2)
	ll.append(3)

	lu.assertEquals(3, ll.pop())
	lu.assertEquals(2, ll.pop())
	lu.assertEquals(1, ll.pop())
	lu.assertNil(ll.pop())
end

function TestReverse()
	local ll = LinkedList()

	ll.append(1)
	ll.append(2)
	ll.append(3)

	ll.reverse()

	lu.assertEquals(1, ll.pop())
	lu.assertEquals(2, ll.pop())
	lu.assertEquals(3, ll.pop())
	lu.assertNil(ll.pop())
end

os.exit(lu.LuaUnit.run())
