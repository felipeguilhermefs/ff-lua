local lu = require("luaunit")
local TreeMap = require("treemap")
local Comparator = require("ff.func.comparator")

function TestIsTreeMap()
	lu.assertTrue(TreeMap.isTreeMap(TreeMap.new()))
	lu.assertFalse(TreeMap.isTreeMap({}))
	lu.assertFalse(TreeMap.isTreeMap(nil))
	lu.assertFalse(TreeMap.isTreeMap("treemap"))
	lu.assertFalse(TreeMap.isTreeMap(123))
end

function TestConstructorEmpty()
	local tm = TreeMap.new()
	lu.assertTrue(tm:empty())
	lu.assertEquals(0, #tm)
end

function TestConstructorWithIterable()
	local tm = TreeMap.new({ d = 40, b = 20, a = 10, c = 30 })
	lu.assertFalse(tm:empty())
	lu.assertEquals(4, #tm)
	lu.assertEquals(10, tm["a"])
	lu.assertEquals(20, tm["b"])
	lu.assertEquals(30, tm["c"])
	lu.assertEquals(40, tm["d"])
end

function TestConstructorWithComparator()
	local tm = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	tm[1] = "one"
	tm[2] = "two"
	tm[3] = "three"

	lu.assertEquals(3, #tm)

	local k, v = tm:min()
	lu.assertEquals(3, k)
	lu.assertEquals("three", v)

	k, v = tm:max()
	lu.assertEquals(1, k)
	lu.assertEquals("one", v)
end

function TestConstructorValidation()
	lu.assertError(TreeMap.new, nil, "invalid")
	lu.assertError(TreeMap.new, nil, 123)
	lu.assertError(TreeMap.new, nil, true)
	lu.assertError(TreeMap.new, { a = 1 }, "not_a_function")
end

function TestEmptyAndClear()
	local tm = TreeMap.new()

	lu.assertTrue(tm:empty())
	lu.assertEquals(0, #tm)

	tm["a"] = 1
	lu.assertFalse(tm:empty())
	lu.assertEquals(1, #tm)

	tm:clear()
	lu.assertTrue(tm:empty())
	lu.assertEquals(0, #tm)

	-- Re-use after clear
	tm["z"] = 26
	lu.assertEquals(1, #tm)
	lu.assertEquals(26, tm["z"])
end

function TestGetAndPut()
	local tm = TreeMap.new()

	lu.assertNil(tm["a"])

	tm["a"] = 100
	lu.assertEquals(100, tm["a"])
	lu.assertEquals(1, #tm)

	-- Update existing key
	tm["a"] = 200
	lu.assertEquals(200, tm["a"])
	lu.assertEquals(1, #tm)

	tm["b"] = 300
	lu.assertEquals(300, tm["b"])
	lu.assertEquals(2, #tm)

	-- Assertion on nil keys / values
	lu.assertError(function()
		tm[nil] = 1
	end)
	lu.assertError(function()
		tm["c"] = nil
	end)
end

function TestBracketAccess()
	local tm = TreeMap.new()

	lu.assertNil(tm["x"])

	tm["x"] = 10
	lu.assertEquals(10, tm["x"])
	lu.assertEquals(1, #tm)

	tm["x"] = 20
	lu.assertEquals(20, tm["x"])
	lu.assertEquals(1, #tm)

	tm["y"] = 30
	lu.assertEquals(30, tm["y"])
	lu.assertEquals(2, #tm)

	-- Fallback to methods on missing key
	lu.assertEquals("function", type(tm["clear"]))
	lu.assertEquals("function", type(tm["range"]))
end

function TestContains()
	local tm = TreeMap.new()

	lu.assertFalse(tm:contains("key"))

	tm["key"] = "value"
	lu.assertTrue(tm:contains("key"))
	lu.assertFalse(tm:contains("missing"))

	tm:remove("key")
	lu.assertFalse(tm:contains("key"))
end

function TestRemove()
	local tm = TreeMap.new()

	tm[4] = "four"
	tm[2] = "two"
	tm[6] = "six"
	tm[1] = "one"
	tm[3] = "three"
	tm[5] = "five"
	tm[7] = "seven"

	lu.assertEquals(7, #tm)

	-- Remove leaf
	local val1 = tm:remove(1)
	lu.assertEquals("one", val1)
	lu.assertEquals(6, #tm)
	lu.assertNil(tm[1])

	-- Remove node with right child only
	local val6 = tm:remove(6)
	lu.assertEquals("six", val6)
	lu.assertEquals(5, #tm)
	lu.assertNil(tm[6])
	lu.assertTrue(tm:contains(5))
	lu.assertTrue(tm:contains(7))

	-- Remove node with two children (root 4)
	local val4 = tm:remove(4)
	lu.assertEquals("four", val4)
	lu.assertEquals(4, #tm)
	lu.assertNil(tm[4])
end

function TestRemoveEdgeCases()
	local tm = TreeMap.new()

	-- Empty tree
	lu.assertNil(tm:remove(10))
	lu.assertEquals(0, #tm)

	-- Non-existent key
	tm[10] = "ten"
	lu.assertNil(tm:remove(99))
	lu.assertEquals(1, #tm)

	-- Single node tree removal
	lu.assertEquals("ten", tm:remove(10))
	lu.assertEquals(0, #tm)
	lu.assertTrue(tm:empty())

	-- Node with left child only
	local tmLeft = TreeMap.new()
	tmLeft[30] = "thirty"
	tmLeft[20] = "twenty"
	tmLeft[10] = "ten"
	lu.assertEquals("twenty", tmLeft:remove(20))
	lu.assertEquals(2, #tmLeft)
	lu.assertTrue(tmLeft:contains(10))
	lu.assertTrue(tmLeft:contains(30))
	lu.assertFalse(tmLeft:contains(20))
end

function TestCompute()
	local tm = TreeMap.new()

	lu.assertEquals(
		1,
		tm:compute(2, function()
			return 1
		end)
	)
	-- Computed value stored
	lu.assertEquals(
		1,
		tm:compute(2, function()
			return 2
		end)
	)

	lu.assertEquals(
		9,
		tm:compute(3, function(key)
			return key * key
		end)
	)
	lu.assertEquals(9, tm[3])

	lu.assertError(function()
		tm:compute(nil, function() end)
	end)
	lu.assertError(function()
		tm:compute(3, "not_a_function")
	end)
end

function TestMerge()
	local function add(a, b)
		return a + b
	end

	local tm = TreeMap.new({ a = 10, b = 20, c = 30 })
	local other = { a = 1, b = 2, d = 4 }

	tm:merge(other, add)

	lu.assertEquals(4, #tm)
	lu.assertEquals(11, tm["a"])
	lu.assertEquals(22, tm["b"])
	lu.assertEquals(30, tm["c"])
	lu.assertEquals(4, tm["d"])

	-- Default merge override
	local tm2 = TreeMap.new({ x = 1, y = 2 })
	tm2:merge({ y = 20, z = 30 })
	lu.assertEquals(3, #tm2)
	lu.assertEquals(1, tm2["x"])
	lu.assertEquals(20, tm2["y"])
	lu.assertEquals(30, tm2["z"])
end

function TestMinMax()
	local tm = TreeMap.new()
	lu.assertNil(tm:min())
	lu.assertNil(tm:max())

	tm[7] = "seven"
	tm[3] = "three"
	tm[9] = "nine"
	tm[1] = "one"
	tm[5] = "five"

	local minK, minV = tm:min()
	lu.assertEquals(1, minK)
	lu.assertEquals("one", minV)

	local maxK, maxV = tm:max()
	lu.assertEquals(9, maxK)
	lu.assertEquals("nine", maxV)
end

function TestFloorCeiling()
	local tm = TreeMap.new()
	tm[10] = "ten"
	tm[20] = "twenty"
	tm[30] = "thirty"
	tm[40] = "forty"
	tm[50] = "fifty"

	-- floor (<=)
	lu.assertNil(tm:floor(5))
	lu.assertEquals(10, tm:floor(10))
	lu.assertEquals(10, tm:floor(15))
	lu.assertEquals(20, tm:floor(20))
	lu.assertEquals(50, tm:floor(50))
	lu.assertEquals(50, tm:floor(99))

	-- ceiling (>=)
	lu.assertEquals(10, tm:ceiling(5))
	lu.assertEquals(10, tm:ceiling(10))
	lu.assertEquals(20, tm:ceiling(15))
	lu.assertEquals(50, tm:ceiling(50))
	lu.assertNil(tm:ceiling(55))
end

function TestRange()
	local tm = TreeMap.new()
	for i = 1, 10 do
		tm[i] = i * 10
	end

	-- Range [3, 7]
	local r1 = {}
	for k, v in tm:range(3, 7) do
		table.insert(r1, { k, v })
	end
	lu.assertEquals({
		{ 3, 30 },
		{ 4, 40 },
		{ 5, 50 },
		{ 6, 60 },
		{ 7, 70 },
	}, r1)

	-- Unbounded below [nil, 4]
	local r2 = {}
	for k, v in tm:range(nil, 4) do
		table.insert(r2, { k, v })
	end
	lu.assertEquals({
		{ 1, 10 },
		{ 2, 20 },
		{ 3, 30 },
		{ 4, 40 },
	}, r2)

	-- Unbounded above [8, nil]
	local r3 = {}
	for k, v in tm:range(8, nil) do
		table.insert(r3, { k, v })
	end
	lu.assertEquals({
		{ 8, 80 },
		{ 9, 90 },
		{ 10, 100 },
	}, r3)
end

function TestPairs()
	local tm = TreeMap.new({ d = 4, b = 2, a = 1, c = 3 })

	local res = {}
	for k, v in pairs(tm) do
		table.insert(res, { key = k, value = v })
	end

	-- pairs iterates in ascending key order
	lu.assertEquals({
		{ key = "a", value = 1 },
		{ key = "b", value = 2 },
		{ key = "c", value = 3 },
		{ key = "d", value = 4 },
	}, res)
end

function TestConcat()
	local tm = TreeMap.new() .. { a = 10, b = 20, c = 30 }
	lu.assertEquals(3, #tm)

	tm = tm .. nil
	lu.assertEquals(3, #tm)

	local other = TreeMap.new({ d = 40, e = 50 })
	tm = tm .. other

	lu.assertEquals(5, #tm)
	lu.assertEquals(10, tm["a"])
	lu.assertEquals(20, tm["b"])
	lu.assertEquals(30, tm["c"])
	lu.assertEquals(40, tm["d"])
	lu.assertEquals(50, tm["e"])
end

function TestEquality()
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

function TestToString()
	local emptyTm = TreeMap.new()
	lu.assertEquals("{  }", tostring(emptyTm))

	local tm = TreeMap.new({ b = 2, a = 1, c = 3 })
	lu.assertEquals("{ a = 1, b = 2, c = 3 }", tostring(tm))
end

function TestCustomComparator()
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

	tm[o1] = "alpha"
	tm[o2] = "beta"
	tm[o3] = "gamma"

	lu.assertEquals(3, #tm)
	lu.assertEquals("gamma", tm[{ score = 5 }])
	lu.assertEquals("alpha", tm[{ score = 10 }])
	lu.assertEquals("beta", tm[{ score = 20 }])

	local minKey, _ = tm:min()
	lu.assertEquals(5, minKey.score)
	local maxKey, _ = tm:max()
	lu.assertEquals(20, maxKey.score)
end

os.exit(lu.LuaUnit.run())
