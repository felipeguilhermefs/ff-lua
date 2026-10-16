-- Example LuaUnit test file for ff-lua.
-- Copy structure and adapt behaviors when adding a src/<area>/<module>_test.lua.
-- See ../docs/test-guidelines.md for full conventions and migration steps.

-- Imports: keep dependencies local; import subject under test directly.
local lu = require("luaunit")
local Array = require("ff.collections.array")

-- Test helpers (optional): adapt public behavior into values LuaUnit can compare.
-- Avoid reading private fields from the subject.
local function arrayValues(array)
	local values = {}
	for index, value in pairs(array) do
		values[index] = value
	end
	return values
end

-- Suite definitions: use local tables; define all suites before test methods.
local TestArray = {}

-- Scenarios: construction behavior.
-- Test methods start with `test` and describe context, action, and outcome.
function TestArray:testNewArrayStartsEmpty()
	local array = Array.new()

	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

-- Scenarios: insertion behavior.
function TestArray:testInsertAppendsValueToArray()
	-- Given: array contains an existing value.
	local array = Array.new({ 10 })

	-- When: append another value.
	array:insert(20)

	-- Then: observable values and length reflect the insertion.
	lu.assertEquals(arrayValues(array), { 10, 20 })
	lu.assertEquals(#array, 2)
end

-- Scenarios: validation behavior.
function TestArray:testInsertRejectsNilValue()
	local array = Array.new()

	-- Error contract: wrap method invocation in a closure for LuaUnit.
	lu.assertErrorMsgContains("value should not be nil", function()
		array:insert(nil)
	end)
end

-- Suite map: return explicit name-to-class entries for test.lua to register.
return { TestArray = TestArray }
