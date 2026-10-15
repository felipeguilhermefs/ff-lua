local lu = require("luaunit")
local empty = require("ff.func.empty")

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

local TestEmptyString = {}
local TestEmptyArray = {}
local TestEmptyMap = {}
local TestEmptyDelegate = {}
local TestEmptyNoop = {}

function TestEmptyString:testEmptyInput_ReturnsTrue()
	lu.assertTrue(empty(""))
end

function TestEmptyString:testNonEmptyInput_ReturnsFalse()
	lu.assertFalse(empty("a"))
	lu.assertFalse(empty(" "))
end

function TestEmptyArray:testEmptyInput_ReturnsTrue()
	lu.assertTrue(empty({}))
	lu.assertTrue(empty({ nil }))
end

function TestEmptyArray:testNonEmptyInput_ReturnsFalse()
	lu.assertFalse(empty({ 0 }))
	lu.assertFalse(empty({ false }))
	lu.assertFalse(empty({ "" }))
	lu.assertFalse(empty({ {} }))
	lu.assertFalse(empty({ 1, true, "s", { 1 } }))
end

function TestEmptyMap:testEmptyInput_ReturnsTrue()
	lu.assertTrue(empty({}))
	lu.assertTrue(empty({ ["a"] = nil }))
end

function TestEmptyMap:testNonEmptyInput_ReturnsFalse()
	lu.assertFalse(empty({ a = 0 }))
	lu.assertFalse(empty({ [false] = true }))
	lu.assertFalse(empty({ [""] = "v" }))
	lu.assertFalse(empty({ ["l"] = {} }))
	lu.assertFalse(empty({ [1] = true, [10] = { 1 } }))
end

function TestEmptyDelegate:testEmptyInput_ReturnsTrue()
	local d = delegate()

	lu.assertTrue(empty(d))

	d.insert("something")
	d.remove()

	lu.assertTrue(empty(d))
end

function TestEmptyDelegate:testNonEmptyInput_ReturnsFalse()
	local d = delegate()

	d.insert("something")

	lu.assertFalse(empty(d))
end

function TestEmptyNoop:testUnsupportedInputs_ReturnNil()
	lu.assertNil(empty(nil))
	lu.assertNil(empty(0))
	lu.assertNil(empty(true))
	lu.assertNil(empty(1.6))
end

return {
	TestEmptyString = TestEmptyString,
	TestEmptyArray = TestEmptyArray,
	TestEmptyMap = TestEmptyMap,
	TestEmptyDelegate = TestEmptyDelegate,
	TestEmptyNoop = TestEmptyNoop,
}
