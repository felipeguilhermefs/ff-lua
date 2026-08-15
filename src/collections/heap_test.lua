local lu = require("luaunit")
local Comparator = require("ff.func.comparator")
local Heap = require("heap")

function TestIsHeap()
	local h = Heap.new()
	lu.assertTrue(Heap.isHeap(h))
	lu.assertTrue(Heap.isHeap(Heap.newMin()))
	lu.assertTrue(Heap.isHeap(Heap.newMax()))
	lu.assertFalse(Heap.isHeap({}))
	lu.assertFalse(Heap.isHeap(nil))
	lu.assertFalse(Heap.isHeap("heap"))
	lu.assertFalse(Heap.isHeap(123))
end

function TestConstructorEmpty()
	local h = Heap.new()
	lu.assertTrue(h:empty())
	lu.assertEquals(0, #h)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())
end

function TestConstructorWithIterable()
	local h = Heap.new({ 30, 10, 20 })
	lu.assertEquals(3, #h)
	lu.assertEquals(10, h:peek())
	lu.assertEquals(10, h:pop())
	lu.assertEquals(20, h:pop())
	lu.assertEquals(30, h:pop())
	lu.assertTrue(h:empty())
end

function TestConstructorWithComparator()
	local h = Heap.new(nil, Comparator.reverse(Comparator.natural))
	lu.assertTrue(h:empty())
	lu.assertEquals(0, #h)

	h:push(10)
	h:push(30)
	h:push(20)

	lu.assertEquals(30, h:peek())
	lu.assertEquals(30, h:pop())
	lu.assertEquals(20, h:pop())
	lu.assertEquals(10, h:pop())
	lu.assertTrue(h:empty())
end

function TestConstructorWithComparatorAndIterable()
	local h = Heap.new({ 10, 30, 20 }, Comparator.reverse(Comparator.natural))
	lu.assertEquals(3, #h)
	lu.assertEquals(30, h:pop())
	lu.assertEquals(20, h:pop())
	lu.assertEquals(10, h:pop())
end

function TestConstructorWithCapacity()
	local h = Heap.new(nil, nil, 5)
	lu.assertTrue(h:empty())
	lu.assertEquals(0, #h)
	lu.assertFalse(h:full())

	local minH = Heap.newMin(nil, 5)
	lu.assertTrue(minH:empty())
	lu.assertEquals(0, #minH)
	lu.assertFalse(minH:full())

	local maxH = Heap.newMax(nil, 5)
	lu.assertTrue(maxH:empty())
	lu.assertEquals(0, #maxH)
	lu.assertFalse(maxH:full())
end

function TestConstructorWithCapacityAndIterable()
	local h = Heap.new({ 10, 20, 30 }, nil, 5)
	lu.assertEquals(3, #h)
	lu.assertFalse(h:full())

	local h3 = Heap.new({ 10, 20, 30, 40, 50 }, nil, 3)
	lu.assertEquals(3, #h3)
	lu.assertTrue(h3:full())

	local minH = Heap.newMin({ 5, 3, 8 }, 5)
	lu.assertEquals(3, #minH)
	lu.assertFalse(minH:full())

	local maxH = Heap.newMax({ 5, 3, 8 }, 3)
	lu.assertEquals(3, #maxH)
	lu.assertTrue(maxH:full())
end

function TestConstructorCapacityValidation()
	lu.assertError(Heap.new, nil, "a")
	lu.assertError(Heap.new, nil, true)
	lu.assertError(Heap.new, nil, -1)
	lu.assertError(Heap.new, nil, 0)
	lu.assertError(Heap.new, nil, nil, "a")
	lu.assertError(Heap.new, nil, nil, -1)
	lu.assertError(Heap.new, nil, nil, 0)
	lu.assertError(Heap.newMin, nil, "a")
	lu.assertError(Heap.newMin, nil, 0)
	lu.assertError(Heap.newMin, nil, -1)
	lu.assertError(Heap.newMax, nil, "a")
	lu.assertError(Heap.newMax, nil, 0)
	lu.assertError(Heap.newMax, nil, -1)
end

function TestConstructorMinMaxWithIterable()
	local minH = Heap.newMin({ 5, 3, 8, 1 })
	lu.assertEquals(4, #minH)
	lu.assertEquals(1, minH:pop())
	lu.assertEquals(3, minH:pop())
	lu.assertEquals(5, minH:pop())
	lu.assertEquals(8, minH:pop())
	lu.assertNil(minH:pop())

	local maxH = Heap.newMax({ 5, 3, 8, 1 })
	lu.assertEquals(4, #maxH)
	lu.assertEquals(8, maxH:pop())
	lu.assertEquals(5, maxH:pop())
	lu.assertEquals(3, maxH:pop())
	lu.assertEquals(1, maxH:pop())
	lu.assertNil(maxH:pop())
end

function TestPushAndPeek()
	local h = Heap.new()

	h:push(4)
	lu.assertEquals(4, h:peek())
	h:push(5)
	lu.assertEquals(4, h:peek())
	h:push(1)
	lu.assertEquals(1, h:peek())
	h:push(3)
	lu.assertEquals(1, h:peek())
end

function TestPushValidation()
	local h = Heap.new()
	lu.assertErrorMsgContains("value should not be nil", function()
		h:push(nil)
	end)
end

function TestPop()
	local h = Heap.new()

	h:push(4)
	h:push(5)
	h:push(1)
	h:push(3)
	h:push(2)

	lu.assertEquals(1, h:pop())
	lu.assertEquals(2, h:pop())
	lu.assertEquals(3, h:pop())
	lu.assertEquals(4, h:pop())
	lu.assertEquals(5, h:pop())
	lu.assertNil(h:pop())
end

function TestPopEmpty()
	local h = Heap.new()
	lu.assertNil(h:pop())
	lu.assertNil(h:peek())
	lu.assertTrue(h:empty())
	lu.assertEquals(0, #h)
end

function TestEmptyAndClear()
	local h = Heap.new()

	lu.assertTrue(h:empty())

	h:push(2)
	lu.assertFalse(h:empty())
	h:push(3)
	lu.assertFalse(h:empty())

	h:pop()
	lu.assertFalse(h:empty())
	h:pop()
	lu.assertTrue(h:empty())

	h:push(10)
	h:push(20)
	lu.assertEquals(2, #h)
	h:clear()
	lu.assertTrue(h:empty())
	lu.assertEquals(0, #h)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())

	-- Verify it works normally after clear
	h:push(42)
	lu.assertEquals(1, #h)
	lu.assertEquals(42, h:peek())
	lu.assertEquals(42, h:pop())
	lu.assertTrue(h:empty())
end

function TestContains()
	local h = Heap.new()
	lu.assertFalse(h:contains(1))

	h:push(10)
	h:push(20)
	h:push(30)

	lu.assertTrue(h:contains(10))
	lu.assertTrue(h:contains(20))
	lu.assertTrue(h:contains(30))

	lu.assertFalse(h:contains(99))

	-- Contains must not modify or consume elements
	lu.assertEquals(3, #h)
	lu.assertEquals(10, h:peek())

	-- After popping, element is no longer contained
	h:pop()
	lu.assertFalse(h:contains(10))
	lu.assertTrue(h:contains(20))
	lu.assertTrue(h:contains(30))
end

function TestContainsValidation()
	local h = Heap.new()
	lu.assertErrorMsgContains("value should not be nil", function()
		h:contains(nil)
	end)

	h:push(10)
	lu.assertErrorMsgContains("attempt to compare string with number", function()
		h:contains("10")
	end)
end

function TestDuplicates()
	local h = Heap.new()
	h:push(5)
	h:push(5)
	h:push(2)
	h:push(8)
	h:push(2)
	h:push(5)
	h:push(8)

	lu.assertEquals(7, #h)
	lu.assertEquals(2, h:pop())
	lu.assertEquals(2, h:pop())
	lu.assertEquals(5, h:pop())
	lu.assertEquals(5, h:pop())
	lu.assertEquals(5, h:pop())
	lu.assertEquals(8, h:pop())
	lu.assertEquals(8, h:pop())
	lu.assertNil(h:pop())
end

function TestMaxHeap()
	local h = Heap.newMax({ 5, 7, 9 })

	h:push(6)
	h:push(8)
	h:push(7)

	lu.assertEquals(9, h:pop())
	lu.assertEquals(8, h:pop())
	lu.assertEquals(7, h:pop())
	lu.assertEquals(7, h:pop())
	lu.assertEquals(6, h:pop())
	lu.assertEquals(5, h:pop())
	lu.assertNil(h:pop())
end

function TestString()
	local h = Heap.new()

	h:push("b")
	h:push("e")
	h:push("c")
	h:push("a")
	h:push("d")

	lu.assertEquals("a", h:pop())
	lu.assertEquals("b", h:pop())
	lu.assertEquals("c", h:pop())
	lu.assertEquals("d", h:pop())
	lu.assertEquals("e", h:pop())
	lu.assertNil(h:pop())
end

function TestComparator()
	local function max(a, b)
		if a.priority < b.priority then
			return Comparator.greater
		end

		if a.priority > b.priority then
			return Comparator.less
		end

		return Comparator.equal
	end

	local function obj(priority, value)
		return { priority = priority, value = value }
	end

	local h = Heap.new({ obj(5, "a"), obj(7, "b"), obj(9, "c") }, max)

	h:push(obj(6, true))
	h:push(obj(8, false))

	lu.assertEquals({ priority = 9, value = "c" }, h:pop())
	lu.assertEquals({ priority = 8, value = false }, h:pop())
	lu.assertEquals({ priority = 7, value = "b" }, h:pop())
	lu.assertEquals({ priority = 6, value = true }, h:pop())
	lu.assertEquals({ priority = 5, value = "a" }, h:pop())
	lu.assertNil(h:pop())
end

function TestIterator()
	local h = Heap.new()

	h:push("b")
	h:push("d")
	h:push("c")
	h:push("a")

	local res = {}
	for _, item in pairs(h) do
		table.insert(res, item)
	end

	lu.assertEquals({ "a", "b", "c", "d" }, res)
	lu.assertTrue(h:empty())
end

function TestIteratorEmpty()
	local h = Heap.new()

	local count = 0
	for _ in pairs(h) do
		count = count + 1
	end

	lu.assertEquals(0, count)
end

function TestConcat()
	local h = Heap.new() .. { 10, 20, 30 }
	lu.assertEquals(3, #h)

	h = h .. nil
	lu.assertEquals(3, #h)

	local ll = require("linkedlist").new()
	ll:pushBack(40)
	ll:pushBack(50)
	ll:pushBack(60)

	h = h .. ll

	lu.assertEquals(6, #h)
	lu.assertEquals(10, h:pop())
	lu.assertEquals(20, h:pop())
	lu.assertEquals(30, h:pop())
	lu.assertEquals(40, h:pop())
	lu.assertEquals(50, h:pop())
	lu.assertEquals(60, h:pop())
end

function TestConcatValidation()
	local h = Heap.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		h = h .. "not a table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		h = h .. 42
	end)
end

function TestEquality()
	local h1 = Heap.new({ 1, 2, 3 })
	local h2 = Heap.new({ 1, 2, 3 })
	local h3 = Heap.new({ 1, 2, 4 })
	local h4 = Heap.new({ 1, 2 })

	lu.assertTrue(h1 == h2)
	lu.assertFalse(h1 == h3)
	lu.assertFalse(h1 == h4)
	lu.assertFalse(h1 == {})
	lu.assertFalse(h1 == nil)
	lu.assertFalse(h1 == 42)
end

function TestEqualityEmpty()
	local h1 = Heap.new()
	local h2 = Heap.new()
	lu.assertTrue(h1 == h2)
end

function TestLen()
	local h = Heap.new()
	lu.assertEquals(0, #h)

	h:push(10)
	lu.assertEquals(1, #h)
	h:push(20)
	h:push(30)
	lu.assertEquals(3, #h)

	h:pop()
	lu.assertEquals(2, #h)
	h:clear()
	lu.assertEquals(0, #h)
end

function TestToString()
	local h = Heap.new({ 1, 2, 3 })
	local str = tostring(h)
	lu.assertTrue(str:find("1") ~= nil)
	lu.assertTrue(str:find("2") ~= nil)
	lu.assertTrue(str:find("3") ~= nil)
	lu.assertTrue(str:find("%[") ~= nil)
	lu.assertTrue(str:find("%]") ~= nil)
end

function TestToStringEmpty()
	local h = Heap.new()
	local str = tostring(h)
	lu.assertEquals("[  ]", str)
end

function TestIndexOf()
	local h = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })

	-- Root element is at index 1
	lu.assertEquals(1, h:indexOf(10))

	-- All existing elements return an index containing that value
	for _, val in ipairs({ 10, 20, 30, 40, 50, 60, 70 }) do
		local idx = h:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(val, h._entries[idx])
	end

	-- Smaller than root (pruned immediately)
	lu.assertNil(h:indexOf(5))

	-- Greater than root but not in heap
	lu.assertNil(h:indexOf(25))
	lu.assertNil(h:indexOf(99))

	-- Empty heap
	lu.assertNil(Heap.new():indexOf(10))
end

function TestIndexOfWithStartIndex()
	local h = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })

	-- Searching starting from left child (index 2) finds elements in that subtree
	local leftVal = h._entries[2]
	local idx = h:indexOf(leftVal, 2)
	lu.assertEquals(2, idx)

	-- Child of index 2 (index 4 or 5)
	if #h >= 4 then
		local childVal = h._entries[4]
		lu.assertEquals(4, h:indexOf(childVal, 2))
	end

	-- Right child element (index 3) is not in left subtree (index 2)
	local rightVal = h._entries[3]
	lu.assertNil(h:indexOf(rightVal, 2))

	-- Searching beyond heap bounds returns nil
	lu.assertNil(h:indexOf(10, 100))
end

function TestIndexOfMaxHeap()
	local maxH = Heap.newMax({ 70, 60, 50, 40, 30, 20, 10 })

	-- Root is max element (index 1)
	lu.assertEquals(1, maxH:indexOf(70))

	-- All existing elements return an index containing that value
	for _, val in ipairs({ 70, 60, 50, 40, 30, 20, 10 }) do
		local idx = maxH:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(val, maxH._entries[idx])
	end

	-- Larger than root (pruned immediately)
	lu.assertNil(maxH:indexOf(100))

	-- Smaller than root but not in heap
	lu.assertNil(maxH:indexOf(25))
	lu.assertNil(maxH:indexOf(0))
end

function TestIndexOfValidation()
	local h = Heap.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("value should not be nil", function()
		h:indexOf(nil)
	end)

	lu.assertErrorMsgContains("index should be a number", function()
		h:indexOf(10, "bad")
	end)

	lu.assertErrorMsgContains("index should be positive", function()
		h:indexOf(10, 0)
	end)

	lu.assertErrorMsgContains("index should be positive", function()
		h:indexOf(10, -1)
	end)
end

function TestCapacityPush()
	local h = Heap.new(nil, nil, 2)

	lu.assertTrue(h:push(10))
	lu.assertEquals(1, #h)
	lu.assertFalse(h:full())

	lu.assertTrue(h:push(20))
	lu.assertEquals(2, #h)
	lu.assertTrue(h:full())

	-- Pushing to full heap returns false and does not modify heap
	lu.assertFalse(h:push(30))
	lu.assertEquals(2, #h)

	-- Popping makes room
	lu.assertEquals(10, h:pop())
	lu.assertEquals(1, #h)
	lu.assertFalse(h:full())

	lu.assertTrue(h:push(30))
	lu.assertEquals(2, #h)
	lu.assertTrue(h:full())
end

function TestFullUnbounded()
	local h = Heap.new()
	lu.assertFalse(h:full())
	h:push(1)
	lu.assertFalse(h:full())
	h:push(2)
	lu.assertFalse(h:full())

	local minH = Heap.newMin()
	lu.assertFalse(minH:full())

	local maxH = Heap.newMax()
	lu.assertFalse(maxH:full())
end

function TestFullBoundedNotFull()
	local h = Heap.new(nil, nil, 3)
	lu.assertFalse(h:full())
	h:push(1)
	lu.assertFalse(h:full())
	h:push(2)
	lu.assertFalse(h:full())
end

function TestFullBoundedAtCapacity()
	local h = Heap.new(nil, nil, 2)
	h:push(1)
	h:push(2)
	lu.assertTrue(h:full())
end

function TestFullBoundedAfterPopAndClear()
	local h = Heap.new(nil, nil, 2)
	h:push(1)
	h:push(2)
	lu.assertTrue(h:full())

	h:pop()
	lu.assertFalse(h:full())

	h:push(3)
	lu.assertTrue(h:full())

	h:clear()
	lu.assertFalse(h:full())
	lu.assertEquals(0, #h)
end

function TestFullConsistentWithPush()
	local h = Heap.new(nil, nil, 3)
	h:push("a")
	h:push("b")
	h:push("c")

	lu.assertTrue(h:full())
	lu.assertFalse(h:push("d"))
end

os.exit(lu.LuaUnit.run())
