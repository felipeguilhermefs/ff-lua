local lu = require("luaunit")
local Stack = require("stack")

function TestEmpty()
	local s = Stack.new()
	lu.assertTrue(s:empty())
	lu.assertNil(s:pop())
end

function TestSingleItem()
	local s = Stack.new()
	s:push(1)

	lu.assertFalse(s:empty())
	lu.assertEquals(s:pop(), 1)
	lu.assertTrue(s:empty())
end

function TestMultipleItems()
	local s = Stack.new()
	s:push(1)
	s:push(true)
	s:push("abc")
	s:push({ 4, 5, 6 })

	lu.assertFalse(s:empty())
	lu.assertEquals(s:pop(), { 4, 5, 6 })
	lu.assertEquals(s:pop(), "abc")
	lu.assertEquals(s:pop(), true)
	lu.assertEquals(s:top(), 1)
	lu.assertEquals(s:pop(), 1)
	lu.assertTrue(s:empty())
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

	local h = require("heap").new()
	h:push(40)
	h:push(50)
	h:push(60)

	h = s .. h

	lu.assertEquals(60, s:pop())
	lu.assertEquals(50, s:pop())
	lu.assertEquals(40, s:pop())
	lu.assertEquals(30, s:pop())
	lu.assertEquals(20, s:pop())
	lu.assertEquals(10, s:pop())
end

os.exit(lu.LuaUnit.run())
