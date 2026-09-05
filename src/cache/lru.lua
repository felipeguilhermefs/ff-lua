local HashMap = require("ff.collections.hashmap")

---@class (private) LRUNode
---@field key   any      Stores the key that is used for the lookup.
---@field value any      Stores the value of this node.
---@field prev  LRUNode? Points to a more recently used node.
---@field next  LRUNode? Points to a less recently used node.
local LRUNode = {}
LRUNode.__index = LRUNode

-----------------------------------------------------------------------------
---Creates a new instance of LRUNode
---
---@param  key   any  Key that will be used for a lookup.
---@param  value any  Value to be stored.
---
---@return LRUNode    New instance
-----------------------------------------------------------------------------
function LRUNode.new(key, value)
	return setmetatable({ key = key, value = value }, LRUNode)
end

---@class LRUCache
---@field private _cap    number                 Cache's maximum size.
---@field private _lookup HashMap<any, LRUNode>  Map for quick lookup.
---@field private _head   LRUNode                LRUNode at the front of the queue.
---                                              It points to the most recent node.
---@field private _tail   LRUNode                LRUNode at the back of the queue.
---                                              It points to the least recent node.
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
	local head = LRUNode.new(0, 0)
	local tail = LRUNode.new(0, 0)
	head.next = tail
	tail.prev = head

	return setmetatable({
		_cap = capacity,
		_lookup = HashMap.new(),
		_head = head,
		_tail = tail,
	}, LRUCache)
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

	local node = self._lookup:get(key)
	if node == nil then
		return false
	end

	self:_remove(node)
	return true
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

	local node = self._lookup:get(key)
	if node then
		self:_remove(node)
		self:_add(node)
		return node.value
	end
end

-----------------------------------------------------------------------------
---Adds a value to the cache associated by a lookup key.
---
---@param  key    any Key that will be used for lookup the value in the cache, `nil` will be ignored.
---@param  value  any Value to be stored in the cache, `nil` will be ignored.
---
---@return boolean    `true` if value was added, false otherwise.
-----------------------------------------------------------------------------
function LRUCache:put(key, value)
	if key == nil or value == nil then
		return false
	end

	local node = self._lookup:get(key)
	if node then
		self:_remove(node)
		node.value = value
		self:_add(node)
	else
		-- just need to check the capacity if a new node is added.
		if #self._lookup >= self._cap then
			self:_remove(self._tail.prev)
		end

		self:_add(LRUNode.new(key, value))
	end
	return true
end

-----------------------------------------------------------------------------
---Appends an node to the head and attach it to the map for quick lookup.
---
---@param  node LRUNode Most recently used node that needs to go to the
---                     front of the queue.
---
---@private
-----------------------------------------------------------------------------
function LRUCache:_add(node)
	-- since we have the head fixed, we just need to make it point to
	-- the most recently used node.
	local temp = self._head.next
	node.next = temp
	temp.prev = node
	self._head.next = node
	node.prev = self._head
	self._lookup:put(node.key, node)
end

-----------------------------------------------------------------------------
---Drops an node from the queue and from the map.
---
---@param  node LRUNode Most recently used node that needs to go to the
---                     front of the queue.
---
---@private
-----------------------------------------------------------------------------
function LRUCache:_remove(node)
	-- since we have head and tail fixed we can ignore common corner cases
	-- of removing from a doubly linked list.
	node.prev.next = node.next
	node.next.prev = node.prev
	self._lookup:remove(node.key)
end

-----------------------------------------------------------------------------
---Returns the number of nodes in the cache.
---
---@return number
---@private
-----------------------------------------------------------------------------
function LRUCache:__len()
	return #self._lookup
end

return LRUCache
