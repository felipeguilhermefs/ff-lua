-- BinaryTree:
--	.new(comparator) - Creates a new instance of a binary tree
--		comparator: (a, b) -> -1|0|1. Default: NaturalComparator
--			Ex:
--				if a < b then -1
--				if a > b then 1
--				if a == b then 0
--	:insert(item) - Adds an item to the tree
--		item: any item
--	:remove(item) - Removes an item from the tree
--		item: any item
--	:min() - Returns the mininum item (leftmost) from the tree
--	:max() - Returns the maximum item (rightmost) from the tree
--	:contains(item) - Checks if item is present in the tree
--		item: any item
--	:preorder() - Returns an iterator that traverses the tree in preorder
--	:inorder() - Returns an iterator that traverses the tree in inorder
--	:postorder() - Returns an iterator that traverses the tree in postorder
--	:array() - Returns an ordered table array
--	:empty() - Returns if the tree is empty or not
--	:clear() - Empties the tree
--

local Comparator = require("ff.func.comparator")
local Stack = require("ff.collections.stack")

local function Node(val, left, right)
	return {
		value = val,
		left = left,
		right = right,
	}
end

local BinaryTree = {}
BinaryTree.__index = BinaryTree

function BinaryTree.new(comparator)
	return setmetatable({
		_comparator = comparator or Comparator.natural,
		_root = nil,
	}, BinaryTree)
end

function BinaryTree:empty()
	return not self._root
end

function BinaryTree:clear()
	self._root = nil
end

function BinaryTree:insert(item)
	self._root = self:_insert(self._root, item)
end

function BinaryTree:remove(item)
	self._root = self:_remove(self._root, item)
end

function BinaryTree:min()
	local min = self:_min(self._root)
	if min then
		return min.value
	end
end

function BinaryTree:max()
	local max = self._root
	while max and max.right do
		max = max.right
	end
	if max then
		return max.value
	end
end

function BinaryTree:contains(item)
	local cur = self._root
	while cur do
		local comp = self._comparator(item, cur.value)
		if comp == 0 then
			return true
		end

		if comp == 1 then
			cur = cur.right
		else
			cur = cur.left
		end
	end

	return false
end

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

function BinaryTree:array()
	local arr = {}
	for val in self:preorder() do
		table.insert(arr, val)
	end
	return arr
end

function BinaryTree:_insert(node, item)
	if not node then
		return Node(item)
	end

	local comp = self._comparator(item, node.value)

	if comp == 1 then
		node.right = self:_insert(node.right, item)
	end

	if comp == -1 then
		node.left = self:_insert(node.left, item)
	end

	return node
end

function BinaryTree:_remove(node, item)
	if not node then
		return nil
	end

	local comp = self._comparator(item, node.value)

	if comp == -1 then
		node.left = self:_remove(node.left, item)
	end

	if comp == 1 then
		node.right = self:_remove(node.right, item)
	end

	if comp == 0 then
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

function BinaryTree:_min(node)
	local cur = node
	while cur and cur.left do
		cur = cur.left
	end
	return cur
end

function BinaryTree:_inorder(node, arr)
	if not node then
		return nil
	end

	self:_inorder(node.left, arr)
	table.insert(arr, node.value)
	self:_inorder(node.right, arr)
end

function BinaryTree:_postorder(node, arr)
	if not node then
		return nil
	end

	self:_postorder(node.left, arr)
	self:_postorder(node.right, arr)
	table.insert(arr, node.value)
end

return BinaryTree
