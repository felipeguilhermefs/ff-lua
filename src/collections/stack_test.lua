local lu = require("luaunit")
local Stack = require("ff.collections.stack")

local append = table.insert

local TestStack = {}

function TestStack:testTypeGuard_RecognizesStacksAndRejectsOtherValues()
	local s = Stack.new()

	lu.assertTrue(Stack.isStack(s))
	lu.assertFalse(Stack.isStack({}))
	lu.assertFalse(Stack.isStack(nil))
	lu.assertFalse(Stack.isStack("stack"))
	lu.assertFalse(Stack.isStack(123))
end

function TestStack:testConstructor_PreservesIterableOrderAndSetsTop()
	local s1 = Stack.new()

	lu.assertTrue(s1:empty())

	local s2 = Stack.new({ 10, 20, 30 })

	lu.assertEquals(#s2, 3)
	lu.assertEquals(s2:top(), 30)
end

function TestStack:testEmptyStack_DoesNotContainValues()
	local stack = Stack.new()

	lu.assertFalse(stack:contains(1))
end

function TestStack:testContains_ReportsEachStoredValueAsPresent()
	local stack = Stack.new({ 10, 20, 30 })

	lu.assertTrue(stack:contains(10))
	lu.assertTrue(stack:contains(20))
	lu.assertTrue(stack:contains(30))
end

function TestStack:testContains_ReportsUnstoredValuesAsAbsent()
	local stack = Stack.new({ 10, 20, 30 })

	lu.assertFalse(stack:contains(99))
	lu.assertFalse(stack:contains("10"))
end

function TestStack:testPoppedValue_IsNoLongerContained()
	local stack = Stack.new({ 10, 20, 30 })

	stack:pop()

	lu.assertFalse(stack:contains(30))
end

function TestStack:testIteration_YieldsValuesFromTopToBottom()
	local s = Stack.new()

	s:push("a")
	s:push("b")
	s:push("c")
	s:push("d")

	local keys = {}
	local res = {}
	for i, item in pairs(s) do
		append(keys, i)
		append(res, item)
	end

	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "d", "c", "b", "a" })
	lu.assertFalse(s:empty())
	lu.assertEquals(#s, 4)
	lu.assertEquals(s:top(), "d")
end

function TestStack:testEmptyStackIteration_YieldsNoValues()
	local s = Stack.new()

	local count = 0

	for _ in pairs(s) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestStack:testRepeatedIteration_PreservesStackContents()
	local s = Stack.new({ "x", "y", "z" })

	local firstRun = {}

	for _, item in pairs(s) do
		append(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(s) do
		append(secondRun, item)
	end

	lu.assertEquals(firstRun, { "z", "y", "x" })
	lu.assertEquals(secondRun, { "z", "y", "x" })
	lu.assertEquals(#s, 3)
end

function TestStack:testEmptyStack_PopReturnsNil()
	local stack = Stack.new()

	lu.assertTrue(stack:empty())
	lu.assertNil(stack:pop())
end

function TestStack:testClear_RemovesAllPushedValues()
	local stack = Stack.new({ "item" })

	stack:clear()

	lu.assertTrue(stack:empty())
	lu.assertEquals(#stack, 0)
end

function TestStack:testPushAndPop_PreserveSingleValue()
	local s = Stack.new()

	s:push(1)

	lu.assertFalse(s:empty())
	lu.assertEquals(s:top(), 1)
	lu.assertEquals(s:pop(), 1)
	lu.assertTrue(s:empty())
end

function TestStack:testPop_ReturnsPushedValuesInLastInFirstOutOrder()
	local s = Stack.new()

	s:push(1)
	s:push(true)
	s:push("abc")
	s:push({ 4, 5, 6 })

	lu.assertFalse(s:empty())
	lu.assertEquals(s:pop(), { 4, 5, 6 })
	lu.assertEquals(s:pop(), "abc")
	lu.assertTrue(s:pop())
	lu.assertEquals(s:top(), 1)
	lu.assertEquals(s:pop(), 1)
	lu.assertTrue(s:empty())
end

function TestStack:testPush_RejectsNilEntries()
	local s = Stack.new()

	lu.assertErrorMsgContains("entry should not be nil", function()
		s:push(nil)
	end)
end

function TestStack:testReverse_MakesBottomValuePopFirst()
	local s = Stack.new({ 1, 2, 3, 4 })

	s:reverse()

	lu.assertEquals(s:pop(), 1)
	lu.assertEquals(s:pop(), 2)
	lu.assertEquals(s:pop(), 3)
	lu.assertEquals(s:pop(), 4)
end

function TestStack:testDrain_YieldsValuesInLastInFirstOutOrderAndEmptiesStack()
	local s = Stack.new()

	s:push("a")
	s:push("b")
	s:push("c")
	s:push("d")

	local res = {}
	for item in s:drain() do
		append(res, item)
	end

	lu.assertEquals(res, { "d", "c", "b", "a" })
	lu.assertTrue(s:empty())
	lu.assertEquals(#s, 0)
	lu.assertNil(s:top())
	lu.assertNil(s:pop())
end

function TestStack:testEmptyStackDrain_Yields_NoValues()
	local s = Stack.new()

	local count = 0

	for _ in s:drain() do
		count = count + 1
	end

	lu.assertEquals(count, 0)
	lu.assertTrue(s:empty())
end

function TestStack:testStacksWithSameValues_CompareEqual()
	local s1 = Stack.new({ 1, 2, 3 })
	local s2 = Stack.new({ 1, 2, 3 })
	local s3 = Stack.new({ 1, 2, 4 })
	local s4 = Stack.new({ 1, 2 })

	lu.assertTrue(s1 == s2)
	lu.assertFalse(s1 == s3)
	lu.assertFalse(s1 == s4)
	lu.assertFalse(s1 == {})
	lu.assertFalse(s1 == nil)
end

function TestStack:testConcat_AppendsValuesToStack()
	local s = Stack.new()
	local other = Stack.new({ 60, 50, 40 })

	s = s .. { 10, 20, 30 }
	s = s .. nil
	s = s .. other

	lu.assertEquals(#s, 6)

	lu.assertEquals(s:pop(), 60)
	lu.assertEquals(s:pop(), 50)
	lu.assertEquals(s:pop(), 40)
	lu.assertEquals(s:pop(), 30)
	lu.assertEquals(s:pop(), 20)
	lu.assertEquals(s:pop(), 10)
end

function TestStack:testNewPropertiesAndMethods_CannotBeAddedOrReplaced()
	local s = Stack.new({ 1, 2, 3 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		s.foo = "bar"
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		s[1] = 99
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		s.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		s.push = function() end
	end)
end

return { TestStack = TestStack }
