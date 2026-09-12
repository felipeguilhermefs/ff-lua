# Collection Standards & Architecture in `ff-lua`

This document defines the architecture, design standards, patterns, and conventions extracted from the implementations in [`src/collections`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections). It details the common blueprint shared across all classes, highlights current inconsistencies, presents recommendations for improvement, and provides a canonical template for developing new collections.

---

## 1. Analyzed Classes Overview

The [`src/collections`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections) directory contains 10 primary data structures:

| Class | File | Primary Storage | Key Dependencies |
| :--- | :--- | :--- | :--- |
| [`Array`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/array.lua#L27) | [`src/collections/array.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/array.lua) | Sequential table array (`_entries`) | None (self-contained) |
| [`HashMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua#L28) | [`src/collections/hashmap.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua) | Hash table (`_entries`) + size counter (`_len`) | None (self-contained) |
| [`Heap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/heap.lua#L22) | [`src/collections/heap.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/heap.lua) | Binary heap array (`_entries: Array`) | [`Array`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/array.lua#L27), [`Comparator`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/func/comparator.lua) |
| [`IntervalTree`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/intervaltree.lua#L57) | [`src/collections/intervaltree.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/intervaltree.lua) | Binary search tree of disjoint intervals (`_root: IntervalNode`) | [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua#L19) |
| [`LinkedList`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/linkedlist.lua#L50) | [`src/collections/linkedlist.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/linkedlist.lua) | Doubly-linked nodes (`_front`, `_back: LinkNode`) | None (self-contained) |
| [`Queue`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/queue.lua#L42) | [`src/collections/queue.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/queue.lua) | Singly-linked FIFO nodes (`_front`, `_back: QNode`) | None (self-contained) |
| [`RadixTree`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/radixtree.lua#L149) | [`src/collections/radixtree.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/radixtree.lua) | Compact trie nodes (`_root: RadixNode`) | [`Array`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/array.lua#L27), [`HashMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua#L28), [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua#L19) |
| [`Set`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/set.lua#L28) | [`src/collections/set.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/set.lua) | Keyed table (`_entries[x] = x`) + size (`_len`) | None (self-contained) |
| [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua#L19) | [`src/collections/stack.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua) | Underlying array (`_entries: Array`) | [`Array`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/array.lua#L27) |
| [`TreeMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/treemap.lua#L130) | [`src/collections/treemap.lua`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/treemap.lua) | Self-balancing AVL tree (`_root: TreeNode`) | [`Comparator`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/func/comparator.lua), [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua#L19) |

---

## 2. Standards & Similarities Across Classes

Analysis reveals a strong architectural pattern across the library. Each class follows a common lifecycle, structural layout, and metatable protocol.

### 2.1 File Anatomy & Structural Sections

Every file in `src/collections` follows a 10-part structure:

1. **Header & Upvalue Caching (`Cache function references`)**:
   Standard library functions and globals (`string.format`, `table.insert`, `assert`, `type`, `setmetatable`, `getmetatable`, `pairs`, `next`) are localized at the top of the file to eliminate global lookup overhead.
2. **Private Node Classes & Helper Functions**:
   Structures requiring node allocations ([`IntervalTree`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/intervaltree.lua#L25), [`LinkedList`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/linkedlist.lua#L20), [`Queue`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/queue.lua#L19), [`RadixTree`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/radixtree.lua#L46), [`TreeMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/treemap.lua#L26)) define a localized helper node table marked with `---@class (private) <Name>Node` with its own minimal constructor `Node.new(...)`.
3. **EmmyLua Type Annotations**:
   The primary collection class is documented using `---@class <Name>` along with `---@field private _<field> <type> <description>`.
4. **Class Table & Dispatch Binding**:
   Defined via `local <Name> = {}` with `<Name>.__index = <Name>`.
5. **Static Type Guard Function**:
   A static predicate `ClassName.is<ClassName>(maybe)` is provided to identify class instances via `getmetatable(maybe) == ClassName`.
6. **Constructor (`ClassName.new(...)`)**:
   Always instantiates state and populates from an optional `iterable` argument.
7. **Public Methods**:
   Object-oriented methods defined with colon syntax (`function ClassName:method(...)`), sorted alphabetically.
8. **Private Methods**:
   Prefixed with a single leading underscore (`_`), marked with EmmyLua `---@private`, and sorted alphabetically.
9. **Metamethods**:
   Predefined Lua metamethods (`__concat`, `__eq`, `__len`, `__newindex`, `__pairs`, `__tostring`), sorted alphabetically.
10. **Module Return**:
    Ends with `return ClassName`.

---

### 2.2 Constructor Pattern & The Fluent Iterable Idiom

All collections share an identical instantiation idiom:

```lua
function ClassName.new(iterable, ...)
    -- validation of configuration parameters (capacity, comparator, etc.)
    return setmetatable({
        -- private instance fields initialized with leading underscore
        _entries = {},
        _len = 0,
    }, ClassName) .. iterable
end
```

**Key Characteristics:**
- **Encapsulated State**: All internal properties use leading underscores (e.g. `_entries`, `_len`, `_root`, `_front`, `_back`, `_capacity`, `_comparator`, `_caseSensitive`).
- **Fluent Initialization via `.. iterable`**: The constructor constructs an empty, initialized instance with its metatable attached, then immediately executes the `..` operator against the passed `iterable`.
- **Delegation to `__concat`**: `__concat` handles `nil` gracefully (treating it as an empty table/no-op) or iterates through the items of `iterable` using standard insertion methods (`insert`, `put`, `push`, `pushBack`, `add`).

---

### 2.3 Method Ordering Standard

Across the codebase, the intended method hierarchy is:
1. **Public methods** (alphabetical order)
2. **Private methods** (alphabetical order, starting with `_`)
3. **Metamethods** (alphabetical order, starting with `__`)

---

### 2.4 Core Method Naming & Semantics

Across the classes, specific functionality shares standard naming:

- **Empty Check**: Every single collection implements `:empty()` returning `boolean` (testing `#self == 0` or `self._len == 0`).
- **Reset**: Every collection implements `:clear()` which resets internal buffers, references, and counters to zero.
- **Size**: Collections do not implement `:size()` or `:len()`. Instead, size is queried strictly via the `#` operator using `__len()`.
- **Search / Membership**:
  - Sets, Trees, and Lists use `:contains(...)` returning `boolean`.
  - Sequential arrays use `:indexOf(value)` returning `number|nil`.
- **Inspection**:
  - `Queue:peek()` returns front without removal.
  - `Heap:peek()` returns root without removal.
  - `LinkedList:peekFront()` and `LinkedList:peekBack()`.
  - `Stack:top()` returns top without removal (note discrepancy with `peek`).
  - `Array:get(index)` and `HashMap:get(key)` / `TreeMap:get(key)`.

---

### 2.5 Metamethod Standards

All collections implement a uniform set of metamethods:

| Metamethod | Standard Behavior | Return Value |
| :--- | :--- | :--- |
| `__len()` | Maps `#instance` to item count. Returns `self._len` or `#self._entries`. | `number` |
| `__concat(iterable)` | In-place bulk insertion of items from `iterable` via `coll .. items`. | `self` |
| `__eq(other)` | Deep/structural equality. Verifies class identity via `is<Class>`, compares sizes, then verifies all elements match. | `boolean` |
| `__pairs()` | Enables `for k, v in pairs(instance) do`. | `iterator, [state, var]` |
| `__tostring()` | Pretty prints content: `[ 1, 2, 3 ]` for sequence-like, `{ k = v }` for key-value, `{ a, b }` for sets. | `string` |
| `__newindex()` | Throws `error("cannot add new properties, methods or functions to <Class>")` to enforce encapsulation. | Error |

---

### 2.6 Defensive Precondition Validation

Methods rigorously validate input arguments using `assert(condition, message)`:
- `assert(value ~= nil, "value should not be nil")`
- `assert(type(index) == "number", "index should be a number")`
- `assert(index > 0 and index <= #self, "index out of bounds")`
- `assert(type(iterable) == "table", "iterable should be a table")`

---

## 3. Comparison Matrix

| Class | Type Guard | `__pairs` Style | Method Order Followed | Peek / Read Method |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [`Array`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/array.lua) | `isArray` | Non-destructive (yields index, value) | Yes | `get(idx)` |
| [`HashMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua) | **Missing** | Non-destructive (yields key, value) | Yes | `get(key)` |
| [`Heap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/heap.lua) | `isHeap` | **Destructive** (pops all items!) | Yes | `peek()` |
| [`IntervalTree`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/intervaltree.lua) | `isIntervalTree` | Non-destructive (yields low, high) | Yes | `contains(val)` |
| [`LinkedList`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/linkedlist.lua) | `isLinkedList` | Non-destructive (yields index, value) | Yes | `peekFront()`, `peekBack()` |
| [`Queue`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/queue.lua) | `isQueue` | **Destructive** (dequeues all items!) | **No** (`dequeue` before `contains`) | `peek()` |
| [`RadixTree`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/radixtree.lua) | `isRadixTree` | Non-destructive (yields index, word) | Yes | `find(prefix)`, `contains(word)`|
| [`Set`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/set.lua) | `isSet` | Non-destructive (yields entry, entry) | **No** (`disjoint`, `subset` unsorted) | `contains(...)` |
| [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua) | `isStack` | **Destructive** (pops all items!) | Yes | `top()` (not `peek`) |
| [`TreeMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/treemap.lua) | `isTreeMap` | Non-destructive (yields key, value) | Partial (`_lookup` before `_insert`) | `get(key)`, `min()`, `max()` |

---

## 4. Inconsistencies & Deviations Identified

1. **Missing Type Guard on [`HashMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua)**:
   Every collection provides `<Class>.is<Class>(maybe)`. [`HashMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua) lacks `HashMap.isHashMap(maybe)`. As a result, [`HashMap:__eq`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua#L206) falls back to `type(other) ~= "table"`, which permits false equality with arbitrary raw tables or other collection types.
2. **Destructive `__pairs` in [`Heap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/heap.lua#L339), [`Queue`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/queue.lua#L269), and [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua#L182)**:
   Calling `pairs(q)` or `pairs(s)` actually empties the collection by repeatedly calling `pop()` or `dequeue()`. In contrast, all other collections provide non-destructive iteration. Mutating data structures as a side-effect of iteration violates Lua iterator semantics and can cause bugs when collections are passed to `__concat` or printing routines.
   - In [`HashMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua#L232) and [`TreeMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/treemap.lua#L653), `__index` is deferred to the metamethod section between `__eq` and `__len`.
3. **Naming Discrepancies**:
   - Peek operations: [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua#L122) uses `:top()` whereas [`Heap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/heap.lua#L186) and [`Queue`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/queue.lua#L192) use `:peek()`.
   - Element existence: [`Array`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/array.lua) has `:indexOf(value)` but no `:contains(value)`.
4. **Missing Upvalue Caching in [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua#L197)**:
   In [`Stack:__tostring`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua#L197), `string.format` and `table.concat` are called as globals instead of using cached local references.
5. **Typos in Error Assertions**:
   [`Set:union`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/set.lua#L279) contains the error message `"other shoudl also be a Set"`.

---

## 5. Suggested Improvements & Standardizations

### 5.1 Implement `HashMap.isHashMap` and Harden Equality
Add `isHashMap` to [`HashMap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua):
```lua
function HashMap.isHashMap(maybe)
    if maybe == nil or type(maybe) ~= "table" then
        return false
    end
    return getmetatable(maybe) == HashMap
end
```
Update [`HashMap:__eq`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/hashmap.lua#L206) to assert `if not HashMap.isHashMap(other) then return false end`.

### 5.2 Separate Non-Destructive Iteration from Draining
Make `__pairs()` strictly non-destructive across all classes:
- For [`Queue`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/queue.lua), [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua), and [`Heap`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/heap.lua), `__pairs` should traverse items from front to back / top to bottom / root to leaf **without consuming them**.
- Introduce an explicit `:drain()` or `:consume()` method for users who specifically desire a destructive consumer generator:
```lua
---Consumes items in FIFO order until empty.
function Queue:drain()
    return function()
        return self:dequeue()
    end
end
```

### 5.3 Standardize Inspection Methods
Provide `:peek()` across all queue/stack/heap collections:
- In [`Stack`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/stack.lua), provide `:peek()` as an alias or replacement for `:top()`.
- In [`Array`](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/array.lua), add `:contains(value)`:
```lua
function Array:contains(value)
    return self:indexOf(value) ~= nil
end
```

### 5.4 Standardize Iterator Return Signature
Standard Lua 5.2+ `__pairs` convention expects `iterator_func, state_table, initial_key`.
Ensure all `__pairs` methods consistently return `iterator, self, nil` (or `next, self._entries, nil`).

### 5.5 Standardize Placement of `Class.__index = Class`
Standardize placing `<Class>.__index = <Class>` immediately following `local <Class> = {}` at the top of the file for clarity and visibility.

---

## 6. Canonical Template for New Collections

When creating a new collection, use the blueprint below to ensure compliance with the repository's architecture, documentation, and ordering standards:

```lua
------------------------------
-- Cache function references
------------------------------

-- String
local sfmt = string.format

-- Table
local tconcat = table.concat
local tinsert = table.insert

-- General
local assert = assert
local error = error
local getmetatable = getmetatable
local pairs = pairs
local setmetatable = setmetatable
local tostring = tostring
local type = type

--------------------------------------------------------------------------------------
---@class ExampleCollection
---@field private _entries table<any> Internal storage holding elements.
---@field private _len     number     Total number of elements in the collection.
--------------------------------------------------------------------------------------
local ExampleCollection = {}
ExampleCollection.__index = ExampleCollection

-----------------------------------------------------------------------------
---Checks if a given value is an ExampleCollection instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function ExampleCollection.isExampleCollection(maybe)
	if maybe == nil or type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == ExampleCollection
end

-----------------------------------------------------------------------------
---Creates a new instance of the collection.
---
---@param  iterable? table<any, any> Optional table or collection to populate from.
---
---@return ExampleCollection
-----------------------------------------------------------------------------
function ExampleCollection.new(iterable)
	return setmetatable({
		_entries = {},
		_len = 0,
	}, ExampleCollection) .. iterable
end

-----------------------------------------------------------------------------
-- Public Methods (Alphabetical Order)
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
---Empties the collection.
-----------------------------------------------------------------------------
function ExampleCollection:clear()
	self._entries = {}
	self._len = 0
end

-----------------------------------------------------------------------------
---Checks whether a value is present in the collection.
---
---@param  value any Value to look up.
---
---@return boolean
-----------------------------------------------------------------------------
function ExampleCollection:contains(value)
	assert(value ~= nil, "value should not be nil")
	for _, v in pairs(self._entries) do
		if v == value then
			return true
		end
	end
	return false
end

-----------------------------------------------------------------------------
---Returns whether the collection is empty.
---
---@return boolean
-----------------------------------------------------------------------------
function ExampleCollection:empty()
	return self._len == 0
end

-----------------------------------------------------------------------------
---Inserts an item into the collection.
---
---@param  value any Value to insert.
-----------------------------------------------------------------------------
function ExampleCollection:insert(value)
	assert(value ~= nil, "value should not be nil")
	tinsert(self._entries, value)
	self._len = self._len + 1
end

-----------------------------------------------------------------------------
---Removes and returns an item from the collection.
---
---@param  value any Value to remove.
---
---@return any?      The removed value, or nil if absent.
-----------------------------------------------------------------------------
function ExampleCollection:remove(value)
	assert(value ~= nil, "value should not be nil")
	for i, v in pairs(self._entries) do
		if v == value then
			self._entries[i] = nil
			self._len = self._len - 1
			return v
		end
	end
	return nil
end

-----------------------------------------------------------------------------
-- Private Methods (Alphabetical Order, prefixed with `_`)
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
---Validates internal constraints.
---
---@private
-----------------------------------------------------------------------------
function ExampleCollection:_validate()
	assert(self._len >= 0, "length cannot be negative")
end

-----------------------------------------------------------------------------
-- Metamethods (Alphabetical Order, prefixed with `__`)
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
---Concatenates items from an iterable into this collection (in-place).
---
---@param  iterable? table<any, any> Items to insert.
---
---@return ExampleCollection         Returns self for chaining.
-----------------------------------------------------------------------------
function ExampleCollection:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")
		for _, item in pairs(iterable) do
			self:insert(item)
		end
	end
	return self
end

-----------------------------------------------------------------------------
---Checks equality between this collection and another.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function ExampleCollection:__eq(other)
	if not ExampleCollection.isExampleCollection(other) then
		return false
	end

	if self._len ~= #other then
		return false
	end

	for i, v in pairs(self._entries) do
		if other._entries[i] ~= v then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Returns the number of elements in the collection.
---
---@return number
-----------------------------------------------------------------------------
function ExampleCollection:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Metamethod __newindex prevents adding new properties, methods, or functions.
-----------------------------------------------------------------------------
function ExampleCollection:__newindex()
	error("cannot add new properties, methods or functions to ExampleCollection")
end

-----------------------------------------------------------------------------
---Non-destructive iterator across collection elements.
---
---@return fun(): any?, any?, ExampleCollection, nil
-----------------------------------------------------------------------------
function ExampleCollection:__pairs()
	local i = 0
	return function()
		i = i + 1
		if i <= #self._entries then
			return i, self._entries[i]
		end
	end, self, nil
end

-----------------------------------------------------------------------------
---String representation of this collection.
---
---@return string
-----------------------------------------------------------------------------
function ExampleCollection:__tostring()
	local items = {}
	for _, v in pairs(self._entries) do
		tinsert(items, tostring(v))
	end
	return sfmt("[ %s ]", tconcat(items, ", "))
end

return ExampleCollection
```
