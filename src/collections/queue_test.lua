-- Imports
local lu = require("luaunit")
local Queue = require("ff.collections.queue")

-- Suite definitions
local TestQueue = {}

-- Scenarios: construction and type recognition

function TestQueue:testTypeGuardRecognizesQueuesAndRejectsOtherValues()
	-- Given: candidates include one Queue, a plain table, and scalar values.
	-- When: check each candidate with Queue.isQueue.
	-- Then: only the Queue instance returns true.
	lu.assertTrue(Queue.isQueue(Queue.new()))
	lu.assertFalse(Queue.isQueue({}))
	lu.assertFalse(Queue.isQueue(nil))
	lu.assertFalse(Queue.isQueue("queue"))
	lu.assertFalse(Queue.isQueue(123))
end

function TestQueue:testEmptyConstructorCreatesEmptyQueue()
	-- Given: construction receives no items and no capacity limit.

	-- When: call Queue.new without arguments.
	local q = Queue.new()

	-- Then: the unbounded Queue reports empty and has length zero.
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
end

function TestQueue:testCapacityConstructorCreatesEmptyQueue()
	-- Given: construction receives capacity 5 and no items.

	-- When: call Queue.new with that capacity.
	local q = Queue.new(nil, 5)

	-- Then: the bounded Queue reports empty and has length zero.
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
end

function TestQueue:testConstructorLoadsInitialValuesAndSetsFront()
	-- Given: the source iterable is { 10, 20, 30 }.

	-- When: initialize a Queue from the iterable.
	local q = Queue.new({ 10, 20, 30 })

	-- Then: length is 3 and peek returns the first item, 10.
	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), 10)
end

function TestQueue:testCapacityConstructorLoadsIterableValues()
	-- Given: values are { 1, 2, 3 } and capacity is 5.

	-- When: initialize the bounded Queue from those values.
	local q = Queue.new({ 1, 2, 3 }, 5)

	-- Then: length is 3 and peek returns 1.
	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), 1)
end

function TestQueue:testConstructorRejectsInvalidCapacity()
	-- Given: capacities include strings, booleans, negative numbers, and zero.
	-- When: pass each invalid capacity to Queue.new.
	-- Then: errors distinguish non-numeric from non-positive capacity.
	lu.assertErrorMsgContains("capacity should be a number", Queue.new, nil, "a")
	lu.assertErrorMsgContains("capacity should be a number", Queue.new, nil, true)
	lu.assertErrorMsgContains("capacity should be positive", Queue.new, nil, -1)
	lu.assertErrorMsgContains("capacity should be positive", Queue.new, nil, 0)
end

-- Scenarios: reads and inspection

function TestQueue:testCapacityRejectsItemsBeyondLimitAndAllowsReuseAfterDequeue()
	-- Given: capacity is 2; values 1, 2, and 3 exercise overflow and reuse.
	local q = Queue.new(nil, 2)

	-- When: fill it, try a third item, dequeue the front, then enqueue again.
	-- Then: overflow is rejected and dequeue frees one slot for reuse.
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

function TestQueue:testIterationYieldsItemsInFifoOrder()
	-- Given: the Queue receives a, b, c, and d in that order.
	local q = Queue.new()

	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")
	q:enqueue("d")

	-- When: collect keys and values yielded by pairs.
	local keys = {}
	local res = {}
	for i, item in pairs(q) do
		table.insert(keys, i)
		table.insert(res, item)
	end

	-- Then: indexes are 1 through 4, values stay in enqueue order, and queue remains intact.
	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertFalse(q:empty())
	lu.assertEquals(#q, 4)
	lu.assertEquals(q:peek(), "a")
end

function TestQueue:testIterationOfEmptyQueueYieldsNoItems()
	-- Given: the Queue has no items to traverse.
	local q = Queue.new()

	local count = 0

	-- When: count items yielded by pairs.
	for _ in pairs(q) do
		count = count + 1
	end

	-- Then: the iterator yields zero items.
	lu.assertEquals(count, 0)
end

function TestQueue:testRepeatedIterationPreservesQueueContents()
	-- Given: the Queue contains 1, 2, and 3.
	local q = Queue.new({ 1, 2, 3 })

	local firstRun = {}

	-- When: collect values during two separate pairs traversals.
	for _, item in pairs(q) do
		table.insert(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(q) do
		table.insert(secondRun, item)
	end

	-- Then: both traversals return 1, 2, 3 and queue length stays 3.
	lu.assertEquals(firstRun, { 1, 2, 3 })
	lu.assertEquals(secondRun, { 1, 2, 3 })
	lu.assertEquals(#q, 3)
end

function TestQueue:testContainsReportsStoredValuesAsPresent()
	-- Given: the Queue contains 10, 20, and 30.
	local q = Queue.new({ 10, 20, 30 })

	-- When: check membership for each queued integer.
	-- Then: contains returns true for all three.
	lu.assertTrue(q:contains(10))
	lu.assertTrue(q:contains(20))
	lu.assertTrue(q:contains(30))
end

function TestQueue:testContainsReportsUnstoredValuesAsAbsent()
	-- Given: the Queue contains numeric values 10, 20, and 30.
	local q = Queue.new({ 10, 20, 30 })

	-- When: check for absent number 99 and string "10".
	-- Then: contains returns false for both.
	lu.assertFalse(q:contains(99))
	lu.assertFalse(q:contains("10"))
end

function TestQueue:testEmptyQueueDoesNotContainValues()
	-- Given: the Queue is empty and queried for value 1.
	local q = Queue.new()

	-- When: check membership of 1.
	-- Then: contains returns false.
	lu.assertFalse(q:contains(1))
end

function TestQueue:testContainsDoesNotConsumeQueuedValues()
	-- Given: the Queue holds a, b, and c in FIFO order.
	local q = Queue.new({ "a", "b", "c" })

	-- contains must not consume items

	-- When: check membership of b.
	-- Then: b is found while length stays 3 and a remains at the front.
	lu.assertTrue(q:contains("b"))
	lu.assertEquals(#q, 3)
	lu.assertEquals(q:peek(), "a")
end

function TestQueue:testContainsReportsDuplicateValuesAsPresent()
	-- Given: the Queue receives three copies of 5.
	local q = Queue.new()

	-- When: enqueue 5 three times, then check membership.
	q:enqueue(5)
	q:enqueue(5)
	q:enqueue(5)

	-- Then: 5 is present and all three queued copies remain.
	lu.assertTrue(q:contains(5))
	lu.assertEquals(#q, 3) -- still intact
end

function TestQueue:testContainsRejectsNilValues()
	-- Given: nil is queried against an empty Queue.
	local q = Queue.new()

	-- When: check membership of nil.
	-- Then: contains reports that values cannot be nil.
	lu.assertErrorMsgContains("value should not be nil", function()
		q:contains(nil)
	end)
end

function TestQueue:testUnboundedQueueNeverReportsFull()
	-- Given: the Queue has no capacity limit.
	local q = Queue.new()

	-- When: check fullness before and after enqueueing 1.
	-- Then: full returns false in both states.
	lu.assertFalse(q:full())
	q:enqueue(1)
	lu.assertFalse(q:full())
end

function TestQueue:testBoundedQueueReportsNotFullBelowCapacity()
	-- Given: capacity is 3; fullness is checked before reaching that limit.
	local q = Queue.new(nil, 3)

	-- When: check fullness at sizes 0, 1, and 2.
	-- Then: full returns false below capacity.
	lu.assertFalse(q:full())
	q:enqueue(1)
	lu.assertFalse(q:full())
	q:enqueue(2)
	lu.assertFalse(q:full())
end

function TestQueue:testBoundedQueueReportsFullAtCapacity()
	-- Given: capacity is 2; x and y fill the two available slots.
	local q = Queue.new(nil, 2)

	-- When: enqueue x and y.
	q:enqueue("x")
	q:enqueue("y")

	-- Then: full returns true at size 2.
	lu.assertTrue(q:full())
end

function TestQueue:testDequeuingFromFullQueueMakesRoom()
	-- Given: capacity is 2; a third item is tested after one dequeue.
	local q = Queue.new(nil, 2)

	-- When: fill it, dequeue the front, then enqueue a replacement.
	q:enqueue(1)
	q:enqueue(2)

	-- Then: removing one item clears fullness and replacement fills the slot.
	lu.assertTrue(q:full())

	q:dequeue()
	lu.assertFalse(q:full())

	q:enqueue(3)
	lu.assertTrue(q:full())
end

function TestQueue:testFullQueueRejectsEnqueue()
	-- Given: capacity is 3; a fourth item is attempted after a, b, and c.
	local q = Queue.new(nil, 3)

	-- When: enqueue a, b, c, then attempt d.
	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")

	-- Then: full returns true and the fourth enqueue returns false.
	lu.assertTrue(q:full())
	lu.assertFalse(q:enqueue("d"))
end

-- Scenarios: state changes

function TestQueue:testClearMakesQueueEmptyAfterEnqueues()
	-- Given: a new Queue receives values before being cleared.
	local q = Queue.new()

	-- When: check empty state, enqueue and dequeue, then enqueue twice and clear.
	-- Then: empty tracks each transition and final length is zero.
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

function TestQueue:testDequeueReturnsQueuedValuesInFifoOrder()
	-- Given: an empty Queue will receive 10 and 20.
	local q = Queue.new()

	-- When: enqueue both values, then dequeue twice.
	q:enqueue(10)
	q:enqueue(20)

	-- Then: removals return 10 then 20, leaving the Queue empty.
	lu.assertEquals(q:dequeue(), 10)
	lu.assertEquals(q:dequeue(), 20)
	lu.assertTrue(q:empty())
end


function TestQueue:testDequeueAndPeekOnEmptyQueueReturnNil()
	-- Given: the Queue starts empty and later receives 30.
	local q = Queue.new()

	-- When: read and remove from empty state, then repeat after removing 30.
	-- Then: peek and dequeue return nil whenever the Queue is empty.
	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())

	q:enqueue(30)
	lu.assertEquals(q:dequeue(), 30)
	lu.assertTrue(q:empty())
	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())
end

function TestQueue:testPeekReturnsFrontWithoutConsumingQueue()
	-- Given: the Queue contains 30 followed by 40.
	local q = Queue.new({ 30, 40 })

	-- When: peek, inspect length, then dequeue the front.
	-- Then: peek returns 30 without changing length; dequeue returns 30.
	lu.assertEquals(q:peek(), 30)
	lu.assertEquals(#q, 2)
	lu.assertEquals(q:dequeue(), 30)
end

function TestQueue:testDrainYieldsQueuedValuesInFifoOrderAndEmptiesQueue()
	-- Given: a new Queue receives a, b, c, and d.
	local q = Queue.new()

	q:enqueue("a")
	q:enqueue("b")
	q:enqueue("c")
	q:enqueue("d")

	-- When: collect items from the drain iterator.
	local res = {}
	for item in q:drain() do
		table.insert(res, item)
	end

	-- Then: collected order matches enqueue order and Queue becomes empty.
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertNil(q:peek())
	lu.assertNil(q:dequeue())
end

function TestQueue:testDrainOnEmptyQueueYieldsNoValues()
	-- Given: the Queue is empty and observed through drain.
	local q = Queue.new()

	local count = 0

	-- When: count items from the drain iterator.
	for _ in q:drain() do
		count = count + 1
	end

	-- Then: no items are yielded and Queue remains empty.
	lu.assertEquals(count, 0)
	lu.assertTrue(q:empty())
end

function TestQueue:testClearedQueueCanBeReused()
	-- Given: a Queue receives two items and is cleared.
	local q = Queue.new()

	-- When: enqueue 1 and 2, then clear and enqueue 99.
	q:enqueue(1)
	q:enqueue(2)
	q:clear()

	-- Then: the cleared Queue is empty, returns nil on reads, and accepts 99.
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertNil(q:dequeue())
	lu.assertNil(q:peek())

	lu.assertTrue(q:enqueue(99))
	lu.assertEquals(#q, 1)
	lu.assertEquals(q:peek(), 99)
end

function TestQueue:testRemovingLastQueuedValueLeavesQueueReusable()
	-- Given: an empty Queue is ready for a single-item enqueue.
	local q = Queue.new()

	-- When: enqueue and remove x, then enqueue and remove y.
	q:enqueue("x")
	q:dequeue()
	-- Single-element dequeue calls clear() internally; verify state is coherent

	-- Then: each last-item removal resets state and the Queue accepts y.
	lu.assertTrue(q:empty())
	lu.assertEquals(#q, 0)
	lu.assertTrue(q:enqueue("y"))
	lu.assertEquals(q:dequeue(), "y")
	lu.assertTrue(q:empty())
end

function TestQueue:testQueuePreservesOrderAcrossValueTypes()
	-- Given: a Queue receives a number, string, boolean, and table.
	local q = Queue.new()

	-- When: dequeue each item after enqueueing all four types.
	q:enqueue(42)
	q:enqueue("hello")
	q:enqueue(true)
	q:enqueue({ 1, 2 })

	-- Then: each original value and type is returned in enqueue order.
	lu.assertEquals(#q, 4)
	lu.assertEquals(q:dequeue(), 42)
	lu.assertEquals(q:dequeue(), "hello")
	lu.assertTrue(q:dequeue())
	lu.assertEquals(q:dequeue(), { 1, 2 })
	lu.assertTrue(q:empty())
end

-- Scenarios: metamethods and formatting

function TestQueue:testLengthTracksEnqueueAndDequeueOperations()
	-- Given: the Queue starts empty.
	local q = Queue.new()

	-- When: add three values, remove two, then remove the last and one extra.
	-- Then: length follows 0, 3, 1, and 0 across those operations.
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

function TestQueue:testConcatAppendsIterableValuesInQueueOrder()
	-- Given: an empty Queue and a Stack whose top-to-bottom values are 40, 50, 60.
	local q = Queue.new()
	local s = require("ff.collections.stack").new()
	s:push(60)
	s:push(50)
	s:push(40)

	-- When: concatenate { 10, 20, 30 }, nil, then the Stack.
	q = q .. { 10, 20, 30 }
	q = q .. nil
	q = q .. s

	-- Then: dequeuing returns all six values in the expected order.
	lu.assertEquals(#q, 6)
	lu.assertEquals(q:dequeue(), 10)
	lu.assertEquals(q:dequeue(), 20)
	lu.assertEquals(q:dequeue(), 30)
	lu.assertEquals(q:dequeue(), 40)
	lu.assertEquals(q:dequeue(), 50)
	lu.assertEquals(q:dequeue(), 60)
end

function TestQueue:testConcatRejectsNonTableValues()
	-- Given: string and number operands are tried against an empty Queue.
	local q = Queue.new()

	-- When: concatenate a string and a number.
	-- Then: each operand raises the iterable type error.
	lu.assertErrorMsgContains("iterable should be a table", function()
		q = q .. "not a table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		q = q .. 42
	end)
end

function TestQueue:testQueuesWithSameValuesCompareEqual()
	-- Given: Queues share values, differ at one value, or have a shorter length.
	local q1 = Queue.new({ 1, 2, 3 })
	local q2 = Queue.new({ 1, 2, 3 })
	local q3 = Queue.new({ 1, 2, 4 })
	local q4 = Queue.new({ 1, 2 })

	-- Boolean assertions here intentionally exercise Queue.__eq.

	-- When: compare each Queue against q1, including non-Queue values.
	-- Then: only matching Queue contents compare equal.
	lu.assertTrue(q1 == q2)
	lu.assertFalse(q1 == q3)
	lu.assertFalse(q1 == q4)
	lu.assertFalse(q1 == {})
	lu.assertFalse(q1 == nil)
	lu.assertFalse(q1 == 42)
end

function TestQueue:testEmptyQueuesCompareEqual()
	-- Given: both Queues contain no items.
	local q1 = Queue.new()
	local q2 = Queue.new()
	-- This assertion exercises Queue.__eq; assertEquals compares table structure.

	-- When: compare the two empty Queues with ==.
	-- Then: equality returns true.
	lu.assertTrue(q1 == q2)
end

function TestQueue:testToStringFormatsQueueContents()
	-- Given: an empty Queue receives 1, 2, and 3 in FIFO order.
	local q = Queue.new()

	q:enqueue(1)
	q:enqueue(2)
	q:enqueue(3)

	-- When: format the populated Queue with tostring.
	local str = tostring(q)

	-- Then: formatted text includes each value and the Front marker.
	lu.assertStrContains(str, "1")
	lu.assertStrContains(str, "2")
	lu.assertStrContains(str, "3")
	lu.assertStrContains(str, "Front")
end

function TestQueue:testToStringFormatsEmptyQueue()
	-- Given: the Queue has no items to include in its text.
	local q = Queue.new()

	-- When: format the empty Queue with tostring.
	local str = tostring(q)

	-- Then: formatted text still includes the Front marker.
	lu.assertStrContains(str, "Front")
end

function TestQueue:testNewPropertiesAndMethodsCannotBeAddedOrReplaced()
	-- Given: an empty Queue defines method peek.
	local q = Queue.new()

	-- disallow adding properties

	-- When: assign a property, numeric key, function, and replacement peek method.
	-- Then: every assignment raises the property-protection error.
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

-- Suite map
return { TestQueue = TestQueue }
