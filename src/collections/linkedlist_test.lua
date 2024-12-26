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

	local bt = require("binarytree").new()
	bt:insert(70)

	ll = ll .. bt

	lu.assertEquals(7, #ll)
	lu.assertEquals(10, ll:popFront())
	lu.assertEquals(20, ll:popFront())
	lu.assertEquals(30, ll:popFront())
	lu.assertEquals(40, ll:popFront())
	lu.assertEquals(50, ll:popFront())
	lu.assertEquals(60, ll:popFront())
	lu.assertEquals(70, ll:popFront())
end

function TestIterator()
	local ll = LinkedList.new()
	ll:pushBack(10)
	ll:pushBack(20)
	ll:pushBack(30)

	local tpairs = {}
	for key, value in pairs(ll) do
		table.insert(tpairs, key)
		table.insert(tpairs, value)
	end

	lu.assertEquals({ 1, 10, 2, 20, 3, 30 }, tpairs)
end

os.exit(lu.LuaUnit.run())
