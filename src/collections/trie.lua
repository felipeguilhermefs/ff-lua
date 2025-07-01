local HashMap = require("ff.collections.hashmap")

---@class TrieNode
---
---@field private _word     boolean Marks if the node is a word
---@field private _children HashMap<string, TrieNode> Maps child nodes by prefix char
local TrieNode = {}
TrieNode.__index = TrieNode

-----------------------------------------------------------------------------
---Creates a new instance of the trie.
---
---@return TrieNode
-----------------------------------------------------------------------------
function TrieNode.new()
	return setmetatable({ _word = false, _children = HashMap.new() }, TrieNode)
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
---Look up letter in this node
---
---@param  letter string
---
---@return TrieNode?
-----------------------------------------------------------------------------
function TrieNode:get(letter)
	return self._children:get(letter)
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
---@param  word string Word to be looked up
---@param  prefix boolean Match just the prefix. Defaults false.
---
---@return boolean
-----------------------------------------------------------------------------
function Trie:contains(word, prefix)
	assert(type(word) == "string", "Word should be a string")
	prefix = prefix or false

	local cur = self._root
	for letter in word:gmatch(".") do
		cur = cur:get(letter)
		if cur == nil then
			return false
		end
	end

	return prefix or cur._word
end

-----------------------------------------------------------------------------
---Returns whether the trie is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Trie:empty()
	return #self == 0
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
	cur._word = true
	self._len = self._len + 1
end

-----------------------------------------------------------------------------
---Removes a word or prefix
---
---@param  word string Word or prefix to be removed
---@param  prefix boolean Match by prefix. Defaults false.
-----------------------------------------------------------------------------
function Trie:remove(word, prefix)
	assert(type(word) == "string", "Word should be a string")
	prefix = prefix or false

	self:_delete(self._root, word, prefix, 1)
end

function Trie:_delete(node, word, prefix, index)
	if index > #word then
		if not prefix and not node._word then
			return false
		end

		node._word = false

		return prefix or node._children:empty()
	end

	local letter = word:sub(index, index)
	local child = node._children:get(letter)

	if child == nil then
		return false
	end

	local delete = self:_delete(child, word, prefix, index + 1)
	if delete then
		node._children:remove(letter)

		return not node._word and node._children:empty()
	end
	return false
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
---Returns the number of words in the trie.
---
---@return number
---@private
-----------------------------------------------------------------------------
function Trie:__len()
	return self._len
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
