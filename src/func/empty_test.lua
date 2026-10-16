-- Imports
local lu = require("luaunit")
local empty = require("ff.func.empty")

-- Test helpers
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

-- Suite definitions
local TestEmptyString = {}
local TestEmptyArray = {}
local TestMap = {}
local TestDelegate = {}
local TestEmptyNoop = {}

-- Scenarios: string inputs
function TestEmptyString:testEmptyInputReturnsTrue()
	lu.assertTrue(empty(""))
end

function TestEmptyString:testNonEmptyInputReturnsFalse()
	lu.assertFalse(empty("a"))
	lu.assertFalse(empty(" "))
end

-- Scenarios: array inputs
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

-- Scenarios: map inputs
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

-- Scenarios: delegated emptiness
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

-- Scenarios: unsupported inputs
function TestEmptyNoop:testUnsupportedInputsReturnNil()
	lu.assertNil(empty(nil))
	lu.assertNil(empty(0))
	lu.assertNil(empty(true))
	lu.assertNil(empty(1.6))
end

-- Suite map
return {
	TestEmptyString = TestEmptyString,
	TestEmptyArray = TestEmptyArray,
	TestMap = TestMap,
	TestDelegate = TestDelegate,
	TestEmptyNoop = TestEmptyNoop,
}
