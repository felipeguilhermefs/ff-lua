local lu = require("luaunit")
local HashMap = require("hashmap")

-- ---------------------------------------------------------------------------
-- Existing tests (preserved and fixed where behaviour was undefined)
-- ---------------------------------------------------------------------------

function TestEmpty()
	local map = HashMap.new()
	lu.assertTrue(map:empty())

	map["a"] = 1
	lu.assertFalse(map:empty())

	map:clear()
	lu.assertTrue(map:empty())
end

function TestGet()
	local map = HashMap.new()

	lu.assertNil(map["a"])

	map["a"] = 1
	lu.assertEquals(1, map["a"])

	map[1] = "a"
	lu.assertEquals("a", map[1])
end

function TestPut()
	local map = HashMap.new()

	map["c"] = 1
	lu.assertEquals(1, map["c"])
	lu.assertEquals(1, #map)

	map["c"] = 2
	lu.assertEquals(2, map["c"])
	lu.assertEquals(1, #map)

	map["d"] = 3
	lu.assertEquals(3, map["d"])
	lu.assertEquals(2, map["c"])
	lu.assertEquals(2, #map)
end

function TestContains()
	local map = HashMap.new()

	lu.assertFalse(map:contains("e"))

	map["e"] = false
	lu.assertTrue(map:contains("e"))

	map:remove("e")
	lu.assertFalse(map:contains("e"))
end

function TestRemove()
	local map = HashMap.new()

	map["f"] = false
	map["g"] = true
	lu.assertEquals(2, #map)

	map:remove("f")

	lu.assertFalse(map:contains("f"))
	lu.assertTrue(map:contains("g"))

	lu.assertEquals(1, #map)
end

function TestCompute()
	local map = HashMap.new()

	lu.assertEquals(
		1,
		map:compute("a", function()
			return 1
		end)
	)
	lu.assertEquals(
		1,
		map:compute("a", function()
			return 2
		end)
	)
	lu.assertEquals(
		9,
		map:compute(3, function(key)
			return key * key
		end)
	)
end

function TestIterator()
	local map = HashMap.new()

	map["a"] = 1
	map["b"] = 2
	map["c"] = 3
	map["d"] = 4

	local res = {}
	for k, v in pairs(map) do
		res[#res + 1] = { key = k, value = v }
	end
	table.sort(res, function(a, b)
		return a.key < b.key
	end)

	lu.assertEquals({
		{ key = "a", value = 1 },
		{ key = "b", value = 2 },
		{ key = "c", value = 3 },
		{ key = "d", value = 4 },
	}, res)
end

function TestConcat()
	local map = HashMap.new() .. { a = 10, b = 20, c = 30 }
	lu.assertEquals(3, #map)

	map = map .. nil
	lu.assertEquals(3, #map)

	local arr = require("array").new({ "d", "e", "f" })

	map = map .. arr

	lu.assertEquals(6, #map)
	lu.assertEquals(10, map["a"])
	lu.assertEquals(20, map["b"])
	lu.assertEquals(30, map["c"])
	lu.assertEquals("d", map[1])
	lu.assertEquals("e", map[2])
	lu.assertEquals("f", map[3])
end

function TestMerge()
	local function add(a, b)
		return a + b
	end

	local map = HashMap.new({ a = 10, b = 20, c = 30 })
	local other = HashMap.new({ a = 1, b = 2, d = 4 })

	map:merge(other, add)

	lu.assertEquals(4, #map)
	lu.assertEquals(11, map["a"])
	lu.assertEquals(22, map["b"])
	lu.assertEquals(30, map["c"])
	lu.assertEquals(4, map["d"])
end

function TestNewWithInitialiser()
	local map = HashMap.new({ x = 1, y = 2, z = 3 })

	lu.assertEquals(3, #map)
	lu.assertEquals(1, map["x"])
	lu.assertEquals(2, map["y"])
	lu.assertEquals(3, map["z"])
end

function TestNewWithHashMapInitialiser()
	local source = HashMap.new({ a = 10, b = 20 })
	local copy = HashMap.new(source)

	lu.assertEquals(2, #copy)
	lu.assertEquals(10, copy["a"])
	lu.assertEquals(20, copy["b"])

	-- Confirm shallow independence
	copy["a"] = 99
	lu.assertEquals(10, source["a"])
end

function TestToString()
	local map = HashMap.new()
	map["key"] = "value"

	lu.assertEquals(tostring(map), "{ key = value }")
end

function TestEquals()
	local m1 = HashMap.new({ a = 1, b = 2 })
	local m2 = HashMap.new({ a = 1, b = 2 })
	local m3 = HashMap.new({ a = 1, b = 99 }) -- different value
	local m4 = HashMap.new({ a = 1 }) -- different size

	lu.assertTrue(m1 == m2)
	lu.assertFalse(m1 == m3)
	lu.assertFalse(m1 == m4)
end

function TestEqualsNotHashMap()
	local map = HashMap.new({ a = 1 })

	-- Comparing with a plain table or non-table must return false
	lu.assertFalse(map == { a = 1 })
	lu.assertFalse(map == nil)
	lu.assertFalse(map == 42)
end

function TestEqualsEmpty()
	local m1 = HashMap.new()
	local m2 = HashMap.new()
	lu.assertTrue(m1 == m2)
end

function TestEqualsFalsyValues()
	local m1 = HashMap.new()
	local m2 = HashMap.new()
	m1["flag"] = false
	m2["flag"] = false
	lu.assertTrue(m1 == m2)

	m2["flag"] = true
	lu.assertFalse(m1 == m2)
end

os.exit(lu.LuaUnit.run())
