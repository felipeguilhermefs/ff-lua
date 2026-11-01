# LuaUnit test guidelines

Keep LuaUnit as test framework. Write tests as behavior specifications with observable results. Root [test.lua](../test.lua) remains the runner; [scafolds/test.lua](../scafolds/test.lua) demonstrates suite and naming structure.

## Test file structure

Keep sections in this order. Omit `Test helpers` when file needs none.

1. `-- Imports`: LuaUnit and subject/dependencies, assigned to locals.
2. `-- Test helpers`: small local fixtures or snapshot helpers.
3. `-- Suite definitions`: local test class tables, all declared before tests.
4. Test methods grouped by class, with classes and methods in alphabetical order. Do not add section comments between test classes.
5. `-- Suite map`: explicit `{ TestName = TestClass }` return value, also in alphabetical order.

A file may return multiple test classes. Modules with no tests return `{}` under a `-- Suite map` heading. Do not use global suite variables; the runner enables strict global checks.

## Naming and ordering

- Use one class per public method or metamethod when a subject has multiple methods. Name it `Test<Subject><Method>`, such as `TestArrayInsert` or `TestArraySwap`.
- Name each test method `test<Scenario>` with the scenario starting uppercase. Example: `function TestArraySwap:testSameIndexLeavesArrayUnchanged()`.
- Keep class declarations, test class groups, methods within each class, and suite map entries in alphabetical order.
- Separate adjacent test methods with exactly one blank line. Avoid redundant section comments; class and method names identify each group.

## Test behavior

- Give each method one behavior and closely related assertions. Split unrelated outcomes into separate tests. Combine inputs when they demonstrate the same contract.
- Test public behavior. Do not inspect private fields. Convert public iteration into plain-table snapshots when needed for structural assertions.
- Build fresh local fixtures for each test. Keep helpers small and specific; avoid shared mutable state or setup that hides the starting state.
- Cover expected behavior, boundary values, invalid inputs, and failure behavior for each method. Do not test implementation details.
- Use descriptive assertions. Check errors with `lu.assertErrorMsgContains`; wrap method calls in closures when needed.

## Adding test files

Copy [scafolds/test.lua](../scafolds/test.lua) to the source module's `<module>_test.lua` path and adapt imports, test classes, scenarios, and suite map.
