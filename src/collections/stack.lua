local Array = require("ff.collections.array")

----------------------------------------------------------------------------------
---@class Stack
---@field private _entries Array<any> Array that holds the entries.
---
----------------------------------------------------------------------------------
local Stack = {}
Stack.__index = Stack

-----------------------------------------------------------------------------
---Checks if it is a Stack instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function Stack.isStack(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == Stack
end

-----------------------------------------------------------------------------
---Creates a new instance of the stack.
---
---@param  iterable? table<any, any>|Stack Optional table or Stack to initialize
---                                        the stack from.
---
---@return Stack
-----------------------------------------------------------------------------
function Stack.new(iterable)
	local new = setmetatable({ _entries = Array.new() }, Stack)
	if iterable ~= nil then
		new:pushAll(iterable)
	end
	return new
end

-----------------------------------------------------------------------------
---Empties the stack.
-----------------------------------------------------------------------------
function Stack:clear()
	self._entries:clear()
end

-----------------------------------------------------------------------------
---Check the stack sequentially O(n), and returns "true" the entry is found.
---Does not consume or modify the stack.
---
---@param  entry  any  Value to search for (compared with `==`).
---
---@return boolean
-----------------------------------------------------------------------------
function Stack:contains(entry)
	assert(entry ~= nil, "entry should not be nil")

	return self._entries:indexOf(entry) ~= nil
end

-----------------------------------------------------------------------------
---Consumes items in LIFO order until empty.
---
---@return fun(): any?
-----------------------------------------------------------------------------
function Stack:drain()
	return function()
		return self:pop()
	end
end

-----------------------------------------------------------------------------
---Returns whether the stack is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Stack:empty()
	return self._entries:empty()
end

-----------------------------------------------------------------------------
---Removes and returns the entry at the top of the stack, `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function Stack:pop()
	if not self:empty() then
		return self._entries:remove(#self._entries)
	end
end

-----------------------------------------------------------------------------
---Pushes an entry to the top of the stack.
---
---@param  entry any Entry to be added.
-----------------------------------------------------------------------------
function Stack:push(entry)
	assert(entry ~= nil, "entry should not be nil")
	self._entries:insert(entry)
end

-----------------------------------------------------------------------------
---Pushes every value in the iterable to the top of the stack
---
---@param iterable table<any, any> Entries to add.
-----------------------------------------------------------------------------
function Stack:pushAll(iterable)
	assert(type(iterable) == "table", "iterable should be a table")

	for _, item in pairs(iterable) do
		self:push(item)
	end
end

-----------------------------------------------------------------------------
---Reverses the elements in the stack in-place.
---
---@return Stack Returns this stack instance.
-----------------------------------------------------------------------------
function Stack:reverse()
	local n = #self._entries
	for i = 1, n // 2 do
		self._entries:swap(i, n - i + 1)
	end
	return self
end

-----------------------------------------------------------------------------
---Returns the entry at the top of the stack, `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function Stack:top()
	if not self:empty() then
		return self._entries:get(#self._entries)
	end
end

-----------------------------------------------------------------------------
---Returns a new Stack containing this collection and iterable entries.
---Does not mutate either operand.
---
---@param iterable table<any, any> Entries to add.
---@return Stack
-----------------------------------------------------------------------------
function Stack:__concat(iterable)
	local result = Stack.new(self)
	if iterable == nil then
		return result
	end
	result:pushAll(iterable)
	return result
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when both are Stacks with the same size
---and containing the same elements in the same order.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function Stack:__eq(other)
	if not Stack.isStack(other) then
		return false
	end

	return self._entries == other._entries
end

-----------------------------------------------------------------------------
---Returns the number of entries in the stack.
---
---@return number
-----------------------------------------------------------------------------
function Stack:__len()
	return #self._entries
end

-----------------------------------------------------------------------------
---Metamethod __newindex prevents adding new properties, methods, or functions.
---
-----------------------------------------------------------------------------
function Stack:__newindex()
	error("cannot add new properties, methods or functions to Stack")
end

-----------------------------------------------------------------------------
---Iterates through the stack in LIFO order from top to bottom without consuming items.
---
---@return fun(state: Stack, key: number): number?, any?
---@return Stack
---@return nil
-----------------------------------------------------------------------------
function Stack:__pairs()
	local i = #self._entries + 1
	local index = 0
	return function()
		i = i - 1
		if i >= 1 then
			index = index + 1
			return index, self._entries:get(i)
		end
	end,
		self,
		nil
end

-----------------------------------------------------------------------------
---String representation of this stack
---
---@return string
-----------------------------------------------------------------------------
function Stack:__tostring()
	return string.format("[ %s <- Top ]", table.concat(self._entries, ", "))
end

return Stack
