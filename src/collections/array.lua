---@class Array
---@field private _entries table<any> Table array that holds the values.
---                                   Delegates most of the implementation to it.
local Array = {}
Array.__index = Array

-----------------------------------------------------------------------------
---Checks if it is (probably) an array, considers an empty table a array.
---
---@param maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function Array.isArray(maybe)
	if not maybe then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	if maybe.__index == Array then
		return true
	end

	if next(maybe) == nil then
		return true
	end

	return #maybe > 0 and next(maybe, #maybe) == nil
end

-----------------------------------------------------------------------------
---Creates a new instance of the array.
---
---@param array table<any>? Entries to be copied and initialize it.
---                         Defaults to an empty array if `nil`.
---
---@return Array
-----------------------------------------------------------------------------
function Array.new(array)
	array = array or {}
	return setmetatable({ _entries = {} }, Array) .. array
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
---Returns the the index of the first entry with a given value.
---It will return `nil` if nothing is found.
---
---@param  value? any
---
---@return number|nil
-----------------------------------------------------------------------------
function Array:indexOf(value)
	if value == nil then
		return nil
	end
	for index, item in pairs(self._entries) do
		if item == value then
			return index
		end
	end
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
---Concatenate a given Array or table array to this.
---
---@param array? table<any>|Array  Entries to be concatenated.
---                                Defaults to an empty array if `nil`.
---
---@return Array
-----------------------------------------------------------------------------
function Array:__concat(array)
	if array ~= nil then
		assert(Array.isArray(array), "Should be an array")

		for _, item in pairs(array) do
			self:insert(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Iterates through the array from 1 to #Array
---
---@return Iterator<any>, Array<any>, nil
-----------------------------------------------------------------------------
function Array:__pairs()
	return function(_, index)
		return next(self._entries, index)
	end, self, nil
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
