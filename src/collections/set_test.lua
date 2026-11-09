local lu = require("luaunit")
local Set = require("ff.collections.set")

local function snapshot(set)
	local entries = {}
	for key, value in pairs(set) do
		entries[key] = value
	end
	return entries
end

local TestSetAdd = {}
local TestSetAddAll = {}
local TestSetClear = {}
local TestSetConcat = {}
local TestSetContains = {}
local TestSetDiff = {}
local TestSetDisjoint = {}
local TestSetEmpty = {}
local TestSetEq = {}
local TestSetIntersection = {}
local TestSetIsSet = {}
local TestSetLen = {}
local TestSetNew = {}
local TestSetNewIndex = {}
local TestSetPairs = {}
local TestSetRemove = {}
local TestSetSubset = {}
local TestSetSuperset = {}
local TestSetSymdiff = {}
local TestSetTostring = {}
local TestSetUnion = {}

function TestSetAdd:testAddsFalseValue()
	local set = Set.new()

	lu.assertTrue(set:add(false))
	lu.assertTrue(set:contains(false))
	lu.assertEquals(snapshot(set), { [false] = false })
end

function TestSetAdd:testAddsLegalTableKeyTypes()
	local set = Set.new()
	local tableEntry = {}
	local function functionEntry() end
	local threadEntry = coroutine.create(function() end)

	lu.assertTrue(set:add(12))
	lu.assertTrue(set:add("entry"))
	lu.assertTrue(set:add(tableEntry))
	lu.assertTrue(set:add(functionEntry))
	lu.assertTrue(set:add(threadEntry))

	lu.assertTrue(set:contains(12, "entry", tableEntry, functionEntry, threadEntry))
	lu.assertEquals(#set, 5)
end

function TestSetAdd:testRejectsNaNEntry()
	local set = Set.new()
	local ok = pcall(function()
		set:add(0 / 0)
	end)

	lu.assertFalse(ok)
end

function TestSetAdd:testRejectsNilEntry()
	local set = Set.new()

	lu.assertErrorMsgContains("entry should not be nil", function()
		set:add(nil)
	end)
end

function TestSetAdd:testReturnsFalseForDuplicateEntry()
	local set = Set.new()

	lu.assertTrue(set:add("entry"))
	lu.assertFalse(set:add("entry"))
	lu.assertEquals(#set, 1)
end

function TestSetAdd:testUsesTableIdentityEvenWhenEntriesCompareEqual()
	local equalityMetatable = {
		__eq = function()
			return true
		end,
	}
	local first = setmetatable({}, equalityMetatable)
	local second = setmetatable({}, equalityMetatable)
	local set = Set.new()

	lu.assertTrue(first == second)
	lu.assertTrue(set:add(first))
	lu.assertFalse(set:contains(second))
	lu.assertTrue(set:add(second))
	lu.assertEquals(#set, 2)
end

function TestSetAddAll:testAccumulatesUniqueValuesFromTable()
	local set = Set.new({ "existing" })
	local iterable = {
		first = "alpha",
		second = "existing",
		third = false,
	}

	lu.assertEquals(set:addAll(iterable), nil)
	lu.assertEquals(snapshot(set), {
		["existing"] = "existing",
		alpha = "alpha",
		[false] = false,
	})
end

function TestSetAddAll:testPropagatesInvalidEntryErrors()
	local set = Set.new()

	local ok = pcall(function()
		set:addAll({ 0 / 0 })
	end)

	lu.assertFalse(ok)
end

function TestSetAddAll:testPropagatesIteratorErrors()
	local set = Set.new()
	local iterable = setmetatable({}, {
		__pairs = function()
			error("iterator failed")
		end,
	})

	lu.assertErrorMsgContains("iterator failed", function()
		set:addAll(iterable)
	end)
end

function TestSetAddAll:testReadsValuesFromCustomPairsIterator()
	local set = Set.new()
	local values = { first = "alpha", second = "beta" }
	local iterable = setmetatable({}, {
		__pairs = function()
			return next, values, nil
		end,
	})

	set:addAll(iterable)

	lu.assertEquals(snapshot(set), { alpha = "alpha", beta = "beta" })
end

function TestSetAddAll:testRejectsNilIterable()
	local set = Set.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		set:addAll(nil)
	end)
end

function TestSetAddAll:testRejectsNonTableIterable()
	local set = Set.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		set:addAll("entries")
	end)
end

function TestSetAddAll:testReturnsNoValue()
	local set = Set.new()

	lu.assertEquals(set:addAll({ "entry" }), nil)
end

function TestSetAddAll:testIgnoresIfAddSelf()
	local set = Set.new({ 1, 2, 3 })

	set:addAll(set)

	lu.assertEquals(#set, 3)
end

function TestSetClear:testClearingEmptySetIsSafe()
	local set = Set.new()

	lu.assertEquals(set:clear(), nil)
	lu.assertTrue(set:empty())
	lu.assertEquals(#set, 0)
end

function TestSetClear:testClearsEntriesAndAllowsReuse()
	local set = Set.new({ "first", "second" })

	set:clear()

	lu.assertTrue(set:empty())
	lu.assertEquals(#set, 0)
	lu.assertEquals(snapshot(set), {})
	lu.assertTrue(set:add("reused"))
	lu.assertTrue(set:contains("reused"))
	lu.assertEquals(#set, 1)
end

function TestSetConcat:testAcceptsSetTableAndCustomPairsOperands()
	local base = Set.new({ "base" })
	local fromTable = base .. { "table-value" }
	local fromSet = base .. Set.new({ "set-value" })
	local values = { field = "custom-value" }
	local customIterable = setmetatable({}, {
		__pairs = function()
			return next, values, nil
		end,
	})
	local fromCustomIterable = base .. customIterable

	lu.assertTrue(fromTable:contains("base", "table-value"))
	lu.assertTrue(fromSet:contains("base", "set-value"))
	lu.assertTrue(fromCustomIterable:contains("base", "custom-value"))
end

function TestSetConcat:testCopiesReceiverAndPreservesBothOperands()
	local source = Set.new({ "first", "shared" })
	local right = { "shared", "second" }
	local result = source .. right

	lu.assertEquals(snapshot(result), {
		first = "first",
		shared = "shared",
		second = "second",
	})
	lu.assertEquals(snapshot(source), { first = "first", shared = "shared" })
	lu.assertEquals(right, { "shared", "second" })
end

function TestSetConcat:testCopiesReceiverWhenRightOperandIsNil()
	local source = Set.new({ "entry" })
	local result = source .. nil

	lu.assertEquals(snapshot(result), { entry = "entry" })
	lu.assertEquals(snapshot(source), { entry = "entry" })
	result:add("copy-only")
	source:add("source-only")
	lu.assertFalse(source:contains("copy-only"))
	lu.assertFalse(result:contains("source-only"))
end

function TestSetConcat:testRejectsNonTableRightOperand()
	local set = Set.new({ "entry" })

	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = set .. false
	end)
end

function TestSetContains:testChecksAllEntriesIncludingFalse()
	local set = Set.new({ "alpha", false, 12 })

	lu.assertTrue(set:contains("alpha", false, 12))
	lu.assertTrue(set:contains(false))
	lu.assertFalse(set:contains("alpha", "missing"))
end

function TestSetContains:testReturnsFalseForMissingOrNilEntry()
	local set = Set.new({ "present" })

	lu.assertFalse(set:contains("missing"))
	lu.assertFalse(set:contains(nil))
	lu.assertFalse(set:contains("present", nil))
end

function TestSetContains:testReturnsFalseWithoutArguments()
	lu.assertFalse(Set.new({ "present" }):contains())
end

function TestSetContains:testShortCircuitsBeforeInvalidLaterEntry()
	local set = Set.new({ "present" })

	lu.assertFalse(set:contains("missing", 0 / 0))
end

function TestSetContains:testTreatsNaNAsAbsentEntry()
	local set = Set.new()

	lu.assertFalse(set:contains(0 / 0))
end

function TestSetDiff:testRejectsNonSetArgument()
	local set = Set.new()

	lu.assertErrorMsgContains("other should also be a Set", function()
		set:diff({})
	end)
end

function TestSetDiff:testReturnsEmptyForEqualOrEmptySets()
	local set = Set.new({ "alpha", "beta" })

	lu.assertTrue(set:diff(set):empty())
	lu.assertTrue(set:diff(Set.new()):contains("alpha", "beta"))
	lu.assertTrue(Set.new():diff(set):empty())
	lu.assertTrue(set:diff(Set.new({ "beta", "alpha" })):empty())
end

function TestSetDiff:testReturnsOnlyLeftExclusiveEntriesWithoutMutatingInputs()
	local left = Set.new({ "alpha", "shared" })
	local right = Set.new({ "shared", "beta" })
	local result = left:diff(right)

	lu.assertEquals(snapshot(result), { alpha = "alpha" })
	lu.assertEquals(snapshot(left), { alpha = "alpha", shared = "shared" })
	lu.assertEquals(snapshot(right), { shared = "shared", beta = "beta" })
end

function TestSetDisjoint:testRejectsNonSetArgument()
	local set = Set.new()

	lu.assertErrorMsgContains("other should also be a Set", function()
		set:disjoint(nil)
	end)
end

function TestSetDisjoint:testReturnsFalseForOverlappingSetsRegardlessOfOrder()
	local smaller = Set.new({ "shared" })
	local larger = Set.new({ "shared", "left", "right" })

	lu.assertFalse(smaller:disjoint(larger))
	lu.assertFalse(larger:disjoint(smaller))
	lu.assertFalse(smaller:disjoint(smaller))
end

function TestSetDisjoint:testReturnsTrueForEmptyOrDisjointSets()
	local smaller = Set.new({ "alpha" })
	local larger = Set.new({ "beta", "gamma", "delta" })

	lu.assertTrue(smaller:disjoint(larger))
	lu.assertTrue(larger:disjoint(smaller))
	lu.assertTrue(Set.new():disjoint(larger))
	lu.assertTrue(larger:disjoint(Set.new()))
end

function TestSetEmpty:testTracksTransitionsFromAddRemoveAndClear()
	local set = Set.new()

	lu.assertTrue(set:empty())
	set:add("entry")
	lu.assertFalse(set:empty())
	set:remove("entry")
	lu.assertTrue(set:empty())
	set:add("again")
	set:clear()
	lu.assertTrue(set:empty())
end

function TestSetEmpty:testTreatsFreshSetAsEmpty()
	lu.assertTrue(Set.new():empty())
end

function TestSetEq:testComparesEqualSetsRegardlessOfInsertionOrder()
	local first = Set.new({ "alpha", false, "beta" })
	local second = Set.new({ "beta", "alpha", false })

	lu.assertTrue(first == second)
	lu.assertFalse(first ~= second)
end

function TestSetEq:testDistinguishesDifferentMembershipAndLengths()
	local original = Set.new({ "alpha", "beta" })

	lu.assertFalse(original == Set.new({ "alpha", "gamma" }))
	lu.assertFalse(original == Set.new({ "alpha" }))
	lu.assertTrue(original ~= Set.new({ "alpha", "gamma" }))
end

function TestSetEq:testReturnsFalseForNonSetOperands()
	local set = Set.new({ "entry" })

	lu.assertFalse(Set.__eq(set, nil))
	lu.assertFalse(Set.__eq(set, {}))
	lu.assertFalse(Set.__eq(set, 42))
	lu.assertFalse(set == nil)
	lu.assertFalse(set == {})
end

function TestSetIntersection:testRejectsNonSetArgument()
	local set = Set.new()

	lu.assertErrorMsgContains("other should also be a Set", function()
		set:intersection("not a set")
	end)
end

function TestSetIntersection:testReturnsEmptyWhenNoEntriesOverlap()
	local left = Set.new({ "left" })
	local right = Set.new({ "right", "other" })

	lu.assertTrue(left:intersection(right):empty())
	lu.assertTrue(Set.new():intersection(right):empty())
	lu.assertTrue(right:intersection(Set.new()):empty())
end

function TestSetIntersection:testReturnsOnlySharedEntriesWithoutMutatingInputs()
	local larger = Set.new({ "alpha", "shared", "left" })
	local smaller = Set.new({ "shared", "beta" })
	local resultFromSmallerReceiver = smaller:intersection(larger)
	local resultFromLargerReceiver = larger:intersection(smaller)

	lu.assertEquals(snapshot(resultFromSmallerReceiver), { shared = "shared" })
	lu.assertEquals(snapshot(resultFromLargerReceiver), { shared = "shared" })
	lu.assertEquals(snapshot(larger), { alpha = "alpha", shared = "shared", left = "left" })
	lu.assertEquals(snapshot(smaller), { shared = "shared", beta = "beta" })
end

function TestSetIsSet:testRecognizesEmptyAndPopulatedSets()
	lu.assertTrue(Set.isSet(Set.new()))
	lu.assertTrue(Set.isSet(Set.new({ "entry" })))
end

function TestSetIsSet:testRejectsScalarsAndNonSetTables()
	lu.assertFalse(Set.isSet(nil))
	lu.assertFalse(Set.isSet(false))
	lu.assertFalse(Set.isSet(12))
	lu.assertFalse(Set.isSet("set"))
	lu.assertFalse(Set.isSet(function() end))
	lu.assertFalse(Set.isSet({ "entry" }))
	lu.assertFalse(Set.isSet(setmetatable({}, {})))
end

function TestSetLen:testCountsUniqueEntriesThroughMutation()
	local set = Set.new()

	lu.assertEquals(#set, 0)
	set:add("entry")
	set:add("entry")
	set:add(false)
	lu.assertEquals(#set, 2)
	set:remove("entry")
	lu.assertEquals(#set, 1)
	set:clear()
	lu.assertEquals(#set, 0)
end

function TestSetNew:testAcceptsNilAsEmptyInput()
	lu.assertTrue(Set.new():empty())
	lu.assertTrue(Set.new(nil):empty())
end

function TestSetNew:testCopiesSetWithoutAliasing()
	local source = Set.new({ "source" })
	local copy = Set.new(source)

	lu.assertEquals(snapshot(copy), { source = "source" })
	source:add("source-only")
	copy:add("copy-only")
	lu.assertFalse(source:contains("copy-only"))
	lu.assertFalse(copy:contains("source-only"))
end

function TestSetNew:testReadsTableValuesInsteadOfKeys()
	local set = Set.new({ first = "alpha", second = "beta" })

	lu.assertEquals(snapshot(set), { alpha = "alpha", beta = "beta" })
	lu.assertFalse(set:contains("first", "second"))
end

function TestSetNew:testRejectsNonTableIterable()
	lu.assertErrorMsgContains("iterable should be a table", function()
		Set.new("not a table")
	end)
end

function TestSetNewIndex:testRejectsAddingNumericEntry()
	local set = Set.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Set", function()
		set[1] = "entry"
	end)
end

function TestSetNewIndex:testRejectsAddingProperty()
	local set = Set.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Set", function()
		set.extra = "value"
	end)
end

function TestSetNewIndex:testRejectsReplacingMethod()
	local set = Set.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Set", function()
		set.add = function() end
	end)
end

function TestSetPairs:testEmptySetYieldsNoEntries()
	local count = 0

	for _ in pairs(Set.new()) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestSetPairs:testKeepsActiveIteratorOnOriginalTableAfterClear()
	local set = Set.new({ "alpha", "beta", "gamma", "delta" })
	local iterator, state, control = pairs(set)
	local firstKey, firstValue = iterator(state, control)
	local seen = { [firstKey] = firstValue }

	lu.assertTrue(firstKey ~= nil)
	lu.assertEquals(firstValue, firstKey)
	set:clear()

	local key, value = iterator(state, firstKey)
	while key ~= nil do
		seen[key] = value
		key, value = iterator(state, key)
	end

	lu.assertEquals(seen, {
		alpha = "alpha",
		beta = "beta",
		gamma = "gamma",
		delta = "delta",
	})
	lu.assertTrue(set:empty())
end

function TestSetPairs:testYieldsEachEntryAsKeyAndValue()
	local set = Set.new({ "alpha", false, 12 })
	local seen = {}
	local count = 0

	for key, value in pairs(set) do
		lu.assertEquals(value, key)
		seen[key] = value
		count = count + 1
	end

	lu.assertEquals(count, 3)
	lu.assertEquals(seen, { alpha = "alpha", [false] = false, [12] = 12 })
end

function TestSetRemove:testRejectsNilEntry()
	local set = Set.new()

	lu.assertErrorMsgContains("entry should not be nil", function()
		set:remove(nil)
	end)
end

function TestSetRemove:testRemovesExistingEntry()
	local set = Set.new({ "first", "second" })

	lu.assertTrue(set:remove("first"))
	lu.assertFalse(set:contains("first"))
	lu.assertTrue(set:contains("second"))
	lu.assertEquals(#set, 1)
	lu.assertFalse(set:remove("first"))
end

function TestSetRemove:testRemovesFalseEntry()
	local set = Set.new({ false })

	lu.assertTrue(set:remove(false))
	lu.assertFalse(set:contains(false))
	lu.assertTrue(set:empty())
end

function TestSetRemove:testReturnsFalseForMissingEntry()
	lu.assertFalse(Set.new():remove("missing"))
end

function TestSetRemove:testReturnsFalseForNaNEntry()
	lu.assertFalse(Set.new():remove(0 / 0))
end

function TestSetSubset:testRejectsNonSetArgument()
	local set = Set.new()

	lu.assertErrorMsgContains("other should also be a Set", function()
		set:subset({})
	end)
end

function TestSetSubset:testReturnsFalseWhenMemberIsMissing()
	local candidate = Set.new({ "alpha", "missing" })
	local other = Set.new({ "alpha", "different" })

	lu.assertFalse(candidate:subset(other))
end

function TestSetSubset:testReturnsFalseWhenReceiverIsLarger()
	local larger = Set.new({ "alpha", "beta" })
	local smaller = Set.new({ "alpha" })

	lu.assertFalse(larger:subset(smaller))
end

function TestSetSubset:testReturnsTrueForEmptyEqualAndStrictSubsets()
	local smaller = Set.new({ "alpha", false })
	local larger = Set.new({ "alpha", false, "beta" })

	lu.assertTrue(Set.new():subset(smaller))
	lu.assertTrue(smaller:subset(smaller))
	lu.assertTrue(smaller:subset(larger))
	lu.assertTrue(larger:subset(larger))
end

function TestSetSuperset:testRejectsNonSetArgument()
	local set = Set.new()

	lu.assertErrorMsgContains("other should also be a Set", function()
		set:superset(false)
	end)
end

function TestSetSuperset:testReturnsFalseWhenOtherHasMissingMembers()
	local candidate = Set.new({ "alpha", "different" })
	local other = Set.new({ "alpha", "missing" })

	lu.assertFalse(candidate:superset(other))
end

function TestSetSuperset:testReturnsTrueForEmptyAndContainedSets()
	local larger = Set.new({ "alpha", false, "beta" })
	local smaller = Set.new({ "alpha", false })

	lu.assertTrue(larger:superset(Set.new()))
	lu.assertTrue(larger:superset(smaller))
	lu.assertTrue(larger:superset(larger))
end

function TestSetSymdiff:testRejectsNonSetArgument()
	local set = Set.new()

	lu.assertErrorMsgContains("other should also be a Set", function()
		set:symdiff("not a set")
	end)
end

function TestSetSymdiff:testReturnsEmptyForEqualSets()
	local first = Set.new({ "alpha", false })
	local second = Set.new({ false, "alpha" })

	lu.assertTrue(first:symdiff(second):empty())
	lu.assertTrue(first:symdiff(first):empty())
end

function TestSetSymdiff:testReturnsExclusiveMembersForOverlappingSets()
	local left = Set.new({ "left", "shared" })
	local right = Set.new({ "right", "shared" })
	local result = left:symdiff(right)

	lu.assertEquals(snapshot(result), { left = "left", right = "right" })
	lu.assertEquals(snapshot(left), { left = "left", shared = "shared" })
	lu.assertEquals(snapshot(right), { right = "right", shared = "shared" })
end

function TestSetSymdiff:testReturnsUnionForDisjointSets()
	local left = Set.new({ "left" })
	local right = Set.new({ "right", false })

	lu.assertEquals(snapshot(left:symdiff(right)), {
		left = "left",
		right = "right",
		[false] = false,
	})
end

function TestSetTostring:testFormatsEmptyAndSingleEntry()
	lu.assertEquals(tostring(Set.new()), "{  }")
	lu.assertEquals(tostring(Set.new({ "single" })), "{ single }")
end

function TestSetTostring:testIncludesAllValuesWithoutAssumingOrder()
	local set = Set.new({ "alpha", 12, false })
	local result = tostring(set)

	lu.assertStrContains(result, "alpha")
	lu.assertStrContains(result, "12")
	lu.assertStrContains(result, "false")
end

function TestSetTostring:testPropagatesErrorsFromEntryStringifier()
	local entry = setmetatable({}, {
		__tostring = function()
			error("stringifier failed")
		end,
	})
	local set = Set.new({ entry })

	lu.assertErrorMsgContains("stringifier failed", function()
		tostring(set)
	end)
end

function TestSetTostring:testUsesEntryStringifier()
	local calls = 0
	local entry = setmetatable({}, {
		__tostring = function()
			calls = calls + 1
			return "custom-entry"
		end,
	})
	local set = Set.new({ entry })

	lu.assertEquals(tostring(set), "{ custom-entry }")
	lu.assertEquals(calls, 1)
end

function TestSetUnion:testRejectsNonSetArgument()
	local set = Set.new()

	lu.assertErrorMsgContains("other should also be a Set", function()
		set:union({ "entry" })
	end)
end

function TestSetUnion:testReturnsCopyWhenOtherSetIsEmpty()
	local source = Set.new({ "alpha", false })
	local result = source:union(Set.new())

	lu.assertEquals(snapshot(result), { alpha = "alpha", [false] = false })
	lu.assertEquals(snapshot(source), { alpha = "alpha", [false] = false })
	result:add("copy-only")
	lu.assertFalse(source:contains("copy-only"))
end

function TestSetUnion:testReturnsEmptyForTwoEmptySets()
	lu.assertTrue(Set.new():union(Set.new()):empty())
end

function TestSetUnion:testReturnsFreshUnionWithoutMutatingInputs()
	local left = Set.new({ "alpha", "shared" })
	local right = Set.new({ "shared", "beta" })
	local result = left:union(right)

	lu.assertEquals(snapshot(result), {
		alpha = "alpha",
		shared = "shared",
		beta = "beta",
	})
	lu.assertEquals(snapshot(left), { alpha = "alpha", shared = "shared" })
	lu.assertEquals(snapshot(right), { shared = "shared", beta = "beta" })
end

function TestSetUnion:testReturnsSameMembersWhenUnionedWithSelf()
	local set = Set.new({ "alpha", false })
	local result = set:union(set)

	lu.assertEquals(snapshot(result), snapshot(set))
	result:add("copy-only")
	lu.assertFalse(set:contains("copy-only"))
end

return {
	TestSetAdd = TestSetAdd,
	TestSetAddAll = TestSetAddAll,
	TestSetClear = TestSetClear,
	TestSetConcat = TestSetConcat,
	TestSetContains = TestSetContains,
	TestSetDiff = TestSetDiff,
	TestSetDisjoint = TestSetDisjoint,
	TestSetEmpty = TestSetEmpty,
	TestSetEq = TestSetEq,
	TestSetIntersection = TestSetIntersection,
	TestSetIsSet = TestSetIsSet,
	TestSetLen = TestSetLen,
	TestSetNew = TestSetNew,
	TestSetNewIndex = TestSetNewIndex,
	TestSetPairs = TestSetPairs,
	TestSetRemove = TestSetRemove,
	TestSetSubset = TestSetSubset,
	TestSetSuperset = TestSetSuperset,
	TestSetSymdiff = TestSetSymdiff,
	TestSetTostring = TestSetTostring,
	TestSetUnion = TestSetUnion,
}
