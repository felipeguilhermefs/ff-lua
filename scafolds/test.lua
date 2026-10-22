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
function TestArray:testNewArray_Starts_Empty()
	-- Given: construction has no initial values.
	-- When: create an empty Array.
	local array = Array.new()

	-- Then: it reports empty and has length zero.
	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

-- Scenarios: insertion behavior.
function TestArray:testInsert_Appends_ValueToArray()
	-- Given: array contains an existing value.
	local array = Array.new({ 10 })

	-- When: append another value.
	array:insert(20)

	-- Then: observable values and length reflect the insertion.
	lu.assertEquals(arrayValues(array), { 10, 20 })
	lu.assertEquals(#array, 2)
end

-- Scenarios: validation behavior.
function TestArray:testInsert_Rejects_NilValue()
	-- Given: an empty Array.
	local array = Array.new()

	-- When: attempt to insert nil.
	-- Then: the public API reports its validation error.
	lu.assertErrorMsgContains("value should not be nil", function()
		array:insert(nil)
	end)
end

-- Suite map: return explicit name-to-class entries for test.lua to register.
return { TestArray = TestArray }
