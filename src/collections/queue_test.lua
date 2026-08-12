local lu = require("luaunit")
local Queue = require("queue")

function TestIsQueue()
	lu.assertTrue(Queue.isQueue(Queue.new()))
	lu.assertFalse(Queue.isQueue({}))
	lu.assertFalse(Queue.isQueue(nil))
	lu.assertFalse(Queue.isQueue("queue"))
	lu.assertFalse(Queue.isQueue(123))
end

function TestConstructorEmpty()
	local q = Queue.new()
	lu.assertTrue(q:empty())
	lu.assertEquals(0, #q)
end

function TestConstructorWithCapacity()
	local q = Queue.new(nil, 5)
	lu.assertTrue(q:empty())
	lu.assertEquals(0, #q)
end

function TestConstructorWithIterable()
	local q = Queue.new({ 10, 20, 30 })
	lu.assertEquals(3, #q)
	lu.assertEquals(10, q:peek())
end

function TestConstructorWithCapacityAndIterable()
	local q = Queue.new({ 1, 2, 3 }, 5)
	lu.assertEquals(3, #q)
	lu.assertEquals(1, q:peek())
end

function TestConstructorValidation()
	lu.assertError(Queue.new, nil, "a")
	lu.assertError(Queue.new, nil, true)
	lu.assertError(Queue.new, nil, -1)
	lu.assertError(Queue.new, nil, 0)
end

function TestEmptyAndClear()
	local q = Queue.new()
	lu.assertTrue(q:empty())

	q:enqueue(1)
	lu.assertFalse(q:empty())

	q:dequeue()
	lu.assertTrue(q:empty())

	q:enqueue("a")
	q:enqueue("b")
	q:clear()
	lu.assertTrue(q:empty())
	lu.assertEquals(0, #q)
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
	q:dequeue() -- dequeue on empty returns nil, len stays 0
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
	local q = Queue.new(nil, 2)

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

function TestIteratorEmpty()
	local q = Queue.new()

	local count = 0
	for _ in pairs(q) do
		count = count + 1
	end

	lu.assertEquals(0, count)
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

	q = q .. s

	lu.assertEquals(6, #q)
	lu.assertEquals(10, q:dequeue())
	lu.assertEquals(20, q:dequeue())
	lu.assertEquals(30, q:dequeue())
	lu.assertEquals(40, q:dequeue())
	lu.assertEquals(50, q:dequeue())
	lu.assertEquals(60, q:dequeue())
end

function TestConcatValidation()
	local q = Queue.new()
	lu.assertError(function()
		q = q .. "not a table"
	end)
	lu.assertError(function()
		q = q .. 42
	end)
end

function TestEquality()
	local q1 = Queue.new({ 1, 2, 3 })
	local q2 = Queue.new({ 1, 2, 3 })
	local q3 = Queue.new({ 1, 2, 4 })
	local q4 = Queue.new({ 1, 2 })

	lu.assertTrue(q1 == q2)
	lu.assertFalse(q1 == q3)
	lu.assertFalse(q1 == q4)
	lu.assertFalse(q1 == {})
	lu.assertFalse(q1 == nil)
	lu.assertFalse(q1 == 42)
end

function TestEqualityEmpty()
	local q1 = Queue.new()
	local q2 = Queue.new()
	lu.assertTrue(q1 == q2)
end

function TestToString()
	local q = Queue.new()
	q:enqueue(1)
	q:enqueue(2)
	q:enqueue(3)

	local str = tostring(q)
	lu.assertTrue(str:find("1") ~= nil)
	lu.assertTrue(str:find("2") ~= nil)
	lu.assertTrue(str:find("3") ~= nil)
	lu.assertTrue(str:find("Front") ~= nil)
end

function TestToStringEmpty()
	local q = Queue.new()
	local str = tostring(q)
	lu.assertTrue(str:find("Front") ~= nil)
end

function TestClearResetsCorrectly()
	local q = Queue.new()
	q:enqueue(1)
	q:enqueue(2)
	q:clear()

	-- After clear, the queue should behave as if brand new
	lu.assertTrue(q:empty())
	lu.assertEquals(0, #q)
	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())

	lu.assertTrue(q:enqueue(99))
	lu.assertEquals(1, #q)
	lu.assertEquals(99, q:peek())
end

function TestDequeueUntilEmpty()
	local q = Queue.new()
	q:enqueue("x")
	q:dequeue()
	-- Single-element dequeue calls clear() internally; verify state is coherent
	lu.assertTrue(q:empty())
	lu.assertEquals(0, #q)
	lu.assertTrue(q:enqueue("y"))
	lu.assertEquals("y", q:dequeue())
	lu.assertTrue(q:empty())
end

function TestMixedTypes()
	local q = Queue.new()
	q:enqueue(42)
	q:enqueue("hello")
	q:enqueue(true)
	q:enqueue({ 1, 2 })

	lu.assertEquals(4, #q)
	lu.assertEquals(42, q:dequeue())
	lu.assertEquals("hello", q:dequeue())
	lu.assertEquals(true, q:dequeue())
	lu.assertEquals({ 1, 2 }, q:dequeue())
	lu.assertTrue(q:empty())
end

function TestContainsPresent()
	local q = Queue.new({ 10, 20, 30 })

	lu.assertTrue(q:contains(10))
	lu.assertTrue(q:contains(20))
	lu.assertTrue(q:contains(30))
end

function TestContainsAbsent()
	local q = Queue.new({ 10, 20, 30 })

	lu.assertFalse(q:contains(99))
	lu.assertFalse(q:contains("10"))
end

function TestContainsEmpty()
	local q = Queue.new()
	lu.assertFalse(q:contains(1))
end

function TestContainsDoesNotConsume()
	local q = Queue.new({ "a", "b", "c" })

	-- contains must not consume items
	lu.assertTrue(q:contains("b"))
	lu.assertEquals(3, #q)
	lu.assertEquals("a", q:peek())
end

function TestContainsDuplicates()
	local q = Queue.new()
	q:enqueue(5)
	q:enqueue(5)
	q:enqueue(5)

	lu.assertTrue(q:contains(5))
	lu.assertEquals(3, #q) -- still intact
end

function TestContainsValidation()
	local q = Queue.new()
	lu.assertError(function()
		q:contains(nil)
	end)
end

function TestFullUnbounded()
	-- An unbounded queue is never full
	local q = Queue.new()
	lu.assertFalse(q:full())
	q:enqueue(1)
	lu.assertFalse(q:full())
end

function TestFullBoundedNotFull()
	local q = Queue.new(nil, 3)
	lu.assertFalse(q:full())
	q:enqueue(1)
	lu.assertFalse(q:full())
	q:enqueue(2)
	lu.assertFalse(q:full())
end

function TestFullBoundedAtCapacity()
	local q = Queue.new(nil, 2)
	q:enqueue("x")
	q:enqueue("y")
	lu.assertTrue(q:full())
end

function TestFullBoundedAfterDequeue()
	local q = Queue.new(nil, 2)
	q:enqueue(1)
	q:enqueue(2)
	lu.assertTrue(q:full())

	q:dequeue()
	lu.assertFalse(q:full())

	q:enqueue(3)
	lu.assertTrue(q:full())
end

function TestFullConsistentWithEnqueue()
	-- full() should agree with enqueue() returning false
	local q = Queue.new(nil, 3)
	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")

	lu.assertTrue(q:full())
	lu.assertFalse(q:enqueue("d"))
end

os.exit(lu.LuaUnit.run())
