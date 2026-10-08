local lu = require("luaunit")
local Comparator = require("ff.func.comparator")
local Heap = require("ff.collections.heap")

TestHeap = {}

function TestHeap:testIsHeap()
	local h = Heap.new()
	lu.assertTrue(Heap.isHeap(h))
	lu.assertTrue(Heap.isHeap(Heap.newMin()))
	lu.assertTrue(Heap.isHeap(Heap.newMax()))
	lu.assertFalse(Heap.isHeap({}))
	lu.assertFalse(Heap.isHeap(nil))
	lu.assertFalse(Heap.isHeap("heap"))
	lu.assertFalse(Heap.isHeap(123))
end

function TestHeap:testConstructorEmpty()
	local h = Heap.new()
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())
end

function TestHeap:testConstructorWithIterable()
	local h = Heap.new({ 30, 10, 20 })
	lu.assertEquals(#h, 3)
	lu.assertEquals(h:peek(), 10)
	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 30)
	lu.assertTrue(h:empty())
end

function TestHeap:testConstructorWithComparator()
	local h = Heap.new(nil, Comparator.reverse(Comparator.natural))
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)

	h:push(10)
	h:push(30)
	h:push(20)

	lu.assertEquals(h:peek(), 30)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 10)
	lu.assertTrue(h:empty())
end

function TestHeap:testConstructorWithComparatorAndIterable()
	local h = Heap.new({ 10, 30, 20 }, Comparator.reverse(Comparator.natural))
	lu.assertEquals(#h, 3)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 10)
end

function TestHeap:testConstructorWithCapacity()
	local h = Heap.new(nil, nil, 5)
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertFalse(h:full())

	local minH = Heap.newMin(nil, 5)
	lu.assertTrue(minH:empty())
	lu.assertEquals(#minH, 0)
	lu.assertFalse(minH:full())

	local maxH = Heap.newMax(nil, 5)
	lu.assertTrue(maxH:empty())
	lu.assertEquals(#maxH, 0)
	lu.assertFalse(maxH:full())
end

function TestHeap:testConstructorWithCapacityAndIterable()
	local h = Heap.new({ 10, 20, 30 }, nil, 5)
	lu.assertEquals(#h, 3)
	lu.assertFalse(h:full())

	local h3 = Heap.new({ 10, 20, 30, 40, 50 }, nil, 3)
	lu.assertEquals(#h3, 3)
	lu.assertTrue(h3:full())

	local minH = Heap.newMin({ 5, 3, 8 }, 5)
	lu.assertEquals(#minH, 3)
	lu.assertFalse(minH:full())

	local maxH = Heap.newMax({ 5, 3, 8 }, 3)
	lu.assertEquals(#maxH, 3)
	lu.assertTrue(maxH:full())
end

function TestHeap:testConstructorCapacityValidation()
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, "a")
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, true)
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, -1)
	lu.assertErrorMsgContains("comparator should be a function", Heap.new, nil, 0)
	lu.assertErrorMsgContains("capacity should be a number", Heap.new, nil, nil, "a")
	lu.assertErrorMsgContains("capacity should be positive", Heap.new, nil, nil, -1)
	lu.assertErrorMsgContains("capacity should be positive", Heap.new, nil, nil, 0)
	lu.assertErrorMsgContains("capacity should be a number", Heap.newMin, nil, "a")
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMin, nil, 0)
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMin, nil, -1)
	lu.assertErrorMsgContains("capacity should be a number", Heap.newMax, nil, "a")
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMax, nil, 0)
	lu.assertErrorMsgContains("capacity should be positive", Heap.newMax, nil, -1)
end

function TestHeap:testConstructorMinMaxWithIterable()
	local minH = Heap.newMin({ 5, 3, 8, 1 })
	lu.assertEquals(#minH, 4)
	lu.assertEquals(minH:pop(), 1)
	lu.assertEquals(minH:pop(), 3)
	lu.assertEquals(minH:pop(), 5)
	lu.assertEquals(minH:pop(), 8)
	lu.assertNil(minH:pop())

	local maxH = Heap.newMax({ 5, 3, 8, 1 })
	lu.assertEquals(#maxH, 4)
	lu.assertEquals(maxH:pop(), 8)
	lu.assertEquals(maxH:pop(), 5)
	lu.assertEquals(maxH:pop(), 3)
	lu.assertEquals(maxH:pop(), 1)
	lu.assertNil(maxH:pop())
end

function TestHeap:testPushAndPeek()
	local h = Heap.new()

	h:push(4)
	lu.assertEquals(h:peek(), 4)
	h:push(5)
	lu.assertEquals(h:peek(), 4)
	h:push(1)
	lu.assertEquals(h:peek(), 1)
	h:push(3)
	lu.assertEquals(h:peek(), 1)
end

function TestHeap:testPushValidation()
	local h = Heap.new()
	lu.assertErrorMsgContains("value should not be nil", function()
		h:push(nil)
	end)
end

function TestHeap:testPop()
	local h = Heap.new()

	h:push(4)
	h:push(5)
	h:push(1)
	h:push(3)
	h:push(2)

	lu.assertEquals(h:pop(), 1)
	lu.assertEquals(h:pop(), 2)
	lu.assertEquals(h:pop(), 3)
	lu.assertEquals(h:pop(), 4)
	lu.assertEquals(h:pop(), 5)
	lu.assertNil(h:pop())
end

function TestHeap:testPopEmpty()
	local h = Heap.new()
	lu.assertNil(h:pop())
	lu.assertNil(h:peek())
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
end

function TestHeap:testEmptyAndClear()
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
	lu.assertEquals(#h, 2)
	h:clear()
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())

	-- Verify it works normally after clear
	h:push(42)
	lu.assertEquals(#h, 1)
	lu.assertEquals(h:peek(), 42)
	lu.assertEquals(h:pop(), 42)
	lu.assertTrue(h:empty())
end

function TestHeap:testContains()
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
	lu.assertEquals(#h, 3)
	lu.assertEquals(h:peek(), 10)

	-- After popping, element is no longer contained
	h:pop()
	lu.assertFalse(h:contains(10))
	lu.assertTrue(h:contains(20))
	lu.assertTrue(h:contains(30))
end

function TestHeap:testContainsValidation()
	local h = Heap.new()
	lu.assertErrorMsgContains("value should not be nil", function()
		h:contains(nil)
	end)

	h:push(10)
	lu.assertErrorMsgContains("attempt to compare string with number", function()
		h:contains("10")
	end)
end

function TestHeap:testDuplicates()
	local h = Heap.new()
	h:push(5)
	h:push(5)
	h:push(2)
	h:push(8)
	h:push(2)
	h:push(5)
	h:push(8)

	lu.assertEquals(#h, 7)
	lu.assertEquals(h:pop(), 2)
	lu.assertEquals(h:pop(), 2)
	lu.assertEquals(h:pop(), 5)
	lu.assertEquals(h:pop(), 5)
	lu.assertEquals(h:pop(), 5)
	lu.assertEquals(h:pop(), 8)
	lu.assertEquals(h:pop(), 8)
	lu.assertNil(h:pop())
end

function TestHeap:testMaxHeap()
	local h = Heap.newMax({ 5, 7, 9 })

	h:push(6)
	h:push(8)
	h:push(7)

	lu.assertEquals(h:pop(), 9)
	lu.assertEquals(h:pop(), 8)
	lu.assertEquals(h:pop(), 7)
	lu.assertEquals(h:pop(), 7)
	lu.assertEquals(h:pop(), 6)
	lu.assertEquals(h:pop(), 5)
	lu.assertNil(h:pop())
end

function TestHeap:testString()
	local h = Heap.new()

	h:push("b")
	h:push("e")
	h:push("c")
	h:push("a")
	h:push("d")

	lu.assertEquals(h:pop(), "a")
	lu.assertEquals(h:pop(), "b")
	lu.assertEquals(h:pop(), "c")
	lu.assertEquals(h:pop(), "d")
	lu.assertEquals(h:pop(), "e")
	lu.assertNil(h:pop())
end

function TestHeap:testComparator()
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

	lu.assertEquals(h:pop(), { priority = 9, value = "c" })
	lu.assertEquals(h:pop(), { priority = 8, value = false })
	lu.assertEquals(h:pop(), { priority = 7, value = "b" })
	lu.assertEquals(h:pop(), { priority = 6, value = true })
	lu.assertEquals(h:pop(), { priority = 5, value = "a" })
	lu.assertNil(h:pop())
end

function TestHeap:testIterator()
	local h = Heap.new()

	h:push("b")
	h:push("d")
	h:push("c")
	h:push("a")

	local keys = {}
	local res = {}
	for i, item in pairs(h) do
		table.insert(keys, i)
		table.insert(res, item)
	end

	lu.assertEquals(keys, { 1, 2, 3, 4 })
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertFalse(h:empty())
	lu.assertEquals(#h, 4)
	lu.assertEquals(h:peek(), "a")
end

function TestHeap:testIteratorEmpty()
	local h = Heap.new()

	local count = 0
	for _ in pairs(h) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestHeap:testIteratorMultipleRuns()
	local h = Heap.new({ 10, 20, 30 })

	local firstRun = {}
	for _, item in pairs(h) do
		table.insert(firstRun, item)
	end

	local secondRun = {}
	for _, item in pairs(h) do
		table.insert(secondRun, item)
	end

	lu.assertEquals(firstRun, { 10, 20, 30 })
	lu.assertEquals(secondRun, { 10, 20, 30 })
	lu.assertEquals(#h, 3)
end

function TestHeap:testIteratorLevelOrder()
	local h = Heap.new()
	h:push(10)
	h:push(30)
	h:push(20)
	h:push(50)
	h:push(40)

	-- Root to leaf level-order: root(10), left(30), right(20), left.left(50), left.right(40)
	local levelOrder = {}
	for _, item in pairs(h) do
		table.insert(levelOrder, item)
	end
	lu.assertEquals(levelOrder, { 10, 30, 20, 50, 40 })
	lu.assertEquals(#h, 5)
end

function TestHeap:testDrain()
	local h = Heap.new()
	h:push("b")
	h:push("d")
	h:push("c")
	h:push("a")

	local res = {}
	for item in h:drain() do
		table.insert(res, item)
	end

	-- Drain yields in priority order (min-to-max)
	lu.assertEquals(res, { "a", "b", "c", "d" })
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
	lu.assertNil(h:peek())
	lu.assertNil(h:pop())
end

function TestHeap:testDrainMaxHeap()
	local h = Heap.newMax({ 10, 50, 30, 20, 40 })

	local res = {}
	for item in h:drain() do
		table.insert(res, item)
	end

	-- Max-heap drain yields descending order
	lu.assertEquals(res, { 50, 40, 30, 20, 10 })
	lu.assertTrue(h:empty())
	lu.assertEquals(#h, 0)
end

function TestHeap:testDrainEmpty()
	local h = Heap.new()

	local count = 0
	for _ in h:drain() do
		count = count + 1
	end

	lu.assertEquals(count, 0)
	lu.assertTrue(h:empty())
end

function TestHeap:testConcat()
	local h = Heap.new() .. { 10, 20, 30 }
	lu.assertEquals(#h, 3)

	h = h .. nil
	lu.assertEquals(#h, 3)

	local ll = require("ff.collections.linkedlist").new()
	ll:pushBack(40)
	ll:pushBack(50)
	ll:pushBack(60)

	h = h .. ll

	lu.assertEquals(#h, 6)
	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(h:pop(), 20)
	lu.assertEquals(h:pop(), 30)
	lu.assertEquals(h:pop(), 40)
	lu.assertEquals(h:pop(), 50)
	lu.assertEquals(h:pop(), 60)
end

function TestHeap:testConcatValidation()
	local h = Heap.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		h = h .. "not a table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		h = h .. 42
	end)
end

function TestHeap:testEquality()
	local h1 = Heap.new({ 1, 2, 3 })
	local h2 = Heap.new({ 1, 2, 3 })
	local h3 = Heap.new({ 1, 2, 4 })
	local h4 = Heap.new({ 1, 2 })

	lu.assertEquals(h1 == h2, true)
	lu.assertEquals(h1 == h3, false)
	lu.assertEquals(h1 == h4, false)
	lu.assertEquals(h1 == {}, false)
	lu.assertEquals(h1 == nil, false)
	lu.assertEquals(h1 == 42, false)
end

function TestHeap:testEqualityEmpty()
	local h1 = Heap.new()
	local h2 = Heap.new()
	lu.assertEquals(h1 == h2, true)
end

function TestHeap:testLen()
	local h = Heap.new()
	lu.assertEquals(#h, 0)

	h:push(10)
	lu.assertEquals(#h, 1)
	h:push(20)
	h:push(30)
	lu.assertEquals(#h, 3)

	h:pop()
	lu.assertEquals(#h, 2)
	h:clear()
	lu.assertEquals(#h, 0)
end

function TestHeap:testToString()
	local h = Heap.new({ 1, 2, 3 })
	local str = tostring(h)
	lu.assertTrue(str:find("1") ~= nil)
	lu.assertTrue(str:find("2") ~= nil)
	lu.assertTrue(str:find("3") ~= nil)
	lu.assertTrue(str:find("%[") ~= nil)
	lu.assertTrue(str:find("%]") ~= nil)
end

function TestHeap:testToStringEmpty()
	local h = Heap.new()
	local str = tostring(h)
	lu.assertEquals(str, "[  ]")
end

function TestHeap:testIndexOf()
	local h = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })

	-- Root element is at index 1
	lu.assertEquals(h:indexOf(10), 1)

	-- All existing elements return an index containing that value
	for _, val in ipairs({ 10, 20, 30, 40, 50, 60, 70 }) do
		local idx = h:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(h._entries:get(idx), val)
	end

	-- Smaller than root (pruned immediately)
	lu.assertNil(h:indexOf(5))

	-- Greater than root but not in heap
	lu.assertNil(h:indexOf(25))
	lu.assertNil(h:indexOf(99))

	-- Empty heap
	lu.assertNil(Heap.new():indexOf(10))
end

function TestHeap:testIndexOfWithStartIndex()
	local h = Heap.new({ 10, 20, 30, 40, 50, 60, 70 })

	-- Searching starting from left child (index 2) finds elements in that subtree
	local leftVal = h._entries:get(2)
	local idx = h:indexOf(leftVal, 2)
	lu.assertEquals(idx, 2)

	-- Child of index 2 (index 4 or 5)
	if #h >= 4 then
		local childVal = h._entries:get(4)
		lu.assertEquals(h:indexOf(childVal, 2), 4)
	end

	-- Right child element (index 3) is not in left subtree (index 2)
	local rightVal = h._entries:get(3)
	lu.assertNil(h:indexOf(rightVal, 2))

	-- Searching beyond heap bounds returns nil
	lu.assertNil(h:indexOf(10, 100))
end

function TestHeap:testIndexOfMaxHeap()
	local maxH = Heap.newMax({ 70, 60, 50, 40, 30, 20, 10 })

	-- Root is max element (index 1)
	lu.assertEquals(maxH:indexOf(70), 1)

	-- All existing elements return an index containing that value
	for _, val in ipairs({ 70, 60, 50, 40, 30, 20, 10 }) do
		local idx = maxH:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(maxH._entries:get(idx), val)
	end

	-- Larger than root (pruned immediately)
	lu.assertNil(maxH:indexOf(100))

	-- Smaller than root but not in heap
	lu.assertNil(maxH:indexOf(25))
	lu.assertNil(maxH:indexOf(0))
end

function TestHeap:testIndexOfMaxHeapSubtree()
	local maxH = Heap.newMax({ 100, 80, 90, 40, 50, 60, 70 })

	local leftVal = maxH._entries:get(2)
	local rightVal = maxH._entries:get(3)

	-- Search starting at root finds both
	lu.assertEquals(maxH:indexOf(leftVal, 1), 2)
	lu.assertEquals(maxH:indexOf(rightVal, 1), 3)

	-- Search starting at left subtree finds leftVal and its descendants
	lu.assertEquals(maxH:indexOf(leftVal, 2), 2)
	if #maxH >= 4 then
		local childVal = maxH._entries:get(4)
		lu.assertEquals(maxH:indexOf(childVal, 2), 4)
	end

	-- Search starting at left subtree does NOT find rightVal (disjoint subtree)
	lu.assertNil(maxH:indexOf(rightVal, 2))
end

function TestHeap:testIndexOfMaxHeapDuplicates()
	local maxH = Heap.newMax({ 50, 40, 40, 30, 20, 20, 10 })

	for _, val in ipairs({ 50, 40, 30, 20, 10 }) do
		local idx = maxH:indexOf(val)
		lu.assertNotNil(idx)
		lu.assertEquals(maxH._entries:get(idx), val)
	end
end

function TestHeap:testIndexOfObjectHeapTies()
	local function cmp(a, b)
		return Comparator.natural(a.priority, b.priority)
	end

	local h = Heap.new(nil, cmp)
	local a = { priority = 10, name = "A" }
	local b = { priority = 10, name = "B" }
	local c = { priority = 10, name = "C" }

	h:push(a)
	h:push(b)

	lu.assertEquals(h:indexOf(a), 1)
	lu.assertEquals(h:indexOf(b), 2)
	lu.assertNil(h:indexOf(c))
	lu.assertFalse(h:contains(c))
end

function TestHeap:testIndexOfMaxHeapObjectTies()
	local function maxObjCmp(a, b)
		return Comparator.reverse(Comparator.natural)(a.priority, b.priority)
	end

	local h = Heap.new(nil, maxObjCmp)
	local a = { priority = 50, name = "A" }
	local b = { priority = 50, name = "B" }
	local c = { priority = 20, name = "C" }
	local d = { priority = 50, name = "D" }

	h:push(a)
	h:push(b)
	h:push(c)

	lu.assertEquals(h:indexOf(a), 1)
	lu.assertEquals(h:indexOf(b), 2)
	lu.assertEquals(h:indexOf(c), 3)
	lu.assertNil(h:indexOf(d))
	lu.assertFalse(h:contains(d))
end

function TestHeap:testIndexOfValidation()
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

function TestHeap:testCapacityPush()
	local h = Heap.new(nil, nil, 2)

	lu.assertTrue(h:push(10))
	lu.assertEquals(#h, 1)
	lu.assertFalse(h:full())

	lu.assertTrue(h:push(20))
	lu.assertEquals(#h, 2)
	lu.assertTrue(h:full())

	-- Pushing to full heap returns false and does not modify heap
	lu.assertFalse(h:push(30))
	lu.assertEquals(#h, 2)

	-- Popping makes room
	lu.assertEquals(h:pop(), 10)
	lu.assertEquals(#h, 1)
	lu.assertFalse(h:full())

	lu.assertTrue(h:push(30))
	lu.assertEquals(#h, 2)
	lu.assertTrue(h:full())
end

function TestHeap:testFullUnbounded()
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

function TestHeap:testFullBoundedNotFull()
	local h = Heap.new(nil, nil, 3)
	lu.assertFalse(h:full())
	h:push(1)
	lu.assertFalse(h:full())
	h:push(2)
	lu.assertFalse(h:full())
end

function TestHeap:testFullBoundedAtCapacity()
	local h = Heap.new(nil, nil, 2)
	h:push(1)
	h:push(2)
	lu.assertTrue(h:full())
end

function TestHeap:testFullBoundedAfterPopAndClear()
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
	lu.assertEquals(#h, 0)
end

function TestHeap:testFullConsistentWithPush()
	local h = Heap.new(nil, nil, 3)
	h:push("a")
	h:push("b")
	h:push("c")

	lu.assertTrue(h:full())
	lu.assertFalse(h:push("d"))
end

function TestHeap:testNewIndexPreventsModifications()
	local h = Heap.new()

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Heap", function()
		h.peek = function() end
	end)
end

