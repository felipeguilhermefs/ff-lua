-----------------------------------------------------------------------------
-- 1. Upvalue caching & Imports
-----------------------------------------------------------------------------
local lu = require("luaunit")
local Queue = require("ff.collections.queue")

-----------------------------------------------------------------------------
-- 2. Test Suite Table Definition
-----------------------------------------------------------------------------
TestQueue = {}

-----------------------------------------------------------------------------
-- 3. Suite Lifecycle Hooks (Optional)
-- Not needed: each test creates its own fixtures.
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- 4. Constructor & Type Guard Tests
-----------------------------------------------------------------------------

function TestQueue:testIsQueue()
	lu.assertTrue(Queue.isQueue(Queue.new()))
	lu.assertFalse(Queue.isQueue({}))
	lu.assertFalse(Queue.isQueue(nil))
	lu.assertFalse(Queue.isQueue("queue"))
	lu.assertFalse(Queue.isQueue(123))
end

function TestQueue:testConstructor_Empty()
	local q = Queue.new()
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
end

function TestQueue:testConstructor_WithCapacity()
	local q = Queue.new(nil, 5)
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
end

function TestQueue:testConstructor_WithIterable()
	local q = Queue.new({ 10, 20, 30 })
	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), 10)
end

function TestQueue:testConstructor_WithCapacityAndIterable()
	local q = Queue.new({ 1, 2, 3 }, 5)
	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), 1)
end

function TestQueue:testConstructor_Validation()
	lu.assertErrorMsgContains("capacity should be a number", Queue.new, nil, "a")
	lu.assertErrorMsgContains("capacity should be a number", Queue.new, nil, true)
	lu.assertErrorMsgContains("capacity should be positive", Queue.new, nil, -1)
	lu.assertErrorMsgContains("capacity should be positive", Queue.new, nil, 0)
end

-----------------------------------------------------------------------------
-- 5. Core Accessor & Inspection Tests
-----------------------------------------------------------------------------

function TestQueue:testCapacity()
	local q = Queue.new(nil, 2)

	lu.assertTrue(q:enqueue(1))
	lu.assertEquals(#q, 1)

	lu.assertTrue(q:enqueue(2))
	lu.assertEquals(#q, 2)

	lu.assertFalse(q:enqueue(3))
	lu.assertEquals(#q, 2)

	lu.assertEquals(q:dequeue(), 1)
	lu.assertEquals(#q, 1)

	lu.assertTrue(q:enqueue(3))
	lu.assertEquals(#q, 2)
end

function TestQueue:testIterator()
	local q = Queue.new()

	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")
	q:enqueue("d")

	local keys = {}
	local res = {}
	for i, item in pairs(q) do
		table.insert(keys, i)
		table.insert(res, item)
	end

	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertFalse(q:empty())
	lu.assertEquals(#q, 4)
	lu.assertEquals(q:peek(), "a")
end

function TestQueue:testIterator_Empty()
	local q = Queue.new()

	local count = 0
	for _ in pairs(q) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestQueue:testIterator_MultipleRuns()
	local q = Queue.new({ 1, 2, 3 })

	local firstRun = {}
	for _, item in pairs(q) do
		table.insert(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(q) do
		table.insert(secondRun, item)
	end

	lu.assertEquals(firstRun, { 1, 2, 3 })
	lu.assertEquals(secondRun, { 1, 2, 3 })
	lu.assertEquals(#q, 3)
end

function TestQueue:testContains_Present()
	local q = Queue.new({ 10, 20, 30 })

	lu.assertTrue(q:contains(10))
	lu.assertTrue(q:contains(20))
	lu.assertTrue(q:contains(30))
end

function TestQueue:testContains_Absent()
	local q = Queue.new({ 10, 20, 30 })

	lu.assertFalse(q:contains(99))
	lu.assertFalse(q:contains("10"))
end

function TestQueue:testContains_Empty()
	local q = Queue.new()
	lu.assertFalse(q:contains(1))
end

function TestQueue:testContains_DoesNotConsume()
	local q = Queue.new({ "a", "b", "c" })

	-- contains must not consume items
	lu.assertTrue(q:contains("b"))
	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), "a")
end

function TestQueue:testContains_Duplicates()
	local q = Queue.new()
	q:enqueue(5)
	q:enqueue(5)
	q:enqueue(5)

	lu.assertTrue(q:contains(5))
	lu.assertEquals(#q, 3) -- still intact
end

function TestQueue:testContains_Validation()
	local q = Queue.new()
	lu.assertErrorMsgContains("value should not be nil", function()
		q:contains(nil)
	end)
end

function TestQueue:testFull_Unbounded()
	-- An unbounded queue is never full
	local q = Queue.new()
	lu.assertFalse(q:full())
	q:enqueue(1)
	lu.assertFalse(q:full())
end

function TestQueue:testFull_BoundedNotFull()
	local q = Queue.new(nil, 3)
	lu.assertFalse(q:full())
	q:enqueue(1)
	lu.assertFalse(q:full())
	q:enqueue(2)
	lu.assertFalse(q:full())
end

function TestQueue:testFull_BoundedAtCapacity()
	local q = Queue.new(nil, 2)
	q:enqueue("x")
	q:enqueue("y")
	lu.assertTrue(q:full())
end

function TestQueue:testFull_BoundedAfterDequeue()
	local q = Queue.new(nil, 2)
	q:enqueue(1)
	q:enqueue(2)
	lu.assertTrue(q:full())

	q:dequeue()
	lu.assertFalse(q:full())

	q:enqueue(3)
	lu.assertTrue(q:full())
end

function TestQueue:testFull_ConsistentWithEnqueue()
	-- full() should agree with enqueue() returning false
	local q = Queue.new(nil, 3)
	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")

	lu.assertTrue(q:full())
	lu.assertFalse(q:enqueue("d"))
end

-----------------------------------------------------------------------------
-- 6. Mutation & Modification Tests
-----------------------------------------------------------------------------

function TestQueue:testEmptyAndClear()
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
	lu.assertEquals(#q, 0)
end

function TestQueue:testGeneral()
	local q = Queue.new()

	q:enqueue(10)
	q:enqueue(20)
	lu.assertEquals(q:dequeue(), 10)
	lu.assertEquals(q:dequeue(), 20)

	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())

	q:enqueue(30)
	lu.assertEquals(q:peek(), 30)
	lu.assertEquals(q:dequeue(), 30)
	lu.assertTrue(q:empty())
end

function TestQueue:testDrain()
	local q = Queue.new()
	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")
	q:enqueue("d")

	local res = {}
	for item in q:drain() do
		table.insert(res, item)
	end

	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertNil(q:peek())
	lu.assertNil(q:dequeue())
end

function TestQueue:testDrain_Empty()
	local q = Queue.new()

	local count = 0
	for _ in q:drain() do
		count = count + 1
	end

	lu.assertEquals(count, 0)
	lu.assertTrue(q:empty())
end

function TestQueue:testClear_ResetsCorrectly()
	local q = Queue.new()
	q:enqueue(1)
	q:enqueue(2)
	q:clear()

	-- After clear, the queue should behave as if brand new
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())

	lu.assertTrue(q:enqueue(99))
	lu.assertEquals(#q, 1)
	lu.assertEquals(q:peek(), 99)
end

function TestQueue:testDequeue_UntilEmpty()
	local q = Queue.new()
	q:enqueue("x")
	q:dequeue()
	-- Single-element dequeue calls clear() internally; verify state is coherent
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertTrue(q:enqueue("y"))
	lu.assertEquals(q:dequeue(), "y")
	lu.assertTrue(q:empty())
end

function TestQueue:testMixedTypes()
	local q = Queue.new()
	q:enqueue(42)
	q:enqueue("hello")
	q:enqueue(true)
	q:enqueue({ 1, 2 })

	lu.assertEquals(#q, 4)
	lu.assertEquals(q:dequeue(), 42)
	lu.assertEquals(q:dequeue(), "hello")
	lu.assertTrue(q:dequeue())
	lu.assertEquals(q:dequeue(), { 1, 2 })
	lu.assertTrue(q:empty())
end

-----------------------------------------------------------------------------
-- 7. Metamethod Tests (__len, __eq, __concat, __tostring, __newindex)
-----------------------------------------------------------------------------

function TestQueue:testLen()
	local q = Queue.new()

	lu.assertEquals(#q, 0)

	q:enqueue(5)
	q:enqueue(6)
	q:enqueue(7)
	lu.assertEquals(#q, 3)

	q:dequeue()
	q:dequeue()
	lu.assertEquals(#q, 1)

	q:dequeue()
	q:dequeue() -- dequeue on empty returns nil, len stays 0
	lu.assertEquals(#q, 0)
end

function TestQueue:testConcat()
	local q = Queue.new() .. { 10, 20, 30 }
	lu.assertEquals(#q, 3)

	q = q .. nil
	lu.assertEquals(#q, 3)

	local s = require("ff.collections.stack").new()
	s:push(60)
	s:push(50)
	s:push(40)

	q = q .. s

	lu.assertEquals(#q, 6)
	lu.assertEquals(q:dequeue(), 10)
	lu.assertEquals(q:dequeue(), 20)
	lu.assertEquals(q:dequeue(), 30)
	lu.assertEquals(q:dequeue(), 40)
	lu.assertEquals(q:dequeue(), 50)
	lu.assertEquals(q:dequeue(), 60)
end

function TestQueue:testConcat_Validation()
	local q = Queue.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		q = q .. "not a table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		q = q .. 42
	end)
end

function TestQueue:testEquality()
	local q1 = Queue.new({ 1, 2, 3 })
	local q2 = Queue.new({ 1, 2, 3 })
	local q3 = Queue.new({ 1, 2, 4 })
	local q4 = Queue.new({ 1, 2 })

	-- Boolean assertions here intentionally exercise Queue.__eq.
	lu.assertTrue(q1 == q2)
	lu.assertFalse(q1 == q3)
	lu.assertFalse(q1 == q4)
	lu.assertFalse(q1 == {})
	lu.assertFalse(q1 == nil)
	lu.assertFalse(q1 == 42)
end

function TestQueue:testEquality_Empty()
	local q1 = Queue.new()
	local q2 = Queue.new()
	-- This assertion exercises Queue.__eq; assertEquals compares table structure.
	lu.assertTrue(q1 == q2)
end

function TestQueue:testToString()
	local q = Queue.new()
	q:enqueue(1)
	q:enqueue(2)
	q:enqueue(3)

	local str = tostring(q)
	lu.assertStrContains(str, "1")
	lu.assertStrContains(str, "2")
	lu.assertStrContains(str, "3")
	lu.assertStrContains(str, "Front")
end

function TestQueue:testToString_Empty()
	local q = Queue.new()
	local str = tostring(q)
	lu.assertStrContains(str, "Front")
end

function TestQueue:testNewIndex_PreventsModifications()
	local q = Queue.new()

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		q.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		q[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		q.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		q.peek = function() end
	end)
end
