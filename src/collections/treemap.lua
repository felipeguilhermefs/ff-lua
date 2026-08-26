local Comparator = require("ff.func.comparator")
local Stack = require("ff.collections.stack")

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
local getmetatable = getmetatable
local pairs = pairs
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local type = type

---@class (private) TreeNode
---@field key   any       Stores the key of this node.
---@field value any       Stores the value of this node.
---@field left  TreeNode? Points to the left child node in the tree.
---@field right TreeNode? Points to the right child node in the tree.
local TreeNode = {}
TreeNode.__index = TreeNode

-----------------------------------------------------------------------------
---Creates a new instance of the node.
---
---@param  key    any
---@param  value  any
---@param  left   TreeNode?
---@param  right  TreeNode?
---
---@return TreeNode
-----------------------------------------------------------------------------
function TreeNode.new(key, value, left, right)
	return setmetatable({
		key = key,
		value = value,
		left = left,
		right = right,
	}, TreeNode)
end

--------------------------------------------------------------------------------------
---@class TreeMap
---@field private _comparator fun(a: any, b: any): -1|0|1 Function used to keep tree order.
---@field private _len        number                      Number of entries in the map.
---@field private _root       TreeNode?                   Root of the tree, if `nil` it is empty.
--------------------------------------------------------------------------------------
local TreeMap = {}

-----------------------------------------------------------------------------
---Checks if it is a TreeMap instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function TreeMap.isTreeMap(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == TreeMap
end

-----------------------------------------------------------------------------
---Creates a new instance of the tree map.
---
---@param  iterable?   table<any, any>		   Optional table
---						   to initialize the map from.
---@param  comparator? fun(a: any, b: any): -1|0|1 Function used to keep the
---                                                tree order. Defaults to
---                                                natural order.
---
---@return TreeMap
-----------------------------------------------------------------------------
function TreeMap.new(iterable, comparator)
	if comparator ~= nil then
		assert(type(comparator) == "function", "comparator should be a function")
	end

	return setmetatable({
		_comparator = comparator or Comparator.natural,
		_len = 0,
		_root = nil,
	}, TreeMap) .. iterable
end

-----------------------------------------------------------------------------
---Returns the key-value mapping associated with the least key greater than or
---equal to the given key, or `nil`.
---
---@param  key any
---
---@return any? key, any? value
-----------------------------------------------------------------------------
function TreeMap:ceiling(key)
	assert(key ~= nil, "key should not be nil")

	local cur = self._root
	local best = nil
	while cur ~= nil do
		local cmp = self._comparator(key, cur.key)
		if cmp == Comparator.equal then
			return cur.key, cur.value
		elseif cmp == Comparator.less then
			best = cur
			cur = cur.left
		else
			cur = cur.right
		end
	end

	if best ~= nil then
		return best.key, best.value
	end
end

-----------------------------------------------------------------------------
---Empties the map.
-----------------------------------------------------------------------------
function TreeMap:clear()
	rawset(self, "_root", nil)
	self._len = 0
end

-----------------------------------------------------------------------------
---Returns the value associated with the key. Computes and stores the value
---if it was not present already.
---
---@param  key any                Key used to look up the value.
---@param  fn  fun(key: any): any Function used to compute a missing value.
---
---@return any                    Value associated with key, or newly computed.
-----------------------------------------------------------------------------
function TreeMap:compute(key, fn)
	assert(key ~= nil, "key should not be nil")
	assert(type(fn) == "function", "fn should be a function")

	local node = self:_lookup(key)
	if node ~= nil then
		return node.value
	end

	local value = fn(key)
	self[key] = value

	return value
end

-----------------------------------------------------------------------------
---Checks if the key is present in the map.
---
---@param  key any Key used for lookup.
---
---@return boolean
-----------------------------------------------------------------------------
function TreeMap:contains(key)
	assert(key ~= nil, "key should not be nil")
	return self:_lookup(key) ~= nil
end

-----------------------------------------------------------------------------
---Returns whether the map is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function TreeMap:empty()
	return self._len == 0
end

-----------------------------------------------------------------------------
---Returns the key-value mapping associated with the greatest key less than or
---equal to the given key, or `nil`.
---
---@param  key any
---
---@return any? key, any? value
-----------------------------------------------------------------------------
function TreeMap:floor(key)
	assert(key ~= nil, "key should not be nil")

	local cur = self._root
	local best = nil
	while cur ~= nil do
		local cmp = self._comparator(key, cur.key)
		if cmp == Comparator.equal then
			return cur.key, cur.value
		elseif cmp == Comparator.greater then
			best = cur
			cur = cur.right
		else
			cur = cur.left
		end
	end

	if best ~= nil then
		return best.key, best.value
	end
end

-----------------------------------------------------------------------------
---Returns the maximum key and value (rightmost) from the tree, `nil` if empty.
---
---@return any? key, any? value
-----------------------------------------------------------------------------
function TreeMap:max()
	local cur = self._root
	while cur ~= nil and cur.right do
		cur = cur.right
	end

	if cur ~= nil then
		return cur.key, cur.value
	end
end

-----------------------------------------------------------------------------
---Merge an iterable into this TreeMap. When keys conflict a merge function
---is called to resolve the new value.
---
---@param  other table<any, any> Other table or map to merge into this.
---@param  fn?   fun(a: any, b: any): any?
---                              Merge function called on conflict.
---                              Receives (existing, incoming); its return
---                              value becomes the new stored value.
---                              Defaults to an override function (returns `incoming`).
---
---@return TreeMap               Returns this TreeMap after the merge.
-----------------------------------------------------------------------------
function TreeMap:merge(other, fn)
	assert(type(other) == "table", "other should be a table")
	assert(fn == nil or type(fn) == "function", "fn should be a function")

	fn = fn or function(_, b)
		return b
	end

	for k, v in pairs(other) do
		local node = self:_lookup(k)
		if node == nil then
			self[k] = v
		else
			local resolved = fn(node.value, v)
			self[k] = resolved
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Returns the minimum key and value (leftmost) from the tree, `nil` if empty.
---
---@return any? key, any? value
-----------------------------------------------------------------------------
function TreeMap:min()
	local minNode = self:_min(self._root)
	if minNode ~= nil then
		return minNode.key, minNode.value
	end
end

-----------------------------------------------------------------------------
---Returns an iterator that traverses entries within [fromKey, toKey] (inclusive).
---If fromKey is nil, it is unbounded below. If toKey is nil, it is unbounded above.
---
---@param  fromKey? any Lower bound (inclusive).
---@param  toKey?   any Upper bound (inclusive).
---
---@return fun(): any?, any? Iterator yielding key, value in ascending order.
-----------------------------------------------------------------------------
function TreeMap:range(fromKey, toKey)
	if fromKey ~= nil and toKey ~= nil then
		assert(self._comparator(fromKey, toKey) == Comparator.less, "'fromKey'  should come before 'toKey'")
	end

	local stack = Stack.new()
	local cur = self._root

	return function()
		while cur ~= nil do
			if fromKey ~= nil and self._comparator(cur.key, fromKey) == Comparator.less then
				cur = cur.right
			else
				if toKey == nil or self._comparator(cur.key, toKey) ~= Comparator.greater then
					stack:push(cur)
				end
				cur = cur.left
			end
		end

		if stack:empty() then
			return nil
		end

		local node = stack:pop()

		cur = node.right
		return node.key, node.value
	end
end

-----------------------------------------------------------------------------
---Removes the entry associated with the key from the map and returns its value.
---
---@param  key any Key to be removed.
---
---@return any?    Previous value associated with key, or `nil` if not found.
-----------------------------------------------------------------------------
function TreeMap:remove(key)
	assert(key ~= nil, "key should not be nil")

	local node = self:_lookup(key)

	if node ~= nil then
		local prevValue = node.value
		self._root = self:_remove(self._root, key)
		return prevValue
	end
end

-----------------------------------------------------------------------------
---Looks up a node by key using the comparator.
---
---@param  key any
---
---@return TreeNode?
---
---@private
-----------------------------------------------------------------------------
function TreeMap:_lookup(key)
	local cur = rawget(self, "_root")
	while cur do
		local cmp = self._comparator(key, cur.key)
		if cmp == Comparator.equal then
			return cur
		elseif cmp == Comparator.greater then
			cur = cur.right
		else
			cur = cur.left
		end
	end
	return nil
end

-----------------------------------------------------------------------------
---Traverse the tree and insert the key-value pair at the appropriate position
---using the comparator function.
---
---@param  node  TreeNode? The node where to start the traversal.
---@param  key   any          Key to insert.
---@param  value any          Value to associate.
---
---@return TreeNode        New node created or the one which was visited.
---
---@private
-----------------------------------------------------------------------------
function TreeMap:_insert(node, key, value)
	if node == nil then
		self._len = self._len + 1
		return TreeNode.new(key, value)
	end

	local cmp = self._comparator(key, node.key)

	if cmp == Comparator.greater then
		node.right = self:_insert(node.right, key, value)
	elseif cmp == Comparator.less then
		node.left = self:_insert(node.left, key, value)
	else
		node.value = value
	end

	return node
end

-----------------------------------------------------------------------------
---Finds and returns the minimum (leftmost) node in the subtree.
---
---@param  node TreeNode? The node where to start the traversal.
---
---@return TreeNode?      Node that was visited or `nil` if empty.
---
---@private
-----------------------------------------------------------------------------
function TreeMap:_min(node)
	local cur = node
	while cur ~= nil and cur.left do
		cur = cur.left
	end
	return cur
end

-----------------------------------------------------------------------------
---Traverse the tree (using the comparator) and remove the key.
---
---@param  node TreeNode? The node where to start the traversal.
---@param  key  any       Key to remove.
---
---@return TreeNode?      New node at the position or `nil` if key not found.
---
---@private
-----------------------------------------------------------------------------
function TreeMap:_remove(node, key)
	if node == nil then
		return nil
	end

	local comp = self._comparator(key, node.key)

	if comp == Comparator.less then
		node.left = self:_remove(node.left, key)
	elseif comp == Comparator.greater then
		node.right = self:_remove(node.right, key)
	else
		if node.left == nil then
			self._len = self._len - 1
			return node.right
		end

		if node.right == nil then
			self._len = self._len - 1
			return node.left
		end

		local minNode = assert(self:_min(node.right), "min should always exist")
		node.key = minNode.key
		node.value = minNode.value
		node.right = self:_remove(node.right, minNode.key)
	end

	return node
end

-----------------------------------------------------------------------------
---Concatenate a given iterable to this TreeMap (in-place modification).
---
---@param  iterable? table<any, any> Entries to be concatenated.
---                                  Defaults to an empty list if `nil`.
---
---@return TreeMap Returns this map instance.
-----------------------------------------------------------------------------
function TreeMap:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for key, value in pairs(iterable) do
			self[key] = value
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when both are tables with the same
---size and containing the same key-value pairs.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function TreeMap:__eq(other)
	if other == nil then
		return false
	end

	if type(other) ~= "table" then
		return false
	end

	if self._len ~= #other then
		return false
	end

	for k, v in pairs(self) do
		if other[k] ~= v then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Metamethod __index controls bracket (a[key]) read access to internals.
---
---@param  key any Key used for lookup, should not be nil.
---
---@return any     Value at key or fallback method.
-----------------------------------------------------------------------------
function TreeMap:__index(key)
	assert(key ~= nil, "key should not be nil")

	-- Check class methods / private fields first; avoids running the BST
	-- comparator on method-name strings against user data keys of other types.
	local classField = rawget(TreeMap, key)
	if classField ~= nil then
		return classField
	end

	-- Data key lookup in the BST.
	local node = rawget(TreeMap, "_lookup")(self, key)
	if node ~= nil then
		return node.value
	end

	return nil
end

-----------------------------------------------------------------------------
---Returns the number of entries in the tree map.
---
---@return number
-----------------------------------------------------------------------------
function TreeMap:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Metamethod __newindex controls bracket (a[key] = value) write access.
---
---@param  key   any Key used for lookup, should not be nil.
---@param  value any Value to be stored, should not be nil.
-----------------------------------------------------------------------------
function TreeMap:__newindex(key, value)
	assert(key ~= nil, "key should not be nil")
	assert(value ~= nil, "value should not be nil")

	rawset(self, "_root", self:_insert(rawget(self, "_root"), key, value))
end

-----------------------------------------------------------------------------
---Iterates through the map in ascending (in-order) key order.
---
---@return fun(t: table, k: any): any, any, table, nil
-----------------------------------------------------------------------------
function TreeMap:__pairs()
	local stack = Stack.new()
	local cur = self._root
	return function()
		while cur ~= nil do
			stack:push(cur)
			cur = cur.left
		end
		if stack:empty() then
			return nil
		end

		local node = stack:pop()
		cur = node.right
		return node.key, node.value
	end
end

-----------------------------------------------------------------------------
---String representation of this TreeMap.
---
---@return string
-----------------------------------------------------------------------------
function TreeMap:__tostring()
	local sb = {}
	for k, v in pairs(self) do
		tinsert(sb, sfmt("%s = %s", k, v))
	end
	return sfmt("{ %s }", tconcat(sb, ", "))
end

return TreeMap
