local HashMap = require("ff.collections.hashmap")

---@class (private) Entry
---@field key   any    Stores the key that is used for the lookup.
---@field value any    Stores the value of this entry.
---@field prev  Entry? Points to a more recently used entry.
---@field next  Entry? Points to a less recently used entry.
local Entry = {}
Entry.__index = Entry

-----------------------------------------------------------------------------
---Creates a new instance of Entry
---
---@param  key   any  Key that will be used for a lookup.
---@param  value any  Value to be stored.
---
---@return Entry      New instance
-----------------------------------------------------------------------------
function Entry.new(key, value)
	return setmetatable({ key = key, value = value }, Entry)
end

---@class LRUCache
---@field private _cap   number               Cache's maximum size.
---@field private _items HashMap<any, Entry>  Map for quick lookup.
---@field private _head  Entry                Entry at the front of the queue.
---                                           It points to the most recent entry.
---@field private _tail  Entry                Entry at the back of the queue.
---                                           It points to the least recent entry.
local LRUCache = {}
LRUCache.__index = LRUCache

-----------------------------------------------------------------------------
---Creates a new instance of the LRU cache
---
---@param  capacity number Maximum size desired for this cache. Should be a positive inumber.
---
---@return LRUCache        New instance
-----------------------------------------------------------------------------
function LRUCache.new(capacity)
	assert(type(capacity) == "number", "Capacity should be a number")
	assert(capacity > 0, "Capacity should be positive")

	-- head and tail are fixed to make adding and removing from the
	-- queue simpler, as checking the borders for `nil` is not needed
	-- since
	local head = Entry.new(0, 0)
	local tail = Entry.new(0, 0)
	head.next = tail
	tail.prev = head

	return setmetatable({
		_cap = capacity,
		_items = HashMap.new(),
		_head = head,
		_tail = tail,
	}, LRUCache)
end

-----------------------------------------------------------------------------
---Returns the value from the cache that is associated with the key.
---
---@param  key any  Key used for lookup the value in the cache
---
---@return any      Value associated with key, or `nil` if not found
-----------------------------------------------------------------------------
function LRUCache:get(key)
	if key == nil then
		return nil
	end

	local entry = self._items:get(key)
	if entry then
		self:_remove(entry)
		self:_add(entry)
		return entry.value
	end
end

-----------------------------------------------------------------------------
---Adds a value to the cache associated by a lookup key.
---
---@param  key    any Key that will be used for lookup the value in the cache, `nil` will be ignored.
---@param  value  any Value to be stored in the cache, `nil` will be ignored.
---
---@return boolean     `true` if value was added, false otherwise.
-----------------------------------------------------------------------------
function LRUCache:put(key, value)
	if key == nil or value == nil then
		return false
	end

	local entry = self._items:get(key)
	if entry then
		self:_remove(entry)
		entry.value = value
		self:_add(entry)
	else
		-- just need to check the capacity if a new entry is added.
		if #self._items >= self._cap then
			self:_remove(self._tail.prev)
		end

		self:_add(Entry.new(key, value))
	end
	return true
end

-----------------------------------------------------------------------------
---Removes a value from the cache that is associated with the key.
---
---@param  key    any Key used for lookup the value in the cache
---
---@return boolean    `true` if value was present, false otherwise.
-----------------------------------------------------------------------------
function LRUCache:evict(key)
	if key == nil then
		return false
	end

	local entry = self._items:get(key)
	if entry == nil then
		return false
	end

	self:_remove(entry)
	return true
end

-----------------------------------------------------------------------------
---Appends an entry to the head and attach it to the map for quick lookup.
---
---@param  entry Entry  Most recently used entry that needs to go to the
---                     front of the queue.
---
---@private
-----------------------------------------------------------------------------
function LRUCache:_add(entry)
	-- since we have the head fixed, we just need to make it point to
	-- the most recently used entry.
	local temp = self._head.next
	entry.next = temp
	temp.prev = entry
	self._head.next = entry
	entry.prev = self._head
	self._items:put(entry.key, entry)
end

-----------------------------------------------------------------------------
---Drops an entry from the queue and from the map.
---
---@param  entry Entry  Most recently used entry that needs to go to the
---                     front of the queue.
---
---@private
-----------------------------------------------------------------------------
function LRUCache:_remove(entry)
	-- since we have head and tail fixed we can ignore common corner cases
	-- of removing from a doubly linked list.
	entry.prev.next = entry.next
	entry.next.prev = entry.prev
	self._items:remove(entry.key)
end

return LRUCache
