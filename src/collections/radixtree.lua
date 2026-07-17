local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")
local Stack = require("ff.collections.stack")

---@class RadixTreeNode
---
---@field private _prefix   string  The string segment this node represents
---@field private _value    any?    The value stored at this node if it represents a full word
---@field private _children HashMap<string, RadixTreeNode> Maps child nodes by the first char of their prefix
local RadixTreeNode = {}
RadixTreeNode.__index = RadixTreeNode

-----------------------------------------------------------------------------
---Creates a new instance of a radix tree node.
---
---@param prefix string?
---@param value any?
---@return RadixTreeNode
-----------------------------------------------------------------------------
function RadixTreeNode.new(prefix, value)
	return setmetatable({
		_prefix = prefix or "",
		_value = value,
		_children = HashMap.new(),
	}, RadixTreeNode)
end

-----------------------------------------------------------------------------
---Returns whether the node has no children.
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTreeNode:empty()
	return self._children:empty()
end

-----------------------------------------------------------------------------
---String representation of radix tree node
---
---@return string
-----------------------------------------------------------------------------
function RadixTreeNode:__tostring()
	return string.format("{ prefix = '%s', value = %s, children = %s }", self._prefix, tostring(self._value), self._children)
end

---@class RadixTree
---
---@field private _root RadixTreeNode Node to start all actions
---@field private _len number Number of words in the trie
---@field private _caseSensitive boolean If should consider word case or not. Default: true
local RadixTree = {}
RadixTree.__index = RadixTree

-----------------------------------------------------------------------------
---Creates a new instance of the radix tree.
---
---@param caseSensitive boolean?
---@return RadixTree
-----------------------------------------------------------------------------
function RadixTree.new(caseSensitive)
	return setmetatable({
		_root = RadixTreeNode.new(""),
		_len = 0,
		_caseSensitive = caseSensitive == nil or caseSensitive,
	}, RadixTree)
end

-----------------------------------------------------------------------------
---Helper to get common prefix length
---
---@param s1 string
---@param s2 string
---@return number
-----------------------------------------------------------------------------
local function getCommonPrefixLen(s1, s2)
	local len = 0
	local minLen = math.min(#s1, #s2)
	for i = 1, minLen do
		if s1:sub(i, i) ~= s2:sub(i, i) then
			break
		end
		len = i
	end
	return len
end

-----------------------------------------------------------------------------
---Checks if the word exists in this trie
---
---@param  prefix string Prefix to be looked up
---@param  exact boolean Whether is an exact match (true) or prefix match (false). Defaults false.
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTree:contains(prefix, exact)
	assert(type(prefix) == "string", "Prefix should be a string")
	exact = exact or false

	if not self._caseSensitive then
		prefix = prefix:lower()
	end

	local node, remP, remNode = self:_lookup(prefix)
	if node == nil or #remP > 0 then
		return false
	end

	if exact then
		return #remNode == 0 and node._value ~= nil
	else
		return true
	end
end

-----------------------------------------------------------------------------
---Returns whether the trie is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTree:empty()
	return self._len == 0
end

-----------------------------------------------------------------------------
---Finds all values given a prefix.
---
---@param  prefix string Prefix to be looked up
---@param  exact boolean Whether is an exact match (true) or prefix match (false). Defaults false.
---
---@return Array<any>
-----------------------------------------------------------------------------
function RadixTree:find(prefix, exact)
	assert(type(prefix) == "string", "Prefix should be a string")
	exact = exact or false

	if not self._caseSensitive then
		prefix = prefix:lower()
	end

	local results = Array.new()
	local node, remP, remNode = self:_lookup(prefix)

	if node == nil or #remP > 0 then
		return results
	end

	if exact then
		if #remNode == 0 and node._value ~= nil then
			results:insert(node._value)
		end
	else
		local next = self:_traverse(node)
		local _, val = next()
		while val ~= nil do
			results:insert(val)
			_, val = next()
		end
	end

	return results
end

-----------------------------------------------------------------------------
---Adds a word to the trie.
---
---@param  key string
---@param  value any
---@param  overwrite boolean?
-----------------------------------------------------------------------------
function RadixTree:insert(key, value, overwrite)
	assert(type(key) == "string", "Key should be a string")
	assert(#key > 0, "Key should not be empty")
	assert(value ~= nil, "Value should not be nil")

	if overwrite == nil then
		overwrite = true
	end

	if not self._caseSensitive then
		key = key:lower()
	end

	local function _insert(node, k, v)
		local firstChar = k:sub(1, 1)
		local child = node._children:get(firstChar)

		if not child then
			node._children:put(firstChar, RadixTreeNode.new(k, v))
			self._len = self._len + 1
			return
		end

		local commonLen = getCommonPrefixLen(k, child._prefix)

		if commonLen == #child._prefix then
			if commonLen == #k then
				-- Exact match
				if child._value == nil then
					self._len = self._len + 1
				elseif not overwrite then
					return child._value
				end
				local oldVal = child._value
				child._value = v
				return oldVal
			else
				-- Recurse
				return _insert(child, k:sub(commonLen + 1), v)
			end
		else
			-- Split node
			local common = k:sub(1, commonLen)
			local childSuffix = child._prefix:sub(commonLen + 1)
			local kSuffix = k:sub(commonLen + 1)

			local splitNode = RadixTreeNode.new(common)
			node._children:put(firstChar, splitNode)

			child._prefix = childSuffix
			splitNode._children:put(childSuffix:sub(1, 1), child)

			if kSuffix == "" then
				splitNode._value = v
				self._len = self._len + 1
			else
				splitNode._children:put(kSuffix:sub(1, 1), RadixTreeNode.new(kSuffix, v))
				self._len = self._len + 1
			end
		end
	end

	return _insert(self._root, key, value)
end

-----------------------------------------------------------------------------
---Removes a word or prefix
---
---@param  prefix string Prefix to be removed
---@param  exact boolean Match exactly (true) or by prefix (false). Defaults false.
-----------------------------------------------------------------------------
function RadixTree:remove(prefix, exact)
	assert(type(prefix) == "string", "Prefix should be a string")
	exact = exact or false

	if not self._caseSensitive then
		prefix = prefix:lower()
	end

	local function _delete(node, p, ex)
		if #p == 0 then
			if ex then
				if node._value ~= nil then
					node._value = nil
					self._len = self._len - 1
					return true -- Might need merging or deletion
				end
				return false
			else
				-- Prefix removal: count how many words are being removed
				local count = 0
				local next = self:_traverse(node)
				local _, val = next()
				while val ~= nil do
					count = count + 1
					_, val = next()
				end
				self._len = self._len - count
				return true -- Node and all children should be gone
			end
		end

		local firstChar = p:sub(1, 1)
		local child = node._children:get(firstChar)
		if not child then
			return false
		end

		local commonLen = getCommonPrefixLen(p, child._prefix)
		if commonLen < #child._prefix then
			if not ex and commonLen == #p then
				-- p is a prefix of child._prefix, and we are not doing exact match
				-- So we remove this entire child branch
				local count = 0
				local next = self:_traverse(child)
				local _, val = next()
				while val ~= nil do
					count = count + 1
					_, val = next()
				end
				self._len = self._len - count
				node._children:remove(firstChar)
				return true
			end
			return false -- Not a full match of the edge
		end

		-- commonLen == #child._prefix
		local deleted = _delete(child, p:sub(commonLen + 1), ex)
		if deleted then
			if child._value == nil and child:empty() then
				node._children:remove(firstChar)
			elseif child._value == nil then
				-- Try merging child with its only grandchild
				local count = 0
				local onlyGrandChild = nil
				for _, gc in pairs(child._children) do
					count = count + 1
					onlyGrandChild = gc
					if count > 1 then
						break
					end
				end
				if count == 1 then
					child._prefix = child._prefix .. onlyGrandChild._prefix
					child._value = onlyGrandChild._value
					child._children = onlyGrandChild._children
				end
			end
			return true
		end
		return deleted
	end

	_delete(self._root, prefix, exact)
end

-----------------------------------------------------------------------------
---Finds node that matches the prefix
---
---@param  prefix string Prefix to lookup
---
---@return RadixTreeNode? Node that matches (might be partially)
---@return string Remaining part of the prefix that didn't match an edge
---@private
-----------------------------------------------------------------------------
function RadixTree:_lookup(prefix)
	local cur = self._root
	local p = prefix

	while #p > 0 do
		local firstChar = p:sub(1, 1)
		local child = cur._children:get(firstChar)
		if not child then
			return nil, p, ""
		end

		local commonLen = getCommonPrefixLen(p, child._prefix)
		if commonLen == #child._prefix then
			cur = child
			p = p:sub(commonLen + 1)
		else
			return child, p:sub(commonLen + 1), child._prefix:sub(commonLen + 1)
		end
	end

	return cur, "", ""
end

-----------------------------------------------------------------------------
---Finds all values from a given node
---
---@param  node RadixTreeNode? Node to start from
---
---@return Iterator<number, any> All values found
-----------------------------------------------------------------------------
function RadixTree:_traverse(node)
	node = node or self._root

	local index = 0
	local visit = Stack.new()
	visit:push(node)

	return function()
		while not visit:empty() do
			local cur = visit:pop()

			for _, child in pairs(cur._children) do
				visit:push(child)
			end

			if cur._value ~= nil then
				index = index + 1
				return index, cur._value
			end
		end
	end
end

-----------------------------------------------------------------------------
---Inserts all strings into this trie.
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return RadixTree
-----------------------------------------------------------------------------
function RadixTree:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "Should be a table")

		for _, item in pairs(iterable) do
			if type(item) == "string" then
				self:insert(item, item)
			end
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Returns the number of words in the trie.
---
---@return number
---@private
-----------------------------------------------------------------------------
function RadixTree:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through every word in this RadixTree
---
---@return Iterator<number, any>, RadixTree, nil
-----------------------------------------------------------------------------
function RadixTree:__pairs()
	return self:_traverse(self._root), self, nil
end

-----------------------------------------------------------------------------
---String representation of this trie
---
---@return string
-----------------------------------------------------------------------------
function RadixTree:__tostring()
	return tostring(self._root)
end

return RadixTree
