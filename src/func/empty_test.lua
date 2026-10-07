local lu = require("luaunit")
local empty = require("ff.func.empty")

-------------------------------
-- String Test Suite [begin] --
-------------------------------

TestEmptyString = {}

function TestEmptyString:testEmpty()
	lu.assertTrue(empty(""))
end

function TestEmptyString:testNonEmpty()
	lu.assertFalse(empty("a"))
	lu.assertFalse(empty(" "))
end

------------------------------
-- String Test Suite [end] ---
------------------------------

------------------------------
-- Array Test Suite [start] --
------------------------------

TestEmptyArray = {}

function TestEmptyArray:testEmpty()
	lu.assertTrue(empty({}))
	lu.assertTrue(empty({ nil }))
end

function TestEmptyArray:testNonEmpty()
	lu.assertFalse(empty({ 0 }))
	lu.assertFalse(empty({ false }))
	lu.assertFalse(empty({ "" }))
	lu.assertFalse(empty({ {} }))
	lu.assertFalse(empty({ 1, true, "s", { 1 } }))
end

----------------------------
-- Array Test Suite [end] --
----------------------------

----------------------------
-- Map Test Suite [begin] --
----------------------------

TestMap = {}

function TestMap:testEmpty()
	lu.assertTrue(empty({}))
	lu.assertTrue(empty({ ["a"] = nil }))
end

function TestMap:testNonEmpty()
	lu.assertFalse(empty({ a = 0 }))
	lu.assertFalse(empty({ [false] = true }))
	lu.assertFalse(empty({ [""] = "v" }))
	lu.assertFalse(empty({ ["l"] = {} }))
	lu.assertFalse(empty({ [1] = true, [10] = { 1 } }))
end

--------------------------
-- Map Test Suite [end] --
--------------------------

---------------------------------
-- Delegate Test Suite [begin] --
---------------------------------

local function delegate()
	local d = {}

	d.insert = function(value)
		d.value = value
	end

	d.remove = function()
		d.value = nil
	end

	d.empty = function()
		return not d.value
	end

	return d
end

TestDelegate = {}

function TestDelegate:testEmpty()
	local d = delegate()
	lu.assertTrue(empty(d))

	d.insert("something")
	d.remove()

	lu.assertTrue(empty(d))
end

function TestDelegate:testNonEmpty()
	local d = delegate()

	d.insert("something")
	lu.assertFalse(empty(d))
end

-------------------------------
-- Delegate Test Suite [end] --
-------------------------------

--------------------------------------
-- Non Supported Test Suite [begin] --
--------------------------------------

TestEmptyNoop = {}

function TestEmptyNoop:testNil()
	lu.assertNil(empty(nil))
	lu.assertNil(empty(0))
	lu.assertNil(empty(true))
	lu.assertNil(empty(1.6))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------
