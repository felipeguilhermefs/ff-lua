-- Imports
local lu = require("luaunit")
local HashMap = require("ff.collections.hashmap")

-- Suite definitions
local TestHashMap = {}

-- Scenarios: construction and type recognition

function TestHashMap:testTypeGuard_Recognizes_HashMapsAndRejectsOtherValues()
	-- Given: candidates include HashMap instances, a plain table, a Set, and scalars.
	-- When: check each candidate with HashMap.isHashMap.
	-- Then: only HashMap instances return true.
	lu.assertTrue(HashMap.isHashMap(HashMap.new()))
	lu.assertTrue(HashMap.isHashMap(HashMap.new({ a = 1 })))

	lu.assertFalse(HashMap.isHashMap(nil))
	lu.assertFalse(HashMap.isHashMap(42))
	lu.assertFalse(HashMap.isHashMap("string"))
	lu.assertFalse(HashMap.isHashMap({ a = 1 }))
	lu.assertFalse(HashMap.isHashMap(require("ff.collections.set").new()))
end


function TestHashMap:testConstructor_CopiesEntries_FromTable()
	-- Given: a source table maps x, y, and z to 1, 2, and 3.

	-- When: initialize a HashMap from the table.
	local map = HashMap.new({ x = 1, y = 2, z = 3 })

	-- Then: all three key-value pairs are available in the new map.
	lu.assertEquals(#map, 3)
	lu.assertEquals(map:get("x"), 1)
	lu.assertEquals(map:get("y"), 2)
	lu.assertEquals(map:get("z"), 3)
end

function TestHashMap:testConstructor_CopiesEntries_FromHashMapIndependently()
	-- Given: a source HashMap maps a to 10 and b to 20.
	local source = HashMap.new({ a = 10, b = 20 })

	-- When: initialize a second HashMap from the source.
	local copy = HashMap.new(source)

	-- Then: the copy has both pairs.
	lu.assertEquals(#copy, 2)
	lu.assertEquals(copy:get("a"), 10)
	lu.assertEquals(copy:get("b"), 20)

	-- When: modify entry in the copy.
	copy:put("a", 99)

	-- Then: the source remains unchanged.
	lu.assertEquals(source:get("a"), 10)
end

-- Scenarios: reads and inspection

function TestHashMap:testGet_ReturnsStoredValues_AndNilForMissingKeys()
	-- Given: the map starts empty.
	local map = HashMap.new()

	-- When: read missing key "a".
	-- Then: lookup returns nil.
	lu.assertNil(map:get("a"))

	-- When: store key "a" with value 1.
	map:put("a", 1)

	-- Then: get returns 1.
	lu.assertEquals(map:get("a"), 1)

	-- When: store numeric key 1 with value "a".
	map:put(1, "a")

	-- Then: get returns "a".
	lu.assertEquals(map:get(1), "a")
end

function TestHashMap:testContains_Reports_MissingKeysAsAbsent()
	-- Given: the map is empty and membership target e is absent.
	local map = HashMap.new()

	-- When: check membership of absent key e.
	-- Then: contains returns false.
	lu.assertFalse(map:contains("e"))
end

function TestHashMap:testContains_ReportsKeyWithFalseValue_AsPresent()
	-- Given: the map is empty; key e will store false.
	local map = HashMap.new()

	-- When: store key e with value false.
	map:put("e", false)

	-- Then: contains returns true for key e.
	lu.assertTrue(map:contains("e"))
end

function TestHashMap:testRemovedKey_IsNoLonger_Contained()
	-- Given: the map contains only key e, whose value is false.
	local map = HashMap.new({ e = false })

	-- When: remove key e.
	map:remove("e")

	-- Then: contains returns false for key e.
	lu.assertFalse(map:contains("e"))
end

function TestHashMap:testIteration_Yields_EveryStoredKeyValuePair()
	-- Given: an empty map is prepared with four key-value pairs.
	local map = HashMap.new()

	map:put("a", 1)
	map:put("b", 2)
	map:put("c", 3)
	map:put("d", 4)

	-- When: collect entries yielded by pairs after insertion.
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

	-- Then: iteration includes each of the four inserted pairs.
	lu.assertItemsEquals(actual_pairs, expected_pairs)
end

-- Scenarios: state changes

function TestHashMap:testClear_Makes_MapEmpty()
	-- Given: an empty HashMap.
	local map = HashMap.new()

	-- When: check empty state initially.
	-- Then: empty reports true.
	lu.assertTrue(map:empty())

	-- When: insert key "a".
	map:put("a", 1)

	-- Then: empty reports false.
	lu.assertFalse(map:empty())

	-- When: clear the map.
	map:clear()

	-- Then: empty reports true again.
	lu.assertTrue(map:empty())
end

function TestHashMap:testPut_AddsEntries_AndReplacesExistingValues()
	-- Given: an empty HashMap.
	local map = HashMap.new()

	-- When: insert key "c" with value 1.
	map:put("c", 1)

	-- Then: get returns 1 and length is 1.
	lu.assertEquals(map:get("c"), 1)
	lu.assertEquals(#map, 1)

	-- When: update key "c" with value 2.
	map:put("c", 2)

	-- Then: get returns 2 and length remains 1.
	lu.assertEquals(map:get("c"), 2)
	lu.assertEquals(#map, 1)

	-- When: insert distinct key "d" with value 3.
	map:put("d", 3)

	-- Then: both keys are present and length is 2.
	lu.assertEquals(map:get("d"), 3)
	lu.assertEquals(map:get("c"), 2)
	lu.assertEquals(#map, 2)
end

function TestHashMap:testRemove_Deletes_OnlyRequestedEntry()
	-- Given: a HashMap containing keys "f" and "g".
	local map = HashMap.new()
	map:put("f", false)
	map:put("g", true)
	lu.assertEquals(#map, 2)

	-- When: remove key "f".
	map:remove("f")

	-- Then: key "f" is absent, key "g" remains, and map size drops to 1.
	lu.assertFalse(map:contains("f"))
	lu.assertTrue(map:contains("g"))
	lu.assertEquals(#map, 1)
end

function TestHashMap:testCompute_Stores_OnlyMissingKeys()
	-- Given: the map starts empty and callbacks are available for keys a and 3.
	local map = HashMap.new()

	-- When: compute key a twice, then compute numeric key 3.
	-- Then: a keeps its first result and key 3 stores its squared value.
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

function TestHashMap:testMerge_Combines_OverlappingAndDistinctKeys()
	-- Given: maps overlap on a and b; source-only keys are c and d.
	local function add(a, b)
		return a + b
	end

	local map = HashMap.new({ a = 10, b = 20, c = 30 })
	local other = HashMap.new({ a = 1, b = 2, d = 4 })

	-- When: merge using addition for keys present in both maps.
	map:merge(other, add)

	-- Then: overlap values add, unique values remain, and size is 4.
	lu.assertEquals(#map, 4)
	lu.assertEquals(map:get("a"), 11)
	lu.assertEquals(map:get("b"), 22)
	lu.assertEquals(map:get("c"), 30)
	lu.assertEquals(map:get("d"), 4)
end

-- Scenarios: metamethods and formatting

function TestHashMap:testConcat_Appends_TableAndArrayEntries()
	-- Given: an empty map, a table with a-c, and an Array with d-f.
	local map = HashMap.new()
	local arr = require("ff.collections.array").new({ "d", "e", "f" })

	-- When: concatenate the table, nil, and Array.
	map = map .. { a = 10, b = 20, c = 30 }
	map = map .. nil
	map = map .. arr

	-- Then: all six entries are present and nil leaves map size unchanged.
	lu.assertEquals(#map, 6)
	lu.assertEquals(map:get("a"), 10)
	lu.assertEquals(map:get("b"), 20)
	lu.assertEquals(map:get("c"), 30)
	lu.assertEquals(map:get(1), "d")
	lu.assertEquals(map:get(2), "e")
	lu.assertEquals(map:get(3), "f")
end

function TestHashMap:testToString_Formats_KeyValuePairs()
	-- Given: an empty map receives the key/value entry.
	local map = HashMap.new()
	map:put("key", "value")

	-- When: format the populated map with tostring.
	local text = tostring(map)

	-- Then: text is { key = value }.
	lu.assertEquals(text, "{ key = value }")
end

function TestHashMap:testMapsWithSameEntries_Compare_Equal()
	-- Given: maps have equal entries, a changed value, or a missing entry.
	local m1 = HashMap.new({ a = 1, b = 2 })
	local m2 = HashMap.new({ a = 1, b = 2 })
	local m3 = HashMap.new({ a = 1, b = 99 }) -- different value
	local m4 = HashMap.new({ a = 1 }) -- different size

	-- Boolean assertions here intentionally exercise HashMap.__eq.

	-- When: compare each map pair with ==.
	-- Then: only maps with matching entries and size are equal.
	lu.assertTrue(m1 == m2)
	lu.assertFalse(m1 == m3)
	lu.assertFalse(m1 == m4)
end

function TestHashMap:testMap_DoesNotCompareEqualTo_OtherValueTypes()
	-- Given: one HashMap is compared with a plain table, nil, and a number.
	local map = HashMap.new({ a = 1 })

	-- These boolean assertions exercise HashMap.__eq for incompatible operands.

	-- When: apply == to each incompatible operand.
	-- Then: all three comparisons return false.
	lu.assertFalse(map == { a = 1 })
	lu.assertFalse(map == nil)
	lu.assertFalse(map == 42)
end

function TestHashMap:testEmptyMaps_Compare_Equal()
	-- Given: both maps contain no entries.
	local m1 = HashMap.new()
	local m2 = HashMap.new()
	-- This assertion exercises HashMap.__eq; assertEquals compares table structure.

	-- When: compare the empty maps with ==.
	-- Then: equality returns true.
	lu.assertTrue(m1 == m2)
end

function TestHashMap:testEquality_Includes_FalseValues()
	-- Given: two maps each storing key "flag" with value false.
	local m1 = HashMap.new()
	local m2 = HashMap.new()
	m1:put("flag", false)
	m2:put("flag", false)

	-- When: compare maps with equal false values.
	-- Then: equality returns true.
	lu.assertTrue(m1 == m2)

	-- When: change flag to true in the second map.
	m2:put("flag", true)

	-- Then: equality returns false.
	lu.assertFalse(m1 == m2)
end

function TestHashMap:testNewPropertiesAndMethods_CannotBe_AddedOrReplaced()
	-- Given: the map contains key a and has existing method get.
	local m = HashMap.new({ a = 1 })

	-- When: assign a property, numeric key, function, and replacement get method.
	-- Then: every assignment raises the property-protection error.
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
