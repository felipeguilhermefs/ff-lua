-- Imports
local lu = require("luaunit")
local Set = require("ff.collections.set")

-- Suite definitions
local TestSet = {}

-- Scenarios: construction and type recognition

function TestSet:testTypeGuardRecognizesSetsAndRejectsOtherValues()
	lu.assertTrue(Set.isSet(Set.new()))
	lu.assertTrue(Set.isSet(Set.new({ 1, 2, 3 })))
	lu.assertFalse(Set.isSet({ 1, 2, 3 }))
	lu.assertFalse(Set.isSet(nil))
	lu.assertFalse(Set.isSet("set"))
	lu.assertFalse(Set.isSet(123))
end

-- Scenarios: reads and inspection

function TestSet:testEmptySetDoesNotContainValues()
	lu.assertFalse(Set.new():contains("e"))
end

function TestSet:testContainsReturnsTrueWhenEveryRequestedValueIsPresent()
	local set = Set.new({ "f", "g", "h" })
	lu.assertTrue(set:contains("f", "g", "h"))
	lu.assertTrue(set:contains("f", "h"))
end

function TestSet:testContainsReturnsFalseWhenAnyRequestedValueIsMissing()
	local set = Set.new({ "f", "g", "h" })
	lu.assertFalse(set:contains("f", "i"))
end

function TestSet:testContainsWithoutValuesReturnsFalse()
	lu.assertFalse(Set.new({ "f" }):contains())
end

function TestSet:testDiffReturnsValuesPresentOnlyInEachSet()
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	local setDiff1 = set1:diff(set2)
	lu.assertTrue(setDiff1:contains("a"))
	lu.assertEquals(#setDiff1, 1)

	local setDiff2 = set2:diff(set1)
	lu.assertTrue(setDiff2:contains("d"))
	lu.assertEquals(#setDiff2, 1)

	local setDiff3 = set1:diff(Set.new())
	lu.assertTrue(setDiff3:contains("a", "b", "c"))
	lu.assertEquals(#setDiff3, 3)
end

function TestSet:testIntersectionReturnsOnlySharedValues()
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	local setInter1 = set1:intersection(set2)
	lu.assertTrue(setInter1:contains("b", "c"))
	lu.assertEquals(#setInter1, 2)

	local setInter2 = set2:intersection(set1)
	lu.assertTrue(setInter2:contains("b", "c"))
	lu.assertEquals(#setInter2, 2)

	local setInter3 = set1:intersection(Set.new())
	lu.assertEquals(#setInter3, 0)
end

function TestSet:testUnionReturnsDistinctValuesFromBothSets()
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	local setUnion1 = set1:union(set2)
	lu.assertTrue(setUnion1:contains("a", "b", "c", "d"))
	lu.assertEquals(#setUnion1, 4)

	local setUnion2 = set2:union(set1)
	lu.assertTrue(setUnion2:contains("a", "b", "c", "d"))
	lu.assertEquals(#setUnion2, 4)

	local setUnion3 = set1:union(Set.new())
	lu.assertTrue(setUnion3:contains("a", "b", "c"))
	lu.assertEquals(#setUnion3, 3)
end

function TestSet:testSymmetricDiffReturnsValuesPresentInOnlyOneSet()
	local set1 = Set.new({ 1, 2, 3, 4 })
	local set2 = Set.new({ 3, 4, 5, 6 })

	local sym = set1:symdiff(set2)
	lu.assertEquals(#sym, 4)
	lu.assertTrue(sym:contains(1, 2, 5, 6))
	lu.assertFalse(sym:contains(3))
	lu.assertFalse(sym:contains(4))
end

function TestSet:testSubsetAndSupersetReportSetContainment()
	local sub = Set.new({ 1, 2 })
	local super = Set.new({ 1, 2, 3, 4 })
	local other = Set.new({ 5, 6 })

	lu.assertTrue(sub:subset(super))
	lu.assertFalse(super:subset(sub))
	lu.assertTrue(super:superset(sub))
	lu.assertFalse(sub:superset(super))

end

function TestSet:testDisjointReportsWhetherSetsShareValues()
	local sub = Set.new({ 1, 2 })
	local super = Set.new({ 1, 2, 3, 4 })
	local other = Set.new({ 5, 6 })
	lu.assertTrue(sub:disjoint(other))
	lu.assertFalse(sub:disjoint(super))
end

function TestSet:testIterationYieldsEveryStoredValue()
	local set = Set.new({ 1, 2, 3, 4, 5 })

	local res = {}
	for item in pairs(set) do
		table.insert(res, item)
	end
	lu.assertItemsEquals(res, { 1, 2, 3, 4, 5 })
end

-- Scenarios: state changes

function TestSet:testClearMakesSetEmpty()
	local set = Set.new()
	lu.assertTrue(set:empty())

	set:add("a")
	lu.assertFalse(set:empty())

	set:clear()
	lu.assertTrue(set:empty())
end

function TestSet:testAddReportsWhetherValueWasNew()
	local set = Set.new()

	lu.assertTrue(set:add("c"))
	lu.assertTrue(set:contains("c"))

	lu.assertFalse(set:add("c"))
	lu.assertTrue(set:contains("c"))

	lu.assertTrue(set:add("d"))
	lu.assertTrue(set:contains("d", "c"))
end

function TestSet:testRemoveDeletesOnlyRequestedValue()
	local set = Set.new({ "f", "g" })
	lu.assertEquals(#set, 2)

	set:remove("f")

	lu.assertFalse(set:contains("f"))
	lu.assertTrue(set:contains("g"))

	lu.assertEquals(#set, 1)
end

function TestSet:testFalseCanBeStoredAndRemovedAsAValue()
	local set = Set.new()
	lu.assertTrue(set:add(false))
	lu.assertEquals(#set, 1)
	lu.assertTrue(set:contains(false))

	lu.assertFalse(set:add(false))
	lu.assertEquals(#set, 1)

	lu.assertTrue(set:remove(false))
	lu.assertEquals(#set, 0)
	lu.assertFalse(set:contains(false))
	lu.assertFalse(set:remove(false))
end

-- Scenarios: metamethods and formatting

function TestSet:testConcatAddsDistinctValuesFromIterables()
	local set = Set.new({ 10, 20, 30 })
	lu.assertEquals(#set, 3)

	set = set .. { 40, 50, 60 }

	lu.assertTrue(set:contains(10, 20, 30, 40, 50, 60))
	lu.assertEquals(#set, 6)

	set = set .. nil
	lu.assertEquals(#set, 6)

	set = set .. Set.new({ 70, 80, 90 })
	lu.assertTrue(set:contains(70, 80, 90))
	lu.assertEquals(#set, 9)

	local q = require("ff.collections.queue").new()
	q:enqueue(100)
	set = set .. q

	lu.assertTrue(set:contains(100))
	lu.assertEquals(#set, 10)
end

function TestSet:testSetsCompareEqualRegardlessOfInsertionOrder()
	local s1 = Set.new({ 1, 2, 3 })
	local s2 = Set.new({ 3, 2, 1 })
	local s3 = Set.new({ 1, 2, 4 })
	local s4 = Set.new({ 1, 2 })

	-- Boolean assertions here intentionally exercise Set.__eq.
	lu.assertTrue(s1 == s2)
	lu.assertFalse(s1 == s3)
	lu.assertFalse(s1 == s4)

	lu.assertFalse(s1 == { 1, 2, 3 })
	lu.assertFalse(s1 == nil)
	lu.assertFalse(s1 == 42)
end

function TestSet:testToStringIncludesStoredValues()
	local set = Set.new({ "hello", 123, true })
	local str = tostring(set)

	lu.assertStrContains(str, "hello")
	lu.assertStrContains(str, "123")
	lu.assertStrContains(str, "true")
end

function TestSet:testNewPropertiesAndMethodsCannotBeAddedOrReplaced()
	local s = Set.new({ 1, 2, 3 })

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Set", function()
		s.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Set", function()
		s[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Set", function()
		s.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Set", function()
		s.add = function() end
	end)
end

-- Suite map
return { TestSet = TestSet }
