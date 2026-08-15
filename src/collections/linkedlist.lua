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
local tostring = tostring
local type = type

---@class (private) LinkNode
---@field value any        Stores the value of this node.
---@field prev  LinkNode?  Points to the previous node in the list.
---@field next  LinkNode?  Points to the next node in the list.
local LinkNode = {}
LinkNode.__index = LinkNode

-----------------------------------------------------------------------------
---Creates a new instance of the node.
---
---@param  value  any
---@param  prev   LinkNode?
---@param  next   LinkNode?
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

--------------------------------------------------------------------------------------
---@class LinkedList
---@field private _front LinkNode? Node at the start of the list.
---@field private _back  LinkNode? Node at the end of the list.
---@field private _len   number    Number of entries in the list.
--------------------------------------------------------------------------------------
local LinkedList = {}
LinkedList.__index = LinkedList

-----------------------------------------------------------------------------
---Checks if it is a LinkedList instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function LinkedList.isLinkedList(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == LinkedList
end

-----------------------------------------------------------------------------
---Creates a new instance of the (doubly) linked list.
---
---@param  iterable? table<any, any>|LinkedList Optional table or LinkedList
---                                             to initialize the list from.
---
---@return LinkedList
-----------------------------------------------------------------------------
function LinkedList.new(iterable)
	return setmetatable({
		_back = nil,
		_front = nil,
		_len = 0,
	}, LinkedList) .. iterable
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
---Check the list sequentially O(n), and returns `true` if the entry is found.
---Does not consume or modify the list.
---
---@param  value any Value to search for (compared with `==`).
---
---@return boolean
-----------------------------------------------------------------------------
function LinkedList:contains(value)
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
---Returns whether the list is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function LinkedList:empty()
	return self._len == 0
end

-----------------------------------------------------------------------------
---Returns the value at the back of the list. Returns `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function LinkedList:peekBack()
	if self:empty() then
		return nil
	end

	return self._back.value
end

-----------------------------------------------------------------------------
---Returns the value at the front of the list. Returns `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function LinkedList:peekFront()
	if self:empty() then
		return nil
	end

	return self._front.value
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
---@param  entry any Entry to be added.
-----------------------------------------------------------------------------
function LinkedList:pushBack(entry)
	assert(entry ~= nil, "entry should not be nil")

	local node = LinkNode.new(entry, self._back, nil)
	if self._back ~= nil then
		self._back.next = node
	else
		self._front = node
	end
	self._back = node
	self._len = self._len + 1
end

-----------------------------------------------------------------------------
---Adds an entry to the front of the list.
---
---@param  entry any Entry to be added.
-----------------------------------------------------------------------------
function LinkedList:pushFront(entry)
	assert(entry ~= nil, "entry should not be nil")

	local node = LinkNode.new(entry, nil, self._front)
	if self._front ~= nil then
		self._front.prev = node
	else
		self._back = node
	end
	self._front = node
	self._len = self._len + 1
end

-----------------------------------------------------------------------------
---Reverses the linked list in-place.
---
---@return LinkedList Returns this LinkedList instance.
-----------------------------------------------------------------------------
function LinkedList:reverse()
	if self._len <= 1 then
		return self
	end

	local cur = self._front
	while cur ~= nil do
		local nxt = cur.next
		cur.next = cur.prev
		cur.prev = nxt
		cur = nxt
	end

	self._front, self._back = self._back, self._front

	return self
end

-----------------------------------------------------------------------------
---Concatenate a given iterable into this LinkedList (in-place modification).
---
---@param  iterable? table<any, any>  Any table or LinkedList that
---                                   can be iterated over. Defaults
---                                   to an empty list if `nil`.
---
---@return LinkedList                 Returns this LinkedList instance.
-----------------------------------------------------------------------------
function LinkedList:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, item in pairs(iterable) do
			self:pushBack(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when both are LinkedLists with the
---same size and containing the same elements in the same order.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function LinkedList:__eq(other)
	if not LinkedList.isLinkedList(other) then
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
---Returns the number of entries in the list.
---
---@return number
-----------------------------------------------------------------------------
function LinkedList:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through the LinkedList from 1 to #LinkedList.
---
---@return fun(): number?, any? Generator function yielding (index, value) pairs in order.
-----------------------------------------------------------------------------
function LinkedList:__pairs()
	local cur = self._front
	local index = 0
	return function()
		if cur ~= nil then
			local node = cur
			cur = node.next
			index = index + 1
			return index, node.value
		end
	end,
		self,
		nil
end

-----------------------------------------------------------------------------
---String representation of this linked list.
---
---@return string
-----------------------------------------------------------------------------
function LinkedList:__tostring()
	local sb = {}
	local cur = self._front
	while cur ~= nil do
		tinsert(sb, tostring(cur.value))
		cur = cur.next
	end
	return sfmt("[ %s ]", tconcat(sb, " -> "))
end

return LinkedList
