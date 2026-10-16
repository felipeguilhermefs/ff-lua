-- Copy this file to src/<area>/<module>_test.lua.
-- Replace every placeholder before running the suite.
--
-- BDD style for LuaUnit
-- ======================
-- Keep LuaUnit; root test.lua remains the runner. Write each test as a behavior
-- specification using Given, When, Then order: establish local starting state,
-- call public behavior, assert result/state/error. Blank lines separate obvious
-- steps. Add step comments only when a step is non-obvious or spans several
-- operations; comments explain intent or subtle contracts, not obvious code.
--
-- File structure (in this order):
--   1. Imports: LuaUnit and subject/dependencies, all local.
--   2. Test helpers (optional): small local fixture/snapshot helpers.
--   3. Suite definitions: local Test<Subject> tables before their methods.
--   4. Scenarios: group methods under -- Scenarios: <behavior area> headings.
--   5. Suite map: explicitly return { TestName = TestClass }.
-- Modules with no tests return {} under a Suite map heading.
--
-- Naming and scenario rules:
--   * Name suites Test<Subject> or Test<Subject><Context>.
--   * Name methods test<Context><Action><ExpectedOutcome> in camelCase.
--     Example: testEmptyStackPopReturnsNil.
--   * A file may return multiple suites when separate contexts help readers.
--   * Give each method one behavior and closely related assertions. Split
--     unrelated outcomes; group input variants only when they share a contract.
--   * Test public behavior. Do not inspect private fields. Snapshot public
--     iteration into plain tables when LuaUnit needs structural comparison.
--   * Build fresh local fixtures per test. Keep helpers small and specific;
--     avoid shared mutable state or setup that hides scenario state.
--   * Use descriptive assertions. For error contracts, use
--     lu.assertErrorMsgContains, with a closure when invoking a method.
--   * Avoid comments that merely restate the next line, such as -- assert result.
--
-- Adding a test module:
--   1. Copy this file to src/<area>/<module>_test.lua.
--   2. Replace placeholder imports, suite name, scenario heading, and failing
--      placeholder method. Add focused local helpers only when useful.
--   3. Preserve one behavior per method and arrange it Given / When / Then.
--   4. Return every suite in the explicit suite map; return {} for no tests.
--   5. Run make test MODULE=<module>, then make test.
--
-- Migrating existing tests: preserve coverage; correct misleading names;
-- declare suites before methods; add scenario headings; replace decorative
-- separators with these section comments. See src/collections/array_test.lua
-- for an existing example that snapshots public iteration for assertions.
--
-- Example: snapshot public iteration, then compare externally visible values.
--
-- local function arrayValues(array)
--     local values = {}
--     for index, value in pairs(array) do
--         values[index] = value
--     end
--     return values
-- end
--
-- function TestArray:testInsertAppendsValueToArray()
--     local array = Array.new({ 10 }) -- Given
--
--     array:insert(20) -- When
--
--     lu.assertEquals(arrayValues(array), { 10, 20 }) -- Then
-- end
--
-- For a longer scenario, explain meaningful steps without narrating each line:
--
-- function TestArray:testClearRemovesValuesAndAllowsReuse()
--     local array = Array.new({ 10, 20 })
--
--     -- When: clear a populated array, then reuse it.
--     array:clear()
--     array:insert(30)
--
--     -- Then: only the new value remains.
--     lu.assertEquals(arrayValues(array), { 30 })
-- end

-- Imports
local lu = require("luaunit")
-- local Subject = require("ff.<area>.<module>")

-- Test helpers (optional)
-- Add small local fixture or snapshot helpers here.

-- Suite definitions
local TestSubject = {}

-- Scenarios: replace with a behavior area
function TestSubject:testReplaceWithBehaviorScenario()
	-- Given: create subject and establish starting state.
	-- local subject = Subject.new(...)

	-- When: invoke one public behavior.
	-- local actual = subject:method(...)

	-- Then: assert observable result or documented error.
	-- lu.assertEquals(actual, expected)

	error("Replace scaffold placeholder with a real test scenario")
end

-- Suite map
return { TestSubject = TestSubject }
