-- Example LuaUnit test file for ff-lua.
-- Copy structure and adapt behaviors for src/<area>/<module>_test.lua.
-- See ../docs/test-guidelines.md for conventions.

-- Imports: keep dependencies local; import subject under test directly.
local lu = require("luaunit")
local Array = require("ff.collections.array")

-- Test helpers (optional): expose public behavior as values LuaUnit can compare.
-- Avoid reading private fields from the subject.
local function arrayValues(array)
	local values = {}
	for index, value in pairs(array) do
		values[index] = value
	end
	return values
end

-- Suite definitions: one class per method; declare classes alphabetically.
local TestArrayInsert = {}
local TestArrayNew = {}

-- Keep test methods alphabetical within each class. Separate methods with one
-- blank line. Method names use test followed by uppercase scenario name.
function TestArrayInsert:testAppendsValueToArray()
	local array = Array.new({ 10 })

	array:insert(20)

	lu.assertEquals(arrayValues(array), { 10, 20 })
	lu.assertEquals(#array, 2)
end

function TestArrayInsert:testRejectsNilValue()
	local array = Array.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		array:insert(nil)
	end)
end

function TestArrayNew:testStartsEmpty()
	local array = Array.new()

	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

-- Suite map: list class names alphabetically for test.lua to register.
return {
	TestArrayInsert = TestArrayInsert,
	TestArrayNew = TestArrayNew,
}
