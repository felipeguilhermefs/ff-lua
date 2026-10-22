-- Imports
local lu = require("luaunit")
local LRUCache = require("ff.cache.lru")

-- Suite definitions
local TestLRUCache = {}

-- Scenarios: cache behavior
function TestLRUCache:testCache_Retains_EntriesBelowCapacity()
	-- Given: an empty cache can hold three entries.
	local cache = LRUCache.new(3)

	-- When: query missing key "a".
	-- Then: lookup returns nil.
	lu.assertNil(cache:get("a"))

	-- When: store a, b, and c below capacity while reading a.
	-- Then: all inserts succeed and a remains readable.
	lu.assertTrue(cache:put("a", 1))
	lu.assertEquals(cache:get("a"), 1)
	lu.assertTrue(cache:put("b", 2))
	lu.assertTrue(cache:put("c", 3))
	lu.assertEquals(cache:get("a"), 1)
end

function TestLRUCache:testCache_Evicts_LeastRecentlyUsedEntryWhenCapacityIsExceeded()
	-- Given: cache has capacity 2.
	local cache = LRUCache.new(2)

	-- When: insert and access a and b.
	-- Then: both entries are stored successfully.
	lu.assertTrue(cache:put("a", 1))
	lu.assertEquals(cache:get("a"), 1)
	lu.assertTrue(cache:put("b", 2))
	lu.assertEquals(cache:get("b"), 2)

	-- When: insert c exceeding capacity.
	-- Then: a is evicted as least-recently-used while b and c remain readable.
	lu.assertTrue(cache:put("c", 3))
	lu.assertEquals(cache:get("c"), 3)
	lu.assertNil(cache:get("a"))
	lu.assertEquals(cache:get("b"), 2)
end

function TestLRUCache:testCache_Drops_LeastRecentlyUsedEntry()
	-- Given: cache with capacity 2 stores a and b.
	local cache = LRUCache.new(2)
	cache:put("a", 1)
	cache:put("b", 2)

	-- When: refresh entry a and insert c exceeding capacity.
	cache:get("a")
	local inserted = cache:put("c", 3)

	-- Then: insert succeeds, a stays cached, and least-recently-used b is evicted.
	lu.assertTrue(inserted)
	lu.assertEquals(cache:get("a"), 1)
	lu.assertNil(cache:get("b"))
end

function TestLRUCache:testUpdatingExistingEntry_DoesNotEvict_AnotherEntry()
	-- Given: cache with capacity 2 stores a and b.
	local cache = LRUCache.new(2)
	cache:put("a", 1)
	cache:put("b", 2)

	-- When: replace value of entry a.
	local updated = cache:put("a", 3)

	-- Then: update succeeds, a returns 3, and b remains cached.
	lu.assertTrue(updated)
	lu.assertEquals(cache:get("a"), 3)
	lu.assertEquals(cache:get("b"), 2)
end

function TestLRUCache:testEviction_Removes_RequestedEntry()
	-- Given: cache with capacity 2 stores a and b.
	local cache = LRUCache.new(2)
	cache:put("a", 1)
	cache:put("b", 2)

	-- When: evict both entries and insert c.
	local evictedB = cache:evict("b")
	local evictedA = cache:evict("a")
	local insertedC = cache:put("c", 3)

	-- Then: evictions and insertion succeed, and former entries are absent while c is readable.
	lu.assertTrue(evictedB)
	lu.assertTrue(evictedA)
	lu.assertTrue(insertedC)
	lu.assertEquals(cache:get("c"), 3)
	lu.assertNil(cache:get("a"))
	lu.assertNil(cache:get("b"))
end

function TestLRUCache:testCache_Rejects_NilKeysAndValues()
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

function TestLRUCache:testConstructor_Rejects_InvalidCapacity()
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
