local lu = require("luaunit")
local TreeMap = require("ff.collections.treemap")
local Comparator = require("ff.func.comparator")

local function entriesOf(treeMap)
	local entries = {}
	for key, value in pairs(treeMap) do
		table.insert(entries, { key = key, value = value })
	end
	return entries
end

local function keysOf(treeMap)
	local keys = {}
	for key in pairs(treeMap) do
		table.insert(keys, key)
	end
	return keys
end

local function orderedIterable(items)
	return setmetatable({}, {
		__pairs = function()
			local index = 0
			return function()
				index = index + 1
				local item = items[index]
				if item ~= nil then
					return item[1], item[2]
				end
			end
		end,
	})
end

local function rangeEntries(iterator)
	local entries = {}
	for key, value in iterator do
		table.insert(entries, { key = key, value = value })
	end
	return entries
end

local function scoreComparator(a, b)
	if a.score < b.score then
		return Comparator.less
	elseif a.score > b.score then
		return Comparator.greater
	end
	return Comparator.equal
end

local function log2Ceiling(value)
	local result = 0
	local power = 1
	while power < value do
		power = power * 2
		result = result + 1
	end
	return result
end

local TestTreeMapCeiling = {}
local TestTreeMapClear = {}
local TestTreeMapCompute = {}
local TestTreeMapConcat = {}
local TestTreeMapContains = {}
local TestTreeMapEmpty = {}
local TestTreeMapEq = {}
local TestTreeMapFloor = {}
local TestTreeMapGet = {}
local TestTreeMapIsTreeMap = {}
local TestTreeMapLen = {}
local TestTreeMapMax = {}
local TestTreeMapMin = {}
local TestTreeMapNew = {}
local TestTreeMapNewindex = {}
local TestTreeMapPairs = {}
local TestTreeMapPut = {}
local TestTreeMapPutAll = {}
local TestTreeMapRange = {}
local TestTreeMapRemove = {}
local TestTreeMapTostring = {}

function TestTreeMapCeiling:testFindsExactMatch()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty", [30] = "thirty" })

	local key, value = treeMap:ceiling(20)

	lu.assertEquals(key, 20)
	lu.assertEquals(value, "twenty")
end

function TestTreeMapCeiling:testFindsNearestGreaterEntry()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty", [30] = "thirty" })

	local key, value = treeMap:ceiling(21)

	lu.assertEquals(key, 30)
	lu.assertEquals(value, "thirty")
end

function TestTreeMapCeiling:testPreservesFalseValue()
	local treeMap = TreeMap.new({ [10] = false })

	local key, value = treeMap:ceiling(10)

	lu.assertEquals(key, 10)
	lu.assertFalse(value)
end

function TestTreeMapCeiling:testRejectsNilKey()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("key should not be nil", function()
		treeMap:ceiling(nil)
	end)
end

function TestTreeMapCeiling:testReturnsNilForEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertNil(treeMap:ceiling(1))
end

function TestTreeMapCeiling:testReturnsNilWhenQueryExceedsMaximum()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty" })

	lu.assertNil(treeMap:ceiling(25))
end

function TestTreeMapCeiling:testReturnsSmallestKeyWhenQueryBelowMinimum()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty" })

	local key, value = treeMap:ceiling(5)

	lu.assertEquals(key, 10)
	lu.assertEquals(value, "ten")
end

function TestTreeMapCeiling:testUsesCustomComparator()
	local treeMap = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	treeMap:put(1, "one")
	treeMap:put(3, "three")
	treeMap:put(5, "five")

	local key, value = treeMap:ceiling(4)

	lu.assertEquals(key, 3)
	lu.assertEquals(value, "three")
end

function TestTreeMapClear:testAllowsReinsertionAfterClearing()
	local treeMap = TreeMap.new({ a = 1, b = 2 })

	treeMap:clear()
	treeMap:put("c", 3)

	lu.assertFalse(treeMap:empty())
	lu.assertEquals(#treeMap, 1)
	lu.assertEquals(entriesOf(treeMap), { { key = "c", value = 3 } })
end

function TestTreeMapClear:testCanClearRepeatedly()
	local treeMap = TreeMap.new({ a = 1 })

	treeMap:clear()
	treeMap:clear()

	lu.assertTrue(treeMap:empty())
	lu.assertEquals(#treeMap, 0)
end

function TestTreeMapClear:testClearsEmptyMap()
	local treeMap = TreeMap.new()

	treeMap:clear()

	lu.assertTrue(treeMap:empty())
	lu.assertEquals(#treeMap, 0)
	lu.assertEquals(entriesOf(treeMap), {})
end

function TestTreeMapClear:testClearsPopulatedMap()
	local treeMap = TreeMap.new({ a = 1, b = 2 })

	treeMap:clear()

	lu.assertTrue(treeMap:empty())
	lu.assertEquals(#treeMap, 0)
	lu.assertEquals(entriesOf(treeMap), {})
	lu.assertNil(treeMap:get("a"))
end

function TestTreeMapCompute:testComputesAndStoresMissingValue()
	local treeMap = TreeMap.new()
	local calls = 0

	local value = treeMap:compute("computedKey", function(key)
		calls = calls + 1
		lu.assertEquals(key, "computedKey")
		return 100
	end)

	lu.assertEquals(value, 100)
	lu.assertEquals(treeMap:get("computedKey"), 100)
	lu.assertEquals(calls, 1)
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapCompute:testExistingFalseValueSkipsCallback()
	local treeMap = TreeMap.new({ flag = false })
	local calls = 0

	local value = treeMap:compute("flag", function()
		calls = calls + 1
		return true
	end)

	lu.assertFalse(value)
	lu.assertEquals(calls, 0)
	lu.assertFalse(treeMap:get("flag"))
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapCompute:testExistingValueSkipsCallback()
	local treeMap = TreeMap.new({ key = "existing" })
	local calls = 0

	local value = treeMap:compute("key", function()
		calls = calls + 1
		return "new"
	end)

	lu.assertEquals(value, "existing")
	lu.assertEquals(calls, 0)
	lu.assertEquals(treeMap:get("key"), "existing")
end

function TestTreeMapCompute:testPropagatesCallbackErrorWithoutInserting()
	local treeMap = TreeMap.new({ existing = 1 })

	lu.assertErrorMsgContains("compute error", function()
		treeMap:compute("missing", function()
			error("compute error")
		end)
	end)

	lu.assertFalse(treeMap:contains("missing"))
	lu.assertEquals(treeMap:get("existing"), 1)
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapCompute:testRejectsInvalidArguments()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("key should not be nil", function()
		treeMap:compute(nil, function()
			return 1
		end)
	end)
	lu.assertErrorMsgContains("fn should be a function", function()
		treeMap:compute("key", 123)
	end)
end

function TestTreeMapCompute:testRejectsNilComputedValue()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		treeMap:compute("missing", function()
			return nil
		end)
	end)

	lu.assertFalse(treeMap:contains("missing"))
	lu.assertTrue(treeMap:empty())
end

function TestTreeMapConcat:testAppendsTableEntriesAndPreservesOperands()
	local source = TreeMap.new({ a = 1 })
	local iterable = { b = 2 }

	local result = source .. iterable

	lu.assertFalse(rawequal(result, source))
	lu.assertEquals(entriesOf(source), { { key = "a", value = 1 } })
	lu.assertEquals(entriesOf(result), {
		{ key = "a", value = 1 },
		{ key = "b", value = 2 },
	})
	lu.assertEquals(iterable, { b = 2 })
end

function TestTreeMapConcat:testCopiesWhenRightOperandIsNil()
	local source = TreeMap.new({ a = 1 })

	local result = source .. nil

	lu.assertFalse(rawequal(result, source))
	result:put("b", 2)
	lu.assertNil(source:get("b"))
	lu.assertEquals(result:get("a"), 1)
end

function TestTreeMapConcat:testMergesTreeMapAndPreservesLeftComparator()
	local source = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	source:put(1, "one")
	local other = TreeMap.new({ [2] = "two", [3] = "three" })

	local result = source .. other

	lu.assertEquals(keysOf(result), { 3, 2, 1 })
	lu.assertNil(source:get(2))
	lu.assertEquals(other:get(3), "three")
end

function TestTreeMapConcat:testOverwritesConflictsWithRightOperand()
	local source = TreeMap.new({ a = 1 })

	local result = source .. { a = 2 }

	lu.assertEquals(result:get("a"), 2)
	lu.assertEquals(source:get("a"), 1)
end

function TestTreeMapConcat:testRejectsNonTableOperand()
	local treeMap = TreeMap.new({ a = 1 })

	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = treeMap .. 100
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = treeMap .. false
	end)
end

function TestTreeMapConcat:testSelfConcatenationProducesIndependentClone()
	local source = TreeMap.new({ a = 1, b = 2 })

	local result = source .. source

	lu.assertFalse(rawequal(result, source))
	lu.assertEquals(entriesOf(result), entriesOf(source))
	result:put("c", 3)
	lu.assertNil(source:get("c"))
end

function TestTreeMapContains:testFindsPresentKeysIncludingFalseValue()
	local treeMap = TreeMap.new({ a = 1, b = false })

	lu.assertTrue(treeMap:contains("a"))
	lu.assertTrue(treeMap:contains("b"))
end

function TestTreeMapContains:testRejectsNilKey()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("key should not be nil", function()
		treeMap:contains(nil)
	end)
end

function TestTreeMapContains:testReturnsFalseForAbsentKeys()
	local treeMap = TreeMap.new({ a = 1 })

	lu.assertFalse(treeMap:contains("missing"))
end

function TestTreeMapContains:testReturnsFalseForEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertFalse(treeMap:contains("any"))
end

function TestTreeMapContains:testReturnsFalseForRemovedKeys()
	local treeMap = TreeMap.new({ a = 1 })

	treeMap:remove("a")

	lu.assertFalse(treeMap:contains("a"))
end

function TestTreeMapEmpty:testReportsEmptyForClearedMap()
	local treeMap = TreeMap.new({ a = 1 })

	treeMap:clear()

	lu.assertTrue(treeMap:empty())
end

function TestTreeMapEmpty:testReportsEmptyForNewMap()
	local treeMap = TreeMap.new()

	lu.assertTrue(treeMap:empty())
end

function TestTreeMapEmpty:testReportsEmptyWhenAllKeysRemoved()
	local treeMap = TreeMap.new({ a = 1 })

	treeMap:remove("a")

	lu.assertTrue(treeMap:empty())
end

function TestTreeMapEmpty:testReportsNotEmptyWhenPopulated()
	local treeMap = TreeMap.new()

	treeMap:put("a", 1)

	lu.assertFalse(treeMap:empty())
end

function TestTreeMapEq:testComparesEmptyMapsAsEqual()
	lu.assertTrue(TreeMap.new() == TreeMap.new())
end

function TestTreeMapEq:testComparesIdenticalContentsAsEqualRegardlessOfInsertionOrder()
	local first = TreeMap.new({ a = 1, b = 2, c = 3 })
	local second = TreeMap.new()
	second:put("c", 3)
	second:put("a", 1)
	second:put("b", 2)

	lu.assertTrue(first == second)
end

function TestTreeMapEq:testComparesSameInstanceAsEqual()
	local treeMap = TreeMap.new({ a = 1, b = 2 })

	lu.assertTrue(treeMap == treeMap)
end

function TestTreeMapEq:testRejectsDifferentKeysWithSameSize()
	local first = TreeMap.new({ a = 1, b = 2 })
	local second = TreeMap.new({ a = 1, c = 2 })

	lu.assertFalse(first == second)
end

function TestTreeMapEq:testRejectsDifferentLength()
	local first = TreeMap.new({ a = 1, b = 2 })
	local second = TreeMap.new({ a = 1 })

	lu.assertFalse(first == second)
end

function TestTreeMapEq:testRejectsDifferentValuesForSameKeys()
	local first = TreeMap.new({ a = 1, b = 2 })
	local second = TreeMap.new({ a = 1, b = 99 })

	lu.assertFalse(first == second)
end

function TestTreeMapEq:testRejectsNonTreeMapValues()
	local treeMap = TreeMap.new({ a = 1 })

	lu.assertFalse(treeMap == nil)
	lu.assertFalse(treeMap == "string")
	lu.assertFalse(treeMap == 42)
	lu.assertFalse(treeMap == false)
	lu.assertFalse(treeMap == { a = 1 })
end

function TestTreeMapEq:testReturnsFalseForDifferentComparatorsDueToIterationOrder()
	local natural = TreeMap.new({ [1] = "one", [2] = "two" })
	local reversed = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	reversed:put(1, "one")
	reversed:put(2, "two")

	lu.assertFalse(natural == reversed)
end

function TestTreeMapEq:testReturnsFalseForDistinctTableKeysEvenIfComparatorEquivalent()
	local firstKey = { score = 10, label = "first" }
	local equivalentKey = { score = 10, label = "second" }
	local first = TreeMap.new(nil, scoreComparator)
	local second = TreeMap.new(nil, scoreComparator)
	first:put(firstKey, "value")
	second:put(equivalentKey, "value")

	lu.assertFalse(first == second)
end

function TestTreeMapFloor:testFindsExactMatch()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty", [30] = "thirty" })

	local key, value = treeMap:floor(20)

	lu.assertEquals(key, 20)
	lu.assertEquals(value, "twenty")
end

function TestTreeMapFloor:testFindsNearestLesserEntry()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty", [30] = "thirty" })

	local key, value = treeMap:floor(19)

	lu.assertEquals(key, 10)
	lu.assertEquals(value, "ten")
end

function TestTreeMapFloor:testPreservesFalseValue()
	local treeMap = TreeMap.new({ [10] = false })

	local key, value = treeMap:floor(10)

	lu.assertEquals(key, 10)
	lu.assertFalse(value)
end

function TestTreeMapFloor:testRejectsNilKey()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("key should not be nil", function()
		treeMap:floor(nil)
	end)
end

function TestTreeMapFloor:testReturnsGreatestKeyWhenQueryExceedsMaximum()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty" })

	local key, value = treeMap:floor(25)

	lu.assertEquals(key, 20)
	lu.assertEquals(value, "twenty")
end

function TestTreeMapFloor:testReturnsNilForEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertNil(treeMap:floor(1))
end

function TestTreeMapFloor:testReturnsNilWhenQueryBelowMinimum()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty" })

	lu.assertNil(treeMap:floor(5))
end

function TestTreeMapFloor:testUsesCustomComparator()
	local treeMap = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	treeMap:put(1, "one")
	treeMap:put(3, "three")
	treeMap:put(5, "five")

	local key, value = treeMap:floor(4)

	lu.assertEquals(key, 5)
	lu.assertEquals(value, "five")
end

function TestTreeMapGet:testFindsKeyWithCustomComparator()
	local key = { score = 20 }
	local treeMap = TreeMap.new(nil, scoreComparator)
	treeMap:put(key, "twenty")

	lu.assertEquals(treeMap:get({ score = 20 }), "twenty")
end

function TestTreeMapGet:testPreservesFalseValue()
	local treeMap = TreeMap.new({ flag = false })

	lu.assertFalse(treeMap:get("flag"))
end

function TestTreeMapGet:testRejectsNilKey()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("key should not be nil", function()
		treeMap:get(nil)
	end)
end

function TestTreeMapGet:testReturnsNilForAbsentKey()
	local treeMap = TreeMap.new({ a = 1 })

	lu.assertNil(treeMap:get("b"))
end

function TestTreeMapGet:testReturnsNilForEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertNil(treeMap:get("a"))
end

function TestTreeMapGet:testReturnsStoredValue()
	local treeMap = TreeMap.new({ a = 1, b = "hello" })

	lu.assertEquals(treeMap:get("a"), 1)
	lu.assertEquals(treeMap:get("b"), "hello")
end

function TestTreeMapIsTreeMap:testRecognizesTreeMapInstances()
	lu.assertTrue(TreeMap.isTreeMap(TreeMap.new()))
	lu.assertTrue(TreeMap.isTreeMap(TreeMap.new({ a = 1 })))
end

function TestTreeMapIsTreeMap:testRejectsNonTableTypes()
	lu.assertFalse(TreeMap.isTreeMap(nil))
	lu.assertFalse(TreeMap.isTreeMap(false))
	lu.assertFalse(TreeMap.isTreeMap(true))
	lu.assertFalse(TreeMap.isTreeMap(42))
	lu.assertFalse(TreeMap.isTreeMap("treemap"))
	lu.assertFalse(TreeMap.isTreeMap(function() end))
end

function TestTreeMapIsTreeMap:testRejectsTablesWithoutTreeMapMetatable()
	lu.assertFalse(TreeMap.isTreeMap({}))
	lu.assertFalse(TreeMap.isTreeMap({ _len = 0 }))
	lu.assertFalse(TreeMap.isTreeMap(setmetatable({}, {})))
end

function TestTreeMapLen:testDecrementsOnRemoval()
	local treeMap = TreeMap.new({ a = 1, b = 2 })

	treeMap:remove("a")
	lu.assertEquals(#treeMap, 1)

	treeMap:remove("missing")
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapLen:testDoesNotChangeOnReplacingValue()
	local treeMap = TreeMap.new({ a = 1 })

	treeMap:put("a", 99)

	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapLen:testIncrementsOnInsertion()
	local treeMap = TreeMap.new()

	treeMap:put("a", 1)
	lu.assertEquals(#treeMap, 1)

	treeMap:put("b", 2)
	lu.assertEquals(#treeMap, 2)
end

function TestTreeMapLen:testResetsToZeroOnClear()
	local treeMap = TreeMap.new({ a = 1, b = 2 })

	treeMap:clear()

	lu.assertEquals(#treeMap, 0)
end

function TestTreeMapLen:testStartsAtZero()
	local treeMap = TreeMap.new()

	lu.assertEquals(#treeMap, 0)
end

function TestTreeMapMax:testReturnsGreatestEntryInPopulatedMap()
	local treeMap = TreeMap.new({ [7] = "seven", [3] = "three", [9] = "nine" })

	local key, value = treeMap:max()

	lu.assertEquals(key, 9)
	lu.assertEquals(value, "nine")
end

function TestTreeMapMax:testReturnsNilForEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertNil(treeMap:max())
end

function TestTreeMapMax:testReturnsSingleEntry()
	local treeMap = TreeMap.new({ [42] = "answer" })

	local key, value = treeMap:max()

	lu.assertEquals(key, 42)
	lu.assertEquals(value, "answer")
end

function TestTreeMapMax:testUsesCustomComparator()
	local treeMap = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	treeMap:put(1, "one")
	treeMap:put(9, "nine")

	local key, value = treeMap:max()

	lu.assertEquals(key, 1)
	lu.assertEquals(value, "one")
end

function TestTreeMapMin:testReturnsLeastEntryInPopulatedMap()
	local treeMap = TreeMap.new({ [7] = "seven", [3] = "three", [9] = "nine" })

	local key, value = treeMap:min()

	lu.assertEquals(key, 3)
	lu.assertEquals(value, "three")
end

function TestTreeMapMin:testReturnsNilForEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertNil(treeMap:min())
end

function TestTreeMapMin:testReturnsSingleEntry()
	local treeMap = TreeMap.new({ [42] = "answer" })

	local key, value = treeMap:min()

	lu.assertEquals(key, 42)
	lu.assertEquals(value, "answer")
end

function TestTreeMapMin:testUsesCustomComparator()
	local treeMap = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	treeMap:put(1, "one")
	treeMap:put(9, "nine")

	local key, value = treeMap:min()

	lu.assertEquals(key, 9)
	lu.assertEquals(value, "nine")
end

function TestTreeMapNew:testAcceptsCustomComparator()
	local customComparator = Comparator.reverse(Comparator.natural)
	local treeMap = TreeMap.new(nil, customComparator)
	treeMap:put(1, "one")
	treeMap:put(2, "two")

	lu.assertEquals(keysOf(treeMap), { 2, 1 })
end

function TestTreeMapNew:testCreatesEmptyMapWithNoArguments()
	local treeMap = TreeMap.new()

	lu.assertTrue(treeMap:empty())
	lu.assertEquals(#treeMap, 0)
	lu.assertEquals(entriesOf(treeMap), {})
end

function TestTreeMapNew:testInitializesFromAnotherTreeMap()
	local source = TreeMap.new({ [1] = "one", [2] = "two" })

	local copy = TreeMap.new(source)

	lu.assertEquals(entriesOf(copy), entriesOf(source))
	copy:put(3, "three")
	lu.assertNil(source:get(3))
end

function TestTreeMapNew:testInitializesFromTableWithoutAliasing()
	local source = { a = 1, b = 2 }

	local treeMap = TreeMap.new(source)
	source.c = 3

	lu.assertEquals(treeMap:get("a"), 1)
	lu.assertEquals(treeMap:get("b"), 2)
	lu.assertNil(treeMap:get("c"))
	lu.assertEquals(#treeMap, 2)
end

function TestTreeMapNew:testRejectsInvalidComparator()
	lu.assertErrorMsgContains("comparator should be a function", function()
		TreeMap.new(nil, "notAFunction")
	end)
	lu.assertErrorMsgContains("comparator should be a function", function()
		TreeMap.new(nil, 42)
	end)
end

function TestTreeMapNew:testRejectsInvalidIterable()
	lu.assertErrorMsgContains("iterable should be a table", function()
		TreeMap.new(false)
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		TreeMap.new(123)
	end)
end

function TestTreeMapNewindex:testPreservesExistingMethods()
	local treeMap = TreeMap.new()
	treeMap:put("key", "value")

	lu.assertEquals(treeMap:get("key"), "value")
	lu.assertFalse(treeMap:empty())
end

function TestTreeMapNewindex:testRejectsAddingNewFields()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		treeMap.newProp = "test"
	end)
end

function TestTreeMapNewindex:testRejectsMethodOverwriting()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		treeMap.get = function()
			return nil
		end
	end)
end

function TestTreeMapNewindex:testRejectsNumericIndexAssignment()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		treeMap[1] = "one"
	end)
end

function TestTreeMapPairs:testIteratesEmptyMapZeroTimes()
	local treeMap = TreeMap.new()
	local count = 0

	for _ in pairs(treeMap) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestTreeMapPairs:testIteratesInAscendingKeyOrder()
	local treeMap = TreeMap.new({ c = 3, a = 1, d = 4, b = 2 })

	lu.assertEquals(keysOf(treeMap), { "a", "b", "c", "d" })
end

function TestTreeMapPairs:testIteratesInCustomComparatorOrder()
	local treeMap = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	treeMap:put(1, "one")
	treeMap:put(2, "two")
	treeMap:put(3, "three")

	lu.assertEquals(keysOf(treeMap), { 3, 2, 1 })
end

function TestTreeMapPairs:testNonDestructiveAndRepeatable()
	local treeMap = TreeMap.new({ [3] = "three", [1] = "one", [2] = "two" })

	lu.assertEquals(keysOf(treeMap), { 1, 2, 3 })
	lu.assertEquals(keysOf(treeMap), { 1, 2, 3 })
	lu.assertEquals(#treeMap, 3)
end

function TestTreeMapPairs:testYieldsBothKeyAndValueIncludingFalse()
	local treeMap = TreeMap.new({ a = 1, b = false })

	lu.assertEquals(entriesOf(treeMap), {
		{ key = "a", value = 1 },
		{ key = "b", value = false },
	})
end

function TestTreeMapPut:testAcceptsBooleanFalseAsValue()
	local treeMap = TreeMap.new()

	treeMap:put("flag", false)

	lu.assertTrue(treeMap:contains("flag"))
	lu.assertFalse(treeMap:get("flag"))
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapPut:testChecksLeftLeftRotation()
	local treeMap = TreeMap.new()

	treeMap:put(3, "three")
	treeMap:put(2, "two")
	treeMap:put(1, "one")

	lu.assertEquals(keysOf(treeMap), { 1, 2, 3 })
	lu.assertEquals(#treeMap, 3)
end

function TestTreeMapPut:testChecksLeftRightRotation()
	local treeMap = TreeMap.new()

	treeMap:put(3, "three")
	treeMap:put(1, "one")
	treeMap:put(2, "two")

	lu.assertEquals(keysOf(treeMap), { 1, 2, 3 })
	lu.assertEquals(#treeMap, 3)
end

function TestTreeMapPut:testChecksRightLeftRotation()
	local treeMap = TreeMap.new()

	treeMap:put(1, "one")
	treeMap:put(3, "three")
	treeMap:put(2, "two")

	lu.assertEquals(keysOf(treeMap), { 1, 2, 3 })
	lu.assertEquals(#treeMap, 3)
end

function TestTreeMapPut:testChecksRightRightRotation()
	local treeMap = TreeMap.new()

	treeMap:put(1, "one")
	treeMap:put(2, "two")
	treeMap:put(3, "three")

	lu.assertEquals(keysOf(treeMap), { 1, 2, 3 })
	lu.assertEquals(#treeMap, 3)
end

function TestTreeMapPut:testPropagatesComparatorErrorWithoutAddingEntry()
	local treeMap = TreeMap.new(nil, function()
		error("comparator exploded")
	end)
	treeMap:put(1, "one")

	lu.assertErrorMsgContains("comparator exploded", function()
		treeMap:put(2, "two")
	end)

	lu.assertEquals(entriesOf(treeMap), { { key = 1, value = "one" } })
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapPut:testRejectsNilKey()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("key should not be nil", function()
		treeMap:put(nil, "val")
	end)
	lu.assertTrue(treeMap:empty())
end

function TestTreeMapPut:testRejectsNilValue()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		treeMap:put("key", nil)
	end)
	lu.assertTrue(treeMap:empty())
end

function TestTreeMapPut:testReplacesExistingKeyValue()
	local treeMap = TreeMap.new()

	treeMap:put("a", 1)
	treeMap:put("a", 2)

	lu.assertEquals(treeMap:get("a"), 2)
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapPut:testSequentialInsertionsMaintainLogarithmicHeight()
	local count = 96
	local ascending = {}
	local descending = {}
	local alternating = {}
	for key = 1, count do
		ascending[key] = key
		descending[key] = count - key + 1
	end
	local low = 1
	local high = count
	while low <= high do
		table.insert(alternating, low)
		if low ~= high then
			table.insert(alternating, high)
		end
		low = low + 1
		high = high - 1
	end

	for _, order in ipairs({ ascending, descending, alternating }) do
		local comparisonCount = 0
		local function countingComparator(a, b)
			comparisonCount = comparisonCount + 1
			if a < b then
				return Comparator.less
			elseif a > b then
				return Comparator.greater
			end
			return Comparator.equal
		end
		local treeMap = TreeMap.new(nil, countingComparator)

		for index, key in ipairs(order) do
			comparisonCount = 0
			treeMap:put(key, key * 10)
			lu.assertTrue(comparisonCount <= 4 * log2Ceiling(index + 1) + 4)
		end

		local expected = {}
		for key = 1, count do
			expected[key] = key
			lu.assertEquals(treeMap:get(key), key * 10)
		end
		lu.assertEquals(keysOf(treeMap), expected)
		lu.assertEquals(#treeMap, count)
	end
end

function TestTreeMapPutAll:testAppliesTableEntriesAndOverwritesConflictsByDefault()
	local treeMap = TreeMap.new({ a = 1, b = 2 })

	treeMap:putAll({ b = 20, c = 30 })

	lu.assertEquals(entriesOf(treeMap), {
		{ key = "a", value = 1 },
		{ key = "b", value = 20 },
		{ key = "c", value = 30 },
	})
	lu.assertEquals(#treeMap, 3)
end

function TestTreeMapPutAll:testCopiesEntriesFromAnotherTreeMap()
	local source = TreeMap.new({ a = 1, b = 2 })
	local treeMap = TreeMap.new()

	treeMap:putAll(source)

	lu.assertEquals(entriesOf(treeMap), entriesOf(source))
	lu.assertEquals(#treeMap, 2)
end

function TestTreeMapPutAll:testCustomResolverReceivesExistingAndIncomingValues()
	local treeMap = TreeMap.new({ counter = 10, flag = true })
	local calls = 0

	treeMap:putAll({ counter = 5, flag = false }, function(existing, incoming)
		calls = calls + 1
		if type(existing) == "number" then
			return existing + incoming
		end
		return incoming
	end)

	lu.assertEquals(calls, 2)
	lu.assertEquals(treeMap:get("counter"), 15)
	lu.assertFalse(treeMap:get("flag"))
end

function TestTreeMapPutAll:testCustomResolverRunsOnlyForConflictingKeys()
	local treeMap = TreeMap.new({ a = 1 })
	local calls = 0

	treeMap:putAll({ a = 2, b = 3 }, function(existing, incoming)
		calls = calls + 1
		lu.assertEquals(existing, 1)
		lu.assertEquals(incoming, 2)
		return 10
	end)

	lu.assertEquals(calls, 1)
	lu.assertEquals(treeMap:get("a"), 10)
	lu.assertEquals(treeMap:get("b"), 3)
	lu.assertEquals(#treeMap, 2)
end

function TestTreeMapPutAll:testIsNoOpForEmptyTable()
	local treeMap = TreeMap.new({ a = 1 })

	treeMap:putAll({})

	lu.assertEquals(entriesOf(treeMap), { { key = "a", value = 1 } })
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapPutAll:testIsNoOpForSelf()
	local treeMap = TreeMap.new({ a = 1, b = 2 })

	treeMap:putAll(treeMap)

	lu.assertEquals(entriesOf(treeMap), {
		{ key = "a", value = 1 },
		{ key = "b", value = 2 },
	})
	lu.assertEquals(#treeMap, 2)
end

function TestTreeMapPutAll:testPreservesFalseValues()
	local treeMap = TreeMap.new()

	treeMap:putAll({ flag = false })

	lu.assertTrue(treeMap:contains("flag"))
	lu.assertFalse(treeMap:get("flag"))
end

function TestTreeMapPutAll:testPropagatesResolverErrorWithoutModifyingConflictingEntry()
	local treeMap = TreeMap.new({ key = "stored" })

	lu.assertErrorMsgContains("resolver failure", function()
		treeMap:putAll({ key = "incoming" }, function()
			error("resolver failure")
		end)
	end)

	lu.assertEquals(treeMap:get("key"), "stored")
end

function TestTreeMapPutAll:testRejectsInvalidArguments()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		treeMap:putAll(nil)
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		treeMap:putAll(99)
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		treeMap:putAll("string")
	end)
	lu.assertErrorMsgContains("fn should be a function", function()
		treeMap:putAll({}, false)
	end)
	lu.assertErrorMsgContains("fn should be a function", function()
		treeMap:putAll({}, 123)
	end)
end

function TestTreeMapPutAll:testRejectsNilResolvedValue()
	local treeMap = TreeMap.new({ key = "stored" })

	lu.assertErrorMsgContains("value should not be nil", function()
		treeMap:putAll({ key = "incoming" }, function()
			return nil
		end)
	end)

	lu.assertEquals(treeMap:get("key"), "stored")
end

function TestTreeMapPutAll:testRejectsNilValuesInIterable()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		treeMap:putAll(orderedIterable({ { "key", nil } }))
	end)
	lu.assertTrue(treeMap:empty())
end

function TestTreeMapRange:testBoundsOutsideDataRangeReturnEmpty()
	local treeMap = TreeMap.new({ [10] = "ten", [20] = "twenty" })

	lu.assertEquals(rangeEntries(treeMap:range(30, 40)), {})
	lu.assertEquals(rangeEntries(treeMap:range(1, 5)), {})
end

function TestTreeMapRange:testIncludesBothBounds()
	local treeMap = TreeMap.new()
	for key = 1, 6 do
		treeMap:put(key, key * 10)
	end

	lu.assertEquals(rangeEntries(treeMap:range(2, 5)), {
		{ key = 2, value = 20 },
		{ key = 3, value = 30 },
		{ key = 4, value = 40 },
		{ key = 5, value = 50 },
	})
end

function TestTreeMapRange:testRejectsEqualBoundsDueToStrictComparisonCheck()
	local treeMap = TreeMap.new({ [1] = "one", [2] = "two", [3] = "three" })

	lu.assertErrorMsgContains("fromKey", function()
		treeMap:range(2, 2)
	end)
end

function TestTreeMapRange:testRejectsInvertedBounds()
	local treeMap = TreeMap.new({ [1] = 1, [2] = 2 })

	lu.assertErrorMsgContains("fromKey", function()
		treeMap:range(2, 1)
	end)
end

function TestTreeMapRange:testReturnsEmptyForEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertEquals(rangeEntries(treeMap:range(1, 10)), {})
end

function TestTreeMapRange:testSupportsBothBoundsNil()
	local treeMap = TreeMap.new({ [1] = "one", [2] = "two", [3] = "three" })

	lu.assertEquals(rangeEntries(treeMap:range(nil, nil)), entriesOf(treeMap))
end

function TestTreeMapRange:testSupportsUnboundedLower()
	local treeMap = TreeMap.new({ [1] = "one", [2] = "two", [3] = "three" })

	lu.assertEquals(rangeEntries(treeMap:range(nil, 2)), {
		{ key = 1, value = "one" },
		{ key = 2, value = "two" },
	})
end

function TestTreeMapRange:testSupportsUnboundedUpper()
	local treeMap = TreeMap.new({ [1] = "one", [2] = "two", [3] = "three" })

	lu.assertEquals(rangeEntries(treeMap:range(2, nil)), {
		{ key = 2, value = "two" },
		{ key = 3, value = "three" },
	})
end

function TestTreeMapRange:testUsesCustomComparator()
	local treeMap = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	for key = 1, 5 do
		treeMap:put(key, key * 10)
	end

	lu.assertEquals(rangeEntries(treeMap:range(4, 2)), {
		{ key = 4, value = 40 },
		{ key = 3, value = 30 },
		{ key = 2, value = 20 },
	})
end

function TestTreeMapRemove:testChecksDeletionRebalancingShapes()
	local cases = {
		{ order = { 4, 2, 6, 1, 3, 5, 0 }, remove = 5, expected = { 0, 1, 2, 3, 4, 6 } },
		{ order = { 4, 6, 2, 7, 5, 3, 8 }, remove = 3, expected = { 2, 4, 5, 6, 7, 8 } },
		{ order = { 5, 2, 6, 7, 1, 4, 3 }, remove = 7, expected = { 1, 2, 3, 4, 5, 6 } },
		{ order = { 5, 8, 4, 3, 9, 6, 7 }, remove = 3, expected = { 4, 5, 6, 7, 8, 9 } },
	}

	for _, case in ipairs(cases) do
		local treeMap = TreeMap.new()
		for _, key in ipairs(case.order) do
			treeMap:put(key, key)
		end

		lu.assertEquals(treeMap:remove(case.remove), case.remove)
		lu.assertEquals(keysOf(treeMap), case.expected)
		lu.assertEquals(#treeMap, #case.expected)
	end
end

function TestTreeMapRemove:testDeletesLeafNode()
	local treeMap = TreeMap.new({ [2] = "two", [1] = "one", [3] = "three" })

	lu.assertEquals(treeMap:remove(1), "one")
	lu.assertEquals(keysOf(treeMap), { 2, 3 })
	lu.assertEquals(#treeMap, 2)
end

function TestTreeMapRemove:testDeletesNodeWithBothChildren()
	local treeMap = TreeMap.new({
		[4] = "four",
		[2] = "two",
		[6] = "six",
		[1] = "one",
		[3] = "three",
		[5] = "five",
		[7] = "seven",
	})

	lu.assertEquals(treeMap:remove(4), "four")
	lu.assertEquals(keysOf(treeMap), { 1, 2, 3, 5, 6, 7 })
	lu.assertEquals(treeMap:get(5), "five")
	lu.assertEquals(#treeMap, 6)
end

function TestTreeMapRemove:testDeletesNodeWithOnlyLeftChild()
	local treeMap = TreeMap.new({ [2] = "two", [1] = "one" })

	lu.assertEquals(treeMap:remove(2), "two")
	lu.assertEquals(keysOf(treeMap), { 1 })
	lu.assertEquals(treeMap:get(1), "one")
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapRemove:testDeletesNodeWithOnlyRightChild()
	local treeMap = TreeMap.new({ [1] = "one", [2] = "two" })

	lu.assertEquals(treeMap:remove(1), "one")
	lu.assertEquals(keysOf(treeMap), { 2 })
	lu.assertEquals(treeMap:get(2), "two")
	lu.assertEquals(#treeMap, 1)
end

function TestTreeMapRemove:testDeletesRootNode()
	local treeMap = TreeMap.new({ [1] = "single" })

	lu.assertEquals(treeMap:remove(1), "single")
	lu.assertTrue(treeMap:empty())
	lu.assertEquals(#treeMap, 0)
end

function TestTreeMapRemove:testPreservesMapWhenKeyIsAbsent()
	local treeMap = TreeMap.new({ [1] = "one", [2] = "two" })

	lu.assertNil(treeMap:remove(99))
	lu.assertEquals(entriesOf(treeMap), {
		{ key = 1, value = "one" },
		{ key = 2, value = "two" },
	})
	lu.assertEquals(#treeMap, 2)
end

function TestTreeMapRemove:testRejectsNilKey()
	local treeMap = TreeMap.new()

	lu.assertErrorMsgContains("key should not be nil", function()
		treeMap:remove(nil)
	end)
end

function TestTreeMapRemove:testRemovesBooleanFalseValue()
	local treeMap = TreeMap.new({ [1] = false })

	lu.assertFalse(treeMap:remove(1))
	lu.assertTrue(treeMap:empty())
	lu.assertEquals(#treeMap, 0)
end

function TestTreeMapRemove:testReturnsNilOnEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertNil(treeMap:remove(1))
end

function TestTreeMapRemove:testSequentialDeletionsDrainMapCompletely()
	local count = 96
	local comparisonCount = 0
	local function countingComparator(a, b)
		comparisonCount = comparisonCount + 1
		if a < b then
			return Comparator.less
		elseif a > b then
			return Comparator.greater
		end
		return Comparator.equal
	end
	local treeMap = TreeMap.new(nil, countingComparator)
	for key = 1, count do
		treeMap:put(key, key * 10)
	end

	local removalOrder = {}
	for key = 2, count, 2 do
		table.insert(removalOrder, key)
	end
	for key = count - 1, 1, -2 do
		table.insert(removalOrder, key)
	end

	local removed = {}
	for _, key in ipairs(removalOrder) do
		comparisonCount = 0
		lu.assertEquals(treeMap:remove(key), key * 10)
		lu.assertTrue(comparisonCount <= 8 * log2Ceiling(count + 1) + 8)
		removed[key] = true

		local expected = {}
		for candidate = 1, count do
			if not removed[candidate] then
				table.insert(expected, candidate)
			end
		end
		lu.assertEquals(keysOf(treeMap), expected)
		lu.assertEquals(#treeMap, #expected)
	end
	lu.assertTrue(treeMap:empty())
end

function TestTreeMapTostring:testFormatsBooleanValues()
	local treeMap = TreeMap.new({ enabled = true })

	lu.assertEquals(tostring(treeMap), "{ enabled = true }")
end

function TestTreeMapTostring:testFormatsEmptyMap()
	local treeMap = TreeMap.new()

	lu.assertEquals(tostring(treeMap), "{  }")
end

function TestTreeMapTostring:testFormatsMultipleEntriesInKeyOrder()
	local treeMap = TreeMap.new({ b = 2, a = 1, c = 3 })

	lu.assertEquals(tostring(treeMap), "{ a = 1, b = 2, c = 3 }")
end

function TestTreeMapTostring:testFormatsSingleEntry()
	local treeMap = TreeMap.new({ a = 1 })

	lu.assertEquals(tostring(treeMap), "{ a = 1 }")
end

return {
	TestTreeMapCeiling = TestTreeMapCeiling,
	TestTreeMapClear = TestTreeMapClear,
	TestTreeMapCompute = TestTreeMapCompute,
	TestTreeMapConcat = TestTreeMapConcat,
	TestTreeMapContains = TestTreeMapContains,
	TestTreeMapEmpty = TestTreeMapEmpty,
	TestTreeMapEq = TestTreeMapEq,
	TestTreeMapFloor = TestTreeMapFloor,
	TestTreeMapGet = TestTreeMapGet,
	TestTreeMapIsTreeMap = TestTreeMapIsTreeMap,
	TestTreeMapLen = TestTreeMapLen,
	TestTreeMapMax = TestTreeMapMax,
	TestTreeMapMin = TestTreeMapMin,
	TestTreeMapNew = TestTreeMapNew,
	TestTreeMapNewindex = TestTreeMapNewindex,
	TestTreeMapPairs = TestTreeMapPairs,
	TestTreeMapPut = TestTreeMapPut,
	TestTreeMapPutAll = TestTreeMapPutAll,
	TestTreeMapRange = TestTreeMapRange,
	TestTreeMapRemove = TestTreeMapRemove,
	TestTreeMapTostring = TestTreeMapTostring,
}
