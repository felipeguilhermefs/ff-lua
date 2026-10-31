local lu = require("luaunit")
local TreeMap = require("ff.collections.treemap")
local Comparator = require("ff.func.comparator")

local append = table.insert

local TestTreeMap = {}

function TestTreeMap:testTypeGuard_RecognizesTreeMapsAndRejectsOtherValues()
	lu.assertTrue(TreeMap.isTreeMap(TreeMap.new()))
	lu.assertFalse(TreeMap.isTreeMap({}))
	lu.assertFalse(TreeMap.isTreeMap(nil))
	lu.assertFalse(TreeMap.isTreeMap("treemap"))
	lu.assertFalse(TreeMap.isTreeMap(123))
end

function TestTreeMap:testEmptyConstructor_CreatesEmptyTreeMap()
	local tm = TreeMap.new()

	lu.assertTrue(tm:empty())
	lu.assertEquals(#tm, 0)
end

function TestTreeMap:testConstructor_CopiesKeyValueEntries()
	local tm = TreeMap.new({ d = 40, b = 20, a = 10, c = 30 })

	lu.assertFalse(tm:empty())
	lu.assertEquals(#tm, 4)
	lu.assertEquals(tm:get("a"), 10)
	lu.assertEquals(tm:get("b"), 20)
	lu.assertEquals(tm:get("c"), 30)
	lu.assertEquals(tm:get("d"), 40)
end

function TestTreeMap:testComparatorConstructor_ReversesKeyOrder()
	local tm = TreeMap.new(nil, Comparator.reverse(Comparator.natural))

	tm:put(1, "one")
	tm:put(2, "two")
	tm:put(3, "three")

	lu.assertEquals(#tm, 3)

	local k, v = tm:min()
	lu.assertEquals(k, 3)
	lu.assertEquals(v, "three")

	k, v = tm:max()
	lu.assertEquals(k, 1)
	lu.assertEquals(v, "one")
end

function TestTreeMap:testConstructor_RejectsInvalidComparators()
	lu.assertErrorMsgContains("comparator should be a function", TreeMap.new, nil, "invalid")
	lu.assertErrorMsgContains("comparator should be a function", TreeMap.new, nil, 123)
	lu.assertErrorMsgContains("comparator should be a function", TreeMap.new, nil, true)
	lu.assertErrorMsgContains("comparator should be a function", TreeMap.new, { a = 1 }, "not_a_function")
end

function TestTreeMap:testCustomComparator_OrdersStructuredKeys()
	local function ScoreComparator(a, b)
		if a.score > b.score then
			return 1
		end
		if a.score < b.score then
			return -1
		else
			return 0
		end
	end

	local tm = TreeMap.new(nil, ScoreComparator)
	local o1 = { score = 10, name = "first" }
	local o2 = { score = 20, name = "second" }
	local o3 = { score = 5, name = "zero" }

	tm:put(o1, "alpha")
	tm:put(o2, "beta")
	tm:put(o3, "gamma")

	lu.assertEquals(#tm, 3)
	lu.assertEquals(tm:get({ score = 5 }), "gamma")
	lu.assertEquals(tm:get({ score = 10 }), "alpha")
	lu.assertEquals(tm:get({ score = 20 }), "beta")

	local minKey, _ = tm:min()
	lu.assertEquals(minKey.score, 5)
	local maxKey, _ = tm:max()
	lu.assertEquals(maxKey.score, 20)
end

function TestTreeMap:testContains_ReportsStoredAndRemovedKeysCorrectly()
	local tm = TreeMap.new()

	lu.assertFalse(tm:contains("key"))

	tm:put("key", "value")

	lu.assertTrue(tm:contains("key"))
	lu.assertFalse(tm:contains("missing"))

	tm:remove("key")

	lu.assertFalse(tm:contains("key"))
end

function TestTreeMap:testMinAndMax_ReturnBoundaryEntriesOrNilWhenEmpty()
	local tm = TreeMap.new()

	lu.assertNil(tm:min())
	lu.assertNil(tm:max())

	tm:put(7, "seven")
	tm:put(3, "three")
	tm:put(9, "nine")
	tm:put(1, "one")
	tm:put(5, "five")
	local minK, minV = tm:min()
	local maxK, maxV = tm:max()

	lu.assertEquals(minK, 1)
	lu.assertEquals(minV, "one")
	lu.assertEquals(maxK, 9)
	lu.assertEquals(maxV, "nine")
end

function TestTreeMap:testFloorAndCeiling_ReturnNearestKeysWithinBounds()
	local tm = TreeMap.new()
	tm:put(10, "ten")
	tm:put(20, "twenty")
	tm:put(30, "thirty")
	tm:put(40, "forty")
	tm:put(50, "fifty")

	lu.assertNil(tm:floor(5))
	lu.assertEquals(tm:floor(10), 10)
	lu.assertEquals(tm:floor(15), 10)
	lu.assertEquals(tm:floor(20), 20)
	lu.assertEquals(tm:floor(50), 50)
	lu.assertEquals(tm:floor(99), 50)

	lu.assertEquals(tm:ceiling(5), 10)
	lu.assertEquals(tm:ceiling(10), 10)
	lu.assertEquals(tm:ceiling(15), 20)
	lu.assertEquals(tm:ceiling(50), 50)
	lu.assertNil(tm:ceiling(55))
end

function TestTreeMap:testRange_YieldsEntriesWithinInclusiveBounds()
	local tm = TreeMap.new()
	for i = 1, 10 do
		tm:put(i, i * 10)
	end

	local r1 = {}
	for k, v in tm:range(3, 7) do
		append(r1, { k, v })
	end

	lu.assertEquals(r1, {
		{ 3, 30 },
		{ 4, 40 },
		{ 5, 50 },
		{ 6, 60 },
		{ 7, 70 },
	})

	local r2 = {}
	for k, v in tm:range(nil, 4) do
		append(r2, { k, v })
	end
	lu.assertEquals(r2, {
		{ 1, 10 },
		{ 2, 20 },
		{ 3, 30 },
		{ 4, 40 },
	})

	local r3 = {}
	for k, v in tm:range(8, nil) do
		append(r3, { k, v })
	end
	lu.assertEquals(r3, {
		{ 8, 80 },
		{ 9, 90 },
		{ 10, 100 },
	})
end

function TestTreeMap:testIteration_YieldsEntriesInAscendingKeyOrder()
	local tm = TreeMap.new({ d = 4, b = 2, a = 1, c = 3 })

	local res = {}

	for k, v in pairs(tm) do
		append(res, { key = k, value = v })
	end

	lu.assertEquals(res, {
		{ key = "a", value = 1 },
		{ key = "b", value = 2 },
		{ key = "c", value = 3 },
		{ key = "d", value = 4 },
	})
end

function TestTreeMap:testClear_EmptiesTreeMapAndAllowsReuse()
	local tm = TreeMap.new()
	lu.assertTrue(tm:empty())
	lu.assertEquals(#tm, 0)

	tm:put("a", 1)
	tm:clear()

	lu.assertTrue(tm:empty())
	lu.assertEquals(#tm, 0)

	tm:put("z", 26)

	lu.assertEquals(#tm, 1)
	lu.assertEquals(tm:get("z"), 26)
end

function TestTreeMap:testPutAndGet_AddOrReplaceValuesAndReturnThem()
	local tm = TreeMap.new()

	lu.assertNil(tm:get("a"))

	tm:put("a", 100)

	lu.assertEquals(tm:get("a"), 100)
	lu.assertEquals(#tm, 1)

	tm:put("a", 200)

	lu.assertEquals(tm:get("a"), 200)
	lu.assertEquals(#tm, 1)

	tm:put("b", 300)

	lu.assertEquals(tm:get("b"), 300)
	lu.assertEquals(#tm, 2)

	lu.assertErrorMsgContains("key should not be nil", function()
		tm:put(nil, 1)
	end)
	lu.assertErrorMsgContains("value should not be nil", function()
		tm:put("c", nil)
	end)
end

function TestTreeMap:testRemove_DeletesRequestedKeyAndPreservesOtherEntries()
	local tm = TreeMap.new()

	tm:put(4, "four")
	tm:put(2, "two")
	tm:put(6, "six")
	tm:put(1, "one")
	tm:put(3, "three")
	tm:put(5, "five")
	tm:put(7, "seven")

	lu.assertEquals(#tm, 7)

	local val1 = tm:remove(1)
	lu.assertEquals(val1, "one")
	lu.assertEquals(#tm, 6)
	lu.assertNil(tm[1])

	local val6 = tm:remove(6)
	lu.assertEquals(val6, "six")
	lu.assertEquals(#tm, 5)
	lu.assertNil(tm:get(6))
	lu.assertTrue(tm:contains(5))
	lu.assertTrue(tm:contains(7))

	local val4 = tm:remove(4)
	lu.assertEquals(val4, "four")
	lu.assertEquals(#tm, 4)
	lu.assertNil(tm:get(4))
end

function TestTreeMap:testRemove_HandlesMissingAndBoundaryKeys()
	local tm = TreeMap.new()

	lu.assertNil(tm:remove(10))
	lu.assertEquals(#tm, 0)

	tm:put(10, "ten")
	local missingRemoved = tm:remove(99)

	lu.assertNil(missingRemoved)
	lu.assertEquals(#tm, 1)

	local removedTen = tm:remove(10)

	lu.assertEquals(removedTen, "ten")
	lu.assertEquals(#tm, 0)
	lu.assertTrue(tm:empty())

	local tmLeft = TreeMap.new()
	tmLeft:put(30, "thirty")
	tmLeft:put(20, "twenty")
	tmLeft:put(10, "ten")
	local removedTwenty = tmLeft:remove(20)

	lu.assertEquals(removedTwenty, "twenty")
	lu.assertEquals(#tmLeft, 2)
	lu.assertTrue(tmLeft:contains(10))
	lu.assertTrue(tmLeft:contains(30))
	lu.assertFalse(tmLeft:contains(20))
end

function TestTreeMap:testCompute_Stores_OnlyMissingKeys()
	local tm = TreeMap.new()

	lu.assertEquals(
		tm:compute(2, function()
			return 1
		end),
		1
	)
	lu.assertEquals(
		tm:compute(2, function()
			return 2
		end),
		1
	)

	lu.assertEquals(
		tm:compute(3, function(key)
			return key * key
		end),
		9
	)
	lu.assertEquals(tm:get(3), 9)

	lu.assertErrorMsgContains("key should not be nil", function()
		tm:compute(nil, function() end)
	end)
	lu.assertErrorMsgContains("fn should be a function", function()
		tm:compute(3, "not_a_function")
	end)
end

function TestTreeMap:testMerge_CombinesOverlappingAndDistinctKeys()
	local function add(a, b)
		return a + b
	end

	local tm = TreeMap.new({ a = 10, b = 20, c = 30 })
	local other = { a = 1, b = 2, d = 4 }

	tm:merge(other, add)

	lu.assertEquals(#tm, 4)
	lu.assertEquals(tm:get("a"), 11)
	lu.assertEquals(tm:get("b"), 22)
	lu.assertEquals(tm:get("c"), 30)
	lu.assertEquals(tm:get("d"), 4)

	local tm2 = TreeMap.new({ x = 1, y = 2 })
	tm2:merge({ y = 20, z = 30 })
	lu.assertEquals(#tm2, 3)
	lu.assertEquals(tm2:get("x"), 1)
	lu.assertEquals(tm2:get("y"), 20)
	lu.assertEquals(tm2:get("z"), 30)
end

function TestTreeMap:testConcat_AppendsMapEntries()
	local tm = TreeMap.new()
	local other = TreeMap.new({ d = 40, e = 50 })

	tm = tm .. { a = 10, b = 20, c = 30 }
	lu.assertEquals(#tm, 3)

	tm = tm .. nil
	lu.assertEquals(#tm, 3)

	tm = tm .. other

	lu.assertEquals(#tm, 5)
	lu.assertEquals(tm:get("a"), 10)
	lu.assertEquals(tm:get("b"), 20)
	lu.assertEquals(tm:get("c"), 30)
	lu.assertEquals(tm:get("d"), 40)
	lu.assertEquals(tm:get("e"), 50)
end

function TestTreeMap:testTreeMapsWithSameEntries_Compare_Equal()
	local tm1 = TreeMap.new({ a = 1, b = 2, c = 3 })
	local tm2 = TreeMap.new({ c = 3, a = 1, b = 2 })
	local tm3 = TreeMap.new({ a = 1, b = 99, c = 3 })
	local tm4 = TreeMap.new({ a = 1, b = 2 })

	lu.assertTrue(tm1 == tm2)
	lu.assertFalse(tm1 == tm3)
	lu.assertFalse(tm1 == tm4)
	lu.assertFalse(tm1 == nil)
	lu.assertFalse(tm1 == "treemap")
	lu.assertFalse(tm1 == 42)

	local empty1 = TreeMap.new()
	local empty2 = TreeMap.new()
	lu.assertTrue(empty1 == empty2)
end

function TestTreeMap:testToString_Formats_TreeMapEntries()
	local emptyTm = TreeMap.new()

	lu.assertEquals(tostring(emptyTm), "{  }")

	local tm = TreeMap.new({ b = 2, a = 1, c = 3 })
	lu.assertEquals(tostring(tm), "{ a = 1, b = 2, c = 3 }")
end

function TestTreeMap:testNewPropertiesAndMethods_CannotBe_AddedOrReplaced()
	local tm = TreeMap.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		tm.foo = "bar"
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		tm[70] = 70
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		tm.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		tm.get = function() end
	end)
end

function TestTreeMap:testConcat_CreatesNewMapAndPutAllMutates()
	local source = TreeMap.new({ a = 1 })
	local joined = source .. { b = 2 }
	lu.assertNotIs(joined, source)
	lu.assertEquals(source:get("b"), nil)
	lu.assertEquals(joined:get("b"), 2)
	source:putAll({ c = 3 })
	lu.assertEquals(source:get("c"), 3)
end

function TestTreeMap:testPutAllRejectsNil()
	local collection = TreeMap.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		collection:putAll(nil)
	end)
end

return { TestTreeMap = TestTreeMap }
