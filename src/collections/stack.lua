---@class Stack
---
---@field private _entries   table<any> Table array that holds the entries.
local Stack = {}
Stack.__index = Stack

-----------------------------------------------------------------------------
---Creates a new instance of the stack.
---
---@return Stack
-----------------------------------------------------------------------------
function Stack.new()
	return setmetatable({ _entries = {} }, Stack)
end

-----------------------------------------------------------------------------
---Returns whether the stack is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Stack:empty()
	return #self == 0
end

-----------------------------------------------------------------------------
---Removes and returns the entry in the top of the stack, `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function Stack:pop()
	if not self:empty() then
		return table.remove(self._entries, #self._entries)
	end
end

-----------------------------------------------------------------------------
---Adds an entry to the top of the stack.
---
---@param  entry any
-----------------------------------------------------------------------------
function Stack:push(entry)
	table.insert(self._entries, entry)
end

-----------------------------------------------------------------------------
---Returns the entry in the top of the stack, `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function Stack:top()
	if not self:empty() then
		return self._entries[#self._entries]
	end
end

-----------------------------------------------------------------------------
---Pushes all items in a given iterable.
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Stack
-----------------------------------------------------------------------------
function Stack:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "Should be a table")

		for _, item in pairs(iterable) do
			self:push(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Returns the number of entries in the stack.
---
---@return number
---@private
-----------------------------------------------------------------------------
function Stack:__len()
	return #self._entries
end

-----------------------------------------------------------------------------
---Iterates through the stack in LIFO order. Same as:
---
---while not stack:empty() do
---   local item = stack:pop()
---end
---
---@return Iterator<1, any>, Stack<any>, nil
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
