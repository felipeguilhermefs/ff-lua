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

---@class Trie
---
---@field private _root TrieNode Node to start all actions
---@field private _len number Number of words in the trie
local Trie = {}
Trie.__index = Trie

-----------------------------------------------------------------------------
---Creates a new instance of the trie.
---
---@return Trie
-----------------------------------------------------------------------------
function Trie.new()
	return setmetatable({ _root = TrieNode.new(), _len = 0 }, Trie)
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
	assert(type(prefix) == "string", "Prefix should be a string")
	exact = exact or false

	local cur = self._root
	for letter in prefix:gmatch(".") do
		cur = cur:get(letter)
		if cur == nil then
			return false
		end
	end

	return not exact or cur._word ~= nil
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
	assert(type(prefix) == "string", "Prefix should be a string")
	exact = exact or false

	local cur = self._root
	for letter in prefix:gmatch(".") do
		cur = cur:get(letter)
		if cur == nil then
			return Array.new()
		end
	end

	if exact and cur._word ~= nil then
		local words = Array.new()
		words:insert(cur._word)
		return words
	else
		return self:_traverse(cur)
	end
end

-----------------------------------------------------------------------------
---Adds a word to the trie.
---
---@param  word string
-----------------------------------------------------------------------------
function Trie:insert(word)
	assert(type(word) == "string", "Word should be a string")

	local cur = self._root
	for letter in word:gmatch(".") do
		cur = cur:add(letter)
	end
	cur._word = word
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

		node._word = nil

		return not exact or node:empty()
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
---Finds all words from a given node
---
---@param  node TrieNode? Node to start from
---
---@return Array<string> All words found
-----------------------------------------------------------------------------
function Trie:_traverse(node)
	local words = Array.new()
	if node == nil then
		return words
	end

	local visit = Stack.new()
	visit:push(node)
	while not visit:empty() do
		local cur = visit:pop()
		if cur._word ~= nil then
			words:insert(cur._word)
		end
		for _, child in pairs(cur._children) do
			visit:push(child)
		end
	end
	return words
end

-----------------------------------------------------------------------------
---Pushes all items in a given iterable.
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Stack
-----------------------------------------------------------------------------
function Trie:__concat(iterable)
	assert(false, "Not implemented")
	if iterable ~= nil then
		assert(type(iterable) == "table", "Should be a table")

		for _, item in pairs(iterable) do
			self:push(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Iterates through the stack in LIFO order. Same as:
---
---while not stack:empty() do
---   local item = stack:pop()
---end
---
---@return Iterator<1, any>, Stack<any>, nil
-----------------------------------------------------------------------------
function Trie:__pairs()
	assert(false, "Not implemented")
	return function()
		local item = self:pop()
		if item ~= nil then
			return 1, item
		end
	end, self, nil
end

-----------------------------------------------------------------------------
---String representation of this stack
---
---@return string
-----------------------------------------------------------------------------
-- function Trie:__tostring()
-- 	assert(false, "Not implemented")
-- 	return string.format("[ %s <- Top ]", table.concat(self._entries, ", "))
-- end

return Trie
