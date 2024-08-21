local lu = require("luaunit")
local LRUCache = require("lru")

function TestUnderCapacity()
	local cache = LRUCache.new(3)

	lu.assertNil(cache:get("a"))

	cache:put("a", 1)
	lu.assertEquals(1, cache:get("a"))
	cache:put("b", 2)
	cache:put("c", 3)
	lu.assertEquals(1, cache:get("a"))
end

function TestRotationWhenOverCapacity()
	local cache = LRUCache.new(2)

	cache:put("a", 1)
	lu.assertEquals(1, cache:get("a"))

	cache:put("b", 2)
	lu.assertEquals(2, cache:get("b"))

	cache:put("c", 3)
	lu.assertEquals(3, cache:get("c"))

	lu.assertNil(cache:get("a"))
	lu.assertEquals(2, cache:get("b"))
end

function TestDropLeastRecentUsed()
	local cache = LRUCache.new(2)

	cache:put("a", 1)
	cache:put("b", 2)
	cache:get("a")
	cache:put("c", 3)

	lu.assertEquals(1, cache:get("a"))
	lu.assertNil(cache:get("b"))
end

function TestEvict()
	local cache = LRUCache.new(2)

	cache:put("a", 1)
	cache:put("b", 2)
	cache:evict("b")
	cache:evict("a")
	cache:put("c", 3)

	lu.assertEquals(3, cache:get("c"))
	lu.assertNil(cache:get("a"))
	lu.assertNil(cache:get("b"))
end

os.exit(lu.LuaUnit.run())
