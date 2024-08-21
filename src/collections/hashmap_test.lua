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

	map:put("c", 2)
	lu.assertEquals(2, map:get("c"))

	map:put("d", 3)
	lu.assertEquals(3, map:get("d"))
	lu.assertEquals(2, map:get("c"))
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
	lu.assertEquals(2, map:len())

	map:remove("f")

	lu.assertFalse(map:contains("f"))
	lu.assertTrue(map:contains("g"))

	lu.assertEquals(1, map:len())
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

	lu.assertEquals(0, map:len())
	map:remove(nil)
	lu.assertEquals(0, map:len())
end

os.exit(lu.LuaUnit.run())
