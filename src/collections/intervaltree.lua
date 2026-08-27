local Stack = require("ff.collections.stack")

------------------------------
-- Cache function references
------------------------------

-- String
local sfmt = string.format

-- Table
local tconcat = table.concat
local tinsert = table.insert

-- Math
local mmax = math.max
local mmin = math.min

-- General
local assert = assert
local getmetatable = getmetatable
local pairs = pairs
local setmetatable = setmetatable
local type = type

---@class (private) IntervalNode
---@field low   number        Lower boundary of this interval.
---@field high  number        Upper boundary of this interval.
---@field left  IntervalNode? Points to the left child node in the tree.
---@field right IntervalNode? Points to the right child node in the tree.
local IntervalNode = {}
IntervalNode.__index = IntervalNode

-----------------------------------------------------------------------------
---Creates a new instance of the node.
---
---@param  low   number
---@param  high  number
---@param  left  IntervalNode?
---@param  right IntervalNode?
---
---@return IntervalNode
-----------------------------------------------------------------------------
function IntervalNode.new(low, high, left, right)
	return setmetatable({
		low = low,
		high = high,
		left = left,
		right = right,
	}, IntervalNode)
end

--------------------------------------------------------------------------------------
---@class IntervalTree
---@field private _root IntervalNode? Root of the tree, if `nil` it is empty.
---@field private _len  number        Number of disjoint intervals stored in the tree.
--------------------------------------------------------------------------------------
local IntervalTree = {}
IntervalTree.__index = IntervalTree

-----------------------------------------------------------------------------
---Checks if it is an IntervalTree instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function IntervalTree.isIntervalTree(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == IntervalTree
end

-----------------------------------------------------------------------------
---Creates a new instance of the interval tree.
---
---Accepts an optional iterable of `{low, high}` pairs used to pre-populate
---the tree. Each entry must be a two-element table `{ low, high }`.
---
---@param  iterable? table<any, {[1]: number, [2]: number}>
---                            Optional table of `{low, high}` pairs.
---
---@return IntervalTree
-----------------------------------------------------------------------------
function IntervalTree.new(iterable)
	return setmetatable({
		_root = nil,
		_len = 0,
	}, IntervalTree) .. iterable
end

-----------------------------------------------------------------------------
---Empties the tree.
-----------------------------------------------------------------------------
function IntervalTree:clear()
	self._root = nil
	self._len = 0
end

-----------------------------------------------------------------------------
---Checks if the value is contained in any stored interval.
---
---@param  value number
---
---@return boolean
-----------------------------------------------------------------------------
function IntervalTree:contains(value)
	assert(type(value) == "number", "'value' should be a number")

	local cur = self._root
	while cur do
		if value >= cur.low and value <= cur.high then
			return true
		elseif value < cur.low then
			cur = cur.left
		else
			cur = cur.right
		end
	end
	return false
end

-----------------------------------------------------------------------------
---Returns whether the tree is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function IntervalTree:empty()
	return self._len == 0
end

-----------------------------------------------------------------------------
---Adds an interval to the tree. Overlapping or adjacent intervals already in
---the tree are merged into one unified interval before insertion, so the
---tree always stores a set of disjoint intervals.
---
---@param low  number lower boundary of the interval to insert
---@param high number upper boundary of the interval to insert
-----------------------------------------------------------------------------
function IntervalTree:insert(low, high)
	assert(type(low) == "number", "'low' should be a number")
	assert(type(high) == "number", "'high' should be a number")

	-- Ensure low is actually smaller than high
	if low > high then
		low, high = high, low
	end

	-- Remove intervals that overlap with the new one and union them
	while true do
		local overlap = self:_find(self._root, low, high)

		if overlap == nil then
			break
		end

		-- Union boundaries
		low = mmin(low, overlap.low)
		high = mmax(high, overlap.high)

		-- Remove overlapping node
		self._root = self:_delete(self._root, overlap.low)
	end

	-- Finally add the merged interval
	self._root = self:_insert(self._root, low, high)
end

-----------------------------------------------------------------------------
---Removes all stored intervals that overlap with [low, high].
---Returns the number of intervals removed.
---
---@param  low  number Lower boundary of the query interval.
---@param  high number Upper boundary of the query interval.
---
---@return number      Number of intervals removed (0 if none overlapped).
-----------------------------------------------------------------------------
function IntervalTree:remove(low, high)
	assert(type(low) == "number", "'low' should be a number")
	assert(type(high) == "number", "'high' should be a number")

	if low > high then
		low, high = high, low
	end

	local removed = 0
	while true do
		local overlap = self:_find(self._root, low, high)
		if overlap == nil then
			break
		end
		self._root = self:_delete(self._root, overlap.low)
		removed = removed + 1
	end

	return removed
end

-----------------------------------------------------------------------------
---Traverse the tree and remove the interval keyed by `low`.
---
---@param node  IntervalNode? The node where to start the traversal.
---@param low   number        Lower boundary of the interval to remove.
---
---@return IntervalNode?      New node at this position, or `nil` if empty.
---
---@private
-----------------------------------------------------------------------------
function IntervalTree:_delete(node, low)
	if node == nil then
		return nil
	end

	if low < node.low then
		node.left = self:_delete(node.left, low)
	elseif low > node.low then
		node.right = self:_delete(node.right, low)
	else
		-- Found the node to delete
		if node.left == nil then
			self._len = self._len - 1
			return node.right
		end

		if node.right == nil then
			self._len = self._len - 1
			return node.left
		end

		-- Two children: replace with in-order successor (smallest in right subtree)
		local successor = assert(self:_min(node.right))
		node.low = successor.low
		node.high = successor.high
		-- Delete successor from right subtree; _len is decremented inside that call
		node.right = self:_delete(node.right, successor.low)
	end

	return node
end

-----------------------------------------------------------------------------
---Finds any node whose interval overlaps with [low, high].
---
---@param node IntervalNode? The node where to start the traversal.
---@param low  number        Lower boundary of the query interval.
---@param high number        Upper boundary of the query interval.
---
---@return IntervalNode?     First overlapping node found, or `nil`.
---
---@private
-----------------------------------------------------------------------------
function IntervalTree:_find(node, low, high)
	if node == nil then
		return nil
	end

	if node.low <= high and node.high >= low then
		return node
	end

	if low < node.low then
		return self:_find(node.left, low, high) or self:_find(node.right, low, high)
	else
		return self:_find(node.right, low, high) or self:_find(node.left, low, high)
	end
end

-----------------------------------------------------------------------------
---Traverse the tree and insert the interval at the appropriate BST position.
---The public `insert` method guarantees no overlaps exist before calling this,
---so ordering by `low` alone is sufficient.
---
---@param node  IntervalNode? The node where to start the traversal.
---@param low   number        Lower boundary of the interval to insert.
---@param high  number        Upper boundary of the interval to insert.
---
---@return IntervalNode       The (possibly new) node at this position.
---
---@private
-----------------------------------------------------------------------------
function IntervalTree:_insert(node, low, high)
	if node == nil then
		self._len = self._len + 1
		return IntervalNode.new(low, high)
	end

	if low < node.low then
		node.left = self:_insert(node.left, low, high)
	else
		node.right = self:_insert(node.right, low, high)
	end

	return node
end

-----------------------------------------------------------------------------
---Finds and returns the minimum (leftmost) node in the subtree.
---
---@param node  IntervalNode? The node where to start the traversal.
---
---@return IntervalNode?      Leftmost node, or `nil` if subtree is empty.
---
---@private
-----------------------------------------------------------------------------
function IntervalTree:_min(node)
	local cur = node
	while cur ~= nil and cur.left do
		cur = cur.left
	end
	return cur
end

-----------------------------------------------------------------------------
---Concatenate a given iterable of `{low, high}` pairs into this IntervalTree
---(in-place modification). Each entry in the iterable must be a two-element
---table `{ low, high }`.
---
---@param  iterable? table<any, {[1]: number, [2]: number}>
---                            Entries to be inserted.
---                            Defaults to an empty table if `nil`.
---
---@return IntervalTree        Returns this IntervalTree instance.
-----------------------------------------------------------------------------
function IntervalTree:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, interval in pairs(iterable) do
			assert(type(interval) == "table", "each entry in iterable should be a {low, high} table")
			self:insert(interval[1], interval[2])
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: considers two IntervalTrees equal when they store the
---same number of intervals and every `low`/`high` pair matches.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function IntervalTree:__eq(other)
	if not IntervalTree.isIntervalTree(other) then
		return false
	end

	if self._len ~= other._len then
		return false
	end

	local its = pairs(self)
	local ito = pairs(other)

	while true do
		local ls, hs = its()
		local lo, ho = ito()

		if ls == nil and lo == nil then
			return true
		end

		if ls ~= lo or hs ~= ho then
			return false
		end
	end
end

-----------------------------------------------------------------------------
---Returns the number of disjoint intervals stored in the tree.
---
---@return number
-----------------------------------------------------------------------------
function IntervalTree:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through the interval tree in ascending order of `low` boundary.
---
---@return fun(): number?, number? Iterator yielding `low, high` per call.
-----------------------------------------------------------------------------
function IntervalTree:__pairs()
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
		return node.low, node.high
	end
end

-----------------------------------------------------------------------------
---String representation of this interval tree.
---
---@return string
-----------------------------------------------------------------------------
function IntervalTree:__tostring()
	local rep = {}
	for low, high in pairs(self) do
		tinsert(rep, sfmt("[%d, %d]", low, high))
	end
	return sfmt("{ %s }", tconcat(rep, ", "))
end

return IntervalTree
