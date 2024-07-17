local Stack = require("ff.stack")

local function Node(val, left, right)
	return {
		value = val,
		left = left,
		right = right,
	}
end

local function insert(node, val)
	if not node then
		return Node(val)
	end

	if val > node.value then
		node.right = insert(node.right, val)
	end

	if val < node.value then
		node.left = insert(node.left, val)
	end

	return node
end

local function minNode(node)
	local cur = node
	while cur and cur.left do
		cur = cur.left
	end
	return cur
end

local function remove(node, val)
	if not node then
		return nil
	end

	if val < node.value then
		node.left = remove(node.left, val)
	end

	if val > node.value then
		node.right = remove(node.right, val)
	end

	if val == node.value then
		if not node.left then
			return node.right
		end

		if not node.right then
			return node.left
		end

		local min = minNode(node.right)
		node.value = min.value
		node.right = remove(node.right, min.value)
	end

	return node
end

local function inorder(node, arr)
	if not node then
		return nil
	end

	inorder(node.left, arr)
	table.insert(arr, node.value)
	inorder(node.right, arr)
end

local function postorder(node, arr)
	if not node then
		return nil
	end

	postorder(node.left, arr)
	postorder(node.right, arr)
	table.insert(arr, node.value)
end

local function BinaryTree()
	local self = { _root = nil }

	self.empty = function()
		return not self._root
	end

	self.clear = function()
		self._root = nil
	end

	self.insert = function(val)
		self._root = insert(self._root, val)
	end

	self.remove = function(val)
		self._root = remove(self._root, val)
	end

	self.min = function()
		local min = minNode(self._root)
		if min then
			return min.value
		end
		return 0
	end

	self.max = function()
		local max = self._root
		while max and max.right do
			max = max.right
		end
		if max then
			return max.value
		end
		return 0
	end

	self.contains = function(val)
		local cur = self._root
		while cur do
			if val == cur.value then
				return true
			end

			if val > cur.value then
				cur = cur.right
			else
				cur = cur.left
			end
		end
		return false
	end

	self.preorder = function()
		local nodes = Stack()
		nodes.push(self._root)
		return function()
			if nodes.empty() then
				return nil
			end

			local node = nodes.pop()
			if node.right then
				nodes.push(node.right)
			end

			if node.left then
				nodes.push(node.left)
			end

			return node.value
		end
	end

	self.inorder = function()
		local nodes = {}
		inorder(self._root, nodes)
		local index = 0
		return function()
			if index <= #nodes then
				index = index + 1
				return nodes[index]
			end
		end
	end

	self.postorder = function()
		local nodes = {}
		postorder(self._root, nodes)
		local index = 0
		return function()
			if index <= #nodes then
				index = index + 1
				return nodes[index]
			end
		end
	end

	self.array = function()
		local arr = {}
		for val in self.preorder() do
			table.insert(arr, val)
		end
		return arr
	end

	return self
end

return BinaryTree
