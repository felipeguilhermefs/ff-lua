-----------------------------------------------------------------------------
-- 1. Upvalue caching & Imports
-----------------------------------------------------------------------------
local lu = require("luaunit")
local Stack = require("ff.collections.stack")

-----------------------------------------------------------------------------
-- 2. Test Suite Table Definition
-----------------------------------------------------------------------------
TestStack = {}

-----------------------------------------------------------------------------
-- 3. Suite Lifecycle Hooks (Optional)
-- Not needed: each test creates its own fixtures.
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- 4. Constructor & Type Guard Tests
-----------------------------------------------------------------------------

function TestStack:testIsStack()
	local s = Stack.new()
	lu.assertTrue(Stack.isStack(s))
	lu.assertFalse(Stack.isStack({}))
	lu.assertFalse(Stack.isStack(nil))
	lu.assertFalse(Stack.isStack("stack"))
	lu.assertFalse(Stack.isStack(123))
end

function TestStack:testConstructor()
	local s1 = Stack.new()
	lu.assertTrue(s1:empty())

	local s2 = Stack.new({ 10, 20, 30 })
	lu.assertEquals(#s2, 3)
	lu.assertEquals(s2:top(), 30)
end

-----------------------------------------------------------------------------
-- 5. Core Accessor & Inspection Tests
-----------------------------------------------------------------------------

function TestStack:testContains()
	-- empty
	local s = Stack.new()
	lu.assertFalse(s:contains(1))

	s:push(10)
	s:push(20)
	s:push(30)

	-- present
	lu.assertTrue(s:contains(10))
	lu.assertTrue(s:contains(20))
	lu.assertTrue(s:contains(30))

	-- absent
	lu.assertFalse(s:contains(99))
	lu.assertFalse(s:contains("10"))

	-- not present anymore
	s:pop()
	lu.assertFalse(s:contains(30))
end

-----------------------------------------------------------------------------
function TestStack:testIterator()
	local s = Stack.new()

	s:push("a")
	s:push("b")
	s:push("c")
	s:push("d")

	local keys = {}
	local res = {}
	for i, item in pairs(s) do
		table.insert(keys, i)
		table.insert(res, item)
	end

	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "d", "c", "b", "a" })
	lu.assertFalse(s:empty())
	lu.assertEquals(#s, 4)
	lu.assertEquals(s:top(), "d")
end

function TestStack:testIterator_Empty()
	local s = Stack.new()

	local count = 0
	for _ in pairs(s) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestStack:testIterator_MultipleRuns()
	local s = Stack.new({ "x", "y", "z" })

	local firstRun = {}
	for _, item in pairs(s) do
		table.insert(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(s) do
		table.insert(secondRun, item)
	end

	lu.assertEquals(firstRun, { "z", "y", "x" })
	lu.assertEquals(secondRun, { "z", "y", "x" })
	lu.assertEquals(#s, 3)
end

-- 6. Mutation & Modification Tests
-----------------------------------------------------------------------------

function TestStack:testEmptyAndClear()
	local s = Stack.new()
	lu.assertTrue(s:empty())
	lu.assertNil(s:pop())

	s:push("item")
	lu.assertFalse(s:empty())

	s:clear()
	lu.assertTrue(s:empty())
	lu.assertEquals(#s, 0)
end

function TestStack:testSingleItem()
	local s = Stack.new()
	s:push(1)

	lu.assertFalse(s:empty())
	lu.assertEquals(s:top(), 1)
	lu.assertEquals(s:pop(), 1)
	lu.assertTrue(s:empty())
end

function TestStack:testMultipleItems()
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

function TestStack:testNil()
	local s = Stack.new()
	lu.assertErrorMsgContains("entry should not be nil", function()
		s:push(nil)
	end)
end

function TestStack:testReverse()
	local s = Stack.new({ 1, 2, 3, 4 })

	s:reverse()

	lu.assertEquals(s:pop(), 1)
	lu.assertEquals(s:pop(), 2)
	lu.assertEquals(s:pop(), 3)
	lu.assertEquals(s:pop(), 4)
end

function TestStack:testDrain()
	local s = Stack.new()
	s:push("a")
	s:push("b")
	s:push("c")
	s:push("d")

	local res = {}
	for item in s:drain() do
		table.insert(res, item)
	end

	lu.assertEquals(res, { "d", "c", "b", "a" })
	lu.assertTrue(s:empty())
	lu.assertEquals(#s, 0)
	lu.assertNil(s:top())
	lu.assertNil(s:pop())
end

function TestStack:testDrain_Empty()
	local s = Stack.new()

	local count = 0
	for _ in s:drain() do
		count = count + 1
	end

	lu.assertEquals(count, 0)
	lu.assertTrue(s:empty())
end

-----------------------------------------------------------------------------
-- 7. Metamethod Tests (__len, __eq, __concat, __tostring, __newindex)
-----------------------------------------------------------------------------

function TestStack:testEquality()
	local s1 = Stack.new({ 1, 2, 3 })
	local s2 = Stack.new({ 1, 2, 3 })
	local s3 = Stack.new({ 1, 2, 4 })
	local s4 = Stack.new({ 1, 2 })

	-- Boolean assertions here intentionally exercise Stack.__eq.
	lu.assertTrue(s1 == s2)
	lu.assertFalse(s1 == s3)
	lu.assertFalse(s1 == s4)
	lu.assertFalse(s1 == {})
	lu.assertFalse(s1 == nil)
end

function TestStack:testConcat()
	local s = Stack.new() .. { 10, 20, 30 }
	lu.assertEquals(#s, 3)

	s = s .. nil
	lu.assertEquals(#s, 3)

	s = s .. Stack.new({ 60, 50, 40 })

	lu.assertEquals(#s, 6)

	lu.assertEquals(s:pop(), 60)
	lu.assertEquals(s:pop(), 50)
	lu.assertEquals(s:pop(), 40)
	lu.assertEquals(s:pop(), 30)
	lu.assertEquals(s:pop(), 20)
	lu.assertEquals(s:pop(), 10)
end

function TestStack:testNewIndex_PreventsModifications()
	local s = Stack.new({ 1, 2, 3 })

	-- disallow adding properties
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
