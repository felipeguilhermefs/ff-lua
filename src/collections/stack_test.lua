-- Imports
local lu = require("luaunit")
local Stack = require("ff.collections.stack")

-- Suite definitions
local TestStack = {}

-- Scenarios: construction and type recognition

function TestStack:testTypeGuardRecognizesStacksAndRejectsOtherValues()
	-- Given: candidates include one Stack, a table, and scalar values.
	local s = Stack.new()

	-- When: check each candidate with Stack.isStack.
	-- Then: only the Stack instance returns true.
	lu.assertTrue(Stack.isStack(s))
	lu.assertFalse(Stack.isStack({}))
	lu.assertFalse(Stack.isStack(nil))
	lu.assertFalse(Stack.isStack("stack"))
	lu.assertFalse(Stack.isStack(123))
end

function TestStack:testConstructorPreservesIterableOrderAndSetsTop()
	-- Given: one construction has no values; another receives { 10, 20, 30 }.
	-- When: create an empty Stack, then one from the iterable.
	local s1 = Stack.new()

	-- Then: the first Stack reports empty.
	lu.assertTrue(s1:empty())

	-- When: inspect the populated Stack's length and top.
	local s2 = Stack.new({ 10, 20, 30 })

	-- Then: length is 3 and top returns the last inserted value, 30.
	lu.assertEquals(#s2, 3)
	lu.assertEquals(s2:top(), 30)
end

-- Scenarios: reads and inspection

function TestStack:testEmptyStackDoesNotContainValues()
	-- Given: the Stack is empty and queried for membership of 1.
	local stack = Stack.new()

	-- When: check membership of 1.
	-- Then: contains returns false.
	lu.assertFalse(stack:contains(1))
end

function TestStack:testContainsReportsEachStoredValueAsPresent()
	-- Given: the Stack contains 10, 20, and 30.
	local stack = Stack.new({ 10, 20, 30 })

	-- When: check membership of each stored integer.
	-- Then: contains returns true for all three.
	lu.assertTrue(stack:contains(10))
	lu.assertTrue(stack:contains(20))
	lu.assertTrue(stack:contains(30))
end

function TestStack:testContainsReportsUnstoredValuesAsAbsent()
	-- Given: the Stack contains numeric values 10, 20, and 30.
	local stack = Stack.new({ 10, 20, 30 })

	-- When: check for absent number 99 and string "10".
	-- Then: contains returns false for both.
	lu.assertFalse(stack:contains(99))
	lu.assertFalse(stack:contains("10"))
end

function TestStack:testPoppedValueIsNoLongerContained()
	-- Given: the Stack contains 10, 20, and 30, with 30 on top.
	local stack = Stack.new({ 10, 20, 30 })

	-- When: pop the top value.
	stack:pop()

	-- Then: contains returns false for removed value 30.
	lu.assertFalse(stack:contains(30))
end

function TestStack:testIterationYieldsValuesFromTopToBottom()
	-- Given: the Stack is populated with a, b, c, and d; d is on top.
	local s = Stack.new()

	s:push("a")
	s:push("b")
	s:push("c")
	s:push("d")

	-- When: collect keys and values yielded by pairs.
	local keys = {}
	local res = {}
	for i, item in pairs(s) do
		table.insert(keys, i)
		table.insert(res, item)
	end

	-- Then: indexes start at 1, values run d-to-a, and top remains d.
	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "d", "c", "b", "a" })
	lu.assertFalse(s:empty())
	lu.assertEquals(#s, 4)
	lu.assertEquals(s:top(), "d")
end

function TestStack:testIterationOfEmptyStackYieldsNoValues()
	-- Given: the Stack contains no entries to traverse.
	local s = Stack.new()

	local count = 0

	-- When: count entries yielded by pairs.
	for _ in pairs(s) do
		count = count + 1
	end

	-- Then: the iterator yields zero entries.
	lu.assertEquals(count, 0)
end

function TestStack:testRepeatedIterationPreservesStackContents()
	-- Given: the Stack contains x, y, and z, with z on top.
	local s = Stack.new({ "x", "y", "z" })

	local firstRun = {}

	-- When: collect values in two separate pairs traversals.
	for _, item in pairs(s) do
		table.insert(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(s) do
		table.insert(secondRun, item)
	end

	-- Then: both traversals return z, y, x and length stays 3.
	lu.assertEquals(firstRun, { "z", "y", "x" })
	lu.assertEquals(secondRun, { "z", "y", "x" })
	lu.assertEquals(#s, 3)
end

-- Scenarios: state changes

function TestStack:testPopOnEmptyStackReturnsNil()
	-- Given: pop is called on a Stack that contains no entries.
	local stack = Stack.new()

	-- When: confirm empty state and call pop.
	-- Then: pop returns nil and Stack remains empty.
	lu.assertTrue(stack:empty())
	lu.assertNil(stack:pop())
end

function TestStack:testClearRemovesAllPushedValues()
	-- Given: the Stack contains one item.
	local stack = Stack.new({ "item" })

	-- When: call clear.
	stack:clear()

	-- Then: Stack reports empty and length zero.
	lu.assertTrue(stack:empty())
	lu.assertEquals(#stack, 0)
end

function TestStack:testPushAndPopPreserveSingleValue()
	-- Given: the Stack is empty before pushing 1.
	local s = Stack.new()

	-- When: push 1, inspect the top, and pop it.
	s:push(1)

	-- Then: 1 becomes the top and pop returns it, restoring empty state.
	lu.assertFalse(s:empty())
	lu.assertEquals(s:top(), 1)
	lu.assertEquals(s:pop(), 1)
	lu.assertTrue(s:empty())
end

function TestStack:testPopReturnsPushedValuesInLastInFirstOutOrder()
	-- Given: the Stack is empty and will receive four different value types.
	local s = Stack.new()

	-- When: push the values, then pop until empty.
	s:push(1)
	s:push(true)
	s:push("abc")
	s:push({ 4, 5, 6 })

	-- Then: values return in reverse push order and Stack becomes empty.
	lu.assertFalse(s:empty())
	lu.assertEquals(s:pop(), { 4, 5, 6 })
	lu.assertEquals(s:pop(), "abc")
	lu.assertTrue(s:pop())
	lu.assertEquals(s:top(), 1)
	lu.assertEquals(s:pop(), 1)
	lu.assertTrue(s:empty())
end

function TestStack:testPushRejectsNilEntries()
	-- Given: the Stack is empty before a nil push attempt.
	local s = Stack.new()

	-- When: push nil.
	-- Then: push reports that entries cannot be nil.
	lu.assertErrorMsgContains("entry should not be nil", function()
		s:push(nil)
	end)
end

function TestStack:testReverseMakesBottomValuePopFirst()
	-- Given: the Stack contains 1, 2, 3, and 4, with 4 on top.
	local s = Stack.new({ 1, 2, 3, 4 })

	-- When: reverse the Stack and pop all four values.
	s:reverse()

	-- Then: values pop in original insertion order, 1 through 4.
	lu.assertEquals(s:pop(), 1)
	lu.assertEquals(s:pop(), 2)
	lu.assertEquals(s:pop(), 3)
	lu.assertEquals(s:pop(), 4)
end

function TestStack:testDrainYieldsValuesInLastInFirstOutOrderAndEmptiesStack()
	-- Given: the Stack is populated with a, b, c, and d for destructive draining.
	local s = Stack.new()

	s:push("a")
	s:push("b")
	s:push("c")
	s:push("d")

	-- When: collect values yielded by drain.
	local res = {}
	for item in s:drain() do
		table.insert(res, item)
	end

	-- Then: values return d-to-a and Stack has no remaining entries.
	lu.assertEquals(res, { "d", "c", "b", "a" })
	lu.assertTrue(s:empty())
	lu.assertEquals(#s, 0)
	lu.assertNil(s:top())
	lu.assertNil(s:pop())
end

function TestStack:testDrainOnEmptyStackYieldsNoValues()
	-- Given: the Stack is empty and drain is the iterator under test.
	local s = Stack.new()

	local count = 0

	-- When: count values from drain.
	for _ in s:drain() do
		count = count + 1
	end

	-- Then: no values are yielded and Stack stays empty.
	lu.assertEquals(count, 0)
	lu.assertTrue(s:empty())
end

-- Scenarios: metamethods and formatting

function TestStack:testStacksWithSameValuesCompareEqual()
	-- Given: Stacks match, differ at one value, or have different lengths.
	local s1 = Stack.new({ 1, 2, 3 })
	local s2 = Stack.new({ 1, 2, 3 })
	local s3 = Stack.new({ 1, 2, 4 })
	local s4 = Stack.new({ 1, 2 })

	-- Boolean assertions here intentionally exercise Stack.__eq.

	-- When: compare each Stack against s1, including a plain table.
	-- Then: only matching Stack contents compare equal.
	lu.assertTrue(s1 == s2)
	lu.assertFalse(s1 == s3)
	lu.assertFalse(s1 == s4)
	lu.assertFalse(s1 == {})
	lu.assertFalse(s1 == nil)
end

function TestStack:testConcatAppendsValuesToStack()
	-- Given: an empty Stack and another Stack containing 60, 50, and 40.
	local s = Stack.new()
	local other = Stack.new({ 60, 50, 40 })

	-- When: concatenate { 10, 20, 30 }, nil, and the other Stack.
	s = s .. { 10, 20, 30 }
	s = s .. nil
	s = s .. other

	-- Then: pop returns values in LIFO order across both inputs.
	lu.assertEquals(#s, 6)

	lu.assertEquals(s:pop(), 60)
	lu.assertEquals(s:pop(), 50)
	lu.assertEquals(s:pop(), 40)
	lu.assertEquals(s:pop(), 30)
	lu.assertEquals(s:pop(), 20)
	lu.assertEquals(s:pop(), 10)
end

function TestStack:testNewPropertiesAndMethodsCannotBeAddedOrReplaced()
	-- Given: a Stack contains 1, 2, and 3 and defines push.
	local s = Stack.new({ 1, 2, 3 })

	-- disallow adding properties

	-- When: assign a property, numeric key, function, and replacement push method.
	-- Then: every assignment raises the property-protection error.
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		s.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		s[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		s.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Stack", function()
		s.push = function() end
	end)
end

-- Suite map
return { TestStack = TestStack }
