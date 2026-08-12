------------------------------
-- Cache function references
------------------------------

-- String
local sfmt = string.format

-- Table
local tconcat = table.concat
local tinsert = table.insert

-- General
local assert = assert
local getmetatable = getmetatable
local pairs = pairs
local setmetatable = setmetatable
local type = type

---@class (private) QNode
---@field value any    Stores the value of this node.
---@field next  QNode? Points to a node further back in the queue.
local QNode = {}
QNode.__index = QNode

-----------------------------------------------------------------------------
---Creates a new instance of QNode.
---
---@param  value  any
---@param  next   QNode?
---
---@return QNode  New instance
-----------------------------------------------------------------------------
function QNode.new(value, next)
	return setmetatable({ value = value, next = next }, QNode)
end

---@class Queue
---@field private _front     QNode?   Wrapper marking the first spot in the queue.
---@field private _back      QNode?   Wrapper marking the last spot in the queue.
---@field private _len       number   Number of items in the queue.
---@field private _capacity  number?  Maximum number of items allowed in the queue.
local Queue = {}
Queue.__index = Queue

-----------------------------------------------------------------------------
---Checks if it is a Queue instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function Queue.isQueue(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == Queue
end

-----------------------------------------------------------------------------
---Creates a new instance of the queue.
---
---@param  iterable? table<any, any>    Optional table to initialize the queue
---                                     from. Items are enqueued in iteration
---                                     order.
---@param  capacity  number?            Maximum size desired for this queue. If
---                                     not provided, there will be no maximum.
---
---@return Queue
-----------------------------------------------------------------------------
function Queue.new(iterable, capacity)
	if capacity ~= nil then
		assert(type(capacity) == "number", "capacity should be a number")
		assert(capacity > 0, "capacity should be positive")
	end

	return setmetatable({
		_back = nil,
		_front = nil,
		_capacity = capacity,
		_len = 0,
	}, Queue) .. iterable
end

-----------------------------------------------------------------------------
---Empties the queue.
-----------------------------------------------------------------------------
function Queue:clear()
	self._front = nil
	self._back = nil
	self._len = 0
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
---Check the queue sequentially O(n), and returns "true" the entry is found.
---Does not consume or modify the stack.
---
---@param  value  any  Value to search for (compared with `==`).
---
---@return boolean
-----------------------------------------------------------------------------
function Queue:contains(value)
	assert(value ~= nil, "value should not be nil")

	local cur = self._front
	while cur ~= nil do
		if cur.value == value then
			return true
		end
		cur = cur.next
	end
	return false
end

-----------------------------------------------------------------------------
---Returns whether the queue is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Queue:empty()
	return self._len == 0
end

-----------------------------------------------------------------------------
---Check if the queue is at capacity. If the queue does not have a limit
---this will always return false.
---
---@return boolean
-----------------------------------------------------------------------------
function Queue:full()
	return self._capacity ~= nil and self._len >= self._capacity
end

-----------------------------------------------------------------------------
---Adds a value to the back of the queue.
---
---@param value  any Value to be stored, `nil` will be ignored.
---
---@return boolean   `true` if successfully enqueued the item.
-----------------------------------------------------------------------------
function Queue:enqueue(value)
	assert(value ~= nil, "value should not be nil")

	if self._capacity ~= nil and self._len >= self._capacity then
		return false
	end

	local node = QNode.new(value, nil)

	if self._back ~= nil then
		self._back.next = node
	else
		self._front = node
	end
	self._back = node
	self._len = self._len + 1
	return true
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
---Enqueues all items from a given iterable into this Queue (in-place
---modification).
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Queue Returns this Queue instance.
-----------------------------------------------------------------------------
function Queue:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, item in pairs(iterable) do
			self:enqueue(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when both are Queues with the same
---size and containing the same elements in the same FIFO order.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function Queue:__eq(other)
	if not Queue.isQueue(other) then
		return false
	end

	if self._len ~= other._len then
		return false
	end

	local a = self._front
	local b = other._front
	while a ~= nil do
		if a.value ~= b.value then
			return false
		end
		a = a.next
		b = b.next
	end

	return true
end

-----------------------------------------------------------------------------
---Returns the number of entries in the queue.
---
---@return number
-----------------------------------------------------------------------------
function Queue:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through the queue in FIFO order by consuming items. Same as:
---
---while not queue:empty() do
---   local item = queue:dequeue()
---end
---
---@return fun(): number?, any? Generator function yielding (1, item) until empty.
-----------------------------------------------------------------------------
function Queue:__pairs()
	return function()
		local item = self:dequeue()
		if item ~= nil then
			return 1, item
		end
	end, self, nil
end

-----------------------------------------------------------------------------
---String representation of this queue.
---
---@return string
-----------------------------------------------------------------------------
function Queue:__tostring()
	local sb = {}
	local cur = self._front
	while cur ~= nil do
		tinsert(sb, tostring(cur.value))
		cur = cur.next
	end

	return sfmt("[ Front => %s ]", tconcat(sb, ", "))
end

return Queue
