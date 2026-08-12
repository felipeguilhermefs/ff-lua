local lu = require("luaunit")
local Stack = require("stack")

function TestIsStack()
	local s = Stack.new()
	lu.assertTrue(Stack.isStack(s))
	lu.assertFalse(Stack.isStack({}))
	lu.assertFalse(Stack.isStack(nil))
	lu.assertFalse(Stack.isStack("stack"))
	lu.assertFalse(Stack.isStack(123))
end

function TestConstructor()
	local s1 = Stack.new()
	lu.assertTrue(s1:empty())

	local s2 = Stack.new({ 10, 20, 30 })
	lu.assertEquals(3, #s2)
	lu.assertEquals(30, s2:top())
end

function TestContains()
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

function TestEmptyAndClear()
	local s = Stack.new()
	lu.assertTrue(s:empty())
	lu.assertNil(s:pop())

	s:push("item")
	lu.assertFalse(s:empty())

	s:clear()
	lu.assertTrue(s:empty())
	lu.assertEquals(0, #s)
end

function TestSingleItem()
	local s = Stack.new()
	s:push(1)

	lu.assertFalse(s:empty())
	lu.assertEquals(1, s:top())
	lu.assertEquals(1, s:pop())
	lu.assertTrue(s:empty())
end

function TestMultipleItems()
	local s = Stack.new()
	s:push(1)
	s:push(true)
	s:push("abc")
	s:push({ 4, 5, 6 })

	lu.assertFalse(s:empty())
	lu.assertEquals({ 4, 5, 6 }, s:pop())
	lu.assertEquals("abc", s:pop())
	lu.assertEquals(true, s:pop())
	lu.assertEquals(1, s:top())
	lu.assertEquals(1, s:pop())
	lu.assertTrue(s:empty())
end

function TestNil()
	local s = Stack.new()
	lu.assertErrorMsgContains("entry should not be nil", function()
		s:push(nil)
	end)
end

function TestReverse()
	local s = Stack.new({ 1, 2, 3, 4 })

	s:reverse()

	lu.assertEquals(1, s:pop())
	lu.assertEquals(2, s:pop())
	lu.assertEquals(3, s:pop())
	lu.assertEquals(4, s:pop())
end

function TestEquality()
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

function TestIterator()
	local s = Stack.new()

	s:push("a")
	s:push("b")
	s:push("c")
	s:push("d")

	local res = {}
	for _, item in pairs(s) do
		table.insert(res, item)
	end

	lu.assertEquals({ "d", "c", "b", "a" }, res)
	lu.assertTrue(s:empty())
end

function TestConcat()
	local s = Stack.new() .. { 10, 20, 30 }
	lu.assertEquals(3, #s)

	s = s .. nil
	lu.assertEquals(3, #s)

	s = s .. Stack.new({ 60, 50, 40 })

	lu.assertEquals(6, #s)

	lu.assertEquals(60, s:pop())
	lu.assertEquals(50, s:pop())
	lu.assertEquals(40, s:pop())
	lu.assertEquals(30, s:pop())
	lu.assertEquals(20, s:pop())
	lu.assertEquals(10, s:pop())
end

os.exit(lu.LuaUnit.run())
