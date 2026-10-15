local lu = require("luaunit")
local empty = require("ff.func.empty")

-------------------------------
-- String Test Suite [begin] --
-------------------------------

local TestEmptyString = {}
function TestEmptyString:testEmptyInputReturnsTrue()
	lu.assertTrue(empty(""))
end

function TestEmptyString:testNonEmptyInputReturnsFalse()
	lu.assertFalse(empty("a"))
	lu.assertFalse(empty(" "))
end

------------------------------
-- String Test Suite [end] ---
------------------------------

------------------------------
-- Array Test Suite [start] --
------------------------------

local TestEmptyArray = {}
function TestEmptyArray:testEmptyInputReturnsTrue()
	lu.assertTrue(empty({}))
	lu.assertTrue(empty({ nil }))
end

function TestEmptyArray:testNonEmptyInputReturnsFalse()
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

local TestMap = {}
function TestMap:testEmptyInputReturnsTrue()
	lu.assertTrue(empty({}))
	lu.assertTrue(empty({ ["a"] = nil }))
end

function TestMap:testNonEmptyInputReturnsFalse()
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

local TestDelegate = {}
function TestDelegate:testEmptyInputReturnsTrue()
	local d = delegate()
	lu.assertTrue(empty(d))

	d.insert("something")
	d.remove()

	lu.assertTrue(empty(d))
end

function TestDelegate:testNonEmptyInputReturnsFalse()
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

local TestEmptyNoop = {}
function TestEmptyNoop:testUnsupportedInputsReturnNil()
	lu.assertNil(empty(nil))
	lu.assertNil(empty(0))
	lu.assertNil(empty(true))
	lu.assertNil(empty(1.6))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------

return {
	TestEmptyString = TestEmptyString,
	TestEmptyArray = TestEmptyArray,
	TestMap = TestMap,
	TestDelegate = TestDelegate,
	TestEmptyNoop = TestEmptyNoop,
}
