# RadixTree & Project Notes

This document highlights possible issues, architectural limitations, and potential areas for improvement.

---

## 1. Lua 5.1 & LuaJIT Metamethod Compatibility

### Description
The collection implementations in this project (including `RadixTree`, `Trie`, `HashMap`, and `Stack`) rely heavily on Lua's metamethods for custom table behaviors, specifically:
- `__len` (for the length operator `#`)
- `__pairs` (for `pairs()` iteration)

In standard **Lua 5.1** and default **LuaJIT** builds, these metamethods are **not supported on tables** (only on userdata). As a result, running tests or utilizing these collections in Lua 5.1 environments causes length checks to return `0` (raw table length) and iterations to loop over internal storage fields (such as `_entries` or `_len`) instead of values.

### Impact
Running this codebase in raw Lua 5.1 or standard LuaJIT leads to silent failures, unexpected data states, and broken unit tests.

### Recommendation
- Ensure all execution environments and CI runners use **Lua 5.2+** (e.g., Lua 5.5).
- If LuaJIT must be used, ensure it is built with the 5.2 compatibility flag enabled (`-DLUAJIT_ENABLE_LUA52COMPAT`).
- Document this environment requirement clearly in the project `README.md`.

---

## 2. RadixTree Iterator Key Loss (`__pairs`)

### Description
The `__pairs` metamethod for `RadixTree` delegates to `_traverse()`, which returns an iterator yielding `index, value` where `index` is a sequential numeric counter (1, 2, 3, ...):
```lua
if cur._value ~= nil then
    index = index + 1
    return index, cur._value
end
```

### Impact
Unlike a standard Map (e.g., `HashMap`), which yields `key, value`, iterating over a `RadixTree` discards the original keys. Users cannot inspect the tree structure or retrieve the keys of the stored values via `pairs()`.

### Recommendation
Modify `_traverse` to keep track of the current path prefix and yield `key, value`. A stack of nodes along with their accumulated prefix can be used to achieve this without recursion:
```lua
-- Suggested iterative traversal yielding key, value
function RadixTree:_traverse(node)
    -- Stack stores pairs of {node, prefix}
    local visit = Stack.new()
    visit:push({node = node or self._root, prefix = ""})

    return function()
        while not visit:empty() do
            local item = visit:pop()
            local cur = item.node
            local prefix = item.prefix .. cur._prefix

            for _, child in pairs(cur._children) do
                visit:push({node = child, prefix = prefix})
            end

            if cur._value ~= nil then
                return prefix, cur._value
            end
        end
    end
end
```

---

## 3. Concat Metamethod (`__concat`) Key Loss

### Description
The `__concat` (`..`) operator inserts elements from an iterable using `pairs(iterable)`.
```lua
for _, item in pairs(iterable) do
    if type(item) == "string" then
        self:insert(item, item)
    end
end
```

### Impact
- If `iterable` is another `RadixTree`, iterating over it yields `index, value`. The concat method inserts the values as both key and value, completely losing the original keys of the source tree.
- If `iterable` is a standard dictionary table (e.g., `{ key1 = "val1" }`), the iterator yields `key, value`, but `__concat` ignores the key (`_` is discarded) and inserts `val1` as both key and value.

### Recommendation
Redesign `__concat` to respect key-value structures. If the iterable is key-value based, insert `key, value` pairs. If it is an array or list of strings, insert `value, value`.

---

## 4. Stack Overflow Risk in Recursion

### Description
`RadixTree:insert` and `RadixTree:remove` utilize internal recursive helper functions (`_insert` and `_delete`) that recurse on every node split or edge traversal.

### Impact
For highly degenerate keys (e.g., extremely long strings with many split nodes) or deep trees, Lua could hit its recursion stack depth limit, leading to a stack overflow error.

### Recommendation
Refactor recursive methods into iterative loops. Since prefix searching in a Radix Tree is deterministic and linear, recursion is not strictly necessary and can be replaced with simple `while` loops.
