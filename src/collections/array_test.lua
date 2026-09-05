local lu = require("luaunit")
local Array = require("array")

function TestNewAndClear()
	local a = Array.new()
	lu.assertEquals(0, #a)
	lu.assertTrue(a:empty())

	local b = Array.new({ 5, 6, 7 })
	lu.assertEquals(3, #b)
	lu.assertFalse(b:empty())

	b:clear()
	lu.assertEquals(0, #b)
	lu.assertTrue(b:empty())
	lu.assertError(function()
		b:get(1)
	end)
end

function TestEmpty()
	local a = Array.new()
	lu.assertTrue(a:empty())

	a:insert("first")
	lu.assertFalse(a:empty())
end

function TestGet()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(10, a:get(1))
	lu.assertEquals(20, a:get(2))
	lu.assertEquals(30, a:get(3))
end

function TestGetValidation()
	local a = Array.new({ 10, 20, 30 })

	-- bounds validation
	lu.assertError(function()
		a:get(0)
	end)
	lu.assertError(function()
		a:get(4)
	end)
	lu.assertError(function()
		a:get(-1)
	end)

	-- numeric validation
	lu.assertError(function()
		a:get("1")
	end)
	lu.assertError(function()
		a:get(nil)
	end)
	lu.assertError(function()
		a:get(true)
	end)
end

function TestNoBracketAccess()
	local a = Array.new({ 10, 20, 30 })
	lu.assertNil(a[1])
	lu.assertNil(a[2])
	lu.assertNil(a[3])
end

function TestNewIndexPreventsModifications()
	local a = Array.new({ 10, 20, 30 })

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions", function()
		a.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions", function()
		a[1] = 99
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions", function()
		a[4] = 40
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions", function()
		a.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions", function()
		a.get = function() end
	end)
end


function TestEquals()
	local a1 = Array.new({ 10, 20, 30 })
	local a2 = Array.new({ 10, 20, 30 })
	local a3 = Array.new({ 10, 20, 40 })

	lu.assertTrue(a1 == a2)
	lu.assertFalse(a1 == a3)
	lu.assertTrue(a1 == { 10, 20, 30 })
	lu.assertFalse(a1 == "string")
end

function TestSlice()
	local a = Array.new({ 10, 20, 30, 40, 50 })
	local s = a:slice(2, 4)
	lu.assertEquals(3, #s)
	lu.assertEquals(20, s:get(1))
	lu.assertEquals(30, s:get(2))
	lu.assertEquals(40, s:get(3))
end

function TestToString()
	local a = Array.new({ 1, 2, 3 })
	lu.assertEquals("[ 1, 2, 3 ]", tostring(a))

	local emptyArr = Array.new()
	lu.assertEquals("[  ]", tostring(emptyArr))
end

function TestInsert()
	local a = Array.new()
	lu.assertEquals(0, #a)

	-- insert at end without index
	a:insert(10)
	lu.assertEquals(1, #a)
	lu.assertEquals(10, a:get(1))

	a:insert(20)
	lu.assertEquals(2, #a)
	lu.assertEquals(20, a:get(2))

	-- insert with index
	a:insert(30, 1)
	lu.assertEquals(3, #a)
	lu.assertEquals(30, a:get(1))
	lu.assertEquals(10, a:get(2))
	lu.assertEquals(20, a:get(3))

	-- insert at index in middle
	a:insert(15, 3)
	lu.assertEquals(4, #a)
	lu.assertEquals(30, a:get(1))
	lu.assertEquals(10, a:get(2))
	lu.assertEquals(15, a:get(3))
	lu.assertEquals(20, a:get(4))

	-- insert at index at end (#a + 1)
	a:insert(50, 5)
	lu.assertEquals(5, #a)
	lu.assertEquals(50, a:get(5))
end

function TestInsertValidation()
	local a = Array.new({ 10, 20, 30 })

	-- value validation
	lu.assertError(function()
		a:insert(nil)
	end)

	-- bounds validation
	lu.assertError(function()
		a:insert(40, 0)
	end)
	lu.assertError(function()
		a:insert(40, -1)
	end)
	lu.assertError(function()
		a:insert(40, 5)
	end)

	-- numeric validation
	lu.assertError(function()
		a:insert(40, "1")
	end)
	lu.assertError(function()
		a:insert(40, true)
	end)
end

function TestRemove()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(3, #a)

	lu.assertEquals(10, a:remove(1))
	lu.assertEquals(2, #a)

	lu.assertEquals(20, a:get(1))
	lu.assertEquals(30, a:get(2))
end

function TestSwap()
	local a = Array.new({ 10, 20, 30 })

	a:swap(1, 2)
	lu.assertEquals(20, a:get(1))
	lu.assertEquals(10, a:get(2))

	a:swap(2, 3)
	lu.assertEquals(30, a:get(2))
	lu.assertEquals(10, a:get(3))

	lu.assertEquals(20, a:get(1))
	lu.assertEquals(30, a:get(2))
	lu.assertEquals(10, a:get(3))
	lu.assertEquals(3, #a)
end

function TestIsArray()
	lu.assertFalse(Array.isArray(nil))
	lu.assertFalse(Array.isArray(true))
	lu.assertFalse(Array.isArray(123))
	lu.assertFalse(Array.isArray("abc"))
	lu.assertFalse(Array.isArray({ a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ 1, 2, 3, a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ [1] = "a", foo = "bar" }))

	lu.assertTrue(Array.isArray({}))
	lu.assertTrue(Array.isArray({ 1, 2, 3 }))
	lu.assertTrue(Array.isArray(Array.new()))
	lu.assertTrue(Array.isArray(Array.new({ 4, 5, 6 })))
end

function TestIndexOf()
	local a = Array.new({ 10, 20, 30, 20 })

	lu.assertEquals(1, a:indexOf(10))
	lu.assertEquals(3, a:indexOf(30))
	lu.assertEquals(2, a:indexOf(20))

	lu.assertNil(a:indexOf(40))
end

function TestConcat()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(3, #a)

	a = a .. { 40, 50, 60 }

	lu.assertEquals(10, a:get(1))
	lu.assertEquals(20, a:get(2))
	lu.assertEquals(30, a:get(3))
	lu.assertEquals(40, a:get(4))
	lu.assertEquals(50, a:get(5))
	lu.assertEquals(60, a:get(6))
	lu.assertEquals(6, #a)

	a = a .. nil
	lu.assertEquals(6, #a)

	a = a .. Array.new({ 70, 80, 90 })
	lu.assertEquals(70, a:get(7))
	lu.assertEquals(80, a:get(8))
	lu.assertEquals(90, a:get(9))
	lu.assertEquals(9, #a)

	local set = require("set").new()
	set:add(100)
	a = a .. set

	lu.assertEquals(100, a:get(10))
	lu.assertEquals(10, #a)
end

function TestIterator()
	local a = Array.new({ 10, 20, 30 })

	local tpairs = {}
	for key, value in pairs(a) do
		table.insert(tpairs, key)
		table.insert(tpairs, value)
	end

	lu.assertEquals({ 1, 10, 2, 20, 3, 30 }, tpairs)
end

os.exit(lu.LuaUnit.run())
