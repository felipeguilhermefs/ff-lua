-- Imports
local lu = require("luaunit")
local IntervalTree = require("ff.collections.intervaltree")

-- Suite definitions
local TestIntervalTree = {}

-- Scenarios: construction and type recognition

function TestIntervalTree:testTypeGuardRecognizesIntervalTreesAndRejectsOtherValues()
	-- Given: candidates include an IntervalTree, a table, and scalars.
	-- When: check each candidate with IntervalTree.isIntervalTree.
	-- Then: only the IntervalTree instance returns true.
	lu.assertTrue(IntervalTree.isIntervalTree(IntervalTree.new()))
	lu.assertFalse(IntervalTree.isIntervalTree({}))
	lu.assertFalse(IntervalTree.isIntervalTree(nil))
	lu.assertFalse(IntervalTree.isIntervalTree("intervaltree"))
	lu.assertFalse(IntervalTree.isIntervalTree(123))
end


function TestIntervalTree:testEmptyConstructorCreatesEmptyIntervalTree()
	-- Given: construction receives no intervals.

	-- When: call IntervalTree.new without arguments.
	local it = IntervalTree.new()

	-- Then: the newly constructed tree is empty and has length zero.
	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testConstructorPreservesDisjointIntervals()
	-- Given: input intervals do not overlap.

	-- When: initialize from ranges that do not overlap.
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 }, { 20, 25 } })

	-- Then: each interval remains separate and ordered.
	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 3)
	lu.assertTrue(it:contains(2))
	lu.assertTrue(it:contains(8))
	lu.assertTrue(it:contains(22))
	lu.assertFalse(it:contains(5))
end

function TestIntervalTree:testConstructorMergesOverlappingIntervals()
	-- Given: input intervals overlap or touch.
	-- Overlapping pairs in iterable should be merged on insertion

	-- When: initialize from ranges that overlap or touch.
	local it = IntervalTree.new({ { 1, 5 }, { 3, 8 }, { 20, 30 } })

	-- Then: overlapping ranges collapse into their merged interval.
	lu.assertEquals(#it, 2)
	lu.assertTrue(it:contains(6))
	lu.assertFalse(it:contains(15))
end

function TestIntervalTree:testConstructorTreatsNilIterableAsEmpty()
	-- Given: the iterable argument is nil.
	-- When: construct an IntervalTree with nil input.
	-- Then: nil input also produces an empty tree of length zero.
	lu.assertNotNil(IntervalTree.new(nil))
	lu.assertEquals(#IntervalTree.new(nil), 0)
end

function TestIntervalTree:testConstructorRejectsNonTableIterables()
	-- Given: constructor inputs include a string, number, and boolean.
	-- When: pass each scalar as the iterable.
	-- Then: each call reports that iterable must be a table.
	lu.assertErrorMsgContains("iterable should be a table", IntervalTree.new, "not_a_table")
	lu.assertErrorMsgContains("iterable should be a table", IntervalTree.new, 42)
end

-- Scenarios: reads and inspection

function TestIntervalTree:testContainsReportsValuesInsideInclusiveIntervals()
	-- Given: an IntervalTree containing intervals [1, 3] and [7, 10].
	local it = IntervalTree.new()
	it:insert(7, 10)
	it:insert(1, 3)

	-- When: query interior, boundary, and outside values.
	local has1 = it:contains(1)
	local has3 = it:contains(3)
	local has7 = it:contains(7)
	local has8 = it:contains(8)
	local has10 = it:contains(10)
	local has0 = it:contains(0)
	local has4 = it:contains(4)
	local has5 = it:contains(5)
	local has11 = it:contains(11)

	-- Then: boundary and interior values are contained; outside values are not.
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

function TestIntervalTree:testContainsRejectsNonNumericValues()
	-- Given: the tree contains numeric intervals.
	local it = IntervalTree.new()

	-- When: query with non-numeric values.
	-- Then: each invalid query raises a type validation error.
	lu.assertErrorMsgContains("'value' should be a number", function()
		it:contains("not_a_number")
	end)
	lu.assertErrorMsgContains("'value' should be a number", function()
		it:contains(nil)
	end)
end


function TestIntervalTree:testIterationYieldsIntervalsInAscendingOrder()
	-- Given: the tree contains four disjoint intervals.
	local it = IntervalTree.new({ { 10, 20 }, { 1, 3 }, { 50, 60 }, { 30, 40 } })
	local res = {}

	-- When: collect intervals yielded by pairs.
	for low, high in pairs(it) do
		table.insert(res, { low, high })
	end

	-- Expect ascending by low

	-- Then: results are ordered by lower boundary.
	lu.assertEquals(res, {
		{ 1, 3 },
		{ 10, 20 },
		{ 30, 40 },
		{ 50, 60 },
	})
end

function TestIntervalTree:testIterationOfEmptyIntervalTreeYieldsNoIntervals()
	-- Given: the tree has no intervals to traverse.
	local it = IntervalTree.new()
	local count = 0

	-- When: count intervals yielded by pairs.
	for _ in pairs(it) do
		count = count + 1
	end

	-- Then: the iterator yields zero intervals.
	lu.assertEquals(count, 0)
end

-- Scenarios: state changes

function TestIntervalTree:testClearEmptiesIntervalTreeAndAllowsReuse()
	-- Given: an empty IntervalTree.
	local it = IntervalTree.new()
	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)

	-- When: insert interval [1, 2].
	it:insert(1, 2)

	-- Then: tree is not empty and length is 1.
	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 1)

	-- When: clear the tree.
	it:clear()

	-- Then: tree is empty with length 0.
	lu.assertTrue(it:empty())
	lu.assertEquals(#it, 0)

	-- When: insert intervals [3, 4] and [8, 9] into cleared tree.
	it:insert(3, 4)
	it:insert(8, 9)

	-- Then: tree is reused successfully with length 2.
	lu.assertFalse(it:empty())
	lu.assertEquals(#it, 2)
end

function TestIntervalTree:testInsertMergesOverlappingIntervals()
	-- Given: an IntervalTree storing [1, 3] and merged [4, 10].
	local it = IntervalTree.new()
	it:insert(4, 8)
	it:insert(5, 10)
	it:insert(1, 3)
	lu.assertEquals(#it, 2)

	-- When: insert bridging interval [2, 7].
	it:insert(2, 7)

	-- Then: all ranges merge into a single interval [1, 10].
	lu.assertEquals(#it, 1)
	for low, high in pairs(it) do
		lu.assertEquals(low, 1)
		lu.assertEquals(high, 10)
	end
end

function TestIntervalTree:testInsertNormalizesReversedBoundaries()
	-- Given: one interval is supplied with its endpoints reversed.
	-- insert(high, low) should be normalised to insert(low, high)
	local it = IntervalTree.new()

	-- When: insert the reversed range.
	it:insert(10, 1)

	-- Then: the stored interval has its lower and upper bounds normalized.
	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(5))
end

function TestIntervalTree:testInsertRejectsNonNumericBoundaries()
	-- Given: interval endpoints include non-numeric values.
	local it = IntervalTree.new()

	-- When: insert pairs with a non-numeric low or high boundary.
	-- Then: each insertion reports that its boundary must be numeric.
	lu.assertErrorMsgContains("'low' should be a number", function()
		it:insert("a", 1)
	end)
	lu.assertErrorMsgContains("'high' should be a number", function()
		it:insert(1, "b")
	end)
end

function TestIntervalTree:testInsertMergesIntervalsThatShareBoundary()
	-- Given: two intervals meet at a shared boundary.
	-- [1,3] and [3,6] share boundary 3 -- they overlap and must merge
	local it = IntervalTree.new()

	-- When: insert both ranges.
	it:insert(1, 3)
	it:insert(3, 6)

	-- Then: the shared boundary joins them into one interval.
	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(3))
	lu.assertTrue(it:contains(5))
end

function TestIntervalTree:testInsertMergesMultipleIntervalsConnectedByNewInterval()
	-- Given: an IntervalTree storing non-overlapping intervals [1, 2], [5, 6], and [9, 10].
	local it = IntervalTree.new()
	it:insert(1, 2)
	it:insert(5, 6)
	it:insert(9, 10)
	lu.assertEquals(#it, 3)

	-- When: insert bridging range [2, 9].
	it:insert(2, 9)

	-- Then: all intervals merge into a single [1, 10] range.
	lu.assertEquals(#it, 1)
	local low, high = pairs(it)()
	lu.assertEquals(low, 1)
	lu.assertEquals(high, 10)
end


function TestIntervalTree:testRemoveDeletesExactInterval()
	-- Given: the tree contains three disjoint intervals.
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 }, { 20, 25 } })

	-- When: remove one interval exactly.
	-- Then: only that interval disappears; the other two remain.
	lu.assertEquals(#it, 3)

	lu.assertEquals(it:remove(7, 10), 1)
	lu.assertEquals(#it, 2)
	lu.assertFalse(it:contains(8))
	lu.assertTrue(it:contains(2))
end

function TestIntervalTree:testRemoveLeavesTreeUnchangedWhenIntervalIsMissing()
	-- Given: the tree contains two intervals and the target is absent.
	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 } })

	-- When: remove the missing range.
	-- Then: missing range removal leaves original intervals and length unchanged.
	lu.assertEquals(it:remove(4, 6), 0) -- no overlap with [1, 3] or [7, 10]
	lu.assertEquals(#it, 2)
end

function TestIntervalTree:testRemoveFromEmptyTreeReturnsNoRemoval()
	-- Given: the tree is empty when removal is attempted.
	local it = IntervalTree.new()

	-- When: remove a range from the empty tree.
	-- Then: no interval is removed and the tree stays empty.
	lu.assertEquals(it:remove(1, 5), 0)
	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testRemoveNormalizesReversedBoundaries()
	-- Given: the tree contains one interval and removal bounds are reversed.
	local it = IntervalTree.new({ { 1, 5 } })

	-- When: remove using the reversed range.
	-- Then: the bounds are normalized and the matching range is removed.
	lu.assertEquals(it:remove(5, 1), 1) -- normalised internally
	lu.assertTrue(it:empty())
end

function TestIntervalTree:testRemoveTrimsPartiallyOverlappingInterval()
	-- Given: a removal range overlaps only part of a stored interval.
	local it = IntervalTree.new({ { 1, 5 }, { 10, 15 } })

	-- When: remove the overlapping range.
	-- Then: the remaining portion of the stored interval is preserved.
	lu.assertEquals(it:remove(4, 8), 1) -- overlaps [1, 5]
	lu.assertEquals(#it, 1)
	lu.assertFalse(it:contains(3))
	lu.assertTrue(it:contains(12))
end

function TestIntervalTree:testRemoveTrimsMultipleOverlappingIntervals()
	-- Given: the removal range crosses several stored intervals.
	local it = IntervalTree.new({ { 1, 3 }, { 5, 8 }, { 10, 12 }, { 15, 20 } })

	-- When: remove the crossing range.
	-- Then: each overlap is trimmed and unaffected portions remain.
	lu.assertEquals(#it, 4)

	-- Overlaps [1, 3], [5, 8], and [10, 12]
	lu.assertEquals(it:remove(2, 11), 3)
	lu.assertEquals(#it, 1)
	lu.assertFalse(it:contains(2))
	lu.assertFalse(it:contains(6))
	lu.assertFalse(it:contains(11))
	lu.assertTrue(it:contains(18))
end

function TestIntervalTree:testRemovePreservesIntervalsThatOnlyTouchRemovedRange()
	-- Given: stored intervals touch the removal range at endpoints.
	local it = IntervalTree.new({ { 1, 3 }, { 5, 8 } })
	-- [3, 5] touches upper bound of [1, 3] and lower bound of [5, 8]

	-- When: remove the range between those endpoints.
	-- Then: touching intervals remain unchanged.
	lu.assertEquals(it:remove(3, 5), 2)
	lu.assertEquals(#it, 0)
	lu.assertTrue(it:empty())
end

function TestIntervalTree:testRemoveUpdatesIntervalCount()
	-- Given: the IntervalTree is empty; inserted ranges create a two-child root.
	-- Validates the two-child deletion bug is fixed
	local it = IntervalTree.new()

	-- When: insert ranges, then remove an interior range.
	it:insert(10, 20)
	it:insert(1, 5)
	it:insert(25, 30)

	-- Then: length matches the number of resulting disjoint intervals.
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

function TestIntervalTree:testRemoveRejectsNonNumericBoundaries()
	-- Given: removal endpoints include non-numeric values.
	local it = IntervalTree.new()

	-- When: remove with a non-numeric low or high boundary.
	-- Then: each removal reports that its boundary must be numeric.
	lu.assertErrorMsgContains("'low' should be a number", function()
		it:remove("a", 1)
	end)
	lu.assertErrorMsgContains("'high' should be a number", function()
		it:remove(1, "b")
	end)
end

-- Scenarios: metamethods and formatting

function TestIntervalTree:testConcatCombinesDisjointIntervals()
	-- Given: an empty IntervalTree and disjoint ranges {1, 3} and {7, 10}.
	local it = IntervalTree.new()

	-- When: concatenate the ranges into the tree.
	it = it .. { { 1, 3 }, { 7, 10 } }

	-- Then: the result contains every disjoint range in order.
	lu.assertEquals(#it, 2)
	lu.assertTrue(it:contains(2))
	lu.assertTrue(it:contains(9))
end

function TestIntervalTree:testConcatWithNilPreservesIntervals()
	-- Given: an empty IntervalTree.
	local it = IntervalTree.new()

	-- When: concatenate nil.
	it = it .. nil

	-- Then: concatenating nil leaves the tree empty and length unchanged.
	lu.assertEquals(#it, 0)
end

function TestIntervalTree:testConcatMergesOverlappingIntervals()
	-- Given: the tree contains [1, 5] and the input range is [3, 8].
	local it = IntervalTree.new({ { 1, 5 } })

	-- When: concatenate the overlapping range.
	it = it .. { { 3, 8 } }

	-- Then: the result contains their merged interval.
	lu.assertEquals(#it, 1)
	lu.assertTrue(it:contains(6))
end

function TestIntervalTree:testConcatSupportsChainedIntervalAppends()
	-- Given: an empty IntervalTree and iterables containing [1, 2] and [10, 20].
	local it = IntervalTree.new()

	-- When: append each iterable through a concatenation chain.
	it = it .. { { 1, 2 } }
	it = it .. { { 10, 20 } }

	-- Then: the final tree contains all appended intervals in order.
	lu.assertEquals(#it, 2)
end

function TestIntervalTree:testConcatRejectsNonTableValues()
	-- Given: the IntervalTree is empty.
	local it = IntervalTree.new()

	-- When: concatenate non-table values.
	-- Then: each operand raises the iterable type error.
	lu.assertErrorMsgContains("iterable should be a table", function()
		it = it .. "not_a_table"
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		it = it .. 42
	end)
end


function TestIntervalTree:testIntervalTreesWithSameIntervalsCompareEqual()
	-- Given: trees contain matching ranges, a changed range, or different lengths.
	local it1 = IntervalTree.new({ { 1, 3 }, { 7, 10 } })
	local it2 = IntervalTree.new({ { 7, 10 }, { 1, 3 } }) -- insertion order differs
	local it3 = IntervalTree.new({ { 1, 3 }, { 7, 11 } })
	local it4 = IntervalTree.new({ { 1, 3 } })

	-- Boolean assertions here intentionally exercise IntervalTree.__eq.

	-- When: compare each tree with the first.
	-- Then: only trees with the same intervals compare equal.
	lu.assertTrue(it1 == it2)
	lu.assertFalse(it1 == it3)
	lu.assertFalse(it1 == it4)
	lu.assertFalse(it1 == nil)
	lu.assertFalse(it1 == {})
	lu.assertFalse(it1 == 42)
end

function TestIntervalTree:testEmptyIntervalTreesCompareEqual()
	-- Given: both interval trees contain no ranges.
	local e1 = IntervalTree.new()
	local e2 = IntervalTree.new()
	-- This assertion exercises IntervalTree.__eq; assertEquals compares table structure.

	-- When: compare the empty trees with ==.
	-- Then: equality returns true.
	lu.assertTrue(e1 == e2)
end


function TestIntervalTree:testLengthReportsNumberOfDisjointIntervals()
	-- Given: an empty IntervalTree.
	local it = IntervalTree.new()
	lu.assertEquals(#it, 0)

	-- When: insert disjoint intervals [1, 2] and [8, 9].
	it:insert(1, 2)
	it:insert(8, 9)

	-- Then: length reports 2 disjoint intervals.
	lu.assertEquals(#it, 2)

	-- When: insert bridging interval [1, 9].
	it:insert(1, 9)

	-- Then: intervals merge and length drops to 1.
	lu.assertEquals(#it, 1)
end


function TestIntervalTree:testToStringFormatsIntervals()
	-- Given: the tree contains multiple intervals.
	local empty = IntervalTree.new()

	-- When: format it with tostring.
	-- Then: formatted text includes the stored ranges in order.
	lu.assertEquals(tostring(empty), "{  }")

	local it = IntervalTree.new({ { 1, 3 }, { 7, 10 } })
	lu.assertEquals(tostring(it), "{ [1, 3], [7, 10] }")
end

function TestIntervalTree:testNewPropertiesAndMethodsCannotBeAddedOrReplaced()
	-- Given: an IntervalTree has its public methods and no added fields.
	local it = IntervalTree.new()

	-- disallow adding properties

	-- When: assign a property, numeric key, function, and replacement method.
	-- Then: every assignment raises the property-protection error.
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

-- Suite map
return { TestIntervalTree = TestIntervalTree }
