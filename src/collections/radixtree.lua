local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")
local Stack = require("ff.collections.stack")

---@class RadixTreeNode
---
---@field private _word     string? Stores the full word when it is the final node
---@field private _children HashMap<string, RadixTreeNode> Maps child nodes by prefix char
local RadixTreeNode = {}
RadixTreeNode.__index = RadixTreeNode

-----------------------------------------------------------------------------
---Creates a new instance of the trie.
---
---@return RadixTreeNode
-----------------------------------------------------------------------------
function RadixTreeNode.new()
	return setmetatable({ _word = nil, _children = HashMap.new() }, RadixTreeNode)
end

-----------------------------------------------------------------------------
---Adds a letter to the node
---
---@param  letter string
---
---@return RadixTreeNode
-----------------------------------------------------------------------------
function RadixTreeNode:add(letter)
	return self._children:compute(letter, RadixTreeNode.new)
end

-----------------------------------------------------------------------------
---Returns whether the node is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTreeNode:empty()
	return self._children:empty()
end

-----------------------------------------------------------------------------
---Look up letter in this node
---
---@param  letter string
---
---@return RadixTreeNode?
-----------------------------------------------------------------------------
function RadixTreeNode:get(letter)
	return self._children:get(letter)
end

-----------------------------------------------------------------------------
---Remove child mapped to the letter
---
---@param  letter string
-----------------------------------------------------------------------------
function RadixTreeNode:remove(letter)
	self._children:remove(letter)
end

-----------------------------------------------------------------------------
---String representation of trie node
---
---@return string
-----------------------------------------------------------------------------
function RadixTreeNode:__tostring()
	return string.format("{ word = '%s', children = %s }", self._word, self._children)
end

function nodefactory() end

local Match = {}
Match.EXACT = 1

---@class RadixTree
---
---@field private _root RadixTreeNode Node to start all actions
---@field private _len number Number of words in the trie
---@field private _caseSensitive boolean If should consider word case or not. Default: true
local RadixTree = {}
RadixTree.__index = RadixTree

-----------------------------------------------------------------------------
---Creates a new instance of the trie.
---
---@return RadixTree
-----------------------------------------------------------------------------
function RadixTree.new(caseSensitive)
	return setmetatable({
		_root = nodefactory("", nil, {}, true),
		_len = 0,
		_caseSensitive = caseSensitive == nil or caseSensitive,
	}, RadixTree)
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
	exact = exact or false

	local node = self:_lookup(prefix)
	if node == nil then
		return false
	end

	return not exact or node._word ~= nil
end

-----------------------------------------------------------------------------
---Returns whether the trie is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTree:empty()
	return self._root:empty()
end

-----------------------------------------------------------------------------
---Finds all words given a prefix.
---
---@param  prefix string Prefix to be looked up
---@param  exact boolean Whether is an exact match (true) or prefix match (false). Defaults false.
---
---@return Array<string>
-----------------------------------------------------------------------------
function RadixTree:find(prefix, exact)
	exact = exact or false

	local words = Array.new()
	local node = self:_lookup(prefix)
	if node == nil then
		return words
	end

	if exact and node._word ~= nil then
		words:insert(node._word)
	else
		local next = self:_traverse(node)
		local _, word = next()
		while word ~= nil do
			words:insert(word)
			_, word = next()
		end
	end
	return words
end

-----------------------------------------------------------------------------
---Adds a word to the trie.
---
---@param  key string
---@param  value any
-----------------------------------------------------------------------------
function RadixTree:insert(key, value, overwrite)
	assert(type(key) == "string", "Key should be a string")
	assert(#key > 0, "Key should not be empty")
	assert(value ~= nil, "Value should not be nil")

	if overwrite == nil then
		overwrite = true
	end
	assert(type(overwrite) == "boolean", "Overwrite should be boolean")

	local matches = self:_search(key)

	if matches.type == Match.EXACT then
		local currentValue = matches.node.value
		if not overwrite and currentValue ~= nil then
			return matches.node.value
		end

		local newNode = nodefactory(matches.node.incoming, value, matches.node.outgoing, false)
		matches.parent.updateOutgoing(newNode)

		return currentValue
	elseif matches.type == Match.PREFIX then
		local keyCharsFromStartOfNodeFound =
			key.subSequence(matches.charsMatched - matches.charsMatchedInNodeFound, #key)
	end
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

	self:_delete(self._root, prefix, exact, 1)
end

-----------------------------------------------------------------------------
---Recursively delete all words and empty nodes related to the prefix.
---
---@param node RadixTreeNode Current node, should be root at the start
---@param prefix string Prefix to be removed
---@param exact boolean Match exactly (true) or by prefix (false)
---@param index number Index of the current letter in the prefix
---
---@return boolean If the current node should be deleted afterwards.
---
---@private
-----------------------------------------------------------------------------
function RadixTree:_delete(node, prefix, exact, index)
	if index > #prefix then
		if exact and node._word == nil then
			return false
		end

		if exact then
			node._word = nil

			self._len = self._len - 1

			return node:empty()
		else
			local next = self:_traverse(node)

			local _, word = next()
			while word ~= nil do
				_, word = next()
				self._len = self._len - 1
			end

			return true
		end
	end

	local letter = prefix:sub(index, index)
	local child = node:get(letter)

	if child == nil then
		return false
	end

	local delete = self:_delete(child, prefix, exact, index + 1)
	if delete then
		node:remove(letter)

		return node._word == nil and node:empty()
	end
	return false
end

-----------------------------------------------------------------------------
---Finds node that matches the prefix
---
---@param  prefix string Prefix to lookup
---
---@return RadixTreeNode? Node that fully matches the prefix
-----------------------------------------------------------------------------
function RadixTree:_lookup(prefix)
	assert(type(prefix) == "string", "Prefix should be a string")

	if not self._caseSensitive then
		prefix = prefix:lower()
	end

	local cur = self._root
	for letter in prefix:gmatch(".") do
		cur = cur:get(letter)
		if cur == nil then
			return nil
		end
	end

	return cur
end

-----------------------------------------------------------------------------
---Finds all words from a given node
---
---@param  node RadixTreeNode? Node to start from
---
---@return Iterator<number, string> All words found
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

			if cur._word ~= nil then
				index = index + 1
				return index, cur._word
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
				self:insert(item)
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
---@return Iterator<number, string>, RadixTree, nil
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
