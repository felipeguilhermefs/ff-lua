local lu = require("luaunit")
local IntervalTree = require("ff.collections.intervaltree")

local TestIntervalTree = {}

function TestIntervalTree:testTypeGuard_RecognizesIntervalTreesAndRejectsOtherValues()
	lu.assertTrue(IntervalTree.isIntervalTree(IntervalTree.new()))
	lu.assertFalse(IntervalTree.isIntervalTree({}))
	lu.assertFalse(IntervalTree.isIntervalTree(nil))
	lu.assertFalse(IntervalTree.isIntervalTree("intervaltree"))
	lu.assertFalse(IntervalTree.isIntervalTree(123))
end

function TestIntervalTree:testEmptyConstructor_CreatesEmptyIntervalTree()
	local it = IntervalTree.new()

	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testConstructor_PreservesDisjointIntervals()
	local it = IntervalTree.new({ [1] = 3, [7] = 10, [20] = 25 })

	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 3)
	lu.assertTrue(it:contains(2))
	lu.assertTrue(it:contains(8))
	lu.assertTrue(it:contains(22))
	lu.assertFalse(it:contains(5))
end

function TestIntervalTree:testConstructor_MergesOverlappingIntervals()
	local it = IntervalTree.new({ [1] = 5, [3] = 8, [20] = 30 })

	lu.assertEquals(#it, 2)
	lu.assertTrue(it:contains(6))
	lu.assertFalse(it:contains(15))
end

function TestIntervalTree:testConstructor_TreatsNilIterableAsEmpty()
	lu.assertNotNil(IntervalTree.new(nil))
	lu.assertEquals(#IntervalTree.new(nil), 0)
end

function TestIntervalTree:testConstructor_RejectsNonTableIterables()
	lu.assertErrorMsgContains("iterable should be a table", IntervalTree.new, "not_a_table")
	lu.assertErrorMsgContains("iterable should be a table", IntervalTree.new, 42)
end

function TestIntervalTree:testContains_ReportsValuesInsideInclusiveIntervals()
	local it = IntervalTree.new()
	it:insert(7, 10)
	it:insert(1, 3)

	local has1 = it:contains(1)
	local has3 = it:contains(3)
	local has7 = it:contains(7)
	local has8 = it:contains(8)
	local has10 = it:contains(10)
	local has0 = it:contains(0)
	local has4 = it:contains(4)
	local has5 = it:contains(5)
	local has11 = it:contains(11)

	lu.assertTrue(has1)
	lu.assertTrue(has3)
	lu.assertTrue(has7)
	lu.assertTrue(has8)
	lu.assertTrue(has10)
	lu.assertFalse(has0)
	lu.assertFalse(has4)
	lu.assertFalse(has5)
	lu.assertFalse(has11)
end

function TestIntervalTree:testContains_RejectsNonNumericValues()
	local it = IntervalTree.new()

	lu.assertErrorMsgContains("'value' should be a number", function()
		it:contains("not_a_number")
	end)
	lu.assertErrorMsgContains("'value' should be a number", function()
		it:contains(nil)
	end)
end

function TestIntervalTree:testIteration_YieldsIntervalsInAscendingOrder()
	local it = IntervalTree.new({ [10] = 20, [1] = 3, [50] = 60, [30] = 40 })
	local res = {}

	for low, high in pairs(it) do
		table.insert(res, { low, high })
	end

	lu.assertEquals(res, {
		{ 1, 3 },
		{ 10, 20 },
		{ 30, 40 },
		{ 50, 60 },
	})
end

function TestIntervalTree:testEmptyIntervalTreeIteration_YieldsNoIntervals()
	local it = IntervalTree.new()
	local count = 0

	for _ in pairs(it) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestIntervalTree:testClear_EmptiesIntervalTreeAndAllowsReuse()
	local it = IntervalTree.new()
	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)

	it:insert(1, 2)

	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 1)

	it:clear()

	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)

	it:insert(3, 4)
	it:insert(8, 9)

	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 2)
end

function TestIntervalTree:testInsert_MergesOverlappingIntervals()
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

function TestIntervalTree:testInsert_NormalizesReversedBoundaries()
	local it = IntervalTree.new()

	it:insert(10, 1)

	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(5))
end

function TestIntervalTree:testInsert_RejectsNonNumericBoundaries()
	local it = IntervalTree.new()

	lu.assertErrorMsgContains("'low' should be a number", function()
		it:insert("a", 1)
	end)
	lu.assertErrorMsgContains("'high' should be a number", function()
		it:insert(1, "b")
	end)
end

function TestIntervalTree:testInsert_MergesIntervalsThatShareBoundary()
	local it = IntervalTree.new()

	it:insert(1, 3)
	it:insert(3, 6)

	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(3))
	lu.assertTrue(it:contains(5))
end

function TestIntervalTree:testInsert_MergesMultipleIntervalsConnectedByNewInterval()
	local it = IntervalTree.new()
	it:insert(1, 2)
	it:insert(5, 6)
	it:insert(9, 10)
	lu.assertEquals(#it, 3)

	it:insert(2, 9)

	lu.assertEquals(#it, 1)
	local low, high = pairs(it)()
	lu.assertEquals(low, 1)
	lu.assertEquals(high, 10)
end

function TestIntervalTree:testRemove_DeletesExactInterval()
	local it = IntervalTree.new({ [1] = 3, [7] = 10, [20] = 25 })

	lu.assertEquals(#it, 3)

	lu.assertEquals(it:remove(7, 10), 1)
	lu.assertEquals(#it, 2)
	lu.assertFalse(it:contains(8))
	lu.assertTrue(it:contains(2))
end

function TestIntervalTree:testRemove_LeavesTreeUnchangedWhenIntervalIsMissing()
	local it = IntervalTree.new({ [1] = 3, [7] = 10 })

	lu.assertEquals(it:remove(4, 6), 0) -- no overlap with [1, 3] or [7, 10]
	lu.assertEquals(#it, 2)
end

function TestIntervalTree:testRemoveFromEmptyTree_ReturnsNoRemoval()
	local it = IntervalTree.new()

	lu.assertEquals(it:remove(1, 5), 0)
	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testRemove_NormalizesReversedBoundaries()
	local it = IntervalTree.new({ [1] = 5 })

	lu.assertEquals(it:remove(5, 1), 1) -- normalised internally
	lu.assertTrue(it:empty())
end

function TestIntervalTree:testRemove_TrimsPartiallyOverlappingInterval()
	local it = IntervalTree.new({ [1] = 5, [10] = 15 })

	lu.assertEquals(it:remove(4, 8), 1) -- overlaps [1, 5]
	lu.assertEquals(#it, 1)
	lu.assertFalse(it:contains(3))
	lu.assertTrue(it:contains(12))
end

function TestIntervalTree:testRemove_TrimsMultipleOverlappingIntervals()
	local it = IntervalTree.new({ [1] = 3, [5] = 8, [10] = 12, [15] = 20 })

	lu.assertEquals(#it, 4)

	lu.assertEquals(it:remove(2, 11), 3)
	lu.assertEquals(#it, 1)
	lu.assertFalse(it:contains(2))
	lu.assertFalse(it:contains(6))
	lu.assertFalse(it:contains(11))
	lu.assertTrue(it:contains(18))
end

function TestIntervalTree:testRemove_PreservesIntervalsThatOnlyTouchRemovedRange()
	local it = IntervalTree.new({ [1] = 3, [5] = 8 })

	lu.assertEquals(it:remove(3, 5), 2)
	lu.assertEquals(#it, 0)
	lu.assertTrue(it:empty())
end

function TestIntervalTree:testRemove_UpdatesIntervalCount()
	local it = IntervalTree.new()

	it:insert(10, 20)
	it:insert(1, 5)
	it:insert(25, 30)

	lu.assertEquals(#it, 3)

	lu.assertEquals(it:remove(10, 20), 1)
	lu.assertEquals(#it, 2)

	lu.assertEquals(it:remove(1, 5), 1)
	lu.assertEquals(#it, 1)

	lu.assertEquals(it:remove(25, 30), 1)
	lu.assertEquals(#it, 0)
	lu.assertTrue(it:empty())
end

function TestIntervalTree:testRemove_RejectsNonNumericBoundaries()
	local it = IntervalTree.new()

	lu.assertErrorMsgContains("'low' should be a number", function()
		it:remove("a", 1)
	end)
	lu.assertErrorMsgContains("'high' should be a number", function()
		it:remove(1, "b")
	end)
end

function TestIntervalTree:testConcat_CombinesDisjointIntervals()
	local it = IntervalTree.new()

	it = it .. { [1] = 3, [7] = 10 }

	lu.assertEquals(#it, 2)
	lu.assertTrue(it:contains(2))
	lu.assertTrue(it:contains(9))
end

function TestIntervalTree:testConcatWithNil_PreservesIntervals()
	local it = IntervalTree.new()

	it = it .. nil

	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testConcat_MergesOverlappingIntervals()
	local it = IntervalTree.new({ [1] = 5 })

	it = it .. { [3] = 8 }

	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(6))
end

function TestIntervalTree:testConcat_SupportsChainedIntervalAppends()
	local it = IntervalTree.new()

	it = it .. { [1] = 2 }
	it = it .. { [10] = 20 }

	lu.assertEquals(#it, 2)
end

function TestIntervalTree:testConcat_RejectsNonTableValues()
	local it = IntervalTree.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		it = it .. "not_a_table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		it = it .. 42
	end)
end

function TestIntervalTree:testIntervalTreesWithSameIntervals_CompareEqual()
	local it1 = IntervalTree.new({ [1] = 3, [7] = 10 })
	local it2 = IntervalTree.new({ [7] = 10, [1] = 3 }) -- insertion order differs
	local it3 = IntervalTree.new({ [1] = 3, [7] = 11 })
	local it4 = IntervalTree.new({ [1] = 3 })

	lu.assertTrue(it1 == it2)
	lu.assertFalse(it1 == it3)
	lu.assertFalse(it1 == it4)
	lu.assertFalse(it1 == nil)
	lu.assertFalse(it1 == {})
	lu.assertFalse(it1 == 42)
end

function TestIntervalTree:testEmptyIntervalTrees_CompareEqual()
	local e1 = IntervalTree.new()
	local e2 = IntervalTree.new()

	lu.assertTrue(e1 == e2)
end

function TestIntervalTree:testLength_ReportsNumberOfDisjointIntervals()
	local it = IntervalTree.new()
	lu.assertEquals(#it, 0)

	it:insert(1, 2)
	it:insert(8, 9)

	lu.assertEquals(#it, 2)

	it:insert(1, 9)

	lu.assertEquals(#it, 1)
end

function TestIntervalTree:testToString_FormatsIntervals()
	local empty = IntervalTree.new()

	lu.assertEquals(tostring(empty), "{  }")

	local it = IntervalTree.new({ [1] = 3, [7] = 10 })
	lu.assertEquals(tostring(it), "{ [1, 3], [7, 10] }")
end

function TestIntervalTree:testNewPropertiesAndMethods_CannotBeAddedOrReplaced()
	local it = IntervalTree.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to IntervalTree", function()
		it.foo = "bar"
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to IntervalTree", function()
		it[1] = 99
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to IntervalTree", function()
		it.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to IntervalTree", function()
		it.insert = function() end
	end)
end

function TestIntervalTree:testConcat_CreatesNewTreeAndInsertAllMutates()
	local source = IntervalTree.new({ [1] = 2 })
	local joined = source .. { [4] = 5 }
	lu.assertNotIs(joined, source)
	lu.assertEquals(#source, 1)
	lu.assertEquals(#joined, 2)
	source:insertAll({ [7] = 8 })
	lu.assertEquals(#source, 2)
end

function TestIntervalTree:testInsertAllRejectsNil()
	local collection = IntervalTree.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		collection:insertAll(nil)
	end)
end

return { TestIntervalTree = TestIntervalTree }
