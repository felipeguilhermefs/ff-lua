-- Stack:
--	.new() - Creates a new instance of a stack
--	:get(key) - Adds an item to the top of the stack
--		item: any item
--	:put(key, value) - Removes and returns the item in the top of the stack
--		Returns nil if empty.
--	:evict(key) - Returns the item in the top of the stack
--		Returns nil if empty.
--

local HashMap = require("ff.collections.hashmap")

local function Entry(key, value, prev, next)
	return { key = key, value = value, prev = prev, next = next }
end

local LRUCache = { __cap = nil, __head = nil, __tail = nil, __items = nil }
LRUCache.__index = LRUCache

function LRUCache:get(key)
	local entry = self.__items:get(key)
	if entry then
		self:__remove(entry)
		self:__add(entry)
		return entry.value
	end
end

function LRUCache:put(key, value)
	local entry = self.__items:get(key)
	if entry then
		self:__remove(entry)
		entry.value = value
		self:__add(entry)
	else
		if self.__items:len() >= self.__cap then
			self:__remove(self.__tail.prev)
		end

		self:__add(Entry(key, value))
	end
end

function LRUCache:evict(key)
	local entry = self.__items:get(key)
	if entry then
		self:__remove(entry)
	end
end

function LRUCache:__add(entry)
	local temp = self.__head.next
	entry.next = temp
	temp.prev = entry
	self.__head.next = entry
	entry.prev = self.__head
	self.__items:put(entry.key, entry)
end

function LRUCache:__remove(entry)
	entry.prev.next = entry.next
	entry.next.prev = entry.prev
	self.__items:remove(entry.key)
end

function LRUCache.new(capacity)
	local new = {}
	setmetatable(new, LRUCache)

	local head = Entry(0, 0)
	local tail = Entry(0, 0)
	head.next = tail
	tail.prev = head

	new.__head = head
	new.__tail = tail
	new.__cap = capacity
	new.__items = HashMap.new()
	return new
end

return LRUCache
