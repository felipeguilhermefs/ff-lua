---@class (private) Entry
---@field value any    Stores the value of this entry.
---@field next  Entry? Points to an entry further back in the queue.
local Entry = {}
Entry.__index = Entry

-----------------------------------------------------------------------------
---Creates a new instance of Entry
---
---@param  value any
---@param  next Entry?
---
---@return Entry      New instance
-----------------------------------------------------------------------------
function Entry.new(value, next)
	return setmetatable({ value = value, next = next }, Entry)
end

---@class Queue
---@field private _front     Entry?   Wrapper marking the first spot in the queue.
---@field private _back      Entry?   Wrapper marking the last spot in the queue.
---@field private _len       number   Number of items in the queue.
---@field private _capacity  number?  Maximum number of items allowed in the queue.
local Queue = {}
Queue.__index = Queue

-----------------------------------------------------------------------------
---Creates a new instance of the queue.
---
---@param  capacity number? Maximum size desired for this queue. If not provided, there will be no maximum capacity.
---
---@return Queue
-----------------------------------------------------------------------------
function Queue.new(capacity)
	if capacity then
		assert(type(capacity) == "number", "Capacity should be a number")
		assert(capacity > 0, "Capacity should be positive")
	end

	return setmetatable({
		_back = nil,
		_front = nil,
		_capacity = capacity,
		_len = 0,
	}, Queue)
end

-----------------------------------------------------------------------------
---Adds a value to the back of the queue
---
---@param value  any Value to be stored, `nil` will be ignored.
---
---@return boolean   `true` if successfully enqueued the item.
-----------------------------------------------------------------------------
function Queue:enqueue(value)
	if value == nil then
		return false
	end

	if self._capacity and self._len >= self._capacity then
		return false
	end

	local entry = Entry.new(value, nil)

	if self._back then
		self._back.next = entry
	else
		self._front = entry
	end
	self._back = entry
	self._len = self._len + 1
	return true
end

-----------------------------------------------------------------------------
---Removes and returns the value at the front of the queue. Returns `nil` if
---empty.
---
---@return any?
-----------------------------------------------------------------------------
function Queue:dequeue()
	if self:empty() then
		return nil
	end

	local value = self._front.value

	if self._front == self._back then
		self:clear()
	else
		self._front = self._front.next
		self._len = self._len - 1
	end

	return value
end

-----------------------------------------------------------------------------
---Returns the value at the front of the queue. Returns `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function Queue:peek()
	if self:empty() then
		return nil
	else
		return self._front.value
	end
end

-----------------------------------------------------------------------------
---Returns whether the queue is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Queue:empty()
	return not self._front
end

-----------------------------------------------------------------------------
---Empties the queue
-----------------------------------------------------------------------------
function Queue:clear()
	self._front = nil
	self._back = nil
	self._len = 0
end

-----------------------------------------------------------------------------
---Returns the number of entries in the queue.
---
---@return number
---@private
-----------------------------------------------------------------------------
function Queue:__len()
	return self._len
end

return Queue
