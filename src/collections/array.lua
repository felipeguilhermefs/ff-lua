---@class Array
---@field private _entries table<any> Table array that holds the values.
---                                   Delegates most of the implementation to it.
local Array = {}

-----------------------------------------------------------------------------
---Metamethod __index controls bracket (a[key]) access to internals.
---
---For numeric keys it will treat and indexed access, all other will fallback to methods.
---
---Ex: a[1] will return the element at index 1 in the array.
---
---Ex2: a["clear"] is the same as using a.clear, which is a function reference.
---
---@param self Array
---@param key any Index or field name.
---@return any Value at index or fallback field.
-----------------------------------------------------------------------------
function Array.__index(self, key)
	if type(key) == "number" then
		return self._entries[key]
	end
	return rawget(Array, key)
end

-----------------------------------------------------------------------------
---Checks if it is (probably) an array, considers an empty table an array.
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
---@param iterable table<any>? Entries to be copied and initialize it.
---                            Defaults to an empty array if `nil`.
---
---@return Array
-----------------------------------------------------------------------------
function Array.new(iterable)
	return setmetatable({ _entries = {} }, Array) .. iterable
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
---@param  index number   Index to add the value.
---@param  value any      Value to be added, will ignore it if `nil`.
-----------------------------------------------------------------------------
function Array:put(index, value)
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
---Concatenate a given iterable to this.
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Array
-----------------------------------------------------------------------------
function Array:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "Should be a table")

		for _, item in pairs(iterable) do
			self:insert(item)
		end
	end

	return self
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
---String representation of this array
---
---@return string
-----------------------------------------------------------------------------
function Array:__tostring()
	return string.format("[ %s ]", table.concat(self._entries, ", "))
end

return Array
