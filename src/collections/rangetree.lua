local Stack = require("ff.collections.stack")

---@class RangeNode
---
---@field low  number
---@field high  number
---@field left  RangeNode?
---@field right RangeNode?
---
---@private
local RangeNode = {}
RangeNode.__index = RangeNode

function RangeNode.new(low, high, left, right)
	return setmetatable({
		low = low,
		high = high,
		left = left,
		right = right,
	}, RangeNode)
end

---@class RangeTree
---
---@field private _root       RangeNode?              Root of the tree, if `nil` it is empty.
---@field private _len        number                 Number of entries in the tree.
---
local RangeTree = {}
RangeTree.__index = RangeTree

-----------------------------------------------------------------------------
---Creates a new instance of the range binary tree.
---
---@return RangeTree
-----------------------------------------------------------------------------
function RangeTree.new()
	return setmetatable({
		_root = nil,
		_len = 0,
	}, RangeTree)
end

-----------------------------------------------------------------------------
---Empties the tree.
-----------------------------------------------------------------------------
function RangeTree:clear()
	self._root = nil
	self._len = 0
end

-----------------------------------------------------------------------------
---Checks if the value is contained in any range
---
---@param  value number
---
---@return boolean
-----------------------------------------------------------------------------
function RangeTree:contains(value)
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
function RangeTree:empty()
	return not self._root
end

-----------------------------------------------------------------------------
---Adds an entry to the tree.
---
---@param low  number lower boundary of range to insert
---@param high number upper boundary of range to insert
-----------------------------------------------------------------------------
function RangeTree:insert(low, high)
	assert(type(low) == "number", "'low' should be a number")
	assert(type(high) == "number", "'high' should be a number")

	-- Ensure low is actually smaller than high
	if low > high then
		low, high = high, low
	end

	-- Remove ranges that overlaps with new one and union them (delete on insert)
	while true do
		local overlap = self:_find(self._root, low, high)

		if not overlap then
			break
		end

		-- Union boundaries
		low = math.min(low, overlap.low)
		high = math.max(high, overlap.high)

		-- Remove overlap
		self._root = self:_delete(self._root, overlap.low)
	end

	-- Finally add the range
	self._root = self:_insert(self._root, low, high)
end

-- Standard BST Deletion (deletes by the unique 'min' key)
-----------------------------------------------------------------------------
---Traverse the tree and remove the range.
---
---@param node  RangeNode The node where to start the traversal.
---@param low   number    Lower boundary of the range to remove.
---
---@return RangeNode?     New node at the position or `nil` if value not found.
---
---@private
-----------------------------------------------------------------------------
function RangeTree:_delete(node, low)
	if not node then
		return nil
	end

	if low < node.low then
		node.left = self:_delete(node.left, low)
	elseif low > node.low then
		node.right = self:_delete(node.right, low)
	else
		if not node.left then
			self._len = self._len - 1
			return node.right
		end

		if not node.right then
			self._len = self._len - 1
			return node.left
		end

		-- Find and move smallest range in right subtree
		local min = self:_min(node.right)

		node.low = min.low
		node.high = min.high

		node.right = self:_delete(node.right, min.low)
	end

	return node
end

-----------------------------------------------------------------------------
---Finds and returns the minimum (leftmost) node.
---
---@param node  RangeNode The node where to start the traversal.
---
---@return RangeNode?     Node that was visited or `nil` if empty.
---
---@private
-----------------------------------------------------------------------------
function RangeTree:_min(node)
	local cur = node
	while cur and cur.left do
		cur = cur.left
	end
	return cur
end

-----------------------------------------------------------------------------
---Traverse the tree and insert the range at the appropriate position
---
---@param node  RangeNode The node where to start the traversal.
---@param low   number    lower boundary of range to insert
---@param high  number    upper boundary of range to insert
---
---@return RangeNode      New node created or the one which was visited.
---
---@private
-----------------------------------------------------------------------------
function RangeTree:_insert(node, low, high)
	if not node then
		self._len = self._len + 1
		return RangeNode.new(low, high)
	end

	-- public method "insert" guarantees that there are no overlaps
	-- so only checking "low" is fine
	if low < node.low then
		node.left = self:_insert(node.left, low, high)
	else
		node.right = self:_insert(node.right, low, high)
	end

	return node
end

-----------------------------------------------------------------------------
---Finds any node that overlaps a given range.
---
---@param node RangeNode The node where to start the traversal.
---@param low  number lower boundary of range to check
---@param high number upper boundary of range to check
---
---@return RangeNode?     First node found that overlaps a given range or `nil` if empty.
---
---@private
-----------------------------------------------------------------------------
function RangeTree:_find(node, low, high)
	if not node then
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
---Returns an iterator that traverses the tree in preorder.
---
---@return Iterator<number, number> Returns low and high boundary each iteration
---
---@private
-----------------------------------------------------------------------------
function RangeTree:_preorder()
	local nodes = Stack.new()
	nodes:push(self._root)
	return function()
		if nodes:empty() then
			return nil
		end

		local node = nodes:pop()
		if node.right then
			nodes:push(node.right)
		end

		if node.left then
			nodes:push(node.left)
		end

		return node.low, node.high
	end
end

-----------------------------------------------------------------------------
---Returns the number of ranges in the tree.
---
---@return number
---
---@private
-----------------------------------------------------------------------------
function RangeTree:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through the range tree (Pre-Order traversal)
---
---@return Iterator<any>
---
---@private
-----------------------------------------------------------------------------
function RangeTree:__pairs()
	return self:_preorder()
end

-----------------------------------------------------------------------------
---String representation of this range tree
---
---@return string
---
---@private
-----------------------------------------------------------------------------
function RangeTree:__tostring()
	local rep = { "[" }
	for low, high in pairs(self) do
		table.insert(rep, string.format("%d ~ %d", low, high))
	end
	table.insert(rep, "]")
	return table.concat(rep, ", ")
end

return RangeTree
