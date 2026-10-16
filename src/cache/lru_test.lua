-- Imports
local lu = require("luaunit")
local LRUCache = require("ff.cache.lru")

-- Suite definitions
local TestLRUCache = {}

-- Scenarios: cache behavior
function TestLRUCache:testCacheRetainsEntriesBelowCapacity()
	-- Given: an empty cache can hold three entries.
	local cache = LRUCache.new(3)

	-- When: store a, b, and c, reading a before reaching capacity.
	-- Then: a remains readable and all inserts succeed.
	lu.assertNil(cache:get("a"))

	lu.assertTrue(cache:put("a", 1))
	lu.assertEquals(cache:get("a"), 1)
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:put("c", 3))
	lu.assertEquals(cache:get("a"), 1)
end

function TestLRUCache:testCacheEvictsLeastRecentlyUsedEntryWhenCapacityIsExceeded()
	-- Given: capacity is 2; a and b will be inserted before c.
	local cache = LRUCache.new(2)

	-- When: insert a and b, then insert c while accessing each new entry.
	-- Then: a is evicted while recently used b and c remain readable.
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
	-- Given: capacity is 2; a will be refreshed before c is inserted.
	local cache = LRUCache.new(2)

	-- When: store a and b, read a, then insert c.
	-- Then: a stays cached and least-recently-used b is evicted.
	lu.assertTrue(cache:put("a", 1))
	lu.assertTrue(cache:put("b", 2))
	lu.assertEquals(cache:get("a"), 1)
	lu.assertTrue(cache:put("c", 3))

	lu.assertEquals(cache:get("a"), 1)
	lu.assertNil(cache:get("b"))
end

function TestLRUCache:testUpdatingExistingEntryDoesNotEvictAnotherEntry()
	-- Given: a cache can hold a and b without eviction.
	local cache = LRUCache.new(2)

	-- When: replace a's value after storing a and b.
	-- Then: a returns 3 and b remains cached.
	lu.assertTrue(cache:put("a", 1))
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:put("a", 3))

	lu.assertEquals(cache:get("a"), 3)
	lu.assertEquals(cache:get("b"), 2)
end

function TestLRUCache:testEvictionRemovesRequestedEntry()
	-- Given: a cache can hold two entries.
	local cache = LRUCache.new(2)

	-- When: store a and b, evict both, then store c.
	-- Then: a and b are absent while c is readable.
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
	-- Given: a cache has capacity 2 and no entries.
	local cache = LRUCache.new(2)

	-- When: put nil keys or values, read nil and a missing key, and evict both.
	-- Then: invalid puts and evictions return false; missing reads return nil.
	lu.assertFalse(cache:put(nil, "a"))
	lu.assertFalse(cache:put("a", nil))

	lu.assertNil(cache:get(nil))
	lu.assertNil(cache:get("a"))

	lu.assertFalse(cache:evict("a"))
	lu.assertFalse(cache:evict(nil))
end

function TestLRUCache:testConstructorRejectsInvalidCapacity()
	-- Given: capacities include strings, nil, booleans, negatives, and zero.
	-- When: pass each candidate to LRUCache.new.
	-- Then: errors distinguish non-numeric from non-positive capacity.
	lu.assertErrorMsgContains("Capacity should be a number", LRUCache.new, "a")
	lu.assertErrorMsgContains("Capacity should be a number", LRUCache.new, nil)
	lu.assertErrorMsgContains("Capacity should be a number", LRUCache.new, true)
	lu.assertErrorMsgContains("Capacity should be positive", LRUCache.new, -1)
	lu.assertErrorMsgContains("Capacity should be positive", LRUCache.new, 0)
end

-- Suite map
return { TestLRUCache = TestLRUCache }
