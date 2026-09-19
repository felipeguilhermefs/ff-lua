# Agent Directives & Repository Guide

## Agent Communication Rules

Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
- Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
- Pattern: [thing] [action] [reason]. [next step].
- Not: "Sure! I'd be happy to help you with that."
- Yes: "Bug in auth middleware. Fix:"

Switch level: `/caveman lite|full|ultra|wenyan-lite|wenyan-full|wenyan-ultra`
Stop: "stop caveman" or "normal mode"

Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

Boundaries: code/commits/PRs written normal.

---

## Repository Overview

- **Package**: `ff-lua` (personal Lua utility library for algorithms, data structures, and playful coding/AoC).
- **Author / Maintainer**: Felipe Flores (`felipeguilhermefs@gmail.com`).
- **Repository**: `https://github.com/felipeguilhermefs/ff-lua`.
- **License**: MIT.
- **Language Requirements**: Lua 5.5+ strictly required (runtime guard in `test.lua` and declared in rockspec).
- **Package Manager**: LuaRocks 3.0+.
- **Current Version**: `0.25.0-1` (`ff-lua-0.25.0-1.rockspec`).

---

## Build & Test Commands

All standard workflows are automated via `Makefile`:

- `make test`: Run complete test suite via LuaRocks test runner (`test.lua` via `luaunit`).
- `make lint`: Lint rockspec manifest (`luarocks lint *.rockspec`).
- `make install`: Install rockspec dependencies only (`luarocks install --deps-only *.rockspec`).
- `make build`: Compile and pack binary rock (`luarocks build --pack-binary-rock`).
- `make pack`: Package source rock (`luarocks pack *.rockspec`).
- `make publish`: Upload to LuaRocks repository (`luarocks upload *.rockspec --api-key=$(LUA_ROCKS_API_KEY)`).
- Direct test run: `lua test.lua` (requires Lua 5.5+ and LuaUnit).

---

## Architecture & Directory Layout

```text
ff-lua/
├── .agents/
│   └── skills/
│       ├── ffcommit/SKILL.md    # Conventional commit guidelines
│       └── ffrelease/SKILL.md   # Release commit and tag summary rules
├── src/
│   ├── aoc/
│   │   └── matrix.lua           # 2D Grid / Matrix for Advent of Code
│   ├── cache/
│   │   ├── lru.lua              # LRU Cache (doubly linked list + HashMap)
│   │   └── lru_test.lua
│   ├── collections/             # Core data structures (see collections.md)
│   │   ├── array.lua            # Dynamic array wrapper
│   │   ├── collections.md       # Architecture spec & canonical template for collections
│   │   ├── hashmap.lua          # Hash table map
│   │   ├── heap.lua             # Binary min/max heap
│   │   ├── intervaltree.lua     # Augmented binary search tree for intervals
│   │   ├── linkedlist.lua       # Doubly linked list
│   │   ├── queue.lua            # Singly linked FIFO queue
│   │   ├── radixtree.lua        # Radix tree / Patricia trie
│   │   ├── set.lua              # Hash set of unique items
│   │   ├── stack.lua            # LIFO stack backed by Array
│   │   ├── treemap.lua          # Self-balancing AVL tree map
│   │   └── *_test.lua           # Unit test suites for each collection
│   ├── func/
│   │   ├── comparator.lua       # Natural & reversed comparator functions
│   │   ├── empty.lua            # Table empty predicate
│   │   ├── head.lua             # First element extractor
│   │   ├── memoize.lua          # Memoization helper
│   │   ├── tail.lua             # Tail elements extractor
│   │   └── *_test.lua
│   ├── graph/
│   │   └── graph.lua            # Directed/undirected weighted graph (Vertex + Graph)
│   ├── iter/
│   │   ├── permutations.lua     # Table permutations generator
│   │   └── permutations_test.lua
│   ├── math/
│   │   ├── factorial.lua        # Factorial computation
│   │   ├── fibonacci.lua        # Fibonacci sequence generator
│   │   ├── max.lua              # Variadic max
│   │   ├── min.lua              # Variadic min
│   │   ├── trunc.lua            # Number truncation
│   │   └── *_test.lua
│   ├── search/
│   │   ├── binarysearch.lua     # Binary search on sorted lists
│   │   ├── quickselect.lua      # k-th order statistic selection
│   │   └── *_test.lua
│   ├── sort/
│   │   ├── bucketsort.lua       # Bucket sort
│   │   ├── quicksort.lua        # Quick sort
│   │   └── *_test.lua
│   └── test/
│       └── spy.lua              # Test spy utility for call counting
├── test.lua                     # Global test runner configuring package.path
├── ff-lua-*.rockspec            # LuaRocks package specification
├── Makefile                     # Make targets for development and release
└── README.md                    # Public documentation
```

---

## Code Standards & Design Conventions

Reference document: `src/collections/collections.md`.

### 1. File Anatomy (10-Part Standard)
Every class module adheres to this structure:
1. **Upvalue caching**: Local aliases for Lua stdlib functions (`sfmt = string.format`, `tinsert = table.insert`, `assert`, `pairs`, `type`, `setmetatable`, etc.) to minimize global lookup overhead.
2. **Private Node Classes & Helpers**: Internal node structures (e.g. `LinkNode`, `TreeNode`, `LRUNode`, `QNode`, `RadixNode`) defined locally with minimal constructors.
3. **EmmyLua Type Annotations**: Clear `---@class <Name>` and `---@field private _<field> <type>` annotations.
4. **Class Table & Dispatch Binding**: `local Class = {}` immediately followed by `Class.__index = Class`.
5. **Static Type Guard**: `Class.isClass(maybe)` verifying `getmetatable(maybe) == Class`.
6. **Constructor**: `Class.new(iterable, ...)` using the fluent initialization idiom `return setmetatable({...}, Class) .. iterable`.
7. **Public Methods**: Object methods using colon syntax (`function Class:method()`), strictly in **alphabetical order**.
8. **Private Methods**: Prefixed with single underscore `_`, annotated with `---@private`, strictly in **alphabetical order**.
9. **Metamethods**: Metamethod implementations prefixed with `__`, strictly in **alphabetical order** (`__concat`, `__eq`, `__len`, `__newindex`, `__pairs`, `__tostring`).
10. **Module Return**: Single export via `return Class`.

### 2. Encapsulation & Mutability Protection
- Instance state is stored in private fields prefixed with `_` (`_entries`, `_len`, `_root`, `_cap`).
- Every class implements `__newindex` throwing an error to block ad-hoc property injection:
  ```lua
  function Class:__newindex()
      error("cannot add new properties, methods or functions to Class")
  end
  ```

### 3. Collection API Patterns
- **Size**: Use `#instance` (implemented via `__len`). Do **not** create `:size()` or `:len()` methods.
- **Empty Check**: Use `:empty()` returning boolean (`#self == 0` or `self._len == 0`).
- **Reset**: Use `:clear()` to reset internal counters and tables.
- **Search**: `:contains(value)` for sets/trees/lists; `:indexOf(value)` for sequential arrays.
- **Iteration**:
  - All collections provide non-destructive `__pairs` iterators (`pairs(coll)`).
  - Consumer collections (`Heap`, `Queue`, and `Stack`) provide an explicit `:drain()` generator method for destructive consumption until empty.
- **Validation**: Strict defensive assertions at method entry points (`assert(value ~= nil, "value should not be nil")`, bounds checks, type checks).

---

## Testing Standards

- **Framework**: `luaunit` (>= 3.4).
- **Colocation**: Test files live alongside implementations (`<module>_test.lua`).
- **Runner**: `test.lua` sets up `package.path` for all `src/` subdirectories and executes all test files via `dofile()`.
- **Structure**: Tests defined as global functions `function Test<Feature>()` using `lu.assertEquals`, `lu.assertTrue`, `lu.assertFalse`, `lu.assertError`.
- Ensure all 170+ existing unit tests pass before committing (`make test`).

---

## Git & Commit Conventions

Commits and releases must follow the project skills in `.agents/skills/`:

### Conventional Commits (`ffcommit`)
Format:
```text
<type>(<scope>): <description>

- Bullet points detailing changes
```
- **Allowed Types**: `feat`, `fix`, `docs`, `refactor`, `chore`.
- Scope represents modified component/module (e.g. `collections`, `array`, `hashmap`, `treemap`).
- Description in imperative mood (e.g. `add contains method to match other collections`).

### Release Workflow (`ffrelease`)
Format:
```text
release(<scope>): version <X.Y.Z>

- Bullet points summarizing commits since last tag
```
- Tag pattern: `vX.Y.Z`.
- Always keep `rockspec` version and `source.tag` in sync.
