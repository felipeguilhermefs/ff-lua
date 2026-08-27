local lu = require("luaunit")
local IntervalTree = require("intervaltree")

-- ---------------------------------------------------------------------------
-- isIntervalTree
-- ---------------------------------------------------------------------------

function TestIsIntervalTree()
	lu.assertTrue(IntervalTree.isIntervalTree(IntervalTree.new()))
	lu.assertFalse(IntervalTree.isIntervalTree({}))
	lu.assertFalse(IntervalTree.isIntervalTree(nil))
	lu.assertFalse(IntervalTree.isIntervalTree("intervaltree"))
	lu.assertFalse(IntervalTree.isIntervalTree(123))
end

-- ---------------------------------------------------------------------------
-- Constructor
-- ---------------------------------------------------------------------------

function TestConstructorEmpty()
	local it = IntervalTree.new()
	lu.assertTrue(it:empty())
	lu.assertEquals(0, #it)
end

function TestConstructorWithIterable()
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 }, { 20, 25 } })
	lu.assertFalse(it:empty())
	lu.assertEquals(3, #it)
	lu.assertTrue(it:contains(2))
	lu.assertTrue(it:contains(8))
	lu.assertTrue(it:contains(22))
	lu.assertFalse(it:contains(5))
end

function TestConstructorIterableMergesOverlaps()
	-- Overlapping pairs in iterable should be merged on insertion
	local it = IntervalTree.new({ { 1, 5 }, { 3, 8 }, { 20, 30 } })
	lu.assertEquals(2, #it)
	lu.assertTrue(it:contains(6))
	lu.assertFalse(it:contains(15))
end

function TestConstructorNilIterable()
	lu.assertNotNil(IntervalTree.new(nil))
	lu.assertEquals(0, #IntervalTree.new(nil))
end

function TestConstructorValidation()
	lu.assertError(IntervalTree.new, "not_a_table")
	lu.assertError(IntervalTree.new, 42)
end

-- ---------------------------------------------------------------------------
-- clear / empty
-- ---------------------------------------------------------------------------

function TestEmptyAndClear()
	local it = IntervalTree.new()

	lu.assertTrue(it:empty())
	lu.assertEquals(0, #it)

	it:insert(1, 2)
	lu.assertFalse(it:empty())
	lu.assertEquals(1, #it)

	it:clear()
	lu.assertTrue(it:empty())
	lu.assertEquals(0, #it)

	-- Re-use after clear
	it:insert(3, 4)
	it:insert(8, 9)
	lu.assertFalse(it:empty())
	lu.assertEquals(2, #it)
end

-- ---------------------------------------------------------------------------
-- contains
-- ---------------------------------------------------------------------------

function TestContains()
	local it = IntervalTree.new()
	lu.assertFalse(it:contains(0))

	it:insert(7, 10)
	it:insert(1, 3)

	lu.assertTrue(it:contains(8))
	lu.assertTrue(it:contains(10))
	lu.assertTrue(it:contains(1))

	-- Boundaries are inclusive
	lu.assertTrue(it:contains(7))
	lu.assertTrue(it:contains(3))

	lu.assertFalse(it:contains(4))
	lu.assertFalse(it:contains(5))
	lu.assertFalse(it:contains(11))
end

function TestContainsValidation()
	local it = IntervalTree.new()
	lu.assertError(function()
		it:contains("not_a_number")
	end)
	lu.assertError(function()
		it:contains(nil)
	end)
end

-- ---------------------------------------------------------------------------
-- insert
-- ---------------------------------------------------------------------------

function TestInsert()
	local it = IntervalTree.new()

	it:insert(4, 8)
	it:insert(5, 10)
	it:insert(1, 3)

	lu.assertEquals(2, #it)

	it:insert(2, 7)
	lu.assertEquals(1, #it)

	for low, high in pairs(it) do
		lu.assertEquals(1, low)
		lu.assertEquals(10, high)
	end
end

function TestInsertSwappedBoundaries()
	-- insert(high, low) should be normalised to insert(low, high)
	local it = IntervalTree.new()
	it:insert(10, 1)
	lu.assertEquals(1, #it)
	lu.assertTrue(it:contains(5))
end

function TestInsertValidation()
	local it = IntervalTree.new()
	lu.assertError(function()
		it:insert("a", 1)
	end)
	lu.assertError(function()
		it:insert(1, "b")
	end)
end

function TestInsertMergesAdjacent()
	-- [1,3] and [3,6] share boundary 3 -- they overlap and must merge
	local it = IntervalTree.new()
	it:insert(1, 3)
	it:insert(3, 6)
	lu.assertEquals(1, #it)
	lu.assertTrue(it:contains(3))
	lu.assertTrue(it:contains(5))
end

function TestInsertManyMerge()
	local it = IntervalTree.new()
	-- Insert non-overlapping first
	it:insert(1, 2)
	it:insert(5, 6)
	it:insert(9, 10)
	lu.assertEquals(3, #it)

	-- Now bridge all three
	it:insert(2, 9)
	lu.assertEquals(1, #it)

	local low, high = pairs(it)()
	lu.assertEquals(1, low)
	lu.assertEquals(10, high)
end

-- ---------------------------------------------------------------------------
-- remove
-- ---------------------------------------------------------------------------

function TestRemoveExact()
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 }, { 20, 25 } })
	lu.assertEquals(3, #it)

	lu.assertEquals(1, it:remove(7, 10))
	lu.assertEquals(2, #it)
	lu.assertFalse(it:contains(8))
	lu.assertTrue(it:contains(2))
end

function TestRemoveNotFound()
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 } })
	lu.assertEquals(0, it:remove(4, 6)) -- no overlap with [1, 3] or [7, 10]
	lu.assertEquals(2, #it)
end

function TestRemoveFromEmpty()
	local it = IntervalTree.new()
	lu.assertEquals(0, it:remove(1, 5))
	lu.assertEquals(0, #it)
end

function TestRemoveSwappedBoundaries()
	local it = IntervalTree.new({ { 1, 5 } })
	lu.assertEquals(1, it:remove(5, 1)) -- normalised internally
	lu.assertTrue(it:empty())
end

function TestRemovePartialOverlap()
	local it = IntervalTree.new({ { 1, 5 }, { 10, 15 } })
	lu.assertEquals(1, it:remove(4, 8)) -- overlaps [1, 5]
	lu.assertEquals(1, #it)
	lu.assertFalse(it:contains(3))
	lu.assertTrue(it:contains(12))
end

function TestRemoveMultipleOverlaps()
	local it = IntervalTree.new({ { 1, 3 }, { 5, 8 }, { 10, 12 }, { 15, 20 } })
	lu.assertEquals(4, #it)

	-- Overlaps [1, 3], [5, 8], and [10, 12]
	lu.assertEquals(3, it:remove(2, 11))
	lu.assertEquals(1, #it)
	lu.assertFalse(it:contains(2))
	lu.assertFalse(it:contains(6))
	lu.assertFalse(it:contains(11))
	lu.assertTrue(it:contains(18))
end

function TestRemoveTouchingBoundaries()
	local it = IntervalTree.new({ { 1, 3 }, { 5, 8 } })
	-- [3, 5] touches upper bound of [1, 3] and lower bound of [5, 8]
	lu.assertEquals(2, it:remove(3, 5))
	lu.assertEquals(0, #it)
	lu.assertTrue(it:empty())
end

function TestRemoveLenCorrectness()
	-- Validates the two-child deletion bug is fixed
	local it = IntervalTree.new()
	it:insert(10, 20)
	it:insert(1, 5)
	it:insert(25, 30)
	lu.assertEquals(3, #it)

	-- Remove root (two children)
	lu.assertEquals(1, it:remove(10, 20))
	lu.assertEquals(2, #it)

	-- Remove leaf
	lu.assertEquals(1, it:remove(1, 5))
	lu.assertEquals(1, #it)

	-- Remove last node
	lu.assertEquals(1, it:remove(25, 30))
	lu.assertEquals(0, #it)
	lu.assertTrue(it:empty())
end

function TestRemoveValidation()
	local it = IntervalTree.new()
	lu.assertError(function()
		it:remove("a", 1)
	end)
	lu.assertError(function()
		it:remove(1, "b")
	end)
end

-- ---------------------------------------------------------------------------
-- __concat
-- ---------------------------------------------------------------------------

function TestConcat()
	local it = IntervalTree.new() .. { { 1, 3 }, { 7, 10 } }
	lu.assertEquals(2, #it)
	lu.assertTrue(it:contains(2))
	lu.assertTrue(it:contains(9))
end

function TestConcatNil()
	local it = IntervalTree.new() .. nil
	lu.assertEquals(0, #it)
end

function TestConcatMergesOverlaps()
	local it = IntervalTree.new({ { 1, 5 } }) .. { { 3, 8 } }
	lu.assertEquals(1, #it)
	lu.assertTrue(it:contains(6))
end

function TestConcatChaining()
	local it = IntervalTree.new() .. { { 1, 2 } }
	it = it .. { { 10, 20 } }
	lu.assertEquals(2, #it)
end

function TestConcatValidation()
	local it = IntervalTree.new()
	lu.assertError(function()
		it = it .. "not_a_table"
	end)
	lu.assertError(function()
		it = it .. 42
	end)
end

-- ---------------------------------------------------------------------------
-- __eq
-- ---------------------------------------------------------------------------

function TestEquality()
	local it1 = IntervalTree.new({ { 1, 3 }, { 7, 10 } })
	local it2 = IntervalTree.new({ { 7, 10 }, { 1, 3 } }) -- insertion order differs
	local it3 = IntervalTree.new({ { 1, 3 }, { 7, 11 } })
	local it4 = IntervalTree.new({ { 1, 3 } })

	lu.assertTrue(it1 == it2)
	lu.assertFalse(it1 == it3)
	lu.assertFalse(it1 == it4)
	lu.assertFalse(it1 == nil)
	lu.assertFalse(it1 == {})
	lu.assertFalse(it1 == 42)
end

function TestEqualityEmpty()
	local e1 = IntervalTree.new()
	local e2 = IntervalTree.new()
	lu.assertTrue(e1 == e2)
end

-- ---------------------------------------------------------------------------
-- __len
-- ---------------------------------------------------------------------------

function TestLen()
	local it = IntervalTree.new()
	lu.assertEquals(0, #it)

	it:insert(1, 2)
	lu.assertEquals(1, #it)

	it:insert(8, 9)
	lu.assertEquals(2, #it)

	-- Overlapping insert reduces count
	it:insert(1, 9)
	lu.assertEquals(1, #it)
end

-- ---------------------------------------------------------------------------
-- __pairs  (in-order)
-- ---------------------------------------------------------------------------

function TestPairsInOrder()
	local it = IntervalTree.new({ { 10, 20 }, { 1, 3 }, { 50, 60 }, { 30, 40 } })
	local res = {}
	for low, high in pairs(it) do
		table.insert(res, { low, high })
	end

	-- Expect ascending by low
	lu.assertEquals({
		{ 1, 3 },
		{ 10, 20 },
		{ 30, 40 },
		{ 50, 60 },
	}, res)
end

function TestPairsEmpty()
	local it = IntervalTree.new()
	local count = 0
	for _ in pairs(it) do
		count = count + 1
	end
	lu.assertEquals(0, count)
end

-- ---------------------------------------------------------------------------
-- __tostring
-- ---------------------------------------------------------------------------

function TestToString()
	local empty = IntervalTree.new()
	lu.assertEquals("{  }", tostring(empty))

	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 } })
	lu.assertEquals("{ [1, 3], [7, 10] }", tostring(it))
end

os.exit(lu.LuaUnit.run())
