---@class LinkNode
---
---@field value any
---@field prev  LinkNode?
---@field next  LinkNode?
---
---@private
local LinkNode = {}
LinkNode.__index = LinkNode

-----------------------------------------------------------------------------
---Creates a new instance of the node.
---
---@param value  any
---@param prev   LinkNode?
---@param next   LinkNode?
---
---@return LinkNode
-----------------------------------------------------------------------------
function LinkNode.new(value, prev, next)
	return setmetatable({
		value = value,
		prev = prev,
		next = next,
	}, LinkNode)
end

---@class LinkedList
---
---@field private _front LinkNode? Node at the start of the list.
---@field private _back  LinkNode? Node at the end of the list.
---@field private _len   number    Number of entries in the list.
local LinkedList = {}
LinkedList.__index = LinkedList

-----------------------------------------------------------------------------
---Creates a new instance of the (doubly) linked list.
---
---@return LinkedList
-----------------------------------------------------------------------------
function LinkedList.new()
	return setmetatable({
		_front = nil,
		_back = nil,
		_len = 0,
	}, LinkedList)
end

-----------------------------------------------------------------------------
---Empties the list.
-----------------------------------------------------------------------------
function LinkedList:clear()
	self._front = nil
	self._back = nil
	self._len = 0
end

-----------------------------------------------------------------------------
---Returns whether the list empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function LinkedList:empty()
	return not self._front
end

-----------------------------------------------------------------------------
---Removes and returns the entry at the back of the list, `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function LinkedList:popBack()
	if self:empty() then
		return nil
	end

	local entry = self._back.value

	if self._back == self._front then
		self:clear()
	else
		self._back = self._back.prev
		self._back.next = nil
		self._len = self._len - 1
	end

	return entry
end

-----------------------------------------------------------------------------
---Removes and returns the entry at the front of the list, `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function LinkedList:popFront()
	if self:empty() then
		return nil
	end

	local entry = self._front.value

	if self._front == self._back then
		self:clear()
	else
		self._front = self._front.next
		self._front.prev = nil
		self._len = self._len - 1
	end

	return entry
end

-----------------------------------------------------------------------------
---Adds an entry to the back of the list.
---
---@param  entry any
-----------------------------------------------------------------------------
function LinkedList:pushBack(entry)
	self._back = LinkNode.new(entry, self._back, nil)
	if self._back.prev then
		self._back.prev.next = self._back
	end
	self._front = self._front or self._back
	self._len = self._len + 1
end

-----------------------------------------------------------------------------
---Adds an entry to the front of the list.
---
---@param  entry any
-----------------------------------------------------------------------------
function LinkedList:pushFront(entry)
	self._front = LinkNode.new(entry, nil, self._front)
	if self._front.next then
		self._front.next.prev = self._front
	end
	self._back = self._back or self._front
	self._len = self._len + 1
end

-----------------------------------------------------------------------------
---Reverses the linked list inplace.
-----------------------------------------------------------------------------
function LinkedList:reverse()
	if self:empty() then
		return
	end

	if self._front == self._back then
		return
	end

	local cur = self._front
	local prev = nil
	local next = nil
	while cur do
		next = cur.next
		cur.next = prev
		cur.prev = next
		cur = next
	end

	cur = self._front
	self._front = self._back
	self._back = cur
end

-----------------------------------------------------------------------------
---Returns the number of entries in the list.
---
---@return number
---@private
-----------------------------------------------------------------------------
function LinkedList:__len()
	return self._len
end

return LinkedList
