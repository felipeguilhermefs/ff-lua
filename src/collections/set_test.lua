-- Imports
local lu = require("luaunit")
local Set = require("ff.collections.set")

-- Suite definitions
local TestSet = {}

-- Scenarios: construction and type recognition

function TestSet:testTypeGuard_Recognizes_SetsAndRejectsOtherValues()
	-- Given: candidates include Set instances, a table, and scalars.
	-- When: check each candidate with Set.isSet.
	-- Then: only Set instances return true.
	lu.assertTrue(Set.isSet(Set.new()))
	lu.assertTrue(Set.isSet(Set.new({ 1, 2, 3 })))
	lu.assertFalse(Set.isSet({ 1, 2, 3 }))
	lu.assertFalse(Set.isSet(nil))
	lu.assertFalse(Set.isSet("set"))
	lu.assertFalse(Set.isSet(123))
end

-- Scenarios: reads and inspection

function TestSet:testEmptySet_DoesNotContain_Values()
	-- Given: a new Set has no members.
	-- When: check membership of e.
	-- Then: contains returns false for e when the Set is empty.
	lu.assertFalse(Set.new():contains("e"))
end

function TestSet:testContains_ReturnsTrue_WhenEveryRequestedValueIsPresent()
	-- Given: the first Set has a, b, c; the second has b, c, d.
	local set = Set.new({ "f", "g", "h" })

	-- When: check membership for all three, then for f and h.
	-- Then: contains returns true when all requested members exist.
	lu.assertTrue(set:contains("f", "g", "h"))
	lu.assertTrue(set:contains("f", "h"))
end

function TestSet:testContains_ReturnsFalse_WhenAnyRequestedValueIsMissing()
	-- Given: the Set contains f, g, h; query also includes absent i.
	local set = Set.new({ "f", "g", "h" })

	-- When: check membership for stored f and absent i.
	-- Then: contains returns false for the mixed request.
	lu.assertFalse(set:contains("f", "i"))
end

function TestSet:testContainsWithoutValues_Returns_False()
	-- Given: a Set contains f and the membership call has no arguments.
	-- When: call contains with an empty argument list.
	-- Then: contains returns false when called with no query values.
	lu.assertFalse(Set.new({ "f" }):contains())
end

function TestSet:testDiff_Returns_ValuesPresentOnlyInEachSet()
	-- Given: A contains a,b,c; B contains b,c,d; empty Set is a third case.
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	-- When: compute both directional differences and difference from empty.
	local setDiff1 = set1:diff(set2)

	-- Then: each result contains only values absent from the opposite set.
	lu.assertTrue(setDiff1:contains("a"))
	lu.assertEquals(#setDiff1, 1)

	local setDiff2 = set2:diff(set1)
	lu.assertTrue(setDiff2:contains("d"))
	lu.assertEquals(#setDiff2, 1)

	local setDiff3 = set1:diff(Set.new())
	lu.assertTrue(setDiff3:contains("a", "b", "c"))
	lu.assertEquals(#setDiff3, 3)
end

function TestSet:testIntersection_Returns_OnlySharedValues()
	-- Given: A and B share b,c and each has one unique member.
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	-- When: intersect in both directions and with an empty Set.
	local setInter1 = set1:intersection(set2)

	-- Then: intersections contain b and c; empty intersection has length zero.
	lu.assertTrue(setInter1:contains("b", "c"))
	lu.assertEquals(#setInter1, 2)

	local setInter2 = set2:intersection(set1)
	lu.assertTrue(setInter2:contains("b", "c"))
	lu.assertEquals(#setInter2, 2)

	local setInter3 = set1:intersection(Set.new())
	lu.assertEquals(#setInter3, 0)
end

function TestSet:testUnion_Returns_DistinctValuesFromBothSets()
	-- Given: A and B overlap on b,c and contribute unique a,d.
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	-- When: union in both directions and with an empty Set.
	local setUnion1 = set1:union(set2)

	-- Then: results contain each distinct member once.
	lu.assertTrue(setUnion1:contains("a", "b", "c", "d"))
	lu.assertEquals(#setUnion1, 4)

	local setUnion2 = set2:union(set1)
	lu.assertTrue(setUnion2:contains("a", "b", "c", "d"))
	lu.assertEquals(#setUnion2, 4)

	local setUnion3 = set1:union(Set.new())
	lu.assertTrue(setUnion3:contains("a", "b", "c"))
	lu.assertEquals(#setUnion3, 3)
end

function TestSet:testSymmetricDiff_Returns_ValuesPresentInOnlyOneSet()
	-- Given: sets overlap on 3 and 4; remaining members are unique.
	local set1 = Set.new({ 1, 2, 3, 4 })
	local set2 = Set.new({ 3, 4, 5, 6 })

	-- When: compute the symmetric difference.
	local sym = set1:symdiff(set2)

	-- Then: result contains 1, 2, 5, and 6, excluding 3 and 4.
	lu.assertEquals(#sym, 4)
	lu.assertTrue(sym:contains(1, 2, 5, 6))
	lu.assertFalse(sym:contains(3))
	lu.assertFalse(sym:contains(4))
end

function TestSet:testSubsetAndSuperset_Report_SetContainment()
	-- Given: one Set is a subset of another; a third Set is disjoint.
	local sub = Set.new({ 1, 2 })
	local super = Set.new({ 1, 2, 3, 4 })
	local other = Set.new({ 5, 6 })

	-- When: check subset and superset relations in both directions.
	-- Then: only the smaller-to-larger containment checks return true.
	lu.assertTrue(sub:subset(super))
	lu.assertFalse(super:subset(sub))
	lu.assertTrue(super:superset(sub))
	lu.assertFalse(sub:superset(super))

end

function TestSet:testDisjoint_Reports_WhetherSetsShareValues()
	-- Given: two Sets share 1 and 2; a third contains 5 and 6.
	local sub = Set.new({ 1, 2 })
	local super = Set.new({ 1, 2, 3, 4 })
	local other = Set.new({ 5, 6 })

	-- When: check disjointness against the shared and separate Sets.
	-- Then: only the pair with no shared members is disjoint.
	lu.assertTrue(sub:disjoint(other))
	lu.assertFalse(sub:disjoint(super))
end

function TestSet:testIteration_Yields_EveryStoredValue()
	-- Given: the Set contains integers 1 through 5.
	local set = Set.new({ 1, 2, 3, 4, 5 })

	local res = {}

	-- When: collect members yielded by pairs.
	for item in pairs(set) do
		table.insert(res, item)
	end

	-- Then: each stored integer appears in the collected results.
	lu.assertItemsEquals(res, { 1, 2, 3, 4, 5 })
end

-- Scenarios: state changes

function TestSet:testClear_Makes_SetEmpty()
	-- Given: an empty Set.
	local set = Set.new()

	-- When: check empty state initially.
	-- Then: empty returns true.
	lu.assertTrue(set:empty())

	-- When: add "a".
	set:add("a")

	-- Then: empty returns false.
	lu.assertFalse(set:empty())

	-- When: clear the set.
	set:clear()

	-- Then: empty returns true again.
	lu.assertTrue(set:empty())
end

function TestSet:testAdd_Reports_WhetherValueWasNew()
	-- Given: a new Set has no members; c and d are the candidate values.
	local set = Set.new()

	-- When: add c, repeat c, then add d.
	-- Then: add returns true only for new members and membership stays accurate.
	lu.assertTrue(set:add("c"))
	lu.assertTrue(set:contains("c"))

	lu.assertFalse(set:add("c"))
	lu.assertTrue(set:contains("c"))

	lu.assertTrue(set:add("d"))
	lu.assertTrue(set:contains("d", "c"))
end

function TestSet:testRemove_Deletes_OnlyRequestedValue()
	-- Given: a Set containing "f" and "g".
	local set = Set.new({ "f", "g" })
	lu.assertEquals(#set, 2)

	-- When: remove "f".
	set:remove("f")

	-- Then: "f" is absent, "g" remains, and size decreases to 1.
	lu.assertFalse(set:contains("f"))
	lu.assertTrue(set:contains("g"))
	lu.assertEquals(#set, 1)
end

function TestSet:testFalseValue_CanBeStoredAndRemovedAs_Value()
	-- Given: a new Set starts empty; false is the value under test.
	local set = Set.new()

	-- When: add false twice, then remove it twice.
	-- Then: false is stored once, removed once, and absent afterward.
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

function TestSet:testConcat_Adds_DistinctValuesFromIterables()
	-- Given: a Set initialized with { 10, 20, 30 }.
	local set = Set.new({ 10, 20, 30 })
	lu.assertEquals(#set, 3)

	-- When: concatenate with a table of new values.
	set = set .. { 40, 50, 60 }

	-- Then: new values are contained and size increases to 6.
	lu.assertTrue(set:contains(10, 20, 30, 40, 50, 60))
	lu.assertEquals(#set, 6)

	-- When: concatenate with nil.
	set = set .. nil

	-- Then: size remains 6.
	lu.assertEquals(#set, 6)

	-- When: concatenate with another Set containing 70, 80, 90.
	set = set .. Set.new({ 70, 80, 90 })

	-- Then: values are added and size increases to 9.
	lu.assertTrue(set:contains(70, 80, 90))
	lu.assertEquals(#set, 9)

	-- When: concatenate with a Queue containing 100.
	local q = require("ff.collections.queue").new()
	q:enqueue(100)
	set = set .. q

	-- Then: 100 is contained and size increases to 10.
	lu.assertTrue(set:contains(100))
	lu.assertEquals(#set, 10)
end

function TestSet:testSetsWithSameValues_Compare_EqualRegardlessOfInsertionOrder()
	-- Given: Sets have equal members in different orders, one difference, and one size mismatch.
	local s1 = Set.new({ 1, 2, 3 })
	local s2 = Set.new({ 3, 2, 1 })
	local s3 = Set.new({ 1, 2, 4 })
	local s4 = Set.new({ 1, 2 })

	-- Boolean assertions here intentionally exercise Set.__eq.

	-- When: compare each Set against s1, including non-Set values.
	-- Then: order does not affect equality; different members or types compare false.
	lu.assertTrue(s1 == s2)
	lu.assertFalse(s1 == s3)
	lu.assertFalse(s1 == s4)

	lu.assertFalse(s1 == { 1, 2, 3 })
	lu.assertFalse(s1 == nil)
	lu.assertFalse(s1 == 42)
end

function TestSet:testToString_Includes_StoredValues()
	-- Given: the Set contains a string, number, and boolean.
	local set = Set.new({ "hello", 123, true })

	-- When: format the Set with tostring.
	local str = tostring(set)

	-- Then: formatted text contains hello, 123, and true.
	lu.assertStrContains(str, "hello")
	lu.assertStrContains(str, "123")
	lu.assertStrContains(str, "true")
end

function TestSet:testNewPropertiesAndMethods_CannotBe_AddedOrReplaced()
	-- Given: the Set contains 1, 2, and 3 and already defines add.
	local s = Set.new({ 1, 2, 3 })

	-- disallow adding properties

	-- When: assign a property, numeric key, function, and replacement add method.
	-- Then: every assignment raises the property-protection error.
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
