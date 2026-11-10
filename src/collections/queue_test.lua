local lu = require("luaunit")
local Queue = require("ff.collections.queue")

local function queueValues(queue)
	local values = {}
	for index, value in pairs(queue) do
		values[index] = value
	end
	return values
end

local function orderedIterable(values)
	return setmetatable({}, {
		__pairs = function()
			local index = 0
			return function()
				index = index + 1
				if values[index] ~= nil then
					return index, values[index]
				end
			end
		end,
	})
end

local TestQueueClear = {}
local TestQueueConcat = {}
local TestQueueContains = {}
local TestQueueDequeue = {}
local TestQueueDrain = {}
local TestQueueEmpty = {}
local TestQueueEnqueue = {}
local TestQueueEnqueueAll = {}
local TestQueueEq = {}
local TestQueueFull = {}
local TestQueueIsQueue = {}
local TestQueueLen = {}
local TestQueueNew = {}
local TestQueueNewindex = {}
local TestQueuePairs = {}
local TestQueuePeek = {}
local TestQueueTostring = {}

function TestQueueClear:testClearPreservesCapacity()
	local queue = Queue.new(nil, 1)
	queue:enqueue("before")

	queue:clear()

	lu.assertFalse(queue:full())
	lu.assertTrue(queue:enqueue("after"))
	lu.assertTrue(queue:full())
	lu.assertFalse(queue:enqueue("extra"))
end

function TestQueueClear:testClearsEmptyQueue()
	local queue = Queue.new()

	queue:clear()

	lu.assertTrue(queue:empty())
	lu.assertEquals(#queue, 0)
	lu.assertNil(queue:peek())
	lu.assertNil(queue:dequeue())
end

function TestQueueClear:testClearsQueueAndAllowsReuse()
	local queue = Queue.new({ "first", "second" })

	queue:clear()

	lu.assertTrue(queue:empty())
	lu.assertEquals(queueValues(queue), {})
	lu.assertTrue(queue:enqueue("again"))
	lu.assertEquals(queue:peek(), "again")
	lu.assertEquals(#queue, 1)
end

function TestQueueConcat:testConcatenationCopiesWhenRightOperandIsNil()
	local queue = Queue.new({ 1, 2 })
	local copy = queue .. nil

	lu.assertFalse(rawequal(copy, queue))
	lu.assertTrue(copy == queue)
	lu.assertEquals(queueValues(queue), { 1, 2 })
	lu.assertEquals(queueValues(copy), { 1, 2 })
end

function TestQueueConcat:testConcatenationPreservesBoundedCapacity()
	local queue = Queue.new({ "first" }, 2)
	local joined = queue .. { "second" }

	lu.assertEquals(queueValues(joined), { "first", "second" })
	lu.assertTrue(joined:full())
	lu.assertFalse(joined:enqueue("third"))
end

function TestQueueConcat:testConcatenationRejectsNonTableRightOperand()
	local queue = Queue.new()

	for _, value in ipairs({ "text", 42, false }) do
		lu.assertErrorMsgContains("iterable should be a table", function()
			local _ = queue .. value
		end)
	end
end

function TestQueueConcat:testConcatenationTruncatesRightValuesAtCapacity()
	local left = Queue.new({ "left" }, 2)
	local joined = left .. orderedIterable({ "fits", "overflow" })

	lu.assertEquals(queueValues(joined), { "left", "fits" })
	lu.assertTrue(joined:full())
	lu.assertEquals(queueValues(left), { "left" })
end

function TestQueueConcat:testConcatenationWithAnotherQueuePreservesOrderAndOperands()
	local left = Queue.new({ "a", "b" })
	local right = Queue.new({ "c", false })
	local joined = left .. right

	lu.assertFalse(rawequal(joined, left))
	lu.assertEquals(queueValues(joined), { "a", "b", "c", false })
	lu.assertEquals(queueValues(left), { "a", "b" })
	lu.assertEquals(queueValues(right), { "c", false })
end

function TestQueueConcat:testConcatenationWithEmptyIterableKeepsLeftValues()
	local left = Queue.new({ 1, 2 })
	local joined = left .. {}

	lu.assertEquals(queueValues(joined), { 1, 2 })
	lu.assertEquals(queueValues(left), { 1, 2 })
end

function TestQueueContains:testContainsDoesNotConsumeOrReorderValues()
	local queue = Queue.new({ "front", "middle", "back" })

	lu.assertTrue(queue:contains("middle"))
	lu.assertEquals(#queue, 3)
	lu.assertEquals(queue:peek(), "front")
	lu.assertEquals(queueValues(queue), { "front", "middle", "back" })
end

function TestQueueContains:testContainsFindsDuplicatesWithoutConsumingThem()
	local queue = Queue.new({ 5, 5, 5 })

	lu.assertTrue(queue:contains(5))
	lu.assertEquals(#queue, 3)
	lu.assertEquals(queueValues(queue), { 5, 5, 5 })
end

function TestQueueContains:testContainsFindsValuesUsingEquality()
	local marker = {}
	local queue = Queue.new({ 0, false, marker })

	lu.assertTrue(queue:contains(0))
	lu.assertTrue(queue:contains(false))
	lu.assertTrue(queue:contains(marker))
	lu.assertFalse(queue:contains({}))
	lu.assertFalse(queue:contains("false"))
end

function TestQueueContains:testContainsRejectsNil()
	local queue = Queue.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		queue:contains(nil)
	end)
end

function TestQueueContains:testContainsReturnsFalseForAbsentValuesAndEmptyQueue()
	local queue = Queue.new({ 10, 20, 30 })

	lu.assertFalse(queue:contains(0))
	lu.assertFalse(queue:contains("10"))
	lu.assertFalse(Queue.new():contains(10))
end

function TestQueueDequeue:testDequeueReturnsFalseAndOtherAcceptedValues()
	local marker = {}
	local queue = Queue.new({ false, marker })

	lu.assertEquals(queue:dequeue(), false)
	lu.assertIs(queue:dequeue(), marker)
	lu.assertNil(queue:dequeue())
	lu.assertTrue(queue:empty())
end

function TestQueueDequeue:testDequeueReturnsNilRepeatedlyWhenEmpty()
	local queue = Queue.new()

	lu.assertNil(queue:dequeue())
	lu.assertNil(queue:dequeue())
	lu.assertTrue(queue:empty())
	lu.assertEquals(#queue, 0)
end

function TestQueueDequeue:testDequeueReturnsValuesInFifoOrder()
	local queue = Queue.new({ "first", "second", "third" })

	lu.assertEquals(queue:dequeue(), "first")
	lu.assertEquals(queue:dequeue(), "second")
	lu.assertEquals(queue:dequeue(), "third")
	lu.assertTrue(queue:empty())
	lu.assertEquals(#queue, 0)
end

function TestQueueDequeue:testRemovingFromFullBoundedQueueMakesRoom()
	local queue = Queue.new({ 1, 2 }, 2)

	lu.assertTrue(queue:full())
	lu.assertEquals(queue:dequeue(), 1)
	lu.assertFalse(queue:full())
	lu.assertTrue(queue:enqueue(3))
	lu.assertEquals(queueValues(queue), { 2, 3 })
	lu.assertTrue(queue:full())
end

function TestQueueDequeue:testRemovingLastValueAllowsQueueReuse()
	local queue = Queue.new({ "only" })

	lu.assertEquals(queue:dequeue(), "only")
	lu.assertTrue(queue:empty())
	lu.assertTrue(queue:enqueue("next"))
	lu.assertEquals(queue:peek(), "next")
	lu.assertEquals(queue:dequeue(), "next")
	lu.assertTrue(queue:empty())
end

function TestQueueDrain:testDrainCanStopEarlyAndContinueFromCurrentFront()
	local queue = Queue.new({ 1, 2, 3 })
	local nextValue = queue:drain()

	lu.assertEquals(nextValue(), 1)
	lu.assertEquals(#queue, 2)
	lu.assertEquals(queue:peek(), 2)
	lu.assertEquals(nextValue(), 2)
	lu.assertEquals(nextValue(), 3)
	lu.assertNil(nextValue())
	lu.assertTrue(queue:empty())
end

function TestQueueDrain:testDrainConsumesInFifoOrderAndEmptiesQueue()
	local queue = Queue.new({ "first", false, "last" })
	local values = {}

	for value in queue:drain() do
		table.insert(values, value)
	end

	lu.assertEquals(values, { "first", false, "last" })
	lu.assertTrue(queue:empty())
	lu.assertEquals(#queue, 0)
	lu.assertNil(queue:peek())
	lu.assertNil(queue:dequeue())
end

function TestQueueDrain:testDrainFromEmptyQueueYieldsNoValues()
	local queue = Queue.new()
	local count = 0

	for _ in queue:drain() do
		count = count + 1
	end

	lu.assertEquals(count, 0)
	lu.assertTrue(queue:empty())
end

function TestQueueEmpty:testEmptyTracksQueueTransitions()
	local queue = Queue.new()

	lu.assertTrue(queue:empty())
	queue:enqueue("value")
	lu.assertFalse(queue:empty())
	queue:dequeue()
	lu.assertTrue(queue:empty())
	queue:enqueue("again")
	queue:clear()
	lu.assertTrue(queue:empty())
end

function TestQueueEnqueue:testEnqueueAcceptsFalseAndOtherNonNilValues()
	local marker = {}
	local queue = Queue.new()

	lu.assertTrue(queue:enqueue(false))
	lu.assertTrue(queue:enqueue(marker))
	lu.assertEquals(queueValues(queue), { false, marker })
	lu.assertEquals(#queue, 2)
end

function TestQueueEnqueue:testEnqueueAddsValuesAtBackInFifoOrder()
	local queue = Queue.new({ "first" })

	lu.assertTrue(queue:enqueue("second"))
	lu.assertTrue(queue:enqueue("third"))
	lu.assertEquals(queueValues(queue), { "first", "second", "third" })
	lu.assertEquals(queue:peek(), "first")
end

function TestQueueEnqueue:testEnqueueRejectsNilWithoutChangingQueue()
	local queue = Queue.new({ "kept" })

	lu.assertErrorMsgContains("value should not be nil", function()
		queue:enqueue(nil)
	end)

	lu.assertEquals(queueValues(queue), { "kept" })
	lu.assertEquals(#queue, 1)
end

function TestQueueEnqueue:testEnqueueReturnsFalseAndPreservesFullQueue()
	local queue = Queue.new({ "first", "second" }, 2)

	lu.assertFalse(queue:enqueue("extra"))
	lu.assertTrue(queue:full())
	lu.assertEquals(queueValues(queue), { "first", "second" })
end

function TestQueueEnqueue:testEnqueueReturnsTrueAndFillsLastAvailableSlot()
	local queue = Queue.new(nil, 2)

	lu.assertTrue(queue:enqueue("first"))
	lu.assertFalse(queue:full())
	lu.assertTrue(queue:enqueue("second"))
	lu.assertTrue(queue:full())
	lu.assertEquals(#queue, 2)
end

function TestQueueEnqueueAll:testEnqueueAllAcceptsCustomPairsOrder()
	local queue = Queue.new({ "existing" })

	lu.assertTrue(queue:enqueueAll(orderedIterable({ "first", false, "last" })))
	lu.assertEquals(queueValues(queue), { "existing", "first", false, "last" })
end

function TestQueueEnqueueAll:testEnqueueAllAddsAllValuesFromTable()
	local queue = Queue.new({ "existing" })

	lu.assertTrue(queue:enqueueAll({ alpha = 10, beta = 20, gamma = 30 }))
	lu.assertEquals(#queue, 4)
	lu.assertTrue(queue:contains("existing"))
	lu.assertTrue(queue:contains(10))
	lu.assertTrue(queue:contains(20))
	lu.assertTrue(queue:contains(30))
end

function TestQueueEnqueueAll:testEnqueueAllEmptyTableLeavesQueueUnchanged()
	local queue = Queue.new({ 1 })

	lu.assertTrue(queue:enqueueAll({}))
	lu.assertEquals(queueValues(queue), { 1 })
	lu.assertEquals(#queue, 1)
end

function TestQueueEnqueueAll:testEnqueueAllIsNoOpOnSelfAndReturnsFalse()
	local queue = Queue.new({ "first", "second" })

	lu.assertFalse(queue:enqueueAll(queue))
	lu.assertEquals(queueValues(queue), { "first", "second" })
	lu.assertEquals(#queue, 2)
end

function TestQueueEnqueueAll:testEnqueueAllRejectsNonTableInputs()
	local queue = Queue.new()

	for _, value in ipairs({ "text", 42, false }) do
		lu.assertErrorMsgContains("iterable should be a table", function()
			queue:enqueueAll(value)
		end)
	end
	lu.assertErrorMsgContains("iterable should be a table", function()
		queue:enqueueAll(nil)
	end)
	lu.assertTrue(queue:empty())
end

function TestQueueEnqueueAll:testEnqueueAllReturnsFalseWhenCapacityIsReachedMidway()
	local queue = Queue.new({ "existing" }, 2)

	lu.assertFalse(queue:enqueueAll(orderedIterable({ "added", "not-added" })))
	lu.assertTrue(queue:full())
	lu.assertEquals(queueValues(queue), { "existing", "added" })
end

function TestQueueEnqueueAll:testEnqueueAllReturnsTrueWhenLastValueFillsCapacity()
	local queue = Queue.new({ "existing" }, 3)

	lu.assertTrue(queue:enqueueAll({ "added", "last" }))
	lu.assertTrue(queue:full())
	lu.assertEquals(queueValues(queue), { "existing", "added", "last" })
end

function TestQueueEq:testEmptyQueuesCompareEqual()
	lu.assertTrue(Queue.new() == Queue.new())
end

function TestQueueEq:testEqualityRejectsNonQueues()
	local queue = Queue.new()

	lu.assertFalse(queue == {})
	lu.assertFalse(queue == setmetatable({}, { __index = Queue }))
	lu.assertFalse(queue == nil)
	lu.assertFalse(queue == "queue")
	lu.assertFalse(queue == 42)
end

function TestQueueEq:testEqualQueuesRequireSameValuesInSameFifoOrder()
	local first = Queue.new({ 1, false, 3 })
	local same = Queue.new({ 1, false, 3 })
	local reordered = Queue.new({ false, 1, 3 })
	local shorter = Queue.new({ 1, false })

	lu.assertTrue(first == same)
	lu.assertFalse(first == reordered)
	lu.assertFalse(first == shorter)
end

function TestQueueEq:testQueuesWithDifferentValuesCompareUnequal()
	lu.assertFalse(Queue.new({ 1, 2, 3 }) == Queue.new({ 1, 2, 4 }))
end

function TestQueueFull:testBoundedQueueReportsFullAtCapacity()
	local queue = Queue.new(nil, 2)

	lu.assertFalse(queue:full())
	queue:enqueue(1)
	lu.assertFalse(queue:full())
	queue:enqueue(2)
	lu.assertTrue(queue:full())
end

function TestQueueFull:testClearAndDequeueMakeBoundedQueueNotFull()
	local queue = Queue.new({ 1 }, 1)

	lu.assertTrue(queue:full())
	queue:dequeue()
	lu.assertFalse(queue:full())
	queue:enqueue(2)
	queue:clear()
	lu.assertFalse(queue:full())
end

function TestQueueFull:testUnboundedQueueNeverReportsFull()
	local queue = Queue.new({ 1, 2, 3 })

	lu.assertFalse(queue:full())
	queue:enqueue(4)
	lu.assertFalse(queue:full())
end

function TestQueueIsQueue:testIsQueueAcceptsQueueInstancesOnly()
	lu.assertTrue(Queue.isQueue(Queue.new()))
	lu.assertTrue(Queue.isQueue(Queue.new({ 1 }, 2)))
	lu.assertFalse(Queue.isQueue(nil))
	lu.assertFalse(Queue.isQueue({}))
	lu.assertFalse(Queue.isQueue(setmetatable({}, { __index = Queue })))
	lu.assertFalse(Queue.isQueue("queue"))
	lu.assertFalse(Queue.isQueue(1))
	lu.assertFalse(Queue.isQueue(false))
	lu.assertFalse(Queue.isQueue(function() end))
end

function TestQueueLen:testLengthTracksEnqueueDequeueAndClear()
	local queue = Queue.new()

	lu.assertEquals(#queue, 0)
	queue:enqueue("first")
	queue:enqueue("second")
	lu.assertEquals(#queue, 2)
	queue:dequeue()
	lu.assertEquals(#queue, 1)
	queue:clear()
	lu.assertEquals(#queue, 0)
end

function TestQueueNew:testNewAcceptsNilIterableAndStartsEmpty()
	local queue = Queue.new(nil)

	lu.assertTrue(Queue.isQueue(queue))
	lu.assertTrue(queue:empty())
	lu.assertEquals(#queue, 0)
	lu.assertNil(queue:peek())
end

function TestQueueNew:testNewAcceptsPositiveIntegerCapacity()
	local queue = Queue.new(nil, 3)

	lu.assertTrue(queue:empty())
	lu.assertFalse(queue:full())
	lu.assertTrue(queue:enqueue("one"))
	lu.assertTrue(queue:enqueue("two"))
	lu.assertTrue(queue:enqueue("three"))
	lu.assertTrue(queue:full())
end

function TestQueueNew:testNewInitializesFromEmptyIterable()
	local queue = Queue.new({})

	lu.assertTrue(queue:empty())
	lu.assertEquals(#queue, 0)
	lu.assertNil(queue:peek())
end

function TestQueueNew:testNewInitializesFromIterableInPairsOrder()
	local queue = Queue.new(orderedIterable({ "first", false, "last" }))

	lu.assertEquals(queueValues(queue), { "first", false, "last" })
	lu.assertEquals(queue:peek(), "first")
end

function TestQueueNew:testNewInitializesFromTableValues()
	local queue = Queue.new({ alpha = 10, beta = 20, gamma = 30 })

	lu.assertEquals(#queue, 3)
	lu.assertTrue(queue:contains(10))
	lu.assertTrue(queue:contains(20))
	lu.assertTrue(queue:contains(30))
end

function TestQueueNew:testNewKeepsInitialValuesThatFitCapacity()
	local queue = Queue.new(orderedIterable({ "first", "fits", "overflow" }), 2)

	lu.assertEquals(queueValues(queue), { "first", "fits" })
	lu.assertTrue(queue:full())
end

function TestQueueNew:testNewRejectsInvalidCapacityTypes()
	for _, capacity in ipairs({ "2", true, {} }) do
		lu.assertErrorMsgContains("capacity should be a number", function()
			Queue.new(nil, capacity)
		end)
	end
end

function TestQueueNew:testNewRejectsNonIntegerOrInfiniteCapacity()
	for _, capacity in ipairs({ 1.5, math.huge }) do
		lu.assertErrorMsgContains("capacity should be an integer", function()
			Queue.new(nil, capacity)
		end)
	end
	lu.assertErrorMsgContains("capacity should be positive", function()
		Queue.new(nil, 0 / 0)
	end)
end

function TestQueueNew:testNewRejectsNonPositiveCapacity()
	for _, capacity in ipairs({ 0, -1, -math.huge }) do
		lu.assertErrorMsgContains("capacity should be positive", function()
			Queue.new(nil, capacity)
		end)
	end
end

function TestQueueNew:testNewRejectsNonTableIterable()
	for _, iterable in ipairs({ "text", 42, false }) do
		lu.assertErrorMsgContains("iterable should be a table", function()
			Queue.new(iterable)
		end)
	end
end

function TestQueueNew:testNewUsesCapacityWhileLoadingIterable()
	local queue = Queue.new({ 1, 2 }, 2)

	lu.assertEquals(queueValues(queue), { 1, 2 })
	lu.assertTrue(queue:full())
end

function TestQueueNewindex:testInheritedMethodsCannotBeReplacedOnInstance()
	local queue = Queue.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		queue.enqueue = function() end
	end)
end

function TestQueueNewindex:testNewPropertiesAndNumericKeysAreRejected()
	local queue = Queue.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		queue.label = "extra"
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Queue", function()
		queue[1] = "extra"
	end)
end

function TestQueuePairs:testPairsIsRepeatableAndNonDestructive()
	local queue = Queue.new({ 1, 2, 3 })
	local firstPass = queueValues(queue)
	local secondPass = queueValues(queue)

	lu.assertEquals(firstPass, { 1, 2, 3 })
	lu.assertEquals(secondPass, { 1, 2, 3 })
	lu.assertEquals(#queue, 3)
	lu.assertEquals(queue:peek(), 1)
end

function TestQueuePairs:testPairsIteratesInFifoOrderWithSequentialKeys()
	local queue = Queue.new({ "first", false, "third" })
	local keys = {}
	local values = {}

	for index, value in pairs(queue) do
		table.insert(keys, index)
		table.insert(values, value)
	end

	lu.assertEquals(keys, { 1, 2, 3 })
	lu.assertEquals(values, { "first", false, "third" })
end

function TestQueuePairs:testPairsOnEmptyQueueYieldsNothing()
	local count = 0

	for _ in pairs(Queue.new()) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestQueuePeek:testPeekReturnsFalseWhenFalseIsAtFront()
	local queue = Queue.new({ false, "back" })

	lu.assertEquals(queue:peek(), false)
	lu.assertEquals(#queue, 2)
end

function TestQueuePeek:testPeekReturnsFrontWithoutConsumingQueue()
	local queue = Queue.new({ "front", "back" })

	lu.assertEquals(queue:peek(), "front")
	lu.assertEquals(queue:peek(), "front")
	lu.assertEquals(#queue, 2)
	lu.assertEquals(queue:dequeue(), "front")
	lu.assertEquals(queue:peek(), "back")
end

function TestQueuePeek:testPeekReturnsNilWhenEmpty()
	lu.assertNil(Queue.new():peek())
end

function TestQueueTostring:testTostringFormatsEmptyQueue()
	lu.assertEquals(tostring(Queue.new()), "[ Front =>  ]")
end

function TestQueueTostring:testTostringFormatsValuesInFifoOrder()
	local queue = Queue.new({ "first", false, 3 })

	lu.assertEquals(tostring(queue), "[ Front => first, false, 3 ]")
end

function TestQueueTostring:testTostringUsesValueStringRepresentations()
	local token = setmetatable({}, {
		__tostring = function()
			return "token"
		end,
	})
	local queue = Queue.new({ token })

	lu.assertEquals(tostring(queue), "[ Front => token ]")
end

return {
	TestQueueClear = TestQueueClear,
	TestQueueConcat = TestQueueConcat,
	TestQueueContains = TestQueueContains,
	TestQueueDequeue = TestQueueDequeue,
	TestQueueDrain = TestQueueDrain,
	TestQueueEmpty = TestQueueEmpty,
	TestQueueEnqueue = TestQueueEnqueue,
	TestQueueEnqueueAll = TestQueueEnqueueAll,
	TestQueueEq = TestQueueEq,
	TestQueueFull = TestQueueFull,
	TestQueueIsQueue = TestQueueIsQueue,
	TestQueueLen = TestQueueLen,
	TestQueueNew = TestQueueNew,
	TestQueueNewindex = TestQueueNewindex,
	TestQueuePairs = TestQueuePairs,
	TestQueuePeek = TestQueuePeek,
	TestQueueTostring = TestQueueTostring,
}
