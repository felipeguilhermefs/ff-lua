local lu = require("luaunit")
local Queue = require("ff.collections.queue")

local append = table.insert

local TestQueue = {}

function TestQueue:testTypeGuard_RecognizesQueuesAndRejectsOtherValues()
	lu.assertTrue(Queue.isQueue(Queue.new()))
	lu.assertFalse(Queue.isQueue({}))
	lu.assertFalse(Queue.isQueue(nil))
	lu.assertFalse(Queue.isQueue("queue"))
	lu.assertFalse(Queue.isQueue(123))
end

function TestQueue:testEmptyConstructor_CreatesEmptyQueue()
	local q = Queue.new()

	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
end

function TestQueue:testCapacityConstructor_CreatesEmptyQueue()
	local q = Queue.new(nil, 5)

	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
end

function TestQueue:testConstructor_LoadsInitialValuesAndSetsFront()
	local q = Queue.new({ 10, 20, 30 })

	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), 10)
end

function TestQueue:testCapacityConstructor_LoadsIterableValues()
	local q = Queue.new({ 1, 2, 3 }, 5)

	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), 1)
end

function TestQueue:testConstructor_RejectsInvalidCapacity()
	lu.assertErrorMsgContains("capacity should be a number", Queue.new, nil, "a")
	lu.assertErrorMsgContains("capacity should be a number", Queue.new, nil, true)
	lu.assertErrorMsgContains("capacity should be positive", Queue.new, nil, -1)
	lu.assertErrorMsgContains("capacity should be positive", Queue.new, nil, 0)
end

function TestQueue:testCapacity_RejectsItemsBeyondLimitAndAllowsReuseAfterDequeue()
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

function TestQueue:testIteration_YieldsItemsInFifoOrder()
	local q = Queue.new()

	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")
	q:enqueue("d")

	local keys = {}
	local res = {}
	for i, item in pairs(q) do
		append(keys, i)
		append(res, item)
	end

	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertFalse(q:empty())
	lu.assertEquals(#q, 4)
	lu.assertEquals(q:peek(), "a")
end

function TestQueue:testEmptyQueueIteration_YieldsNoItems()
	local q = Queue.new()

	local count = 0

	for _ in pairs(q) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestQueue:testRepeatedIteration_PreservesQueueContents()
	local q = Queue.new({ 1, 2, 3 })

	local firstRun = {}

	for _, item in pairs(q) do
		append(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(q) do
		append(secondRun, item)
	end

	lu.assertEquals(firstRun, { 1, 2, 3 })
	lu.assertEquals(secondRun, { 1, 2, 3 })
	lu.assertEquals(#q, 3)
end

function TestQueue:testContains_ReportsStoredValuesAsPresent()
	local q = Queue.new({ 10, 20, 30 })

	lu.assertTrue(q:contains(10))
	lu.assertTrue(q:contains(20))
	lu.assertTrue(q:contains(30))
end

function TestQueue:testContains_ReportsUnstoredValuesAsAbsent()
	local q = Queue.new({ 10, 20, 30 })

	lu.assertFalse(q:contains(99))
	lu.assertFalse(q:contains("10"))
end

function TestQueue:testEmptyQueue_DoesNotContainValues()
	local q = Queue.new()

	lu.assertFalse(q:contains(1))
end

function TestQueue:testContains_DoesNotConsumeQueuedValues()
	local q = Queue.new({ "a", "b", "c" })

	lu.assertTrue(q:contains("b"))
	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), "a")
end

function TestQueue:testContains_ReportsDuplicateValuesAsPresent()
	local q = Queue.new()

	q:enqueue(5)
	q:enqueue(5)
	q:enqueue(5)

	lu.assertTrue(q:contains(5))
	lu.assertEquals(#q, 3) -- still intact
end

function TestQueue:testContains_RejectsNilValues()
	local q = Queue.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		q:contains(nil)
	end)
end

function TestQueue:testUnboundedQueue_NeverReportsFull()
	local q = Queue.new()

	lu.assertFalse(q:full())

	q:enqueue(1)

	lu.assertFalse(q:full())
end

function TestQueue:testBoundedQueue_ReportsNotFullBelowCapacity()
	local q = Queue.new(nil, 3)

	lu.assertFalse(q:full())

	q:enqueue(1)
	q:enqueue(2)

	lu.assertFalse(q:full())
end

function TestQueue:testBoundedQueue_ReportsFullAtCapacity()
	local q = Queue.new(nil, 2)

	q:enqueue("x")
	q:enqueue("y")

	lu.assertTrue(q:full())
end

function TestQueue:testDequeuingFromFullQueue_MakesRoom()
	local q = Queue.new(nil, 2)
	q:enqueue(1)
	q:enqueue(2)
	lu.assertTrue(q:full())

	q:dequeue()

	lu.assertFalse(q:full())

	q:enqueue(3)

	lu.assertTrue(q:full())
end

function TestQueue:testFullQueue_RejectsEnqueue()
	local q = Queue.new(nil, 3)

	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")

	lu.assertTrue(q:full())
	lu.assertFalse(q:enqueue("d"))
end

function TestQueue:testClear_MakesQueueEmptyAfterEnqueues()
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

function TestQueue:testDequeue_ReturnsQueuedValuesInFifoOrder()
	local q = Queue.new()

	q:enqueue(10)
	q:enqueue(20)

	lu.assertEquals(q:dequeue(), 10)
	lu.assertEquals(q:dequeue(), 20)
	lu.assertTrue(q:empty())
end

function TestQueue:testEmptyQueueDequeueAndPeek_ReturnNil()
	local q = Queue.new()

	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())

	q:enqueue(30)
	local dequeued = q:dequeue()

	lu.assertEquals(dequeued, 30)
	lu.assertTrue(q:empty())
	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())
end

function TestQueue:testPeek_ReturnsFrontWithoutConsumingQueue()
	local q = Queue.new({ 30, 40 })

	lu.assertEquals(q:peek(), 30)
	lu.assertEquals(#q, 2)
	lu.assertEquals(q:dequeue(), 30)
end

function TestQueue:testDrain_YieldsQueuedValuesInFifoOrderAndEmptiesQueue()
	local q = Queue.new()

	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")
	q:enqueue("d")

	local res = {}
	for item in q:drain() do
		append(res, item)
	end

	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertNil(q:peek())
	lu.assertNil(q:dequeue())
end

function TestQueue:testEmptyQueueDrain_YieldsNoValues()
	local q = Queue.new()

	local count = 0

	for _ in q:drain() do
		count = count + 1
	end

	lu.assertEquals(count, 0)
	lu.assertTrue(q:empty())
end

function TestQueue:testClearedQueue_CanBeReused()
	local q = Queue.new()

	q:enqueue(1)
	q:enqueue(2)
	q:clear()

	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())

	lu.assertTrue(q:enqueue(99))
	lu.assertEquals(#q, 1)
	lu.assertEquals(q:peek(), 99)
end

function TestQueue:testRemovingLastQueuedValue_LeavesQueueReusable()
	local q = Queue.new()

	q:enqueue("x")
	q:dequeue()

	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertTrue(q:enqueue("y"))
	lu.assertEquals(q:dequeue(), "y")
	lu.assertTrue(q:empty())
end

function TestQueue:testQueue_PreservesOrderAcrossValueTypes()
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

function TestQueue:testLength_TracksEnqueueAndDequeueOperations()
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
	q:dequeue()

	lu.assertEquals(#q, 0)
end

function TestQueue:testConcat_AppendsIterableValuesInQueueOrder()
	local q = Queue.new()
	local s = require("ff.collections.stack").new()
	s:push(60)
	s:push(50)
	s:push(40)

	q = q .. { 10, 20, 30 }
	q = q .. nil
	q = q .. s

	lu.assertEquals(#q, 6)
	lu.assertEquals(q:dequeue(), 10)
	lu.assertEquals(q:dequeue(), 20)
	lu.assertEquals(q:dequeue(), 30)
	lu.assertEquals(q:dequeue(), 40)
	lu.assertEquals(q:dequeue(), 50)
	lu.assertEquals(q:dequeue(), 60)
end

function TestQueue:testConcat_RejectsNonTableValues()
	local q = Queue.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		q = q .. "not a table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		q = q .. 42
	end)
end

function TestQueue:testQueuesWithSameValues_CompareEqual()
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

function TestQueue:testEmptyQueues_CompareEqual()
	local q1 = Queue.new()
	local q2 = Queue.new()

	lu.assertTrue(q1 == q2)
end

function TestQueue:testToString_FormatsQueueContents()
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

function TestQueue:testToString_FormatsEmptyQueue()
	local q = Queue.new()

	local str = tostring(q)

	lu.assertStrContains(str, "Front")
end

function TestQueue:testNewPropertiesAndMethods_CannotBeAddedOrReplaced()
	local q = Queue.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		q.foo = "bar"
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		q[1] = 99
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		q.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		q.peek = function() end
	end)
end

function TestQueue:testConcat_CreatesNewQueueAndEnqueueAllMutates()
	local source = Queue.new({ 1 })
	local joined = source .. { 2 }
	lu.assertNotIs(joined, source)
	lu.assertEquals(#source, 1)
	lu.assertEquals(#joined, 2)
	source:enqueueAll({ 3 })
	lu.assertEquals(#source, 2)
end

function TestQueue:testEnqueueAllRejectsNil()
	local collection = Queue.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		collection:enqueueAll(nil)
	end)
end

return { TestQueue = TestQueue }
