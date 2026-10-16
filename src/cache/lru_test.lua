-- Imports
local lu = require("luaunit")
local LRUCache = require("ff.cache.lru")

-- Suite definitions
local TestLRUCache = {}

-- Scenarios: cache behavior
function TestLRUCache:testCacheRetainsEntriesBelowCapacity()
	local cache = LRUCache.new(3)

	lu.assertNil(cache:get("a"))

	lu.assertTrue(cache:put("a", 1))
	lu.assertEquals(cache:get("a"), 1)
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:put("c", 3))
	lu.assertEquals(cache:get("a"), 1)
end

function TestLRUCache:testCacheEvictsLeastRecentlyUsedEntryWhenCapacityIsExceeded()
	local cache = LRUCache.new(2)

	lu.assertTrue(cache:put("a", 1))
	lu.assertEquals(cache:get("a"), 1)

	lu.assertTrue(cache:put("b", 2))
	lu.assertEquals(cache:get("b"), 2)

	lu.assertTrue(cache:put("c", 3))
	lu.assertEquals(cache:get("c"), 3)

	lu.assertNil(cache:get("a"))
	lu.assertEquals(cache:get("b"), 2)
end

function TestLRUCache:testCacheDropsLeastRecentlyUsedEntry()
	local cache = LRUCache.new(2)

	lu.assertTrue(cache:put("a", 1))
	lu.assertTrue(cache:put("b", 2))
	lu.assertEquals(cache:get("a"), 1)
	lu.assertTrue(cache:put("c", 3))

	lu.assertEquals(cache:get("a"), 1)
	lu.assertNil(cache:get("b"))
end

function TestLRUCache:testUpdatingExistingEntryDoesNotEvictAnotherEntry()
	local cache = LRUCache.new(2)

	lu.assertTrue(cache:put("a", 1))
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:put("a", 3))

	lu.assertEquals(cache:get("a"), 3)
	lu.assertEquals(cache:get("b"), 2)
end

function TestLRUCache:testEvictionRemovesRequestedEntry()
	local cache = LRUCache.new(2)

	lu.assertTrue(cache:put("a", 1))
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:evict("b"))
	lu.assertTrue(cache:evict("a"))
	lu.assertTrue(cache:put("c", 3))

	lu.assertEquals(cache:get("c"), 3)
	lu.assertNil(cache:get("a"))
	lu.assertNil(cache:get("b"))
end

function TestLRUCache:testCacheRejectsNilKeysAndValues()
	local cache = LRUCache.new(2)

	lu.assertFalse(cache:put(nil, "a"))
	lu.assertFalse(cache:put("a", nil))

	lu.assertNil(cache:get(nil))
	lu.assertNil(cache:get("a"))

	lu.assertFalse(cache:evict("a"))
	lu.assertFalse(cache:evict(nil))
end

function TestLRUCache:testConstructorRejectsInvalidCapacity()
	lu.assertErrorMsgContains("Capacity should be a number", LRUCache.new, "a")
	lu.assertErrorMsgContains("Capacity should be a number", LRUCache.new, nil)
	lu.assertErrorMsgContains("Capacity should be a number", LRUCache.new, true)
	lu.assertErrorMsgContains("Capacity should be positive", LRUCache.new, -1)
	lu.assertErrorMsgContains("Capacity should be positive", LRUCache.new, 0)
end

-- Suite map
return { TestLRUCache = TestLRUCache }
