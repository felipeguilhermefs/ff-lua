-- Imports
local lu = require("luaunit")
local HashMap = require("ff.collections.hashmap")

-- Suite definitions
local TestHashMap = {}

-- Scenarios: construction and type recognition

function TestHashMap:testTypeGuardRecognizesHashMapsAndRejectsOtherValues()
	lu.assertTrue(HashMap.isHashMap(HashMap.new()))
	lu.assertTrue(HashMap.isHashMap(HashMap.new({ a = 1 })))

	lu.assertFalse(HashMap.isHashMap(nil))
	lu.assertFalse(HashMap.isHashMap(42))
	lu.assertFalse(HashMap.isHashMap("string"))
	lu.assertFalse(HashMap.isHashMap({ a = 1 }))
	lu.assertFalse(HashMap.isHashMap(require("ff.collections.set").new()))
end


function TestHashMap:testConstructorCopiesEntriesFromTable()
	local map = HashMap.new({ x = 1, y = 2, z = 3 })

	lu.assertEquals(#map, 3)
	lu.assertEquals(map:get("x"), 1)
	lu.assertEquals(map:get("y"), 2)
	lu.assertEquals(map:get("z"), 3)
end

function TestHashMap:testConstructorCopiesEntriesFromHashMapIndependently()
	local source = HashMap.new({ a = 10, b = 20 })
	local copy = HashMap.new(source)

	lu.assertEquals(#copy, 2)
	lu.assertEquals(copy:get("a"), 10)
	lu.assertEquals(copy:get("b"), 20)

	-- Confirm shallow independence
	copy:put("a", 99)
	lu.assertEquals(source:get("a"), 10)
end

-- Scenarios: reads and inspection

function TestHashMap:testGetReturnsStoredValuesAndNilForMissingKeys()
	local map = HashMap.new()

	lu.assertNil(map:get("a"))

	map:put("a", 1)
	lu.assertEquals(map:get("a"), 1)

	map:put(1, "a")
	lu.assertEquals(map:get(1), "a")
end

function TestHashMap:testContainsReportsMissingKeysAsAbsent()
	local map = HashMap.new()
	lu.assertFalse(map:contains("e"))
end

function TestHashMap:testContainsReportsKeyWithFalseValueAsPresent()
	local map = HashMap.new()
	map:put("e", false)
	lu.assertTrue(map:contains("e"))
end

function TestHashMap:testRemovedKeyIsNoLongerContained()
	local map = HashMap.new({ e = false })
	map:remove("e")
	lu.assertFalse(map:contains("e"))
end

function TestHashMap:testIterationYieldsEveryStoredKeyValuePair()
	local map = HashMap.new()

	map:put("a", 1)
	map:put("b", 2)
	map:put("c", 3)
	map:put("d", 4)

	local actual_pairs = {}
	for k, v in pairs(map) do
		actual_pairs[#actual_pairs + 1] = { key = k, value = v }
	end

	local expected_pairs = {
		{ key = "a", value = 1 },
		{ key = "b", value = 2 },
		{ key = "c", value = 3 },
		{ key = "d", value = 4 },
	}
	lu.assertItemsEquals(actual_pairs, expected_pairs)
end

-- Scenarios: state changes

function TestHashMap:testClearMakesMapEmpty()
	local map = HashMap.new()
	lu.assertTrue(map:empty())

	map:put("a", 1)
	lu.assertFalse(map:empty())

	map:clear()
	lu.assertTrue(map:empty())
end

function TestHashMap:testPutAddsEntriesAndReplacesExistingValues()
	local map = HashMap.new()

	map:put("c", 1)
	lu.assertEquals(map:get("c"), 1)
	lu.assertEquals(#map, 1)

	map:put("c", 2)
	lu.assertEquals(map:get("c"), 2)
	lu.assertEquals(#map, 1)

	map:put("d", 3)
	lu.assertEquals(map:get("d"), 3)
	lu.assertEquals(map:get("c"), 2)
	lu.assertEquals(#map, 2)
end

function TestHashMap:testRemoveDeletesOnlyRequestedEntry()
	local map = HashMap.new()

	map:put("f", false)
	map:put("g", true)
	lu.assertEquals(#map, 2)

	map:remove("f")

	lu.assertFalse(map:contains("f"))
	lu.assertTrue(map:contains("g"))

	lu.assertEquals(#map, 1)
end

function TestHashMap:testComputeStoresOnlyMissingKeys()
	local map = HashMap.new()

	lu.assertEquals(map:compute("a", function()
			return 1
		end), 1)
	lu.assertEquals(map:compute("a", function()
			return 2
		end), 1)
	lu.assertEquals(map:compute(3, function(key)
			return key * key
		end), 9)
end

function TestHashMap:testMergeCombinesOverlappingAndDistinctKeys()
	local function add(a, b)
		return a + b
	end

	local map = HashMap.new({ a = 10, b = 20, c = 30 })
	local other = HashMap.new({ a = 1, b = 2, d = 4 })

	map:merge(other, add)

	lu.assertEquals(#map, 4)
	lu.assertEquals(map:get("a"), 11)
	lu.assertEquals(map:get("b"), 22)
	lu.assertEquals(map:get("c"), 30)
	lu.assertEquals(map:get("d"), 4)
end

-- Scenarios: metamethods and formatting

function TestHashMap:testConcatAppendsTableAndArrayEntries()
	local map = HashMap.new() .. { a = 10, b = 20, c = 30 }
	lu.assertEquals(#map, 3)

	map = map .. nil
	lu.assertEquals(#map, 3)

	local arr = require("ff.collections.array").new({ "d", "e", "f" })

	map = map .. arr

	lu.assertEquals(#map, 6)
	lu.assertEquals(map:get("a"), 10)
	lu.assertEquals(map:get("b"), 20)
	lu.assertEquals(map:get("c"), 30)
	lu.assertEquals(map:get(1), "d")
	lu.assertEquals(map:get(2), "e")
	lu.assertEquals(map:get(3), "f")
end

function TestHashMap:testToStringFormatsKeyValuePairs()
	local map = HashMap.new()
	map:put("key", "value")

	lu.assertEquals(tostring(map), "{ key = value }")
end

function TestHashMap:testMapsWithSameEntriesCompareEqual()
	local m1 = HashMap.new({ a = 1, b = 2 })
	local m2 = HashMap.new({ a = 1, b = 2 })
	local m3 = HashMap.new({ a = 1, b = 99 }) -- different value
	local m4 = HashMap.new({ a = 1 }) -- different size

	-- Boolean assertions here intentionally exercise HashMap.__eq.
	lu.assertTrue(m1 == m2)
	lu.assertFalse(m1 == m3)
	lu.assertFalse(m1 == m4)
end

function TestHashMap:testMapDoesNotCompareEqualToOtherValueTypes()
	local map = HashMap.new({ a = 1 })

	-- These boolean assertions exercise HashMap.__eq for incompatible operands.
	lu.assertFalse(map == { a = 1 })
	lu.assertFalse(map == nil)
	lu.assertFalse(map == 42)
end

function TestHashMap:testEmptyMapsCompareEqual()
	local m1 = HashMap.new()
	local m2 = HashMap.new()
	-- This assertion exercises HashMap.__eq; assertEquals compares table structure.
	lu.assertTrue(m1 == m2)
end

function TestHashMap:testEqualityIncludesFalseValues()
	local m1 = HashMap.new()
	local m2 = HashMap.new()
	m1:put("flag", false)
	m2:put("flag", false)
	-- Boolean assertions here intentionally exercise HashMap.__eq.
	lu.assertTrue(m1 == m2)

	m2:put("flag", true)
	lu.assertFalse(m1 == m2)
end

function TestHashMap:testNewPropertiesAndMethodsCannotBeAddedOrReplaced()
	local m = HashMap.new({ a = 1 })

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to HashMap", function()
		m.foo = "bar"
	end)

	-- disallow adding numeric indices via bracket assignment
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to HashMap", function()
		m[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to HashMap", function()
		m.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to HashMap", function()
		m.get = function() end
	end)
end

-- Suite map
return { TestHashMap = TestHashMap }
