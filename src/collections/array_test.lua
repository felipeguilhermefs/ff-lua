-----------------------------------------------------------------------------
-- 1. Upvalue caching & Imports
-----------------------------------------------------------------------------
local lu = require("luaunit")
local Array = require("ff.collections.array")

-- LuaUnit's assertEquals compares tables structurally, not via Array.__eq;
-- plain-table snapshots give element-level diffs without exposing internals.
local function arrayValues(array)
	local values = {}
	for index, value in pairs(array) do
		values[index] = value
	end
	return values
end

-----------------------------------------------------------------------------
-- 2. Test Suite Table Definition
-----------------------------------------------------------------------------
TestArray = {}

-----------------------------------------------------------------------------
-- 3. Suite Lifecycle Hooks (Optional)
-- Not needed: each test creates its own fixtures.
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- 4. Constructor & Type Guard Tests
-----------------------------------------------------------------------------

function TestArray:testIsArray()
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

-----------------------------------------------------------------------------

function TestArray:testNewAndClear()
	local a = Array.new()
	lu.assertEquals(#a, 0)
	lu.assertTrue(a:empty())

	local b = Array.new({ 5, 6, 7 })
	lu.assertEquals(#b, 3)
	lu.assertFalse(b:empty())

	b:clear()
	lu.assertEquals(#b, 0)
	lu.assertTrue(b:empty())
	lu.assertErrorMsgContains("index out of bounds", function()
		b:get(1)
	end)
end

-- 5. Core Accessor & Inspection Tests
-----------------------------------------------------------------------------

function TestArray:testEmpty()
	local a = Array.new()
	lu.assertTrue(a:empty())

	a:insert("first")
	lu.assertFalse(a:empty())
end

function TestArray:testGet()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(a:get(1), 10)
	lu.assertEquals(a:get(2), 20)
	lu.assertEquals(a:get(3), 30)
end

function TestArray:testGet_Validation()
	local a = Array.new({ 10, 20, 30 })

	-- bounds validation
	lu.assertErrorMsgContains("index out of bounds", function()
		a:get(0)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		a:get(4)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		a:get(-1)
	end)

	-- numeric validation
	lu.assertErrorMsgContains("index should be a number", function()
		a:get("1")
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		a:get(nil)
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		a:get(true)
	end)
end

function TestArray:testSlice()
	local a = Array.new({ 10, 20, 30, 40, 50 })
	local s = a:slice(2, 4)
	lu.assertEquals(#s, 3)
	lu.assertEquals(s:get(1), 20)
	lu.assertEquals(s:get(2), 30)
	lu.assertEquals(s:get(3), 40)
end

function TestArray:testIndexOf()
	local a = Array.new({ 10, 20, 30, 20 })

	lu.assertEquals(a:indexOf(10), 1)
	lu.assertEquals(a:indexOf(30), 3)
	lu.assertEquals(a:indexOf(20), 2)

	lu.assertNil(a:indexOf(40))
end

function TestArray:testContains()
	local a = Array.new({ 10, 20, 30 })

	lu.assertTrue(a:contains(10))
	lu.assertTrue(a:contains(20))
	lu.assertTrue(a:contains(30))
	lu.assertFalse(a:contains(40))

	-- empty array contains nothing
	local empty = Array.new()
	lu.assertFalse(empty:contains(10))

	-- duplicate values
	local b = Array.new({ 5, 5, 5 })
	lu.assertTrue(b:contains(5))
	lu.assertFalse(b:contains(1))
end

function TestArray:testContains_Validation()
	local a = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("value should not be nil", function()
		a:contains(nil)
	end)
end

-----------------------------------------------------------------------------
function TestArray:testNoBracketAccess()
	local a = Array.new({ 10, 20, 30 })
	lu.assertNil(a[1])
	lu.assertNil(a[2])
	lu.assertNil(a[3])
end

function TestArray:testIterator()
	local a = Array.new({ 10, 20, 30 })

	local tpairs = {}
	for key, value in pairs(a) do
		table.insert(tpairs, key)
		table.insert(tpairs, value)
	end

	lu.assertEquals(tpairs, { 1, 10, 2, 20, 3, 30 })
end

-- 6. Mutation & Modification Tests
-----------------------------------------------------------------------------

function TestArray:testInsert()
	local a = Array.new()
	lu.assertEquals(#a, 0)

	-- insert at end without index
	a:insert(10)
	lu.assertEquals(#a, 1)
	lu.assertEquals(a:get(1), 10)

	a:insert(20)
	lu.assertEquals(#a, 2)
	lu.assertEquals(a:get(2), 20)

	-- insert with index
	a:insert(30, 1)
	lu.assertEquals(#a, 3)
	lu.assertEquals(a:get(1), 30)
	lu.assertEquals(a:get(2), 10)
	lu.assertEquals(a:get(3), 20)

	-- insert at index in middle
	a:insert(15, 3)
	lu.assertEquals(#a, 4)
	lu.assertEquals(a:get(1), 30)
	lu.assertEquals(a:get(2), 10)
	lu.assertEquals(a:get(3), 15)
	lu.assertEquals(a:get(4), 20)

	-- insert at index at end (#a + 1)
	a:insert(50, 5)
	lu.assertEquals(#a, 5)
	lu.assertEquals(a:get(5), 50)
end

function TestArray:testInsert_Validation()
	local a = Array.new({ 10, 20, 30 })

	-- value validation
	lu.assertErrorMsgContains("value should not be nil", function()
		a:insert(nil)
	end)

	-- bounds validation
	lu.assertErrorMsgContains("index out of bounds", function()
		a:insert(40, 0)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		a:insert(40, -1)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		a:insert(40, 5)
	end)

	-- numeric validation
	lu.assertErrorMsgContains("index should be a number", function()
		a:insert(40, "1")
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		a:insert(40, true)
	end)
end

function TestArray:testRemove()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(#a, 3)

	lu.assertEquals(a:remove(1), 10)
	lu.assertEquals(#a, 2)

	lu.assertEquals(a:get(1), 20)
	lu.assertEquals(a:get(2), 30)
end

function TestArray:testSwap()
	local a = Array.new({ 10, 20, 30 })

	a:swap(1, 2)
	lu.assertEquals(a:get(1), 20)
	lu.assertEquals(a:get(2), 10)

	a:swap(2, 3)
	lu.assertEquals(a:get(2), 30)
	lu.assertEquals(a:get(3), 10)

	lu.assertEquals(a:get(1), 20)
	lu.assertEquals(a:get(2), 30)
	lu.assertEquals(a:get(3), 10)
	lu.assertEquals(#a, 3)
end

-----------------------------------------------------------------------------
-- 7. Metamethod Tests (__len, __eq, __concat, __tostring, __newindex)
-----------------------------------------------------------------------------

function TestArray:testNewIndex_PreventsModifications()
	local a = Array.new({ 10, 20, 30 })

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		a.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		a[1] = 99
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		a[4] = 40
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		a.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		a.get = function() end
	end)
end

function TestArray:testEquals()
	local a1 = Array.new({ 10, 20, 30 })
	local a2 = Array.new({ 10, 20, 30 })
	local a3 = Array.new({ 10, 20, 40 })

	-- Compare plain values for LuaUnit's detailed diff. Boolean assertions below
	-- intentionally exercise Array.__eq, which assertEquals does not invoke.
	lu.assertEquals(arrayValues(a1), arrayValues(a2))
	lu.assertTrue(a1 == a2)
	lu.assertNotEquals(arrayValues(a1), arrayValues(a3))
	lu.assertFalse(a1 == a3)
	lu.assertEquals(arrayValues(a1), { 10, 20, 30 })
	lu.assertTrue(a1 == { 10, 20, 30 })
	lu.assertNotEquals(a1, "string")
end

function TestArray:testToString()
	local a = Array.new({ 1, 2, 3 })
	lu.assertEquals(tostring(a), "[ 1, 2, 3 ]")

	local emptyArr = Array.new()
	lu.assertEquals(tostring(emptyArr), "[  ]")
end

function TestArray:testConcat()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(#a, 3)

	a = a .. { 40, 50, 60 }

	lu.assertEquals(a:get(1), 10)
	lu.assertEquals(a:get(2), 20)
	lu.assertEquals(a:get(3), 30)
	lu.assertEquals(a:get(4), 40)
	lu.assertEquals(a:get(5), 50)
	lu.assertEquals(a:get(6), 60)
	lu.assertEquals(#a, 6)

	a = a .. nil
	lu.assertEquals(#a, 6)

	a = a .. Array.new({ 70, 80, 90 })
	lu.assertEquals(a:get(7), 70)
	lu.assertEquals(a:get(8), 80)
	lu.assertEquals(a:get(9), 90)
	lu.assertEquals(#a, 9)

	local set = require("ff.collections.set").new()
	set:add(100)
	a = a .. set

	lu.assertEquals(a:get(10), 100)
	lu.assertEquals(#a, 10)
end
