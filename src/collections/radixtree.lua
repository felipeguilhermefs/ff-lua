local Array = require("ff.collections.array")
local HashMap = require("ff.collections.hashmap")
local Stack = require("ff.collections.stack")

------------------------------
-- Cache function references
------------------------------

-- Math
local mmax = math.max

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

-----------------------------------------------------------------------------
---Calculates the length of the common prefix between two strings.
---
---@param  a string
---@param  b string
---
---@return number Length of matching prefix.
-----------------------------------------------------------------------------
local function commonPrefixLength(a, b)
	local maxLen = mmax(#a, #b)
	local i = 1
	while i <= maxLen and a:byte(i) == b:byte(i) do
		i = i + 1
	end
	return i - 1
end

--------------------------------------------------------------------------------------
---@class (private) RadixNode
---@field _prefix   string                     Edge label from parent to this node.
---@field _word     string?                    Stores full word when this node terminates a key.
---@field _children HashMap<number, RadixNode> Maps child nodes by the first character of their edge prefix.
--------------------------------------------------------------------------------------
local RadixNode = {}
RadixNode.__index = RadixNode

-----------------------------------------------------------------------------
---Creates a new instance of RadixNode.
---
---@param  prefix? string Edge label leading into this node (defaults to `""`).
---@param  word?   string Terminating word stored at this node, if any.
---
---@return RadixNode
-----------------------------------------------------------------------------
function RadixNode.new(prefix, word)
	return setmetatable({
		_prefix = prefix or "",
		_word = word,
		_children = HashMap.new(),
	}, RadixNode)
end

-----------------------------------------------------------------------------
---Returns the any child node.
---Used during tree compression when collapsing single-child non-word nodes.
---
---@return RadixNode?
-----------------------------------------------------------------------------
function RadixNode:any()
	for _, child in pairs(self._children) do
		return child
	end
end

-----------------------------------------------------------------------------
---Look up child node mapped by prefix.
---
---@param  prefix string Prefix to find an associate edge.
---
---@return RadixNode?
-----------------------------------------------------------------------------
function RadixNode:get(prefix)
	return self._children[prefix:byte(1)]
end

-----------------------------------------------------------------------------
---Add a child node mapped by the first character of its edge prefix.
---
---@param  node RadixNode node to associate
---
-----------------------------------------------------------------------------
function RadixNode:put(node)
	self._children[node._prefix:byte(1)] = node
end

-----------------------------------------------------------------------------
---Remove child node mapped by prefix.
---
---@param  prefix string Prefix associated to an edge.
-----------------------------------------------------------------------------
function RadixNode:remove(prefix)
	self._children:remove(prefix:byte(1))
end

-----------------------------------------------------------------------------
---Returns the number of children nodes in this node.
---
---@return number
-----------------------------------------------------------------------------
function RadixNode:__len()
	return #self._children
end

-----------------------------------------------------------------------------
---Iterates through the children in an undefined order.
---
---@return fun(): string?, RadixNode? Generator
-----------------------------------------------------------------------------
function RadixNode:__pairs()
	return pairs(self._children)
end
-----------------------------------------------------------------------------
---String representation of radix node.
---
---@return string
-----------------------------------------------------------------------------
function RadixNode:__tostring()
	return sfmt(
		"{ prefix = %s, word = %s, children = %s }",
		tostring(self._prefix),
		tostring(self._word),
		tostring(self._children)
	)
end

--------------------------------------------------------------------------------------
---@class RadixTree
---@field private _root          RadixNode Root node of the radix tree.
---@field private _len           number    Number of unique words stored in the tree.
---@field private _caseSensitive boolean   Whether word matching is case sensitive. Default: true.
--------------------------------------------------------------------------------------
local RadixTree = {}
RadixTree.__index = RadixTree

-----------------------------------------------------------------------------
---Checks if a given value is a RadixTree instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTree.isRadixTree(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == RadixTree
end

-----------------------------------------------------------------------------
---Creates a new instance of the RadixTree.
---
---Accepts an optional iterable of strings to initialize the tree with.
---
---@param  iterable?      table<any, any> Optional table to initialize from.
---@param  caseSensitive? boolean         Whether matching is case sensitive.
---                                       Defaults to `true`.
---
---@return RadixTree
-----------------------------------------------------------------------------
function RadixTree.new(iterable, caseSensitive)
	if caseSensitive == nil then
		caseSensitive = true
	end

	assert(type(caseSensitive) == "boolean", "caseSensitive should be a boolean")

	return setmetatable({
		_root = RadixNode.new(),
		_len = 0,
		_caseSensitive = caseSensitive,
	}, RadixTree) .. iterable
end

-----------------------------------------------------------------------------
---Empties the radix tree.
-----------------------------------------------------------------------------
function RadixTree:clear()
	self._root = RadixNode.new()
	self._len = 0
end

-----------------------------------------------------------------------------
---Checks if the word or prefix exists in this radix tree.
---
---@param  prefix string   Prefix or word to be looked up.
---@param  exact? boolean  Whether is an exact match (true) or prefix match (false).
---                        Defaults to `false`.
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTree:contains(prefix, exact)
	assert(type(prefix) == "string", "prefix should be a string")

	exact = exact or false
	assert(type(exact) == "boolean", "exact should be a boolean")

	if self._len == 0 then
		return false
	end

	local node, isExactNode = self:_lookup(prefix)
	if node == nil then
		return false
	end

	if exact then
		return isExactNode and node._word ~= nil
	end

	return true
end

-----------------------------------------------------------------------------
---Returns whether the radix tree is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTree:empty()
	return self._len == 0
end

-----------------------------------------------------------------------------
---Finds all words in the radix tree starting with the given prefix.
---
---@param  prefix  string  Prefix to be looked up.
---@param  exact?  boolean Whether is an exact match (true) or prefix match (false).
---                        Defaults to `false`.
---
---@return Array<string>   Array containing all matching words.
-----------------------------------------------------------------------------
function RadixTree:find(prefix, exact)
	assert(type(prefix) == "string", "prefix should be a string")

	exact = exact or false
	assert(type(exact) == "boolean", "exact should be a boolean")

	local words = Array.new()
	if self._len == 0 then
		return words
	end

	local node, isExactNode = self:_lookup(prefix)
	if node == nil then
		return words
	end

	if exact then
		if isExactNode and node._word ~= nil then
			words:insert(node._word)
		end
		return words
	end

	for _, word in self:_traverse(node) do
		words:insert(word)
	end

	return words
end

-----------------------------------------------------------------------------
---Adds a word to the radix tree.
---
---@param  word string Word to add.
---
---@return boolean     `true` if word was absent, `false` if present.
-----------------------------------------------------------------------------
function RadixTree:insert(word)
	assert(type(word) == "string", "word should be a string")
	assert(#word > 0, "word should not be an empty string")

	local lookupWord = word
	if not self._caseSensitive then
		lookupWord = word:lower()
	end

	local cur = self._root
	local remaining = lookupWord

	while true do
		local child = cur:get(remaining)

		-- Case 1: No edge with common prefix
		if child == nil then
			cur:put(RadixNode.new(remaining, word))
			self._len = self._len + 1
			return true
		end

		local commonLen = commonPrefixLength(remaining, child._prefix)

		-- Case 2: Common prefix divergences midway
		if commonLen < #child._prefix then
			-- Create a node holding the common prefix and replace the edge
			local commonNode = RadixNode.new(child._prefix:sub(1, commonLen), nil)
			cur:put(commonNode)

			-- Updates previous child node with remaining prefix and reattach under new common node
			child._prefix = child._prefix:sub(commonLen + 1)
			commonNode:put(child)

			if commonLen == #remaining then
				-- Incoming word terminates exactly at the split point
				commonNode._word = word
				self._len = self._len + 1
				return true
			else
				-- Incoming word has remaining characters, attach as a new child of common node
				local newNode = RadixNode.new(remaining:sub(commonLen + 1), word)
				commonNode:put(newNode)
				self._len = self._len + 1
				return true
			end
		end

		-- Case 3: Common prefix matches
		if commonLen == #remaining then
			-- Word terminates at this existing node
			if child._word == nil then
				child._word = word
				self._len = self._len + 1
				return true
			end
			return false
		end

		-- Case 4: Word continues past child edge
		cur = child
		remaining = remaining:sub(commonLen + 1)
	end
end

-----------------------------------------------------------------------------
---Removes a word or prefix from the radix tree.
---
---@param  prefix string   Prefix or word to be removed.
---@param  exact? boolean  Match exactly (true) or by prefix (false).
---                        Defaults to `false`.
---
---@return number          Number of words deleted.
-----------------------------------------------------------------------------
function RadixTree:remove(prefix, exact)
	assert(type(prefix) == "string", "prefix should be a string")

	exact = exact or false
	assert(type(exact) == "boolean", "exact should be a boolean")

	if self._len == 0 or #prefix < 1 then
		return 0
	end

	if not self._caseSensitive then
		prefix = prefix:lower()
	end

	local deletedCount = self:_delete(self._root, prefix, exact)
	self._len = self._len - deletedCount
	return deletedCount
end

-----------------------------------------------------------------------------
---Recursively deletes words and compresses edges.
---
---@param  node   RadixNode Current node being inspected.
---@param  prefix string    Prefix or word to be removed.
---@param  exact  boolean   Match exactly (true) or by prefix (false).
---
---@return number           Number of words deleted.
---
---@private
-----------------------------------------------------------------------------
function RadixTree:_delete(node, prefix, exact)
	local child = node:get(prefix)
	if child == nil then
		return 0
	end

	local commonLen = commonPrefixLength(prefix, child._prefix)
	local deletedCount = 0

	if commonLen < #prefix then
		if commonLen < #child._prefix then
			return 0
		end
		deletedCount = self:_delete(child, prefix:sub(commonLen + 1), exact)
	else
		-- prefix fully matched against child._prefix
		if exact then
			if commonLen < #child._prefix then
				return 0
			end
			if child._word == nil then
				return 0
			end
			child._word = nil
			deletedCount = 1
		else
			-- Delete entire subtree under child
			for _ in self:_traverse(child) do
				deletedCount = deletedCount + 1
			end
			node:remove(prefix)
			return deletedCount
		end
	end

	-- Path compression: clean up or merge single-child non-word nodes
	if deletedCount > 0 and child._word == nil then
		if #child == 0 then
			node:remove(prefix)
		elseif #child == 1 then
			local grand = assert(child:any())
			grand._prefix = child._prefix .. grand._prefix
			node:put(grand)
		end
	end

	return deletedCount
end

-----------------------------------------------------------------------------
---Finds the node matching the given prefix.
---
---@param  prefix string Prefix to lookup.
---
---@return RadixNode?    Node that matches or contains the prefix, or `nil`.
---@return boolean       `true` if the prefix matched an exact node boundary.
---
---@private
-----------------------------------------------------------------------------
function RadixTree:_lookup(prefix)
	if #prefix < 1 then
		return nil, false
	end

	if not self._caseSensitive then
		prefix = prefix:lower()
	end

	local cur = self._root
	local remaining = prefix

	while true do
		local child = cur:get(remaining)
		if child == nil then
			return nil, false
		end

		local commonLen = commonPrefixLength(remaining, child._prefix)
		if commonLen == #remaining then
			-- prefix matched within or at child._prefix
			local isExactNode = (commonLen == #child._prefix)
			return child, isExactNode
		end

		if commonLen == #child._prefix then
			-- child._prefix matched completely, continue into subtree
			cur = child
			remaining = remaining:sub(commonLen + 1)
		else
			return nil, false
		end
	end
end

-----------------------------------------------------------------------------
---Traverses and yields all words contained in the subtree rooted at `node`.
---
---@param  node RadixNode Node to start traversal from.
---
---@return fun(): number?, string? Iterator yielding 1-based index and word string.
---
---@private
-----------------------------------------------------------------------------
function RadixTree:_traverse(node)
	local index = 0
	local visit = Stack.new()
	visit:push(node)

	return function()
		while not visit:empty() do
			local cur = visit:pop()

			for _, child in pairs(cur) do
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
---Concatenate a given iterable of strings into this RadixTree (in-place modification).
---
---@param  iterable? table<any, any> Any table of strings to insert.
---                                  Defaults to no-op if `nil`.
---
---@return RadixTree                 Returns this RadixTree instance.
-----------------------------------------------------------------------------
function RadixTree:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, item in pairs(iterable) do
			self:insert(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when both are RadixTrees with the same size,
---case sensitivity, and containing the same words.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function RadixTree:__eq(other)
	if not RadixTree.isRadixTree(other) then
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
---Returns the number of words in the radix tree.
---
---@return number
-----------------------------------------------------------------------------
function RadixTree:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through every word in this RadixTree.
---
---@return fun(): number?, string?, RadixTree, nil
-----------------------------------------------------------------------------
function RadixTree:__pairs()
	return self:_traverse(self._root), self, nil
end

-----------------------------------------------------------------------------
---String representation of this radix tree in sorted alphabetical order.
---
---@return string
-----------------------------------------------------------------------------
function RadixTree:__tostring()
	local words = {}
	for _, word in pairs(self) do
		tinsert(words, word)
	end
	tsort(words)
	return sfmt("{ %s }", tconcat(words, ", "))
end

return RadixTree
