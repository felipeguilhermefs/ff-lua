local Stack = require("ff.stack")

local function Node(val, left, right)
	return {
		value = val,
		left = left,
		right = right,
	}
end

local function NaturalComparator(a, b)
	if a > b then
		return 1
	end

	if a < b then
		return -1
	else
		return 0
	end
end

local BinaryTree = { __root = nil, __comparator = nil }
BinaryTree.__index = BinaryTree

function BinaryTree:empty()
	return not self.__root
end

function BinaryTree:clear()
	self.__root = nil
end

function BinaryTree:insert(item)
	self.__root = self:__insert(self.__root, item)
end

function BinaryTree:remove(item)
	self.__root = self:__remove(self.__root, item)
end

function BinaryTree:min()
	local min = self:__min(self.__root)
	if min then
		return min.value
	end
end

function BinaryTree:max()
	local max = self.__root
	while max and max.right do
		max = max.right
	end
	if max then
		return max.value
	end
end

function BinaryTree:contains(item)
	local cur = self.__root
	while cur do
		local comp = self.__comparator(item, cur.value)
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
	nodes:push(self.__root)
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
	self:__inorder(self.__root, nodes)
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
	self:__postorder(self.__root, nodes)
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

function BinaryTree:__insert(node, item)
	if not node then
		return Node(item)
	end

	local comp = self.__comparator(item, node.value)

	if comp == 1 then
		node.right = self:__insert(node.right, item)
	end

	if comp == -1 then
		node.left = self:__insert(node.left, item)
	end

	return node
end

function BinaryTree:__remove(node, item)
	if not node then
		return nil
	end

	local comp = self.__comparator(item, node.value)

	if comp == -1 then
		node.left = self:__remove(node.left, item)
	end

	if comp == 1 then
		node.right = self:__remove(node.right, item)
	end

	if comp == 0 then
		if not node.left then
			return node.right
		end

		if not node.right then
			return node.left
		end

		local min = self:__min(node.right)
		node.value = min.value
		node.right = self:__remove(node.right, min.value)
	end

	return node
end

function BinaryTree:__min(node)
	local cur = node
	while cur and cur.left do
		cur = cur.left
	end
	return cur
end

function BinaryTree:__inorder(node, arr)
	if not node then
		return nil
	end

	self:__inorder(node.left, arr)
	table.insert(arr, node.value)
	self:__inorder(node.right, arr)
end

function BinaryTree:__postorder(node, arr)
	if not node then
		return nil
	end

	self:__postorder(node.left, arr)
	self:__postorder(node.right, arr)
	table.insert(arr, node.value)
end

function BinaryTree.new(comparator)
	local new = {}
	setmetatable(new, BinaryTree)
	new.__comparator = comparator or NaturalComparator
	return new
end

return BinaryTree
