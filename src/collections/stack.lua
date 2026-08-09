local Array = require("ff.collections.array")

------------------------------
-- Cache function references
------------------------------

-- General
local assert = assert
local getmetatable = getmetatable
local pairs = pairs
local setmetatable = setmetatable
local type = type

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
	return setmetatable({ _entries = Array.new() }, Stack) .. iterable
end

-----------------------------------------------------------------------------
---Empties the stack.
-----------------------------------------------------------------------------
function Stack:clear()
	self._entries:clear()
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
---Adds an entry to the top of the stack.
---
---@param  entry any Entry to be added.
-----------------------------------------------------------------------------
function Stack:push(entry)
	assert(entry ~= nil, "entry should not be nil")
	self._entries[#self._entries + 1] = entry
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
		return self._entries[#self._entries]
	end
end

-----------------------------------------------------------------------------
---Pushes all items from a given iterable into this Stack (in-place modification).
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Stack Returns this Stack instance.
-----------------------------------------------------------------------------
function Stack:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, item in pairs(iterable) do
			self:push(item)
		end
	end

	return self
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
---Prevents the Stack class to be modified
-----------------------------------------------------------------------------
function Stack.__newindex()
	error("'Stack' class should not be modified")
end

-----------------------------------------------------------------------------
---Iterates through the stack in LIFO order by consuming items. Same as:
---
---while not stack:empty() do
---   local item = stack:pop()
---end
---
---@return fun(): number?, any? Generator function yielding (1, item) until empty.
-----------------------------------------------------------------------------
function Stack:__pairs()
	return function()
		local item = self:pop()
		if item ~= nil then
			return 1, item
		end
	end, self, nil
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
