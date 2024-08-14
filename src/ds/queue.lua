-- Queue:
--	.new() - Creates a new instance of a queue
--	:enqueue(item) - Adds an item to the back of the queue
--		item: any item
--	:dequeue() - Removes and returns the item in the front of the queue
--		Returns nil if empty.
--	:peek() - Returns the item in the front of the queue
--		Returns nil if empty.
--	:empty() - Returns if the heap is empty or not
--
local Queue = { __front = nil }
Queue.__index = Queue

local function Node(value, next)
	return {
		value = value,
		next = next,
	}
end

function Queue:enqueue(item)
	local node = Node(item, nil)

	if self.__back then
		self.__back.next = node
	else
		self.__front = node
	end
	self.__back = node
end

function Queue:dequeue()
	if self:empty() then
		return nil
	end

	local value = self.__front.value

	if self.__front == self.__back then
		self.__front = nil
		self.__back = nil
	else
		self.__front = self.__front.next
	end

	return value
end

function Queue:peek()
	if self:empty() then
		return nil
	else
		return self.__front.value
	end
end

function Queue:empty()
	return not self.__front
end

function Queue.new()
	local new = {}
	setmetatable(new, Queue)
	return new
end

return Queue
