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
- Name methods `test<Context><Action><ExpectedOutcome>` in camelCase. Example:
  `testEmptyStackPopReturnsNil`.
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

Arrange each test in this order:

1. **Given**: create the subject and establish its starting state.
2. **When**: call the public operation being specified.
3. **Then**: assert its return value, resulting state, or documented error.

Separate setup, action, and assertions with blank lines. Add `-- Given:`,
`-- When:`, and `-- Then:` comments when they clarify a non-obvious step or a
sequence of operations. Omit comments that merely narrate obvious code. Comments
should explain intent or a subtle contract and sit next to the relevant step.

Each test should read as one behavior specification. Keep names and assertions
focused on observable results; split scenarios with unrelated expected results.

## Adding or migrating test files

1. Copy [scafolds/test.lua](../scafolds/test.lua) to the source module's
   `<module>_test.lua` path and adapt imports, suite, scenarios, and assertions.
2. Preserve existing coverage when migrating. Correct misleading names, declare
   suites before their methods, add scenario headings, and replace decorative
   separators with the standard section comments.
3. Return suites explicitly as `{ TestName = TestClass }`; return `{}` when a
   module has no tests.
4. Run focused and full suites:

   ```sh
   make test MODULE=ff.collections.array
   make test
   ```
