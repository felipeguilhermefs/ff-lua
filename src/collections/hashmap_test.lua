local lu = require("luaunit")
local HashMap = require("hashmap")

function TestEmpty()
	local map = HashMap.new()
	lu.assertTrue(map:empty())

	map:put("a", 1)
	lu.assertFalse(map:empty())

	map:clear()
	lu.assertTrue(map:empty())
end

function TestGet()
	local map = HashMap.new()

	lu.assertNil(map:get("a"))

	map:put("a", 1)
	lu.assertEquals(1, map:get("a"))

	map:put(1, "a")
	lu.assertEquals("a", map:get(1))

	lu.assertEquals(10, map:get("b", 10))
end

function TestPut()
	local map = HashMap.new()

	map:put("c", 1)
	lu.assertEquals(1, map:get("c"))
	lu.assertEquals(1, #map)

	map:put("c", 2)
	lu.assertEquals(2, map:get("c"))
	lu.assertEquals(1, #map)

	map:put("d", 3)
	lu.assertEquals(3, map:get("d"))
	lu.assertEquals(2, map:get("c"))
	lu.assertEquals(2, #map)
end

function TestContains()
	local map = HashMap.new()

	lu.assertFalse(map:contains("e"))

	map:put("e", false)
	lu.assertTrue(map:contains("e"))

	map:remove("e")
	lu.assertFalse(map:contains("e"))
end

function TestRemove()
	local map = HashMap.new()

	map:put("f", false)
	map:put("g", true)
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

function TestNil()
	local map = HashMap.new()

	map:put(nil, 1)
	lu.assertNil(map:get(nil))
	map:put(1, nil)
	lu.assertNil(map:get(1))

	lu.assertEquals("a", map:get(nil, "a"))

	lu.assertFalse(map:contains(nil))

	lu.assertEquals(0, #map)
	map:remove(nil)
	lu.assertEquals(0, #map)
end

function TestIterator()
	local map = HashMap.new()

	map:put("a", 1)
	map:put("b", 2)
	map:put("c", 3)
	map:put("d", 4)

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
	lu.assertEquals(10, map:get("a"))
	lu.assertEquals(20, map:get("b"))
	lu.assertEquals(30, map:get("c"))
	lu.assertEquals("d", map:get(1))
	lu.assertEquals("e", map:get(2))
	lu.assertEquals("f", map:get(3))
end

function TestMerge()
	local function add(a, b)
		return a + b
	end

	local map = HashMap.new() .. { a = 10, b = 20, c = 30 }
	local other = HashMap.new() .. { a = 1, b = 2, d = 4 }

	map:merge(other, add)

	lu.assertEquals(4, #map)
	lu.assertEquals(11, map:get("a"))
	lu.assertEquals(22, map:get("b"))
	lu.assertEquals(30, map:get("c"))
	lu.assertEquals(4, map:get("d"))
end

os.exit(lu.LuaUnit.run())
