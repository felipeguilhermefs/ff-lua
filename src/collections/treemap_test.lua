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
	lu.assertEquals(10, tm:get("a"))
	lu.assertEquals(20, tm:get("b"))
	lu.assertEquals(30, tm:get("c"))
	lu.assertEquals(40, tm:get("d"))
end

function TestConstructorWithComparator()
	local tm = TreeMap.new(nil, Comparator.reverse(Comparator.natural))
	tm:put(1, "one")
	tm:put(2, "two")
	tm:put(3, "three")

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

	tm:put("a", 1)
	lu.assertFalse(tm:empty())
	lu.assertEquals(1, #tm)

	tm:clear()
	lu.assertTrue(tm:empty())
	lu.assertEquals(0, #tm)

	-- Re-use after clear
	tm:put("z", 26)
	lu.assertEquals(1, #tm)
	lu.assertEquals(26, tm:get("z"))
end

function TestGetAndPut()
	local tm = TreeMap.new()

	lu.assertNil(tm:get("a"))

	tm:put("a", 100)
	lu.assertEquals(100, tm:get("a"))
	lu.assertEquals(1, #tm)

	-- Update existing key
	tm:put("a", 200)
	lu.assertEquals(200, tm:get("a"))
	lu.assertEquals(1, #tm)

	tm:put("b", 300)
	lu.assertEquals(300, tm:get("b"))
	lu.assertEquals(2, #tm)

	-- Assertion on nil keys / values
	lu.assertError(function()
		tm:put(nil, 1)
	end)
	lu.assertError(function()
		tm:put("c", nil)
	end)
end

function TestContains()
	local tm = TreeMap.new()

	lu.assertFalse(tm:contains("key"))

	tm:put("key", "value")
	lu.assertTrue(tm:contains("key"))
	lu.assertFalse(tm:contains("missing"))

	tm:remove("key")
	lu.assertFalse(tm:contains("key"))
end

function TestRemove()
	local tm = TreeMap.new()

	tm:put(4, "four")
	tm:put(2, "two")
	tm:put(6, "six")
	tm:put(1, "one")
	tm:put(3, "three")
	tm:put(5, "five")
	tm:put(7, "seven")

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
	lu.assertNil(tm:get(6))
	lu.assertTrue(tm:contains(5))
	lu.assertTrue(tm:contains(7))

	-- Remove node with two children (root 4)
	local val4 = tm:remove(4)
	lu.assertEquals("four", val4)
	lu.assertEquals(4, #tm)
	lu.assertNil(tm:get(4))
end

function TestRemoveEdgeCases()
	local tm = TreeMap.new()

	-- Empty tree
	lu.assertNil(tm:remove(10))
	lu.assertEquals(0, #tm)

	-- Non-existent key
	tm:put(10, "ten")
	lu.assertNil(tm:remove(99))
	lu.assertEquals(1, #tm)

	-- Single node tree removal
	lu.assertEquals("ten", tm:remove(10))
	lu.assertEquals(0, #tm)
	lu.assertTrue(tm:empty())

	-- Node with left child only
	local tmLeft = TreeMap.new()
	tmLeft:put(30, "thirty")
	tmLeft:put(20, "twenty")
	tmLeft:put(10, "ten")
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
	lu.assertEquals(9, tm:get(3))

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
	lu.assertEquals(11, tm:get("a"))
	lu.assertEquals(22, tm:get("b"))
	lu.assertEquals(30, tm:get("c"))
	lu.assertEquals(4, tm:get("d"))

	-- Default merge override
	local tm2 = TreeMap.new({ x = 1, y = 2 })
	tm2:merge({ y = 20, z = 30 })
	lu.assertEquals(3, #tm2)
	lu.assertEquals(1, tm2:get("x"))
	lu.assertEquals(20, tm2:get("y"))
	lu.assertEquals(30, tm2:get("z"))
end

function TestMinMax()
	local tm = TreeMap.new()
	lu.assertNil(tm:min())
	lu.assertNil(tm:max())

	tm:put(7, "seven")
	tm:put(3, "three")
	tm:put(9, "nine")
	tm:put(1, "one")
	tm:put(5, "five")

	local minK, minV = tm:min()
	lu.assertEquals(1, minK)
	lu.assertEquals("one", minV)

	local maxK, maxV = tm:max()
	lu.assertEquals(9, maxK)
	lu.assertEquals("nine", maxV)
end

function TestFloorCeiling()
	local tm = TreeMap.new()
	tm:put(10, "ten")
	tm:put(20, "twenty")
	tm:put(30, "thirty")
	tm:put(40, "forty")
	tm:put(50, "fifty")

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
		tm:put(i, i * 10)
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
	lu.assertEquals(10, tm:get("a"))
	lu.assertEquals(20, tm:get("b"))
	lu.assertEquals(30, tm:get("c"))
	lu.assertEquals(40, tm:get("d"))
	lu.assertEquals(50, tm:get("e"))
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

	tm:put(o1, "alpha")
	tm:put(o2, "beta")
	tm:put(o3, "gamma")

	lu.assertEquals(3, #tm)
	lu.assertEquals("gamma", tm:get({ score = 5 }))
	lu.assertEquals("alpha", tm:get({ score = 10 }))
	lu.assertEquals("beta", tm:get({ score = 20 }))

	local minKey, _ = tm:min()
	lu.assertEquals(5, minKey.score)
	local maxKey, _ = tm:max()
	lu.assertEquals(20, maxKey.score)
end

function TestNewIndexPreventsModifications()
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

os.exit(lu.LuaUnit.run())
