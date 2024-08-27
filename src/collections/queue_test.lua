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

os.exit(lu.LuaUnit.run())
