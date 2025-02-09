local lu = require("luaunit")
local Comparator = require("ff.func.comparator")
local Heap = require("heap")

function TestEmpty()
	local h = Heap.new()

	lu.assertTrue(h:empty())

	h:push(2)
	lu.assertFalse(h:empty())
	h:push(3)
	lu.assertFalse(h:empty())

	h:pop()
	lu.assertFalse(h:empty())
	h:pop()
	lu.assertTrue(h:empty())
end

function TestPush()
	local h = Heap.new()

	h:push(4)
	lu.assertEquals(4, h:peek())
	h:push(5)
	lu.assertEquals(4, h:peek())
	h:push(1)
	lu.assertEquals(1, h:peek())

	h:push(3)
	lu.assertEquals(1, h:peek())
end

function TestPop()
	local h = Heap.new()

	h:push(4)
	h:push(5)
	h:push(1)
	h:push(3)
	h:push(2)

	lu.assertEquals(1, h:pop())
	lu.assertEquals(2, h:pop())
	lu.assertEquals(3, h:pop())
	lu.assertEquals(4, h:pop())
	lu.assertEquals(5, h:pop())
	lu.assertNil(h:pop())
end

function TestHeapify()
	local h = Heap.new()
	h:heapify({ 5, 7, 9, 6, 8 })

	lu.assertEquals(5, h:pop())
	lu.assertEquals(6, h:pop())
	lu.assertEquals(7, h:pop())
	lu.assertEquals(8, h:pop())
	lu.assertEquals(9, h:pop())
	lu.assertNil(h:pop())
end

function TestMaxHeap()
	local h = Heap.newMax()
	h:heapify({ 5, 7, 9 })

	h:push(6)
	h:push(8)
	h:push(7)

	lu.assertEquals(9, h:pop())
	lu.assertEquals(8, h:pop())
	lu.assertEquals(7, h:pop())
	lu.assertEquals(7, h:pop())
	lu.assertEquals(6, h:pop())
	lu.assertEquals(5, h:pop())
	lu.assertNil(h:pop())
end

function TestString()
	local h = Heap.new()

	h:push("b")
	h:push("e")
	h:push("c")
	h:push("a")
	h:push("d")

	lu.assertEquals("a", h:pop())
	lu.assertEquals("b", h:pop())
	lu.assertEquals("c", h:pop())
	lu.assertEquals("d", h:pop())
	lu.assertEquals("e", h:pop())
	lu.assertNil(h:pop())
end

function TestComparator()
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

	local h = Heap.new(max)
	h:heapify({ obj(5, "a"), obj(7, "b"), obj(9, "c") })

	h:push(obj(6, true))
	h:push(obj(8, false))

	lu.assertEquals({ priority = 9, value = "c" }, h:pop())
	lu.assertEquals({ priority = 8, value = false }, h:pop())
	lu.assertEquals({ priority = 7, value = "b" }, h:pop())
	lu.assertEquals({ priority = 6, value = true }, h:pop())
	lu.assertEquals({ priority = 5, value = "a" }, h:pop())
	lu.assertNil(h:pop())
end

function TestIterator()
	local h = Heap.new()

	h:push("b")
	h:push("d")
	h:push("c")
	h:push("a")

	local res = {}
	for _, item in pairs(h) do
		table.insert(res, item)
	end

	lu.assertEquals({ "a", "b", "c", "d" }, res)
	lu.assertTrue(h:empty())
end

function TestConcat()
	local h = Heap.new() .. { 10, 20, 30 }
	lu.assertEquals(3, #h)

	h = h .. nil
	lu.assertEquals(3, #h)

	local ll = require("linkedlist").new()
	ll:pushBack(40)
	ll:pushBack(50)
	ll:pushBack(60)

	ll = h .. ll

	lu.assertEquals(10, h:pop())
	lu.assertEquals(20, h:pop())
	lu.assertEquals(30, h:pop())
	lu.assertEquals(40, h:pop())
	lu.assertEquals(50, h:pop())
	lu.assertEquals(60, h:pop())
end

os.exit(lu.LuaUnit.run())
