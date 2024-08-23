local lu = require("luaunit")
local LRUCache = require("lru")

function TestUnderCapacity()
	local cache = LRUCache.new(3)

	lu.assertNil(cache:get("a"))

	lu.assertTrue(cache:put("a", 1))
	lu.assertEquals(1, cache:get("a"))
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:put("c", 3))
	lu.assertEquals(1, cache:get("a"))
end

function TestRotationWhenOverCapacity()
	local cache = LRUCache.new(2)

	lu.assertTrue(cache:put("a", 1))
	lu.assertEquals(1, cache:get("a"))

	lu.assertTrue(cache:put("b", 2))
	lu.assertEquals(2, cache:get("b"))

	lu.assertTrue(cache:put("c", 3))
	lu.assertEquals(3, cache:get("c"))

	lu.assertNil(cache:get("a"))
	lu.assertEquals(2, cache:get("b"))
end

function TestDropLeastRecentUsed()
	local cache = LRUCache.new(2)

	lu.assertTrue(cache:put("a", 1))
	lu.assertTrue(cache:put("b", 2))
	lu.assertEquals(1, cache:get("a"))
	lu.assertTrue(cache:put("c", 3))

	lu.assertEquals(1, cache:get("a"))
	lu.assertNil(cache:get("b"))
end

function TestUpdateValueWithoutDroping()
	local cache = LRUCache.new(2)

	lu.assertTrue(cache:put("a", 1))
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:put("a", 3))

	lu.assertEquals(3, cache:get("a"))
	lu.assertEquals(2, cache:get("b"))
end

function TestEvict()
	local cache = LRUCache.new(2)

	lu.assertTrue(cache:put("a", 1))
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:evict("b"))
	lu.assertTrue(cache:evict("a"))
	lu.assertTrue(cache:put("c", 3))

	lu.assertEquals(3, cache:get("c"))
	lu.assertNil(cache:get("a"))
	lu.assertNil(cache:get("b"))
end

function TestNil()
	local cache = LRUCache.new(2)

	lu.assertFalse(cache:put(nil, "a"))
	lu.assertFalse(cache:put("a", nil))

	lu.assertNil(cache:get(nil))
	lu.assertNil(cache:get("a"))

	lu.assertFalse(cache:evict("a"))
	lu.assertFalse(cache:evict(nil))
end

function TestCapacity()
	lu.assertError(LRUCache.new, "a")
	lu.assertError(LRUCache.new, nil)
	lu.assertError(LRUCache.new, true)
	lu.assertError(LRUCache.new, -1)
	lu.assertError(LRUCache.new, 0)
end

os.exit(lu.LuaUnit.run())
