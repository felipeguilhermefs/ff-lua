local lu = require("luaunit")
local Queue = require("queue")

function TestEmpty()
	local q = Queue()

	lu.assertTrue(q.empty())

	q.enqueue(1)
	lu.assertFalse(q.empty())

	q.dequeue()
	lu.assertTrue(q.empty())
end

function TestGeneral()
	local q = Queue()

	q.enqueue(10)
	q.enqueue(20)
	lu.assertEquals(10, q.dequeue())
	lu.assertEquals(20, q.dequeue())

	lu.assertNil(q.dequeue())
	lu.assertNil(q.peek())

	q.enqueue(30)
	lu.assertEquals(30, q.peek())
	lu.assertEquals(30, q.dequeue())
	lu.assertTrue(q.empty())
end

os.exit(lu.LuaUnit.run())
