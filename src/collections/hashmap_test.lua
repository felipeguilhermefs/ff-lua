local lu = require("luaunit")
local HashMap = require("ff.collections.hashmap")
local Set = require("ff.collections.set")

local function mapSnapshot(map)
	local snapshot = {}
	for key, value in pairs(map) do
		snapshot[key] = value
	end
	return snapshot
end

local TestHashMapClear = {}
local TestHashMapCompute = {}
local TestHashMapConcat = {}
local TestHashMapContains = {}
local TestHashMapEmpty = {}
local TestHashMapEq = {}
local TestHashMapGet = {}
local TestHashMapIsHashMap = {}
local TestHashMapLen = {}
local TestHashMapNew = {}
local TestHashMapNewIndex = {}
local TestHashMapPairs = {}
local TestHashMapPut = {}
local TestHashMapPutAll = {}
local TestHashMapRemove = {}
local TestHashMapTostring = {}

function TestHashMapClear:testClearingEmptyMapIsSafe()
	local map = HashMap.new()

	map:clear()
	map:clear()

	lu.assertTrue(map:empty())
	lu.assertEquals(#map, 0)
end

function TestHashMapClear:testClearsEntriesAndAllowsReuse()
	local map = HashMap.new({ a = 1, flag = false })

	map:clear()

	lu.assertTrue(map:empty())
	lu.assertEquals(#map, 0)
	lu.assertEquals(mapSnapshot(map), {})

	map:put("after-clear", 2)

	lu.assertFalse(map:empty())
	lu.assertEquals(map:get("after-clear"), 2)
	lu.assertEquals(#map, 1)
end

function TestHashMapCompute:testCallbackErrorLeavesMapUnchanged()
	local map = HashMap.new({ existing = 1 })

	lu.assertErrorMsgContains("compute failed", function()
		map:compute("missing", function()
			error("compute failed")
		end)
	end)

	lu.assertNil(map:get("missing"))
	lu.assertEquals(map:get("existing"), 1)
	lu.assertEquals(#map, 1)
end

function TestHashMapCompute:testComputesAndStoresMissingValue()
	local map = HashMap.new()
	local calls = 0

	local value = map:compute("answer", function(key)
		calls = calls + 1
		lu.assertEquals(key, "answer")
		return 42
	end)

	lu.assertEquals(value, 42)
	lu.assertEquals(map:get("answer"), 42)
	lu.assertEquals(calls, 1)
	lu.assertEquals(#map, 1)
end

function TestHashMapCompute:testExistingFalseValueSkipsCallback()
	local map = HashMap.new({ flag = false })
	local calls = 0

	local value = map:compute("flag", function()
		calls = calls + 1
		return true
	end)

	lu.assertFalse(value)
	lu.assertEquals(calls, 0)
	lu.assertEquals(map:get("flag"), false)
	lu.assertEquals(#map, 1)
end

function TestHashMapCompute:testRejectsInvalidKeys()
	local map = HashMap.new()
	local nan = 0 / 0

	lu.assertErrorMsgContains("key should not be nil", function()
		map:compute(nil, function()
			return 1
		end)
	end)
	lu.assertErrorMsgContains("key should not be NaN", function()
		map:compute(nan, function()
			return 1
		end)
	end)
	lu.assertTrue(map:empty())
end

function TestHashMapCompute:testRejectsNilComputedValue()
	local map = HashMap.new()

	lu.assertErrorMsgContains("value should not be nil", function()
		map:compute("missing", function()
			return nil
		end)
	end)

	lu.assertFalse(map:contains("missing"))
	lu.assertEquals(#map, 0)
end

function TestHashMapCompute:testRejectsNonFunctionCallback()
	local map = HashMap.new({ present = 1 })

	lu.assertErrorMsgContains("fn should be a function", function()
		map:compute("missing", nil)
	end)
	lu.assertErrorMsgContains("fn should be a function", function()
		map:compute("missing", "callback")
	end)
	lu.assertErrorMsgContains("fn should be a function", function()
		map:compute("present", false)
	end)
	lu.assertEquals(#map, 1)
end

function TestHashMapConcat:testConcatenatesHashMapEntries()
	local left = HashMap.new({ left = 1 })
	local right = HashMap.new({ right = 2 })

	local result = left .. right

	lu.assertEquals(mapSnapshot(result), { left = 1, right = 2 })
	lu.assertEquals(mapSnapshot(left), { left = 1 })
	lu.assertEquals(mapSnapshot(right), { right = 2 })
	lu.assertNotIs(result, left)
end

function TestHashMapConcat:testConcatenatesNilAsIndependentCopy()
	local source = HashMap.new({ a = 1, flag = false })

	local result = source .. nil

	lu.assertEquals(mapSnapshot(result), mapSnapshot(source))
	lu.assertFalse(rawequal(result, source))
	result:put("new", 2)
	lu.assertNil(source:get("new"))
end

function TestHashMapConcat:testConcatenatesTableEntriesAndReplacesConflicts()
	local source = HashMap.new({ a = 1, kept = 3 })
	local other = { a = 2, added = false }

	local result = source .. other

	lu.assertEquals(mapSnapshot(result), { a = 2, kept = 3, added = false })
	lu.assertEquals(mapSnapshot(source), { a = 1, kept = 3 })
	lu.assertEquals(other, { a = 2, added = false })
	lu.assertNotIs(result, source)
end

function TestHashMapConcat:testRejectsNonTableOperand()
	local map = HashMap.new({ a = 1 })

	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = map .. "invalid"
	end)
	lu.assertEquals(mapSnapshot(map), { a = 1 })
end

function TestHashMapContains:testRejectsInvalidKeys()
	local map = HashMap.new()
	local nan = 0 / 0

	lu.assertErrorMsgContains("key should not be nil", function()
		map:contains(nil)
	end)
	lu.assertErrorMsgContains("key should not be NaN", function()
		map:contains(nan)
	end)
end

function TestHashMapContains:testReportsMissingAndStoredKeysIncludingFalseValues()
	local map = HashMap.new({ present = 1, flag = false })

	lu.assertFalse(map:contains("missing"))
	lu.assertTrue(map:contains("present"))
	lu.assertTrue(map:contains("flag"))
end

function TestHashMapEmpty:testReportsEmptyStateAfterMutations()
	local map = HashMap.new()

	lu.assertTrue(map:empty())
	map:put("key", false)
	lu.assertFalse(map:empty())
	map:remove("key")
	lu.assertTrue(map:empty())
	map:put("again", 1)
	map:clear()
	lu.assertTrue(map:empty())
end

function TestHashMapEq:testEmptyMapsCompareEqual()
	lu.assertTrue(HashMap.new() == HashMap.new())
end

function TestHashMapEq:testMapsCompareByShallowKeyValueEquality()
	local sharedValue = { nested = true }
	local left = HashMap.new({ a = 1, flag = false, nested = sharedValue })
	local right = HashMap.new({ nested = sharedValue, flag = false, a = 1 })

	lu.assertTrue(left == right)
	lu.assertFalse(HashMap.new({ nested = { value = 1 } }) == HashMap.new({ nested = { value = 1 } }))
end

function TestHashMapEq:testMapsWithDifferentEntriesCompareUnequal()
	local baseline = HashMap.new({ a = 1, b = 2 })

	lu.assertFalse(baseline == HashMap.new({ a = 1, b = 3 }))
	lu.assertFalse(baseline == HashMap.new({ a = 1, c = 2 }))
	lu.assertFalse(baseline == HashMap.new({ a = 1 }))
end

function TestHashMapEq:testNonHashMapValuesNeverCompareEqual()
	local map = HashMap.new({ a = 1 })

	lu.assertFalse(map == { a = 1 })
	lu.assertFalse(map == nil)
	lu.assertFalse(map == 42)
	lu.assertFalse(map == "map")
	lu.assertFalse(map == Set.new())
end

function TestHashMapGet:testRejectsInvalidKeys()
	local map = HashMap.new()
	local nan = 0 / 0

	lu.assertErrorMsgContains("key should not be nil", function()
		map:get(nil)
	end)
	lu.assertErrorMsgContains("key should not be NaN", function()
		map:get(nan)
	end)
end

function TestHashMapGet:testReturnsNilForMissingKeys()
	lu.assertNil(HashMap.new():get("missing"))
end

function TestHashMapGet:testReturnsStoredFalseAndOtherValues()
	local map = HashMap.new({ flag = false, answer = 42 })

	lu.assertFalse(map:get("flag"))
	lu.assertEquals(map:get("answer"), 42)
end

function TestHashMapIsHashMap:testRecognizesHashMapInstances()
	lu.assertTrue(HashMap.isHashMap(HashMap.new()))
	lu.assertTrue(HashMap.isHashMap(HashMap.new({ a = 1 })))
end

function TestHashMapIsHashMap:testRejectsOtherValueTypes()
	lu.assertFalse(HashMap.isHashMap(nil))
	lu.assertFalse(HashMap.isHashMap(false))
	lu.assertFalse(HashMap.isHashMap(42))
	lu.assertFalse(HashMap.isHashMap("map"))
	lu.assertFalse(HashMap.isHashMap({ a = 1 }))
	lu.assertFalse(HashMap.isHashMap(Set.new()))
end

function TestHashMapLen:testEmptyMapHasZeroLength()
	lu.assertEquals(#HashMap.new(), 0)
end

function TestHashMapLen:testLengthTracksInsertionsReplacementsRemovalsAndClear()
	local map = HashMap.new()

	map:put("a", 1)
	map:put("b", false)
	lu.assertEquals(#map, 2)

	map:put("a", 3)
	lu.assertEquals(#map, 2)

	map:remove("b")
	lu.assertEquals(#map, 1)

	map:clear()
	lu.assertEquals(#map, 0)
end

function TestHashMapNew:testCopiesEntriesFromHashMap()
	local source = HashMap.new({ a = 1, flag = false })

	local copy = HashMap.new(source)

	lu.assertEquals(mapSnapshot(copy), { a = 1, flag = false })
	lu.assertFalse(rawequal(copy, source))
	copy:put("a", 9)
	lu.assertEquals(source:get("a"), 1)
end

function TestHashMapNew:testCopiesTableShallowly()
	local nested = { value = 1 }
	local source = { a = 1, flag = false, nested = nested }

	local map = HashMap.new(source)

	source.a = 2
	lu.assertEquals(mapSnapshot(map), { a = 1, flag = false, nested = nested })
	lu.assertIs(map:get("nested"), nested)
end

function TestHashMapNew:testRejectsNonTableIterable()
	lu.assertErrorMsgContains("iterable should be a table", function()
		HashMap.new(false)
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		HashMap.new("invalid")
	end)
end

function TestHashMapNew:testStartsEmptyWhenIterableIsOmittedOrNil()
	local omitted = HashMap.new()
	local explicitNil = HashMap.new(nil)

	lu.assertTrue(omitted:empty())
	lu.assertTrue(explicitNil:empty())
	lu.assertEquals(#omitted, 0)
	lu.assertEquals(#explicitNil, 0)
end

function TestHashMapNewIndex:testRejectsAddingNewProperty()
	local map = HashMap.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to HashMap", function()
		map.extra = "value"
	end)
end

function TestHashMapNewIndex:testRejectsReplacingMethod()
	local map = HashMap.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to HashMap", function()
		map.put = function() end
	end)
end

function TestHashMapPairs:testEmptyMapYieldsNoPairs()
	local count = 0

	for _ in pairs(HashMap.new()) do
		count = count + 1
	end

	lu.assertEquals(count, 0)
end

function TestHashMapPairs:testIterationCanBeRepeatedWithoutMutation()
	local map = HashMap.new({ a = 1, b = false })
	local first = mapSnapshot(map)
	local second = mapSnapshot(map)

	lu.assertEquals(first, second)
	lu.assertEquals(mapSnapshot(map), { a = 1, b = false })
	lu.assertEquals(#map, 2)
end

function TestHashMapPairs:testIterationYieldsEveryKeyValuePair()
	local objectKey = {}
	local map = HashMap.new({ a = 1, flag = false, [objectKey] = "object key" })

	lu.assertEquals(mapSnapshot(map), { a = 1, flag = false, [objectKey] = "object key" })
end

function TestHashMapPut:testAcceptsFalseValuesAndNonPrimitiveKeys()
	local map = HashMap.new()
	local objectKey = {}

	map:put(false, false)
	map:put(objectKey, "table key")
	map:put(7, "number key")

	lu.assertTrue(map:contains(false))
	lu.assertFalse(map:get(false))
	lu.assertEquals(map:get(objectKey), "table key")
	lu.assertEquals(map:get(7), "number key")
	lu.assertEquals(#map, 3)
end

function TestHashMapPut:testRejectsNilKeysValuesAndNanKeys()
	local map = HashMap.new({ existing = 1 })
	local nan = 0 / 0

	lu.assertErrorMsgContains("key should not be nil", function()
		map:put(nil, 2)
	end)
	lu.assertErrorMsgContains("key should not be NaN", function()
		map:put(nan, 2)
	end)
	lu.assertErrorMsgContains("value should not be nil", function()
		map:put("missing", nil)
	end)
	lu.assertEquals(mapSnapshot(map), { existing = 1 })
end

function TestHashMapPut:testReplacesExistingValueWithoutChangingLength()
	local map = HashMap.new({ a = 1, b = 2 })

	map:put("a", false)

	lu.assertFalse(map:get("a"))
	lu.assertEquals(map:get("b"), 2)
	lu.assertEquals(#map, 2)
end

function TestHashMapPutAll:testCopiesAndOverwritesEntries()
	local map = HashMap.new({ a = 1, kept = 2 })
	local source = { a = false, added = 3 }

	map:putAll(source)

	lu.assertEquals(mapSnapshot(map), { a = false, kept = 2, added = 3 })
	lu.assertEquals(source, { a = false, added = 3 })
	lu.assertEquals(#map, 3)
end

function TestHashMapPutAll:testCustomResolverReceivesConflictValuesAndPreservesDistinctEntries()
	local map = HashMap.new({ a = 10, flag = false, kept = 5 })
	local resolverCalls = 0

	map:putAll({ a = 2, flag = true, added = 3 }, function(existing, incoming)
		resolverCalls = resolverCalls + 1
		if type(existing) == "number" then
			return existing + incoming
		end
		return incoming
	end)

	lu.assertEquals(resolverCalls, 2)
	lu.assertEquals(mapSnapshot(map), { a = 12, flag = true, kept = 5, added = 3 })
end

function TestHashMapPutAll:testDefaultResolverUsesIncomingValues()
	local map = HashMap.new({ a = 1, kept = 2 })

	map:putAll({ a = 3, added = 4 })

	lu.assertEquals(mapSnapshot(map), { a = 3, kept = 2, added = 4 })
end

function TestHashMapPutAll:testMergesHashMapEntries()
	local map = HashMap.new({ a = 1 })
	local source = HashMap.new({ b = false })

	map:putAll(source)

	lu.assertEquals(mapSnapshot(map), { a = 1, b = false })
	lu.assertEquals(mapSnapshot(source), { b = false })
end

function TestHashMapPutAll:testRejectsInvalidResolver()
	local map = HashMap.new({ a = 1 })

	lu.assertErrorMsgContains("fn should be a function", function()
		map:putAll({ a = 2 }, false)
	end)
	lu.assertErrorMsgContains("fn should be a function", function()
		map:putAll({ a = 2 }, "resolver")
	end)
	lu.assertEquals(map:get("a"), 1)
end

function TestHashMapPutAll:testRejectsNonTableIterable()
	local map = HashMap.new()

	lu.assertErrorMsgContains("iterable should be a table", function()
		map:putAll(nil)
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		map:putAll(42)
	end)
	lu.assertTrue(map:empty())
end

function TestHashMapPutAll:testResolverCannotStoreNilResult()
	local map = HashMap.new({ a = 1 })

	lu.assertErrorMsgContains("value should not be nil", function()
		map:putAll({ a = 2 }, function()
			return nil
		end)
	end)

	lu.assertEquals(map:get("a"), 1)
	lu.assertEquals(#map, 1)
end

function TestHashMapPutAll:testResolverErrorLeavesConflictingEntryUnchanged()
	local map = HashMap.new({ a = 1 })

	lu.assertErrorMsgContains("merge failed", function()
		map:putAll({ a = 2 }, function()
			error("merge failed")
		end)
	end)

	lu.assertEquals(map:get("a"), 1)
	lu.assertEquals(#map, 1)
end

function TestHashMapRemove:testRejectsInvalidKeys()
	local map = HashMap.new()
	local nan = 0 / 0

	lu.assertErrorMsgContains("key should not be nil", function()
		map:remove(nil)
	end)
	lu.assertErrorMsgContains("key should not be NaN", function()
		map:remove(nan)
	end)
end

function TestHashMapRemove:testRemovesStoredFalseAndOtherValues()
	local map = HashMap.new({ flag = false, value = 1, keep = 2 })

	lu.assertFalse(map:remove("flag"))
	lu.assertEquals(map:remove("value"), 1)
	lu.assertFalse(map:contains("flag"))
	lu.assertFalse(map:contains("value"))
	lu.assertTrue(map:contains("keep"))
	lu.assertEquals(#map, 1)
end

function TestHashMapRemove:testReturnsNilForMissingKeys()
	local map = HashMap.new({ keep = 2 })

	lu.assertNil(map:remove("missing"))
	lu.assertEquals(mapSnapshot(map), { keep = 2 })
	lu.assertEquals(#map, 1)
end

function TestHashMapTostring:testEmptyMapFormatsWithEmptyBraces()
	lu.assertEquals(tostring(HashMap.new()), "{  }")
end

function TestHashMapTostring:testFormatsSingleKeyValuePair()
	lu.assertEquals(tostring(HashMap.new({ key = "value" })), "{ key = value }")
end

function TestHashMapTostring:testIncludesAllPairsRegardlessOfOrder()
	local text = tostring(HashMap.new({ number = 42, flag = false, word = "value" }))

	lu.assertStrContains(text, "number = 42")
	lu.assertStrContains(text, "flag = false")
	lu.assertStrContains(text, "word = value")
end

return {
	TestHashMapClear = TestHashMapClear,
	TestHashMapCompute = TestHashMapCompute,
	TestHashMapConcat = TestHashMapConcat,
	TestHashMapContains = TestHashMapContains,
	TestHashMapEmpty = TestHashMapEmpty,
	TestHashMapEq = TestHashMapEq,
	TestHashMapGet = TestHashMapGet,
	TestHashMapIsHashMap = TestHashMapIsHashMap,
	TestHashMapLen = TestHashMapLen,
	TestHashMapNew = TestHashMapNew,
	TestHashMapNewIndex = TestHashMapNewIndex,
	TestHashMapPairs = TestHashMapPairs,
	TestHashMapPut = TestHashMapPut,
	TestHashMapPutAll = TestHashMapPutAll,
	TestHashMapRemove = TestHashMapRemove,
	TestHashMapTostring = TestHashMapTostring,
}
