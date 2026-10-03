## 1. Executive Summary & Audit Findings

The `ff-lua` repository currently defines **26 test files** covering data structures, functional utilities, iterators, math functions, and sorting/searching algorithms.

A deep investigation into the test runner ([`test.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/test.lua)), test files, and package specifications revealed several critical flaws:

| Category | Observed Symptom | Underlying Cause | Impact |
| :--- | :--- | :--- | :--- |
| **Namespace Isolation** | 324 test functions defined in source, but only 184 tests reported by runner | Global function declarations (`function TestX()`) overwrite each other in `_G` | **140 tests (>43%) are silently lost** and never executed in the suite |
| **Test Execution** | Output contains 27 repeated `Ran X tests... OK` summaries | Each test file calls `os.exit(lu.LuaUnit.run())`; `dofile()` triggers LuaUnit on every file | **Cascading execution** (~3,000 redundant function calls) |
| **Assertion Style** | Failure messages report `expected: <actual>, actual: <expected>` | Tests use `assertEquals(expected, actual)` while LuaUnit default is `(actual, expected)` | Inverted error diagnostics hinder debugging |
| **Coverage Gaps** | [`src/aoc/matrix.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/aoc/matrix.lua) and [`src/graph/graph.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/graph/graph.lua) have no tests | Omitted from test authoring and runner list | Zero test coverage for complex structures |

---

## 2. Deep-Dive: Critical Issues in Current Test Code

### 2.1 Global Collision & Test Clobbering (The 140-Test Loss)

In the current test codebase, test cases are declared as global functions in the global environment `_G`:

```lua
-- src/collections/array_test.lua
function TestEmpty() ... end
function TestContains() ... end
function TestConcat() ... end
function TestToString() ... end
function TestNewIndexPreventsModifications() ... end

-- src/collections/hashmap_test.lua
function TestEmpty() ... end    -- Clobbers array_test's TestEmpty!
function TestContains() ... end -- Clobbers array_test's TestContains!

-- src/collections/heap_test.lua
function TestConstructorEmpty() ... end
function TestNewIndexPreventsModifications() ... end -- Clobbers previous!
```

#### Collision Frequency Across `src/collections/`:
- `TestNewIndexPreventsModifications`: Defined identically in **10 files**.
- `TestConcat`: Defined identically in **10 files**.
- `TestToString`: Defined identically in **9 files**.
- `TestContains`: Defined identically in **9 files**.
- `TestIterator`: Defined identically in **7 files**.
- `TestEquality` / `TestEquals`: Defined identically in **10 files**.
- `TestEmptyAndClear` / `TestEmpty`: Defined identically in **10 files**.
- `TestRemove`: Defined identically in **5 files**.
- `TestConstructorEmpty`: Defined identically in **5 files**.
- `TestConstructorWithIterable`: Defined identically in **5 files**.

#### Cross-Directory Type Collision:
- [`src/func/empty_test.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/func/empty_test.lua#L27) defines `TestArray = {}` (a table).
- [`src/sort/quicksort_test.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/sort/quicksort_test.lua#L6) defines `function TestArray()` (a function).
- [`src/sort/bucketsort_test.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/sort/bucketsort_test.lua#L5) defines `function TestArray()` (a function).

When `empty_test.lua` runs after `quicksort_test.lua`, `TestArray` is transformed from a function to a table. When `bucketsort_test.lua` runs, it overwrites the table with another function.

**Direct Result**: Out of **324** test functions authored in the repository, only **184** exist in `_G` when the final runner executes. **140 tests are never validated in the final test suite run**.

---

### 2.5 Non-Idiomatic Assertions & Missed LuaUnit Features

1. **`assertTrue(a == b)` instead of `assertEquals(a, b)`**:
   ```lua
   -- Current (array_test.lua:100)
   lu.assertTrue(a1 == a2)
   -- Failure output: expected: true, actual: false (no context!)

   -- Recommended
   lu.assertEquals(a1, a2)
   -- Failure output: expected: [ 1, 2, 4 ], actual: [ 1, 2, 3 ] (rich object diff!)
   ```

2. **Manual Key Sorting vs `assertItemsEquals`**:
   In `hashmap_test.lua`:
   ```lua
   -- Current: 15 lines of manual table extraction and sorting
   local res = {}
   for k, v in pairs(map) do res[#res + 1] = { key = k, value = v } end
   table.sort(res, function(a, b) return a.key < b.key end)
   lu.assertEquals({ ... }, res)

   -- Recommended: 1 line with assertItemsEquals
   lu.assertItemsEquals(actual_pairs, expected_pairs)
   ```

3. **Missing Error Message Validation**:
   `lu.assertError(fn)` verifies that an error was thrown, but ignores whether it was the *expected* error. Using `lu.assertErrorMsgContains(sub, fn, ...)` ensures that accidental syntax errors or nil-pointer dereferences are not mistaken for valid precondition guards.

---

## 3. Recommended Code Style & Architecture for Tests

### 3.1 The Class-Based Test Suite Pattern

Every test file must encapsulate its tests into a dedicated test table matching `Test<Module>` or `Test<Class>`:

```lua
local lu = require("luaunit")
local Array = require("ff.collections.array")

TestArray = {}

function TestArray:setUp()
    self.emptyArray = Array.new()
    self.sampleArray = Array.new({ 10, 20, 30 })
end

function TestArray:tearDown()
    self.emptyArray = nil
    self.sampleArray = nil
end

function TestArray:testEmpty()
    lu.assertTrue(self.emptyArray:empty())
    lu.assertFalse(self.sampleArray:empty())
end

function TestArray:testGet()
    lu.assertEquals(self.sampleArray:get(1), 10)
    lu.assertEquals(self.sampleArray:get(2), 20)
    lu.assertEquals(self.sampleArray:get(3), 30)
end
```

#### Key Architectural Benefits:
1. **Namespace Isolation**: `TestArray:testEmpty()` and `TestHashMap:testEmpty()` live in separate tables. Zero clobbering.
2. **Lifecycle Management**: `setUp()` and `tearDown()` execute before and after every test method, guaranteeing clean state.
3. **Selective CLI Execution**: Run specific suites or methods from the command line:
   ```bash
   lua test.lua TestArray
   lua test.lua TestArray.testGet
   lua test.lua -p Heap
   ```

---

### 3.2 Canonical Test Method Naming Standard

Adopt a consistent method naming format across all suites:

```text
function Test<Class>:test<Feature>[_<Condition>]()
```

- Prefix: `test` (camelCase).
- Feature: Method or property being tested (`Insert`, `Get`, `Contains`, `Concat`).
- Condition (Optional): Edge case, validation, or state (`Empty`, `OutOfBounds`, `Duplicates`, `ThrowsOnNil`).

Examples:
- `TestArray:testInsert_AtEnd()`
- `TestArray:testInsert_OutOfBoundsThrows()`
- `TestHashMap:testCompute_KeyPresent()`
- `TestHeap:testPop_EmptyReturnsNil()`

---

### 3.3 Canonical Assertion Table

Standardize assertions across the test suite:

| Goal | Recommended Assertion | Anti-Pattern to Avoid |
| :--- | :--- | :--- |
| Equality (primitives & objects) | `lu.assertEquals(actual, expected)` | `lu.assertEquals(expected, actual)`<br/>`lu.assertTrue(actual == expected)` |
| Inequality | `lu.assertNotEquals(actual, unexpected)` | `lu.assertFalse(actual == unexpected)` |
| Boolean evaluation | `lu.assertTrue(actual)` / `lu.assertFalse(actual)` | `lu.assertEquals(actual, true)` |
| Nil checks | `lu.assertNil(actual)` / `lu.assertNotNil(actual)` | `lu.assertTrue(actual == nil)` |
| Error presence | `lu.assertError(fn, ...)` | `local ok = pcall(fn); lu.assertFalse(ok)` |
| Error message guard | `lu.assertErrorMsgContains(expected_sub, fn, ...)` | Unchecked `assertError` |
| Unordered item matching | `lu.assertItemsEquals(actual_list, expected_list)` | Manual `table.sort` + `assertEquals` |
| String matching | `lu.assertStrMatches(actual, pattern)` | `lu.assertTrue(actual:match(pattern) ~= nil)` |

---

### 3.4 Canonical Test File Anatomy (10-Part Standard Companion)

Mirroring the [10-part specification for collection classes](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/collections.md#L32), every collection test file should follow this structure:

```lua
-----------------------------------------------------------------------------
-- 1. Upvalue caching & Imports
-----------------------------------------------------------------------------
local lu = require("luaunit")
local Array = require("ff.collections.array")

-----------------------------------------------------------------------------
-- 2. Test Suite Table Definition
-----------------------------------------------------------------------------
TestArray = {}

-----------------------------------------------------------------------------
-- 3. Suite Lifecycle Hooks (Optional)
-----------------------------------------------------------------------------
function TestArray:setUp()
    self.arr = Array.new({ 1, 2, 3 })
end

function TestArray:tearDown()
    self.arr = nil
end

-----------------------------------------------------------------------------
-- 4. Constructor & Type Guard Tests
-----------------------------------------------------------------------------
function TestArray:testIsArray()
    lu.assertTrue(Array.isArray(self.arr))
    lu.assertFalse(Array.isArray({}))
    lu.assertFalse(Array.isArray(nil))
end

function TestArray:testNew_Empty()
    local a = Array.new()
    lu.assertEquals(#a, 0)
    lu.assertTrue(a:empty())
end

-----------------------------------------------------------------------------
-- 5. Core Accessor & Inspection Tests
-----------------------------------------------------------------------------
function TestArray:testGet()
    lu.assertEquals(self.arr:get(1), 1)
    lu.assertEquals(self.arr:get(2), 2)
end

function TestArray:testGet_OutOfBoundsThrows()
    lu.assertError(function() self.arr:get(0) end)
    lu.assertError(function() self.arr:get(4) end)
end

-----------------------------------------------------------------------------
-- 6. Mutation & Modification Tests
-----------------------------------------------------------------------------
function TestArray:testInsert()
    self.arr:insert(4)
    lu.assertEquals(#self.arr, 4)
    lu.assertEquals(self.arr:get(4), 4)
end

-----------------------------------------------------------------------------
-- 7. Metamethod Tests (__len, __eq, __concat, __tostring, __newindex)
-----------------------------------------------------------------------------
function TestArray:testLen()
    lu.assertEquals(#self.arr, 3)
end

function TestArray:testEquality()
    local duplicate = Array.new({ 1, 2, 3 })
    lu.assertEquals(self.arr, duplicate)
end

function TestArray:testNewIndex_PreventsModification()
    lu.assertErrorMsgContains("cannot add new properties", function()
        self.arr.foo = "bar"
    end)
end

-----------------------------------------------------------------------------
-- 8. Standalone Execution Guard
-----------------------------------------------------------------------------
if arg and arg[0] and arg[0]:find("array_test%.lua$") then
    os.exit(lu.LuaUnit.run())
end

return TestArray
```

---

## 6. Migration Roadmap

To transition the repository to these standards without breaking existing workflows:

2. **Phase 2: Migrate `src/collections/*_test.lua` to Test Classes**:
   - Wrap test functions in `Test<Name> = {}` tables.
   - Fix assertion ordering to `lu.assertEquals(actual, expected)`.
   - Replace `assertTrue(a == b)` with `lu.assertEquals(a, b)`.
   - Restore all 140 lost tests to active execution.
3. **Phase 3: Add Missing Suites**:
   - Implement `src/aoc/matrix_test.lua` for `Matrix`.
   - Implement `src/graph/graph_test.lua` for `Graph`.
