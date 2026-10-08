local lu = require("luaunit")
local IntervalTree = require("ff.collections.intervaltree")

TestIntervalTree = {}

-- ---------------------------------------------------------------------------
-- isIntervalTree
-- ---------------------------------------------------------------------------

function TestIntervalTree:testIsIntervalTree()
	lu.assertTrue(IntervalTree.isIntervalTree(IntervalTree.new()))
	lu.assertFalse(IntervalTree.isIntervalTree({}))
	lu.assertFalse(IntervalTree.isIntervalTree(nil))
	lu.assertFalse(IntervalTree.isIntervalTree("intervaltree"))
	lu.assertFalse(IntervalTree.isIntervalTree(123))
end

-- ---------------------------------------------------------------------------
-- Constructor
-- ---------------------------------------------------------------------------

function TestIntervalTree:testConstructor_Empty()
	local it = IntervalTree.new()
	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testConstructor_WithIterable()
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 }, { 20, 25 } })
	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 3)
	lu.assertTrue(it:contains(2))
	lu.assertTrue(it:contains(8))
	lu.assertTrue(it:contains(22))
	lu.assertFalse(it:contains(5))
end

function TestIntervalTree:testConstructor_IterableMergesOverlaps()
	-- Overlapping pairs in iterable should be merged on insertion
	local it = IntervalTree.new({ { 1, 5 }, { 3, 8 }, { 20, 30 } })
	lu.assertEquals(#it, 2)
	lu.assertTrue(it:contains(6))
	lu.assertFalse(it:contains(15))
end

function TestIntervalTree:testConstructor_NilIterable()
	lu.assertNotNil(IntervalTree.new(nil))
	lu.assertEquals(#IntervalTree.new(nil), 0)
end

function TestIntervalTree:testConstructor_Validation()
	lu.assertErrorMsgContains("iterable should be a table", IntervalTree.new, "not_a_table")
	lu.assertErrorMsgContains("iterable should be a table", IntervalTree.new, 42)
end

-- ---------------------------------------------------------------------------
-- clear / empty
-- ---------------------------------------------------------------------------

function TestIntervalTree:testEmptyAndClear()
	local it = IntervalTree.new()

	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)

	it:insert(1, 2)
	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 1)

	it:clear()
	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)

	-- Re-use after clear
	it:insert(3, 4)
	it:insert(8, 9)
	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 2)
end

-- ---------------------------------------------------------------------------
-- contains
-- ---------------------------------------------------------------------------

function TestIntervalTree:testContains()
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

function TestIntervalTree:testContains_Validation()
	local it = IntervalTree.new()
	lu.assertErrorMsgContains("'value' should be a number", function()
		it:contains("not_a_number")
	end)
	lu.assertErrorMsgContains("'value' should be a number", function()
		it:contains(nil)
	end)
end

-- ---------------------------------------------------------------------------
-- insert
-- ---------------------------------------------------------------------------

function TestIntervalTree:testInsert()
	local it = IntervalTree.new()

	it:insert(4, 8)
	it:insert(5, 10)
	it:insert(1, 3)

	lu.assertEquals(#it, 2)

	it:insert(2, 7)
	lu.assertEquals(#it, 1)

	for low, high in pairs(it) do
		lu.assertEquals(low, 1)
		lu.assertEquals(high, 10)
	end
end

function TestIntervalTree:testInsert_SwappedBoundaries()
	-- insert(high, low) should be normalised to insert(low, high)
	local it = IntervalTree.new()
	it:insert(10, 1)
	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(5))
end

function TestIntervalTree:testInsert_Validation()
	local it = IntervalTree.new()
	lu.assertErrorMsgContains("'low' should be a number", function()
		it:insert("a", 1)
	end)
	lu.assertErrorMsgContains("'high' should be a number", function()
		it:insert(1, "b")
	end)
end

function TestIntervalTree:testInsert_MergesAdjacent()
	-- [1,3] and [3,6] share boundary 3 -- they overlap and must merge
	local it = IntervalTree.new()
	it:insert(1, 3)
	it:insert(3, 6)
	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(3))
	lu.assertTrue(it:contains(5))
end

function TestIntervalTree:testInsert_ManyMerge()
	local it = IntervalTree.new()
	-- Insert non-overlapping first
	it:insert(1, 2)
	it:insert(5, 6)
	it:insert(9, 10)
	lu.assertEquals(#it, 3)

	-- Now bridge all three
	it:insert(2, 9)
	lu.assertEquals(#it, 1)

	local low, high = pairs(it)()
	lu.assertEquals(low, 1)
	lu.assertEquals(high, 10)
end

-- ---------------------------------------------------------------------------
-- remove
-- ---------------------------------------------------------------------------

function TestIntervalTree:testRemove_Exact()
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 }, { 20, 25 } })
	lu.assertEquals(#it, 3)

	lu.assertEquals(it:remove(7, 10), 1)
	lu.assertEquals(#it, 2)
	lu.assertFalse(it:contains(8))
	lu.assertTrue(it:contains(2))
end

function TestIntervalTree:testRemove_NotFound()
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 } })
	lu.assertEquals(it:remove(4, 6), 0) -- no overlap with [1, 3] or [7, 10]
	lu.assertEquals(#it, 2)
end

function TestIntervalTree:testRemove_FromEmpty()
	local it = IntervalTree.new()
	lu.assertEquals(it:remove(1, 5), 0)
	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testRemove_SwappedBoundaries()
	local it = IntervalTree.new({ { 1, 5 } })
	lu.assertEquals(it:remove(5, 1), 1) -- normalised internally
	lu.assertTrue(it:empty())
end

function TestIntervalTree:testRemove_PartialOverlap()
	local it = IntervalTree.new({ { 1, 5 }, { 10, 15 } })
	lu.assertEquals(it:remove(4, 8), 1) -- overlaps [1, 5]
	lu.assertEquals(#it, 1)
	lu.assertFalse(it:contains(3))
	lu.assertTrue(it:contains(12))
end

function TestIntervalTree:testRemove_MultipleOverlaps()
	local it = IntervalTree.new({ { 1, 3 }, { 5, 8 }, { 10, 12 }, { 15, 20 } })
	lu.assertEquals(#it, 4)

	-- Overlaps [1, 3], [5, 8], and [10, 12]
	lu.assertEquals(it:remove(2, 11), 3)
	lu.assertEquals(#it, 1)
	lu.assertFalse(it:contains(2))
	lu.assertFalse(it:contains(6))
	lu.assertFalse(it:contains(11))
	lu.assertTrue(it:contains(18))
end

function TestIntervalTree:testRemove_TouchingBoundaries()
	local it = IntervalTree.new({ { 1, 3 }, { 5, 8 } })
	-- [3, 5] touches upper bound of [1, 3] and lower bound of [5, 8]
	lu.assertEquals(it:remove(3, 5), 2)
	lu.assertEquals(#it, 0)
	lu.assertTrue(it:empty())
end

function TestIntervalTree:testRemove_LenCorrectness()
	-- Validates the two-child deletion bug is fixed
	local it = IntervalTree.new()
	it:insert(10, 20)
	it:insert(1, 5)
	it:insert(25, 30)
	lu.assertEquals(#it, 3)

	-- Remove root (two children)
	lu.assertEquals(it:remove(10, 20), 1)
	lu.assertEquals(#it, 2)

	-- Remove leaf
	lu.assertEquals(it:remove(1, 5), 1)
	lu.assertEquals(#it, 1)

	-- Remove last node
	lu.assertEquals(it:remove(25, 30), 1)
	lu.assertEquals(#it, 0)
	lu.assertTrue(it:empty())
end

function TestIntervalTree:testRemove_Validation()
	local it = IntervalTree.new()
	lu.assertErrorMsgContains("'low' should be a number", function()
		it:remove("a", 1)
	end)
	lu.assertErrorMsgContains("'high' should be a number", function()
		it:remove(1, "b")
	end)
end

-- ---------------------------------------------------------------------------
-- __concat
-- ---------------------------------------------------------------------------

function TestIntervalTree:testConcat()
	local it = IntervalTree.new() .. { { 1, 3 }, { 7, 10 } }
	lu.assertEquals(#it, 2)
	lu.assertTrue(it:contains(2))
	lu.assertTrue(it:contains(9))
end

function TestIntervalTree:testConcat_Nil()
	local it = IntervalTree.new() .. nil
	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testConcat_MergesOverlaps()
	local it = IntervalTree.new({ { 1, 5 } }) .. { { 3, 8 } }
	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(6))
end

function TestIntervalTree:testConcat_Chaining()
	local it = IntervalTree.new() .. { { 1, 2 } }
	it = it .. { { 10, 20 } }
	lu.assertEquals(#it, 2)
end

function TestIntervalTree:testConcat_Validation()
	local it = IntervalTree.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		it = it .. "not_a_table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		it = it .. 42
	end)
end

-- ---------------------------------------------------------------------------
-- __eq
-- ---------------------------------------------------------------------------

function TestIntervalTree:testEquality()
	local it1 = IntervalTree.new({ { 1, 3 }, { 7, 10 } })
	local it2 = IntervalTree.new({ { 7, 10 }, { 1, 3 } }) -- insertion order differs
	local it3 = IntervalTree.new({ { 1, 3 }, { 7, 11 } })
	local it4 = IntervalTree.new({ { 1, 3 } })

	-- Boolean assertions here intentionally exercise IntervalTree.__eq.
	lu.assertTrue(it1 == it2)
	lu.assertFalse(it1 == it3)
	lu.assertFalse(it1 == it4)
	lu.assertFalse(it1 == nil)
	lu.assertFalse(it1 == {})
	lu.assertFalse(it1 == 42)
end

function TestIntervalTree:testEquality_Empty()
	local e1 = IntervalTree.new()
	local e2 = IntervalTree.new()
	-- This assertion exercises IntervalTree.__eq; assertEquals compares table structure.
	lu.assertTrue(e1 == e2)
end

-- ---------------------------------------------------------------------------
-- __len
-- ---------------------------------------------------------------------------

function TestIntervalTree:testLen()
	local it = IntervalTree.new()
	lu.assertEquals(#it, 0)

	it:insert(1, 2)
	lu.assertEquals(#it, 1)

	it:insert(8, 9)
	lu.assertEquals(#it, 2)

	-- Overlapping insert reduces count
	it:insert(1, 9)
	lu.assertEquals(#it, 1)
end

-- ---------------------------------------------------------------------------
-- __pairs  (in-order)
-- ---------------------------------------------------------------------------

function TestIntervalTree:testPairs_InOrder()
	local it = IntervalTree.new({ { 10, 20 }, { 1, 3 }, { 50, 60 }, { 30, 40 } })
	local res = {}
	for low, high in pairs(it) do
		table.insert(res, { low, high })
	end

	-- Expect ascending by low
	lu.assertEquals(res, {
		{ 1, 3 },
		{ 10, 20 },
		{ 30, 40 },
		{ 50, 60 },
	})
end

function TestIntervalTree:testPairs_Empty()
	local it = IntervalTree.new()
	local count = 0
	for _ in pairs(it) do
		count = count + 1
	end
	lu.assertEquals(count, 0)
end

-- ---------------------------------------------------------------------------
-- __tostring
-- ---------------------------------------------------------------------------

function TestIntervalTree:testToString()
	local empty = IntervalTree.new()
	lu.assertEquals(tostring(empty), "{  }")

	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 } })
	lu.assertEquals(tostring(it), "{ [1, 3], [7, 10] }")
end

function TestIntervalTree:testNewIndex_PreventsModifications()
	local it = IntervalTree.new()

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to IntervalTree", function()
		it.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to IntervalTree", function()
		it[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to IntervalTree", function()
		it.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to IntervalTree", function()
		it.insert = function() end
	end)
end

