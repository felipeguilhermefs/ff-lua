---@class Array
---@field private _entries table<any> Table array that holds the values.
---                                   Delegates most of the implementation to it.
local Array = {}
Array.__index = Array

-----------------------------------------------------------------------------
---Checks if it is an array, considers an empty table a array.
---
---@param maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function Array.isTableArray(maybe)
	if type(maybe) ~= "table" then
		return false
	end

	if next(maybe) == nil then
		return true
	end

	return #maybe > 0 and next(maybe, #maybe) == nil
end

-----------------------------------------------------------------------------
---Creates a new instance of the array.
---
---@param array table<any>? Collection of entries to initialize it.
---                         Defaults to an empty array if `nil`.
---
---@return Array
-----------------------------------------------------------------------------
function Array.new(array)
	local entries = {}

	if array then
		assert(Array.isTableArray(array), "Should be an array")

		for _, value in ipairs(array) do
			if value ~= nil then
				table.insert(entries, value)
			end
		end
	end

	return setmetatable({ _entries = entries }, Array)
end

-----------------------------------------------------------------------------
---Empties the array
-----------------------------------------------------------------------------
function Array:clear()
	self._entries = {}
end

-----------------------------------------------------------------------------
---Returns whether the array is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Array:empty()
	return #self == 0
end

-----------------------------------------------------------------------------
---Returns the value that in the given index.
---
---@param  index number
---
---@return any?
-----------------------------------------------------------------------------
function Array:get(index)
	return self._entries[index]
end

-----------------------------------------------------------------------------
---Add a value to a given index, following values will be shifted forward.
---Adds to the end of the array if no index is given.
---
---@param  value any      Value to be added, will ignore it if `nil`.
---@param  index number?  Index to add the value.
-----------------------------------------------------------------------------
function Array:insert(value, index)
	if value == nil then
		return
	end
	if index then
		table.insert(self._entries, index, value)
	else
		table.insert(self._entries, value)
	end
end

-----------------------------------------------------------------------------
---Overrides a value in a given index.
---
---@param  value any      Value to be added, will ignore it if `nil`.
---@param  index number   Index to add the value.
-----------------------------------------------------------------------------
function Array:put(value, index)
	if value and index then
		self._entries[index] = value
	end
end

-----------------------------------------------------------------------------
---Removes a value at a given index.
---
---@param  index number
-----------------------------------------------------------------------------
function Array:remove(index)
	if index then
		return table.remove(self._entries, index)
	end
end

-----------------------------------------------------------------------------
---Swap values at given indexes
---
---@param  index      number
---@param  otherIndex number
-----------------------------------------------------------------------------
function Array:swap(index, otherIndex)
	local tmp = self._entries[index]
	self._entries[index] = self._entries[otherIndex]
	self._entries[otherIndex] = tmp
end

-----------------------------------------------------------------------------
---Returns the number of entries in the array.
---
---@return number
---@private
-----------------------------------------------------------------------------
function Array:__len()
	return #self._entries
end

return Array
