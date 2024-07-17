local lu = require("luaunit")
local BinaryTree = require("binarytree")

function TestEmpty()
	local bt = BinaryTree()

	lu.assertTrue(bt.empty())

	bt.insert(1)
	lu.assertFalse(bt.empty())

	bt.clear()
	lu.assertTrue(bt.empty())

	bt.insert(2)
	bt.insert(3)
	lu.assertFalse(bt.empty())

	bt.remove(2)
	lu.assertFalse(bt.empty())
	bt.remove(3)
	lu.assertTrue(bt.empty())
end

function TestInsert()
	local bt = BinaryTree()

	bt.insert(4)
	bt.insert(5)
	bt.insert(1)

	lu.assertEquals({ 4, 1, 5 }, bt.array())

	bt.insert(3)
	bt.insert(2)

	lu.assertEquals({ 4, 1, 3, 2, 5 }, bt.array())
end

function TestRemove()
	local bt = BinaryTree()

	bt.insert(4)
	bt.insert(5)
	bt.insert(1)
	bt.insert(3)
	bt.insert(2)

	bt.remove(2)
	bt.remove(3)
	bt.remove(9)

	lu.assertEquals({ 4, 1, 5 }, bt.array())

	bt.remove(4)
	bt.remove(5)

	lu.assertEquals({ 1 }, bt.array())

	bt.remove(1)
	lu.assertEquals({}, bt.array())
end

function TestMin()
	local bt = BinaryTree()
	lu.assertEquals(0, bt.min())

	bt.insert(7)
	bt.insert(8)
	bt.insert(4)
	bt.insert(5)
	bt.insert(6)
	lu.assertEquals(4, bt.min())

	bt.remove(4)
	bt.remove(5)
	bt.remove(8)
	lu.assertEquals(6, bt.min())

	bt.remove(7)
	bt.remove(6)
	lu.assertEquals(0, bt.min())
end

function TestMax()
	local bt = BinaryTree()
	lu.assertEquals(0, bt.max())

	bt.insert(7)
	bt.insert(8)
	bt.insert(4)
	bt.insert(5)
	bt.insert(6)
	lu.assertEquals(8, bt.max())

	bt.remove(4)
	bt.remove(5)
	bt.remove(8)
	lu.assertEquals(7, bt.max())

	bt.remove(7)
	bt.remove(6)
	lu.assertEquals(0, bt.max())
end

function TestContains()
	local bt = BinaryTree()
	lu.assertFalse(bt.contains(0))

	bt.insert(7)
	bt.insert(8)
	bt.insert(4)
	bt.insert(5)
	bt.insert(6)
	lu.assertTrue(bt.contains(8))
	lu.assertTrue(bt.contains(5))

	bt.remove(5)
	bt.remove(8)
	lu.assertFalse(bt.contains(8))
	lu.assertFalse(bt.contains(5))
end

function TestPreOrderTraversal()
	local bt = BinaryTree()

	bt.insert(4)
	bt.insert(2)
	bt.insert(7)
	bt.insert(8)
	bt.insert(9)
	bt.insert(1)
	bt.insert(5)
	bt.insert(3)
	bt.insert(6)

	local test = {}
	for val in bt.preorder() do
		table.insert(test, val)
	end
	lu.assertEquals({ 4, 2, 1, 3, 7, 5, 6, 8, 9 }, test)
end

function TestInOrderTraversal()
	local bt = BinaryTree()

	bt.insert(4)
	bt.insert(2)
	bt.insert(7)
	bt.insert(8)
	bt.insert(9)
	bt.insert(1)
	bt.insert(5)
	bt.insert(3)
	bt.insert(6)

	local test = {}
	for val in bt.inorder() do
		table.insert(test, val)
	end
	lu.assertEquals({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, test)
end

function TestPostOrderTraversal()
	local bt = BinaryTree()

	bt.insert(4)
	bt.insert(2)
	bt.insert(7)
	bt.insert(8)
	bt.insert(9)
	bt.insert(1)
	bt.insert(5)
	bt.insert(3)
	bt.insert(6)

	local test = {}
	for val in bt.postorder() do
		table.insert(test, val)
	end
	lu.assertEquals({ 1, 3, 2, 6, 5, 9, 8, 7, 4 }, test)
end

os.exit(lu.LuaUnit.run())
