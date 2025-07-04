local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")
local Stack = require("ff.collections.stack")

---@class TrieNode
---
---@field private _word     string? Stores the full word when it is the final node
---@field private _children HashMap<string, TrieNode> Maps child nodes by prefix char
local TrieNode = {}
TrieNode.__index = TrieNode

-----------------------------------------------------------------------------
---Creates a new instance of the trie.
---
---@return TrieNode
-----------------------------------------------------------------------------
function TrieNode.new()
	return setmetatable({ _word = nil, _children = HashMap.new() }, TrieNode)
end

-----------------------------------------------------------------------------
---Adds a letter to the node
---
---@param  letter string
---
---@return TrieNode
-----------------------------------------------------------------------------
function TrieNode:add(letter)
	return self._children:compute(letter, TrieNode.new)
end

-----------------------------------------------------------------------------
---Returns whether the node is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function TrieNode:empty()
	return self._children:empty()
end

-----------------------------------------------------------------------------
---Look up letter in this node
---
---@param  letter string
---
---@return TrieNode?
-----------------------------------------------------------------------------
function TrieNode:get(letter)
	return self._children:get(letter)
end

-----------------------------------------------------------------------------
---Remove child mapped to the letter
---
---@param  letter string
-----------------------------------------------------------------------------
function TrieNode:remove(letter)
	self._children:remove(letter)
end

-----------------------------------------------------------------------------
---String representation of trie node
---
---@return string
-----------------------------------------------------------------------------
function TrieNode:__tostring()
	return string.format("{ word = '%s', children = %s }", self._word, self._children)
end

---@class Trie
---
---@field private _root TrieNode Node to start all actions
---@field private _len number Number of words in the trie
---@field private _caseSensitive boolean If should consider word case or not. Default: true
local Trie = {}
Trie.__index = Trie

-----------------------------------------------------------------------------
---Creates a new instance of the trie.
---
---@return Trie
-----------------------------------------------------------------------------
function Trie.new(caseSensitive)
	return setmetatable({
		_root = TrieNode.new(),
		_len = 0,
		_caseSensitive = caseSensitive == nil or caseSensitive,
	}, Trie)
end

-----------------------------------------------------------------------------
---Checks if the word exists in this trie
---
---@param  prefix string Prefix to be looked up
---@param  exact boolean Whether is an exact match (true) or prefix match (false). Defaults false.
---
---@return boolean
-----------------------------------------------------------------------------
function Trie:contains(prefix, exact)
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
function Trie:empty()
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
function Trie:find(prefix, exact)
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
---@param  word string
-----------------------------------------------------------------------------
function Trie:insert(word)
	assert(type(word) == "string", "Word should be a string")

	if not self._caseSensitive then
		word = word:lower()
	end

	local cur = self._root
	for letter in word:gmatch(".") do
		cur = cur:add(letter)
	end

	if cur._word == nil then
		cur._word = word
		self._len = self._len + 1
	end
end

-----------------------------------------------------------------------------
---Removes a word or prefix
---
---@param  prefix string Prefix to be removed
---@param  exact boolean Match exactly (true) or by prefix (false). Defaults false.
-----------------------------------------------------------------------------
function Trie:remove(prefix, exact)
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
---@param node TrieNode Current node, should be root at the start
---@param prefix string Prefix to be removed
---@param exact boolean Match exactly (true) or by prefix (false)
---@param index number Index of the current letter in the prefix
---
---@return boolean If the current node should be deleted afterwards.
---
---@private
-----------------------------------------------------------------------------
function Trie:_delete(node, prefix, exact, index)
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
---@return TrieNode? Node that fully matches the prefix
-----------------------------------------------------------------------------
function Trie:_lookup(prefix)
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
---@param  node TrieNode? Node to start from
---
---@return Iterator<number, string> All words found
-----------------------------------------------------------------------------
function Trie:_traverse(node)
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
---@return Trie
-----------------------------------------------------------------------------
function Trie:__concat(iterable)
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
function Trie:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through every word in this Trie
---
---@return Iterator<number, string>, Trie, nil
-----------------------------------------------------------------------------
function Trie:__pairs()
	return self:_traverse(self._root), self, nil
end

-----------------------------------------------------------------------------
---String representation of this trie
---
---@return string
-----------------------------------------------------------------------------
function Trie:__tostring()
	return tostring(self._root)
end

return Trie
