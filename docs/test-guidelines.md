# LuaUnit test guidelines

Keep LuaUnit as test framework. Use BDD conventions so each test states a
behavior and its expected observable result. Root [test.lua](../test.lua) remains
the runner; [scafolds/test.lua](../scafolds/test.lua) demonstrates a complete test
file with explanatory comments.

## Test file structure

Keep these sections in order. Omit `Test helpers` when file needs none.

1. `-- Imports`: LuaUnit and subject/dependencies, assigned to locals.
2. `-- Test helpers`: small local fixtures or snapshot helpers.
3. `-- Suite definitions`: local suite tables, declared before methods.
4. `-- Scenarios: <behavior area>`: related test methods grouped by behavior.
5. `-- Suite map`: explicit `{ TestName = TestClass }` return value.

A file may return multiple suites when distinct contexts improve readability.
Modules with no tests return `{}` under a `-- Suite map` heading. Do not use
global suite variables; the runner enables strict global checks.

## Naming and behavior

- Name suites `Test<Subject>` or `Test<Subject><Context>`.
- Name methods `test<Context>_<Action>_<ExpectedOutcome>` in camelCase. Example:
  `testEmptyStack_Pop_ReturnsNil`.
- Group methods under scenario headings such as construction, reads, state
  changes, iteration, validation, or metamethods.
- Give each method one behavior and its closely related assertions. Split
  unrelated outcomes into separate methods. Multiple inputs may share one
  method when they demonstrate the same contract.
- Test public behavior. Do not inspect private fields. Convert public iteration
  into plain-table snapshots when needed for structural assertions.
- Build fresh local fixtures for each test. Keep helpers small and specific;
  avoid shared mutable state or setup that hides the starting state.
- Use descriptive assertions. Check errors with `lu.assertErrorMsgContains`;
  wrap method calls in closures when needed.

## Given, When, Then and comments

Every `test...` method must contain these comment sections in order:

1. `-- Given:` marks inputs, fixtures, and initial state.
2. `-- When:` marks the public behavior being exercised.
3. `-- Then:` marks assertions for the return value, resulting state, or error.

Place each marker inside its test method, immediately before the code it labels.
Give each phase distinct, test-specific content: `Given` describes the input and
starting state, `When` names the operation performed, and `Then` states the
observable result or error. For tests that check separate behavior steps,
additional `-- When:` / `-- Then:` pairs may mark each step and its outcome.

Each test should read as one behavior specification. Keep names and assertions
focused on observable results; split scenarios with unrelated expected results.

## Adding test files

Copy [scafolds/test.lua](../scafolds/test.lua) to the source module's 
`<module>_test.lua` path and adapt imports, suite, scenarios, and assertions.

