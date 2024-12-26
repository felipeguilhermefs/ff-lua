local lu = require("luaunit")
local Queue = require("queue")

function TestEmpty()
	local q = Queue.new()

	lu.assertTrue(q:empty())

	q:enqueue(1)
	lu.assertFalse(q:empty())

	q:dequeue()
	lu.assertTrue(q:empty())
end

function TestLen()
	local q = Queue.new()

	lu.assertEquals(0, #q)

	q:enqueue(5)
	q:enqueue(6)
	q:enqueue(7)
	lu.assertEquals(3, #q)

	q:dequeue()
	q:dequeue()
	lu.assertEquals(1, #q)

	q:dequeue()
	q:dequeue()
	lu.assertEquals(0, #q)
end

function TestGeneral()
	local q = Queue.new()

	q:enqueue(10)
	q:enqueue(20)
	lu.assertEquals(10, q:dequeue())
	lu.assertEquals(20, q:dequeue())

	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())

	q:enqueue(30)
	lu.assertEquals(30, q:peek())
	lu.assertEquals(30, q:dequeue())
	lu.assertTrue(q:empty())
end

function TestCapacity()
	local q = Queue.new(2)

	lu.assertTrue(q:enqueue(1))
	lu.assertEquals(1, #q)

	lu.assertTrue(q:enqueue(2))
	lu.assertEquals(2, #q)

	lu.assertFalse(q:enqueue(3))
	lu.assertEquals(2, #q)

	lu.assertEquals(1, q:dequeue())
	lu.assertEquals(1, #q)

	lu.assertTrue(q:enqueue(3))
	lu.assertEquals(2, #q)
end

function TestInitialization()
	lu.assertError(Queue.new, "a")
	lu.assertError(Queue.new, true)
	lu.assertError(Queue.new, -1)
end

function TestIterator()
	local q = Queue.new()

	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")
	q:enqueue("d")

	local res = {}
	for _, item in pairs(q) do
		table.insert(res, item)
	end

	lu.assertEquals({ "a", "b", "c", "d" }, res)
	lu.assertTrue(q:empty())
end

function TestConcat()
	local q = Queue.new() .. { 10, 20, 30 }
	lu.assertEquals(3, #q)

	q = q .. nil
	lu.assertEquals(3, #q)

	local s = require("stack").new()
	s:push(60)
	s:push(50)
	s:push(40)

	s = q .. s

	lu.assertEquals(10, q:dequeue())
	lu.assertEquals(20, q:dequeue())
	lu.assertEquals(30, q:dequeue())
	lu.assertEquals(40, q:dequeue())
	lu.assertEquals(50, q:dequeue())
	lu.assertEquals(60, q:dequeue())
end

os.exit(lu.LuaUnit.run())
