local lu = require("luaunit")
local TreeMap = require("ff.collections.treemap")
local Comparator = require("ff.func.comparator")

TestTreeMap = {}

function TestTreeMap:testIsTreeMap()
	lu.assertTrue(TreeMap.isTreeMap(TreeMap.new()))
	lu.assertFalse(TreeMap.isTreeMap({}))
	lu.assertFalse(TreeMap.isTreeMap(nil))
	lu.assertFalse(TreeMap.isTreeMap("treemap"))
	lu.assertFalse(TreeMap.isTreeMap(123))
end

function TestTreeMap:testConstructor_Empty()
	local tm = TreeMap.new()
	lu.assertTrue(tm:empty())
	lu.assertEquals(#tm, 0)
end

function TestTreeMap:testConstructor_WithIterable()
	local tm = TreeMap.new({ d = 40, b = 20, a = 10, c = 30 })
	lu.assertFalse(tm:empty())
	lu.assertEquals(#tm, 4)
	lu.assertEquals(tm:get("a"), 10)
	lu.assertEquals(tm:get("b"), 20)
	lu.assertEquals(tm:get("c"), 30)
	lu.assertEquals(tm:get("d"), 40)
end

function TestTreeMap:testConstructor_WithComparator()
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

function TestTreeMap:testConstructor_Validation()
	lu.assertErrorMsgContains("comparator should be a function", TreeMap.new, nil, "invalid")
	lu.assertErrorMsgContains("comparator should be a function", TreeMap.new, nil, 123)
	lu.assertErrorMsgContains("comparator should be a function", TreeMap.new, nil, true)
	lu.assertErrorMsgContains("comparator should be a function", TreeMap.new, { a = 1 }, "not_a_function")
end

function TestTreeMap:testEmptyAndClear()
	local tm = TreeMap.new()

	lu.assertTrue(tm:empty())
	lu.assertEquals(#tm, 0)

	tm:put("a", 1)
	lu.assertFalse(tm:empty())
	lu.assertEquals(#tm, 1)

	tm:clear()
	lu.assertTrue(tm:empty())
	lu.assertEquals(#tm, 0)

	-- Re-use after clear
	tm:put("z", 26)
	lu.assertEquals(#tm, 1)
	lu.assertEquals(tm:get("z"), 26)
end

function TestTreeMap:testGetAndPut()
	local tm = TreeMap.new()

	lu.assertNil(tm:get("a"))

	tm:put("a", 100)
	lu.assertEquals(tm:get("a"), 100)
	lu.assertEquals(#tm, 1)

	-- Update existing key
	tm:put("a", 200)
	lu.assertEquals(tm:get("a"), 200)
	lu.assertEquals(#tm, 1)

	tm:put("b", 300)
	lu.assertEquals(tm:get("b"), 300)
	lu.assertEquals(#tm, 2)

	-- Assertion on nil keys / values
	lu.assertErrorMsgContains("key should not be nil", function()
		tm:put(nil, 1)
	end)
	lu.assertErrorMsgContains("value should not be nil", function()
		tm:put("c", nil)
	end)
end

function TestTreeMap:testContains()
	local tm = TreeMap.new()

	lu.assertFalse(tm:contains("key"))

	tm:put("key", "value")
	lu.assertTrue(tm:contains("key"))
	lu.assertFalse(tm:contains("missing"))

	tm:remove("key")
	lu.assertFalse(tm:contains("key"))
end

function TestTreeMap:testRemove()
	local tm = TreeMap.new()

	tm:put(4, "four")
	tm:put(2, "two")
	tm:put(6, "six")
	tm:put(1, "one")
	tm:put(3, "three")
	tm:put(5, "five")
	tm:put(7, "seven")

	lu.assertEquals(#tm, 7)

	-- Remove leaf
	local val1 = tm:remove(1)
	lu.assertEquals(val1, "one")
	lu.assertEquals(#tm, 6)
	lu.assertNil(tm[1])

	-- Remove node with right child only
	local val6 = tm:remove(6)
	lu.assertEquals(val6, "six")
	lu.assertEquals(#tm, 5)
	lu.assertNil(tm:get(6))
	lu.assertTrue(tm:contains(5))
	lu.assertTrue(tm:contains(7))

	-- Remove node with two children (root 4)
	local val4 = tm:remove(4)
	lu.assertEquals(val4, "four")
	lu.assertEquals(#tm, 4)
	lu.assertNil(tm:get(4))
end

function TestTreeMap:testRemove_EdgeCases()
	local tm = TreeMap.new()

	-- Empty tree
	lu.assertNil(tm:remove(10))
	lu.assertEquals(#tm, 0)

	-- Non-existent key
	tm:put(10, "ten")
	lu.assertNil(tm:remove(99))
	lu.assertEquals(#tm, 1)

	-- Single node tree removal
	lu.assertEquals(tm:remove(10), "ten")
	lu.assertEquals(#tm, 0)
	lu.assertTrue(tm:empty())

	-- Node with left child only
	local tmLeft = TreeMap.new()
	tmLeft:put(30, "thirty")
	tmLeft:put(20, "twenty")
	tmLeft:put(10, "ten")
	lu.assertEquals(tmLeft:remove(20), "twenty")
	lu.assertEquals(#tmLeft, 2)
	lu.assertTrue(tmLeft:contains(10))
	lu.assertTrue(tmLeft:contains(30))
	lu.assertFalse(tmLeft:contains(20))
end

function TestTreeMap:testCompute()
	local tm = TreeMap.new()

	lu.assertEquals(tm:compute(2, function()
			return 1
		end), 1)
	-- Computed value stored
	lu.assertEquals(tm:compute(2, function()
			return 2
		end), 1)

	lu.assertEquals(tm:compute(3, function(key)
			return key * key
		end), 9)
	lu.assertEquals(tm:get(3), 9)

	lu.assertErrorMsgContains("key should not be nil", function()
		tm:compute(nil, function() end)
	end)
	lu.assertErrorMsgContains("fn should be a function", function()
		tm:compute(3, "not_a_function")
	end)
end

function TestTreeMap:testMerge()
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

	-- Default merge override
	local tm2 = TreeMap.new({ x = 1, y = 2 })
	tm2:merge({ y = 20, z = 30 })
	lu.assertEquals(#tm2, 3)
	lu.assertEquals(tm2:get("x"), 1)
	lu.assertEquals(tm2:get("y"), 20)
	lu.assertEquals(tm2:get("z"), 30)
end

function TestTreeMap:testMinMax()
	local tm = TreeMap.new()
	lu.assertNil(tm:min())
	lu.assertNil(tm:max())

	tm:put(7, "seven")
	tm:put(3, "three")
	tm:put(9, "nine")
	tm:put(1, "one")
	tm:put(5, "five")

	local minK, minV = tm:min()
	lu.assertEquals(minK, 1)
	lu.assertEquals(minV, "one")

	local maxK, maxV = tm:max()
	lu.assertEquals(maxK, 9)
	lu.assertEquals(maxV, "nine")
end

function TestTreeMap:testFloorCeiling()
	local tm = TreeMap.new()
	tm:put(10, "ten")
	tm:put(20, "twenty")
	tm:put(30, "thirty")
	tm:put(40, "forty")
	tm:put(50, "fifty")

	-- floor (<=)
	lu.assertNil(tm:floor(5))
	lu.assertEquals(tm:floor(10), 10)
	lu.assertEquals(tm:floor(15), 10)
	lu.assertEquals(tm:floor(20), 20)
	lu.assertEquals(tm:floor(50), 50)
	lu.assertEquals(tm:floor(99), 50)

	-- ceiling (>=)
	lu.assertEquals(tm:ceiling(5), 10)
	lu.assertEquals(tm:ceiling(10), 10)
	lu.assertEquals(tm:ceiling(15), 20)
	lu.assertEquals(tm:ceiling(50), 50)
	lu.assertNil(tm:ceiling(55))
end

function TestTreeMap:testRange()
	local tm = TreeMap.new()
	for i = 1, 10 do
		tm:put(i, i * 10)
	end

	-- Range [3, 7]
	local r1 = {}
	for k, v in tm:range(3, 7) do
		table.insert(r1, { k, v })
	end
	lu.assertEquals(r1, {
		{ 3, 30 },
		{ 4, 40 },
		{ 5, 50 },
		{ 6, 60 },
		{ 7, 70 },
	})

	-- Unbounded below [nil, 4]
	local r2 = {}
	for k, v in tm:range(nil, 4) do
		table.insert(r2, { k, v })
	end
	lu.assertEquals(r2, {
		{ 1, 10 },
		{ 2, 20 },
		{ 3, 30 },
		{ 4, 40 },
	})

	-- Unbounded above [8, nil]
	local r3 = {}
	for k, v in tm:range(8, nil) do
		table.insert(r3, { k, v })
	end
	lu.assertEquals(r3, {
		{ 8, 80 },
		{ 9, 90 },
		{ 10, 100 },
	})
end

function TestTreeMap:testPairs()
	local tm = TreeMap.new({ d = 4, b = 2, a = 1, c = 3 })

	local res = {}
	for k, v in pairs(tm) do
		table.insert(res, { key = k, value = v })
	end

	-- pairs iterates in ascending key order
	lu.assertEquals(res, {
		{ key = "a", value = 1 },
		{ key = "b", value = 2 },
		{ key = "c", value = 3 },
		{ key = "d", value = 4 },
	})
end

function TestTreeMap:testConcat()
	local tm = TreeMap.new() .. { a = 10, b = 20, c = 30 }
	lu.assertEquals(#tm, 3)

	tm = tm .. nil
	lu.assertEquals(#tm, 3)

	local other = TreeMap.new({ d = 40, e = 50 })
	tm = tm .. other

	lu.assertEquals(#tm, 5)
	lu.assertEquals(tm:get("a"), 10)
	lu.assertEquals(tm:get("b"), 20)
	lu.assertEquals(tm:get("c"), 30)
	lu.assertEquals(tm:get("d"), 40)
	lu.assertEquals(tm:get("e"), 50)
end

function TestTreeMap:testEquality()
	local tm1 = TreeMap.new({ a = 1, b = 2, c = 3 })
	local tm2 = TreeMap.new({ c = 3, a = 1, b = 2 })
	local tm3 = TreeMap.new({ a = 1, b = 99, c = 3 })
	local tm4 = TreeMap.new({ a = 1, b = 2 })

	-- Boolean assertions here intentionally exercise TreeMap.__eq.
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

function TestTreeMap:testToString()
	local emptyTm = TreeMap.new()
	lu.assertEquals(tostring(emptyTm), "{  }")

	local tm = TreeMap.new({ b = 2, a = 1, c = 3 })
	lu.assertEquals(tostring(tm), "{ a = 1, b = 2, c = 3 }")
end

function TestTreeMap:testCustomComparator()
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

function TestTreeMap:testNewIndex_PreventsModifications()
	local tm = TreeMap.new()

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		tm.foo = "bar"
	end)

	-- disallow adding numeric indices via bracket assignment
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		tm[70] = 70
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		tm.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to TreeMap", function()
		tm.get = function() end
	end)
end

