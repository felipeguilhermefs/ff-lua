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
	-- Given: the string contains no characters.
	-- When: check whether the string contains characters.
	-- Then: empty returns true for the string.
	lu.assertTrue(empty(""))
end

function TestEmptyString:testNonEmptyInputReturnsFalse()
	-- Given: the strings contain a letter or a space.
	-- When: check both strings, including the single-space case.
	-- Then: empty returns false for both strings.
	lu.assertFalse(empty("a"))
	lu.assertFalse(empty(" "))
end

-- Scenarios: array inputs
function TestEmptyArray:testEmptyInputReturnsTrue()
	-- Given: the array has no indexed elements.
	-- When: check whether the array contains indexed elements.
	-- Then: empty returns true for the array.
	lu.assertTrue(empty({}))
	lu.assertTrue(empty({ nil }))
end

function TestEmptyArray:testNonEmptyInputReturnsFalse()
	-- Given: arrays contain falsey, empty, nested, and mixed values.
	-- When: check arrays with falsey, nested, and mixed values.
	-- Then: empty returns false for every populated array.
	lu.assertFalse(empty({ 0 }))
	lu.assertFalse(empty({ false }))
	lu.assertFalse(empty({ "" }))
	lu.assertFalse(empty({ {} }))
	lu.assertFalse(empty({ 1, true, "s", { 1 } }))
end

-- Scenarios: map inputs
function TestMap:testEmptyInputReturnsTrue()
	-- Given: the map has no key-value entries.
	-- When: check whether the map contains key-value entries.
	-- Then: empty returns true for the map.
	lu.assertTrue(empty({}))
	lu.assertTrue(empty({ ["a"] = nil }))
end

function TestMap:testNonEmptyInputReturnsFalse()
	-- Given: maps contain entries with falsey, empty, or nested values.
	-- When: check maps with falsey, nested, and mixed values.
	-- Then: empty returns false for every populated map.
	lu.assertFalse(empty({ a = 0 }))
	lu.assertFalse(empty({ [false] = true }))
	lu.assertFalse(empty({ [""] = "v" }))
	lu.assertFalse(empty({ ["l"] = {} }))
	lu.assertFalse(empty({ [1] = true, [10] = { 1 } }))
end

-- Scenarios: delegated emptiness
function TestDelegate:testEmptyInputReturnsTrue()
	-- Given: the delegate starts without a stored value.
	local d = delegate()

	-- When: query the delegate before and after inserting then removing a value.
	-- Then: empty returns true in both states.
	lu.assertTrue(empty(d))

	d.insert("something")
	d.remove()

	lu.assertTrue(empty(d))
end

function TestDelegate:testNonEmptyInputReturnsFalse()
	-- Given: the delegate starts empty before insert stores a value.
	local d = delegate()

	-- When: store a value through the delegate before checking emptiness.
	d.insert("something")

	-- Then: empty returns false while the delegate holds that value.
	lu.assertFalse(empty(d))
end

-- Scenarios: unsupported inputs
function TestEmptyNoop:testUnsupportedInputsReturnNil()
	-- Given: inputs include nil, numbers, and a boolean.
	-- When: evaluate each unsupported input.
	-- Then: every call returns nil.
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
