local Comparator = require("ff.func.comparator")
local Stack = require("ff.collections.stack")

local _LESS = Comparator.less
local _EQUAL = Comparator.equal
local _GREATER = Comparator.greater

---@class TreeNode
---
---@field value any
---@field left  TreeNode?
---@field right TreeNode?
---
---@private
local TreeNode = {}
TreeNode.__index = TreeNode

function TreeNode.new(val, left, right)
	return setmetatable({
		value = val,
		left = left,
		right = right,
	}, TreeNode)
end

---@class BinaryTree
---
---@field private _root       TreeNode?              Root of the tree, if `nil` it is empty.
---@field private _comparator fun(any, any): -1|0|1  Function used to keep the tree order.
local BinaryTree = {}
BinaryTree.__index = BinaryTree

-----------------------------------------------------------------------------
---Creates a new instance of the binary tree.
---
---@param comparator fun(any, any): -1|0|1 If nothing is given a natural order
---                                        a natural order will be used.
---
---@return BinaryTree
-----------------------------------------------------------------------------
function BinaryTree.new(comparator)
	return setmetatable({
		_comparator = comparator or Comparator.natural,
		_root = nil,
	}, BinaryTree)
end

-----------------------------------------------------------------------------
---Empties the tree.
-----------------------------------------------------------------------------
function BinaryTree:clear()
	self._root = nil
end

-----------------------------------------------------------------------------
---Checks if the entry is present in the tree.
---
---@param  entry any
---
---@return boolean
-----------------------------------------------------------------------------
function BinaryTree:contains(entry)
	local cur = self._root
	while cur do
		local comp = self._comparator(entry, cur.value)
		if comp == _EQUAL then
			return true
		end

		if comp == _GREATER then
			cur = cur.right
		else
			cur = cur.left
		end
	end

	return false
end

-----------------------------------------------------------------------------
---Returns whether the tree is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function BinaryTree:empty()
	return not self._root
end

-----------------------------------------------------------------------------
---Adds an entry to the tree.
---
---@param  entry  any
-----------------------------------------------------------------------------
function BinaryTree:insert(entry)
	self._root = self:_insert(self._root, entry)
end

-----------------------------------------------------------------------------
---Returns the maximum entry (rightmost) from the tree, `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function BinaryTree:max()
	local max = self._root
	while max and max.right do
		max = max.right
	end
	if max then
		return max.value
	end
end

-----------------------------------------------------------------------------
---Returns the mininum entry (leftmost) from the tree.
---
---@return any?
-----------------------------------------------------------------------------
function BinaryTree:min()
	local min = self:_min(self._root)
	if min then
		return min.value
	end
end

-----------------------------------------------------------------------------
---Removes the entry from the tree.
---
---@param  entry any
-----------------------------------------------------------------------------
function BinaryTree:remove(entry)
	self._root = self:_remove(self._root, entry)
end

-----------------------------------------------------------------------------
---Returns an iterator that traverses the tree in inorder.
---
---@return Iterator<any>
-----------------------------------------------------------------------------
function BinaryTree:inorder()
	local nodes = {}
	self:_inorder(self._root, nodes)
	local index = 0
	return function()
		if index <= #nodes then
			index = index + 1
			return nodes[index]
		end
	end
end

-----------------------------------------------------------------------------
---Returns an iterator that traverses the tree in postorder.
---
---@return Iterator<any>
-----------------------------------------------------------------------------
function BinaryTree:postorder()
	local nodes = {}
	self:_postorder(self._root, nodes)
	local index = 0
	return function()
		if index <= #nodes then
			index = index + 1
			return nodes[index]
		end
	end
end

-----------------------------------------------------------------------------
---Returns an iterator that traverses the tree in preorder.
---
---@return Iterator<any>
-----------------------------------------------------------------------------
function BinaryTree:preorder()
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

		return node.value
	end
end

-----------------------------------------------------------------------------
---Returns an ordered table array.
---
---@return table<any>
-----------------------------------------------------------------------------
function BinaryTree:array()
	local arr = {}
	for val in self:preorder() do
		table.insert(arr, val)
	end
	return arr
end

-----------------------------------------------------------------------------
---Traverse the tree and insert the entry at the appropriate position using
---the comparator function.
---
---@param node  TreeNode The node where to start the traversal.
---@param entry any      Entry to insert.
---
---@return TreeNode      New node created or the one which was visited.
---
---@private
-----------------------------------------------------------------------------
function BinaryTree:_insert(node, entry)
	if not node then
		return TreeNode.new(entry)
	end

	local cmp = self._comparator(entry, node.value)

	if cmp == _GREATER then
		node.right = self:_insert(node.right, entry)
	end

	if cmp == _LESS then
		node.left = self:_insert(node.left, entry)
	end

	return node
end

-----------------------------------------------------------------------------
---Traverse the tree (using the comparator) and remove the entry.
---
---@param node  TreeNode The node where to start the traversal.
---@param entry any      Entry to remove.
---
---@return TreeNode?     Node that was visited or `nil` if node is removed.
---
---@private
-----------------------------------------------------------------------------
function BinaryTree:_remove(node, entry)
	if not node then
		return nil
	end

	local comp = self._comparator(entry, node.value)

	if comp == _LESS then
		node.left = self:_remove(node.left, entry)
	end

	if comp == _GREATER then
		node.right = self:_remove(node.right, entry)
	end

	if comp == _EQUAL then
		if not node.left then
			return node.right
		end

		if not node.right then
			return node.left
		end

		local min = self:_min(node.right)
		node.value = min.value
		node.right = self:_remove(node.right, min.value)
	end

	return node
end

-----------------------------------------------------------------------------
---Finds and returns the minimum (leftmost) node.
---
---@param node  TreeNode The node where to start the traversal.
---
---@return TreeNode?     Node that was visited or `nil` if empty.
---
---@private
-----------------------------------------------------------------------------
function BinaryTree:_min(node)
	local cur = node
	while cur and cur.left do
		cur = cur.left
	end
	return cur
end

-----------------------------------------------------------------------------
---Traverses the tree inorder, and accumulates nodes in a given array.
---
---@param node   TreeNode?   The node where to start the traversal.
---@param array  table<any>  Array to insert the values from visited nodes.
---
---@private
-----------------------------------------------------------------------------
function BinaryTree:_inorder(node, array)
	if node then
		self:_inorder(node.left, array)
		table.insert(array, node.value)
		self:_inorder(node.right, array)
	end
end

-----------------------------------------------------------------------------
---Traverses the tree postorder, and accumulates nodes in a given array.
---
---@param node   TreeNode?   The node where to start the traversal.
---@param array  table<any>  Array to insert the values from visited nodes.
---
---@private
-----------------------------------------------------------------------------
function BinaryTree:_postorder(node, array)
	if node then
		self:_postorder(node.left, array)
		self:_postorder(node.right, array)
		table.insert(array, node.value)
	end
end

return BinaryTree
