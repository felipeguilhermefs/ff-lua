local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")
local Stack = require("ff.collections.stack")

------------------------------
-- Cache function references
------------------------------

-- String
local sfmt = string.format

-- Table
local tconcat = table.concat
local tinsert = table.insert
local tsort = table.sort

-- General
local assert = assert
local getmetatable = getmetatable
local pairs = pairs
local setmetatable = setmetatable
local tostring = tostring
local type = type

--------------------------------------------------------------------------------------
---@class (private) TrieNode
---@field _word     string?                   Stores the full word when it is the final node.
---@field _children HashMap<string, TrieNode> Maps child nodes by prefix char.
--------------------------------------------------------------------------------------
local TrieNode = {}
TrieNode.__index = TrieNode

-----------------------------------------------------------------------------
---Creates a new instance of TrieNode.
---
---@return TrieNode
-----------------------------------------------------------------------------
function TrieNode.new()
	return setmetatable({
		_word = nil,
		_children = HashMap.new(),
	}, TrieNode)
end

-----------------------------------------------------------------------------
---Adds a child node for the given letter if not already present.
---
---@param  letter string Letter to add.
---
---@return TrieNode      Existing or newly created child node.
-----------------------------------------------------------------------------
function TrieNode:add(letter)
	return self._children:compute(letter, TrieNode.new) -- TODO: should be __newindex
end

-----------------------------------------------------------------------------
---Returns whether the node has no children.
---
---@return boolean
-----------------------------------------------------------------------------
function TrieNode:empty()
	return self._children:empty()
end

-----------------------------------------------------------------------------
---Look up child node mapped to the letter.
---
---@param  letter string
---
---@return TrieNode?
-----------------------------------------------------------------------------
function TrieNode:get(letter)
	return self._children[letter] --TODO: should be __index
end

-----------------------------------------------------------------------------
---Remove child node mapped to the letter.
---
---@param  letter string
-----------------------------------------------------------------------------
function TrieNode:remove(letter)
	self._children:remove(letter)
end

-----------------------------------------------------------------------------
---String representation of trie node.
---
---@return string
-----------------------------------------------------------------------------
function TrieNode:__tostring()
	return sfmt("{ word = %s, children = %s }", tostring(self._word), tostring(self._children))
end

--------------------------------------------------------------------------------------
---@class Trie
---@field private _root          TrieNode Node to start all actions.
---@field private _len           number   Number of words in the trie.
---@field private _caseSensitive boolean  If should consider word case or not. Default: true.
--------------------------------------------------------------------------------------
local Trie = {}
Trie.__index = Trie

-----------------------------------------------------------------------------
---Checks if it is a Trie instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function Trie.isTrie(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == Trie
end

-----------------------------------------------------------------------------
---Creates a new instance of the trie.
---
---@param  iterable?      table<any, any> Optional table to initialize the
---					  trie from.
---@param  caseSensitive? boolean         If should consider word case or not.
---                                       Defaults to `true`.
---
---@return Trie
-----------------------------------------------------------------------------
function Trie.new(iterable, caseSensitive)
	if caseSensitive == nil then
		caseSensitive = true
	end

	assert(type(caseSensitive) == "boolean", "caseSensitive should be a boolean")

	return setmetatable({
		_root = TrieNode.new(),
		_len = 0,
		_caseSensitive = caseSensitive,
	}, Trie) .. iterable
end

-----------------------------------------------------------------------------
---Empties the trie.
-----------------------------------------------------------------------------
function Trie:clear()
	self._root = TrieNode.new()
	self._len = 0
end

-----------------------------------------------------------------------------
---Checks if the word or prefix exists in this trie.
---
---@param  prefix string   Prefix or word to be looked up.
---@param  exact? boolean  Whether is an exact match (true) or prefix match (false).
---                        Defaults to `false`.
---
---@return boolean
-----------------------------------------------------------------------------
function Trie:contains(prefix, exact)
	assert(type(prefix) == "string", "prefix should be a string")

	exact = exact or false

	if self._len == 0 then
		return false
	end

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
	return self._len == 0
end

-----------------------------------------------------------------------------
---Finds all words given a prefix.
---
---@param  prefix? string  Prefix to be looked up. Defaults to `""`.
---@param  exact?  boolean Whether is an exact match (true) or prefix match (false).
---                       Defaults to `false`.
---
---@return Array<string>
-----------------------------------------------------------------------------
function Trie:find(prefix, exact)
	prefix = prefix or ""
	assert(type(prefix) == "string", "prefix should be a string")
	exact = exact or false
	assert(type(exact) == "boolean", "exact should be a boolean")

	local words = Array.new()
	if self._len == 0 then
		return words
	end

	local node = self:_lookup(prefix)
	if node == nil then
		return words
	end

	if exact then
		if node._word ~= nil then
			words[#words + 1] = node._word
		end
		return words
	end

	for _, word in self:_traverse(node) do
		words[#words + 1] = word
	end

	return words
end

-----------------------------------------------------------------------------
---Adds a word to the trie.
---
---@param  word string Word to add.
---
---@return boolean     `true` if word was newly inserted, `false` if already present.
-----------------------------------------------------------------------------
function Trie:insert(word)
	assert(type(word) == "string", "word should be a string")
	assert(#word > 0, "word should not be an empty string")

	local lookupWord = word
	if not self._caseSensitive then
		lookupWord = word:lower()
		word = lookupWord
	end

	local cur = self._root
	for letter in lookupWord:gmatch(".") do
		cur = cur:add(letter)
	end

	if cur._word == nil then
		cur._word = word
		self._len = self._len + 1
		return true
	end

	return false
end

-----------------------------------------------------------------------------
---Removes a word or prefix from the trie.
---
---@param  prefix string   Prefix or word to be removed.
---@param  exact? boolean  Match exactly (true) or by prefix (false). Defaults to `false`.
---
---@return boolean        `true` if any word was removed, `false` otherwise.
-----------------------------------------------------------------------------
function Trie:remove(prefix, exact)
	assert(type(prefix) == "string", "prefix should be a string")
	assert(#prefix > 0, "prefix should not be an empty string")

	exact = exact or false
	assert(type(exact) == "boolean", "exact should be a boolean")

	if self._len == 0 then
		return false
	end

	if not self._caseSensitive then
		prefix = prefix:lower()
	end

	local initialLen = self._len
	self:_delete(self._root, prefix, exact, 1)
	return self._len < initialLen
end

-----------------------------------------------------------------------------
---Recursively delete all words and empty nodes related to the prefix.
---
---@param  node   TrieNode Current node, should be root at the start.
---@param  prefix string   Prefix to be removed.
---@param  exact  boolean  Match exactly (true) or by prefix (false).
---@param  index  number   Index of the current letter in the prefix.
---
---@return boolean         `true` if the current node should be deleted afterwards.
---
---@private
-----------------------------------------------------------------------------
function Trie:_delete(node, prefix, exact, index)
	if index > #prefix then
		if exact then
			if node._word == nil then
				return false
			end

			node._word = nil
			self._len = self._len - 1
			return node:empty()
		else
			for _ in self:_traverse(node) do
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
---Finds node that matches the prefix.
---
---@param  prefix string Prefix to lookup.
---
---@return TrieNode?     Node that fully matches the prefix, or `nil`.
---
---@private
-----------------------------------------------------------------------------
function Trie:_lookup(prefix)
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
---Finds all words from a given node.
---
---@param  node TrieNode Node to start from.
---
---@return fun(): number?, string? All words found.
---
---@private
-----------------------------------------------------------------------------
function Trie:_traverse(node)
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
---Concatenate a given iterable of strings into this Trie (in-place modification).
---
---@param  iterable? table<any, any> Any table that can be iterated over.
---                                  Defaults to an empty table if `nil`.
---
---@return Trie                      Returns this Trie instance.
-----------------------------------------------------------------------------
function Trie:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, item in pairs(iterable) do
			self:insert(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when both are Tries with the same size,
---case sensitivity, and containing the same words.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function Trie:__eq(other)
	if not Trie.isTrie(other) then
		return false
	end

	if self._len ~= other._len then
		return false
	end

	if self._caseSensitive ~= other._caseSensitive then
		return false
	end

	for _, word in pairs(self) do
		if not other:contains(word, true) then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Returns the number of words in the trie.
---
---@return number
-----------------------------------------------------------------------------
function Trie:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through every word in this Trie.
---
---@return fun(): number?, string?, Trie, nil
-----------------------------------------------------------------------------
function Trie:__pairs()
	return self:_traverse(self._root), self, nil
end

-----------------------------------------------------------------------------
---String representation of this trie.
---
---@return string
-----------------------------------------------------------------------------
function Trie:__tostring()
	local words = {}
	for _, word in pairs(self) do
		tinsert(words, word)
	end
	tsort(words)
	return sfmt("{ %s }", tconcat(words, ", "))
end

return Trie
