-- LinkedList:
--	.new() - Creates a new instance of a (doubly) linked list
--	:pushFront(item) - Adds an item to the front of the list
--		item: Any item
--	:pushBack(item) - Adds an item to the back of the list
--		item: any item
--	:popFront() - Removes and returns the item in the front of the list
--		Returns nil if empty.
--	:popBack() - Removes and returns the item from the back of the list
--		Returns nil if empty.
--	:reverse() - Reverses the linked list inplace
--	:clear() - Empties the list
--	:empty() - Returns if the list is empty or not
--

local LinkedList = { __front = nil, __back = nil }
LinkedList.__index = LinkedList

local function Node(value, prev, next)
	return {
		value = value,
		prev = prev,
		next = next,
	}
end

function LinkedList:empty()
	return not self.__front
end

function LinkedList:clear()
	self.__front = nil
	self.__back = nil
end

function LinkedList:pushFront(item)
	self.__front = Node(item, nil, self.__front)
	if self.__front.next then
		self.__front.next.prev = self.__front
	end
	self.__back = self.__back or self.__front
end

function LinkedList:pushBack(item)
	self.__back = Node(item, self.__back, nil)
	if self.__back.prev then
		self.__back.prev.next = self.__back
	end
	self.__front = self.__front or self.__back
end

function LinkedList:popFront()
	if self:empty() then
		return nil
	end

	local item = self.__front.value

	if self.__front == self.__back then
		self:clear()
	else
		self.__front = self.__front.next
		self.__front.prev = nil
	end

	return item
end

function LinkedList:popBack()
	if self:empty() then
		return nil
	end

	local item = self.__back.value

	if self.__back == self.__front then
		self:clear()
	else
		self.__back = self.__back.prev
		self.__back.next = nil
	end

	return item
end

function LinkedList:reverse()
	if self:empty() then
		return
	end

	if self.__front == self.__back then
		return
	end

	local cur = self.__front
	local prev = nil
	local next = nil
	while cur do
		next = cur.next
		cur.next = prev
		cur.prev = next
		cur = next
	end

	cur = self.__front
	self.__front = self.__back
	self.__back = cur
end

function LinkedList.new()
	local new = {}
	setmetatable(new, LinkedList)

	return new
end

return LinkedList
