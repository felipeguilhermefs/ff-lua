local lu = require("luaunit")
local Stack = require("ff.collections.stack")

local function stackValues(stack)
	local values = {}
	for index, value in pairs(stack) do
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

local TestStackClear = {}
local TestStackConcat = {}
local TestStackContains = {}
local TestStackDrain = {}
local TestStackEmpty = {}
local TestStackEq = {}
local TestStackIsStack = {}
local TestStackLen = {}
local TestStackNew = {}
local TestStackNewindex = {}
local TestStackPairs = {}
local TestStackPop = {}
local TestStackPush = {}
local TestStackPushAll = {}
local TestStackReverse = {}
local TestStackTop = {}
local TestStackTostring = {}

function TestStackClear:testClearsEmptyStackWithoutError()
	local stack = Stack.new()

	stack:clear()

	lu.assertTrue(stack:empty())
	lu.assertEquals(#stack, 0)
end

function TestStackClear:testClearsStackAndAllowsReuse()
	local stack = Stack.new({ "bottom", "top" })

	stack:clear()

	lu.assertTrue(stack:empty())
	lu.assertNil(stack:top())
	lu.assertNil(stack:pop())
	lu.assertFalse(stack:contains("top"))
	stack:push("again")
	lu.assertEquals(stack:top(), "again")
	lu.assertEquals(#stack, 1)
end

function TestStackConcat:testConcatenationAppendsValuesAndPreservesOperands()
	local left = Stack.new()
	left:push("bottom")
	left:push("top")
	local right = orderedIterable({ "next-bottom", "next-top" })

	local joined = left .. right

	lu.assertFalse(rawequal(joined, left))
	lu.assertEquals(stackValues(left), { "top", "bottom" })
	lu.assertEquals(stackValues(joined), { "next-top", "next-bottom", "top", "bottom" })
end

function TestStackConcat:testConcatenationOfNilReturnsIndependentCopy()
	local source = Stack.new()
	source:push(1)
	source:push(2)

	local copy = source .. nil

	lu.assertFalse(rawequal(copy, source))
	lu.assertEquals(stackValues(copy), { 2, 1 })
	lu.assertEquals(stackValues(source), { 2, 1 })
end

function TestStackConcat:testConcatenationRejectsNonTableIterable()
	local stack = Stack.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = stack .. false
	end)
end

function TestStackConcat:testConcatenationWithStackPreservesBothOrders()
	local left = Stack.new()
	left:push(1)
	left:push(2)
	local right = Stack.new()
	right:push(3)
	right:push(4)

	local joined = left .. right

	lu.assertEquals(stackValues(joined), { 4, 3, 2, 1 })
	lu.assertEquals(stackValues(left), { 2, 1 })
	lu.assertEquals(stackValues(right), { 4, 3 })
end

function TestStackContains:testContainsDoesNotChangeStack()
	local stack = Stack.new()
	stack:push(1)
	stack:push(2)

	lu.assertTrue(stack:contains(1))
	lu.assertEquals(#stack, 2)
	lu.assertEquals(stack:top(), 2)
	lu.assertEquals(stackValues(stack), { 2, 1 })
end

function TestStackContains:testContainsMatchesValuesAndUsesEquality()
	local marker = {}
	local stack = Stack.new()
	stack:push(0)
	stack:push(false)
	stack:push(marker)

	lu.assertTrue(stack:contains(0))
	lu.assertTrue(stack:contains(false))
	lu.assertTrue(stack:contains(marker))
	lu.assertFalse(stack:contains({}))
	lu.assertFalse(stack:contains("false"))
end

function TestStackContains:testContainsRejectsNil()
	local stack = Stack.new()

	lu.assertErrorMsgContains("entry should not be nil", function()
		stack:contains(nil)
	end)
end

function TestStackDrain:testDrainCanStopEarlyAndContinuesFromCurrentTop()
	local stack = Stack.new()
	stack:push(1)
	stack:push(2)
	stack:push(3)
	local nextValue = stack:drain()

	lu.assertEquals(nextValue(), 3)
	lu.assertEquals(#stack, 2)
	lu.assertEquals(stack:top(), 2)
	lu.assertEquals(nextValue(), 2)
	lu.assertEquals(nextValue(), 1)
	lu.assertNil(nextValue())
	lu.assertTrue(stack:empty())
end

function TestStackDrain:testDrainConsumesValuesInLifoOrder()
	local stack = Stack.new()
	stack:push("first")
	stack:push(false)
	stack:push("third")

	local values = {}
	for value in stack:drain() do
		table.insert(values, value)
	end

	lu.assertEquals(values, { "third", false, "first" })
	lu.assertTrue(stack:empty())
	lu.assertEquals(#stack, 0)
	lu.assertNil(stack:top())
end

function TestStackDrain:testDrainFromEmptyStackYieldsNoValues()
	local stack = Stack.new()
	local count = 0

	for _ in stack:drain() do
		count = count + 1
	end

	lu.assertEquals(count, 0)
	lu.assertTrue(stack:empty())
end

function TestStackEmpty:testEmptyTracksPushAndPopTransitions()
	local stack = Stack.new()

	lu.assertTrue(stack:empty())
	stack:push(false)
	lu.assertFalse(stack:empty())
	stack:pop()
	lu.assertTrue(stack:empty())
end

function TestStackEq:testEmptyStacksCompareEqual()
	lu.assertTrue(Stack.new() == Stack.new())
end

function TestStackEq:testEqualStacksRequireSameValuesInSameOrder()
	local first = Stack.new()
	first:push(1)
	first:push(2)
	local same = Stack.new()
	same:push(1)
	same:push(2)
	local reversed = Stack.new()
	reversed:push(2)
	reversed:push(1)
	local shorter = Stack.new()
	shorter:push(1)

	lu.assertTrue(first == same)
	lu.assertFalse(first == reversed)
	lu.assertFalse(first == shorter)
end

function TestStackEq:testEqualityRejectsNonStacks()
	local stack = Stack.new()

	lu.assertFalse(stack == {})
	lu.assertFalse(stack == nil)
	lu.assertFalse(stack == "stack")
end

function TestStackIsStack:testIsStackAcceptsInstancesOnly()
	local stack = Stack.new()

	lu.assertTrue(Stack.isStack(stack))
	lu.assertFalse(Stack.isStack(nil))
	lu.assertFalse(Stack.isStack({}))
	lu.assertFalse(Stack.isStack(setmetatable({}, { __index = Stack })))
	lu.assertFalse(Stack.isStack("stack"))
	lu.assertFalse(Stack.isStack(1))
	lu.assertFalse(Stack.isStack(false))
end

function TestStackLen:testLengthTracksMutations()
	local stack = Stack.new()

	lu.assertEquals(#stack, 0)
	stack:push("one")
	lu.assertEquals(#stack, 1)
	stack:push("two")
	lu.assertEquals(#stack, 2)
	stack:pop()
	lu.assertEquals(#stack, 1)
	stack:clear()
	lu.assertEquals(#stack, 0)
end

function TestStackNew:testNewAcceptsNilAndStartsEmpty()
	local stack = Stack.new(nil)

	lu.assertTrue(stack:empty())
	lu.assertEquals(#stack, 0)
	lu.assertNil(stack:top())
end

function TestStackNew:testNewCopiesStackWithoutChangingItsOrder()
	local source = Stack.new()
	source:push("bottom")
	source:push("top")

	local copy = Stack.new(source)

	lu.assertTrue(Stack.isStack(copy))
	lu.assertFalse(rawequal(copy, source))
	lu.assertEquals(stackValues(copy), { "top", "bottom" })
	lu.assertEquals(stackValues(source), { "top", "bottom" })
end

function TestStackNew:testNewFollowsIterablePairsOrder()
	local stack = Stack.new(orderedIterable({ 10, 20, 30 }))

	lu.assertEquals(#stack, 3)
	lu.assertEquals(stack:top(), 30)
	lu.assertEquals(stack:pop(), 30)
	lu.assertEquals(stack:pop(), 20)
	lu.assertEquals(stack:pop(), 10)
	lu.assertTrue(stack:empty())
end

function TestStackNew:testNewInitializesFromTableValues()
	local stack = Stack.new({ alpha = 10, beta = 20, gamma = 30 })

	lu.assertEquals(#stack, 3)
	lu.assertTrue(stack:contains(10))
	lu.assertTrue(stack:contains(20))
	lu.assertTrue(stack:contains(30))
end

function TestStackNew:testNewRejectsNonTableIterable()
	for _, value in ipairs({ "text", 1, false }) do
		lu.assertErrorMsgContains("iterable should be a table", function()
			Stack.new(value)
		end)
	end
end

function TestStackNewindex:testNewPropertiesAndNumericKeysAreRejected()
	local stack = Stack.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		stack.label = "extra"
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		stack[1] = "extra"
	end)
end

function TestStackNewindex:testInheritedMethodsCannotBeReplacedOnInstance()
	local stack = Stack.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		stack.push = function() end
	end)
end

function TestStackPairs:testPairsIsRepeatableAndNonDestructive()
	local stack = Stack.new()
	stack:push(1)
	stack:push(2)

	local firstPass = stackValues(stack)
	local secondPass = stackValues(stack)

	lu.assertEquals(firstPass, { 2, 1 })
	lu.assertEquals(secondPass, { 2, 1 })
	lu.assertEquals(#stack, 2)
	lu.assertEquals(stack:top(), 2)
end

function TestStackPairs:testPairsIteratesTopToBottomWithSequentialKeys()
	local stack = Stack.new()
	stack:push("bottom")
	stack:push("middle")
	stack:push("top")

	lu.assertEquals(stackValues(stack), { "top", "middle", "bottom" })
end

function TestStackPairs:testPairsOnEmptyStackYieldsNothing()
	local count = 0
	for _ in pairs(Stack.new()) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestStackPop:testPopFromEmptyStackReturnsNilRepeatedly()
	local stack = Stack.new()

	lu.assertNil(stack:pop())
	lu.assertNil(stack:pop())
	lu.assertTrue(stack:empty())
end

function TestStackPop:testPopReturnsValuesInLifoOrderIncludingFalse()
	local marker = {}
	local stack = Stack.new()
	stack:push(1)
	stack:push(false)
	stack:push(marker)

	lu.assertIs(stack:pop(), marker)
	lu.assertEquals(stack:pop(), false)
	lu.assertFalse(stack:contains(false))
	lu.assertEquals(stack:pop(), 1)
	lu.assertNil(stack:pop())
	lu.assertTrue(stack:empty())
end

function TestStackPush:testPushAcceptsFalseAndOtherNonNilValues()
	local marker = {}
	local stack = Stack.new()

	stack:push(false)
	lu.assertEquals(stack:top(), false)
	stack:push(marker)
	lu.assertIs(stack:top(), marker)
	lu.assertEquals(#stack, 2)
end

function TestStackPush:testPushRejectsNilWithoutChangingExistingValues()
	local stack = Stack.new()
	stack:push("kept")

	lu.assertErrorMsgContains("entry should not be nil", function()
		stack:push(nil)
	end)

	lu.assertEquals(#stack, 1)
	lu.assertEquals(stack:top(), "kept")
end

function TestStackPushAll:testPushAllAddsEveryTableValue()
	local marker = {}
	local stack = Stack.new()
	stack:push("existing")

	stack:pushAll({ alpha = marker, beta = false, gamma = 3 })

	lu.assertEquals(#stack, 4)
	lu.assertTrue(stack:contains(marker))
	lu.assertTrue(stack:contains(false))
	lu.assertTrue(stack:contains(3))
	lu.assertTrue(stack:contains("existing"))
end

function TestStackPushAll:testPushAllEmptyTableLeavesStackUnchanged()
	local stack = Stack.new()
	stack:push(1)

	stack:pushAll({})

	lu.assertEquals(#stack, 1)
	lu.assertEquals(stack:top(), 1)
end

function TestStackPushAll:testPushAllPushesValuesAfterExistingStack()
	local stack = Stack.new()
	stack:push(10)

	stack:pushAll({ 20 })

	lu.assertEquals(stack:top(), 20)
	lu.assertEquals(stack:pop(), 20)
	lu.assertEquals(stack:pop(), 10)
end

function TestStackPushAll:testPushAllRejectsNonTableInputs()
	local stack = Stack.new()

	for _, value in ipairs({ "text", 1, false }) do
		lu.assertErrorMsgContains("iterable should be a table", function()
			stack:pushAll(value)
		end)
	end
	lu.assertErrorMsgContains("iterable should be a table", function()
		stack:pushAll(nil)
	end)
	lu.assertTrue(stack:empty())
end

function TestStackReverse:testReverseEmptyAndSingleValueStacks()
	local empty = Stack.new()
	local single = Stack.new()
	single:push("only")

	lu.assertTrue(rawequal(empty:reverse(), empty))
	lu.assertTrue(empty:empty())
	lu.assertTrue(rawequal(single:reverse(), single))
	lu.assertEquals(stackValues(single), { "only" })
end

function TestStackReverse:testReverseEvenAndOddStacks()
	local even = Stack.new()
	for value = 1, 4 do
		even:push(value)
	end
	local odd = Stack.new()
	for value = 1, 5 do
		odd:push(value)
	end

	even:reverse()
	odd:reverse()

	lu.assertEquals(stackValues(even), { 1, 2, 3, 4 })
	lu.assertEquals(stackValues(odd), { 1, 2, 3, 4, 5 })
end

function TestStackReverse:testReverseTwiceRestoresOriginalOrder()
	local stack = Stack.new()
	stack:push("a")
	stack:push("b")
	stack:push("c")
	local original = stackValues(stack)

	stack:reverse():reverse()

	lu.assertEquals(stackValues(stack), original)
end

function TestStackTop:testTopReturnsCurrentValueWithoutConsumingIt()
	local stack = Stack.new()
	stack:push("bottom")
	stack:push(false)

	lu.assertEquals(stack:top(), false)
	lu.assertEquals(stack:top(), false)
	lu.assertEquals(#stack, 2)
	lu.assertEquals(stack:pop(), false)
	lu.assertEquals(stack:top(), "bottom")
end

function TestStackTop:testTopReturnsNilWhenEmpty()
	lu.assertNil(Stack.new():top())
end

function TestStackTostring:testTostringFormatsEmptyAndOrderedStacks()
	local empty = Stack.new()
	local stack = Stack.new()
	stack:push("bottom")
	stack:push("top")

	lu.assertEquals(tostring(empty), "[  <- Top ]")
	lu.assertEquals(tostring(stack), "[ bottom, top <- Top ]")
end

function TestStackTostring:testTostringFormatsNumericEntries()
	local stack = Stack.new()
	stack:push(10)
	stack:push(20)

	lu.assertEquals(tostring(stack), "[ 10, 20 <- Top ]")
end

function TestStackTostring:testTostringSupportsOtherAcceptedEntryTypes()
	local stack = Stack.new()
	stack:push(false)

	lu.assertEquals(tostring(stack), "[ false <- Top ]")
end

return {
	TestStackClear = TestStackClear,
	TestStackConcat = TestStackConcat,
	TestStackContains = TestStackContains,
	TestStackDrain = TestStackDrain,
	TestStackEmpty = TestStackEmpty,
	TestStackEq = TestStackEq,
	TestStackIsStack = TestStackIsStack,
	TestStackLen = TestStackLen,
	TestStackNew = TestStackNew,
	TestStackNewindex = TestStackNewindex,
	TestStackPairs = TestStackPairs,
	TestStackPop = TestStackPop,
	TestStackPush = TestStackPush,
	TestStackPushAll = TestStackPushAll,
	TestStackReverse = TestStackReverse,
	TestStackTop = TestStackTop,
	TestStackTostring = TestStackTostring,
}
