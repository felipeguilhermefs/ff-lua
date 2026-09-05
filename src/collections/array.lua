------------------------------
-- Cache function references
------------------------------

-- String
local sfmt = string.format

-- Table
local tconcat = table.concat
local tinsert = table.insert
local tremove = table.remove

-- General
local assert = assert
local error = error
local getmetatable = getmetatable
local next = next
local pairs = pairs
local setmetatable = setmetatable
local type = type

----------------------------------------------------------------------------------
---@class Array
---@field private _entries table<any> Table array that holds the values.
---                                   Delegates most of the implementation to it.
----------------------------------------------------------------------------------
local Array = {}
Array.__index = Array

-----------------------------------------------------------------------------
---Checks if it is (probably) an array, considers an empty table an array.
---
---@param maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function Array.isArray(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	if getmetatable(maybe) == Array then
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
---Returns the value at a given index.
---
---@param  index number Index to get the value from. Should be in range (1 .. #array)
---
---@return any
-----------------------------------------------------------------------------
function Array:get(index)
	assert(type(index) == "number", "index should be a number")
	assert(index > 0 and index <= #self, "index out of bounds")

	return self._entries[index]
end

-----------------------------------------------------------------------------
---Returns the index of the first entry with a given value.
---Iterates sequentially (1..#Array) to guarantee returning the first match.
---It will return `nil` if nothing is found.
---
---@param  value any
---
---@return number|nil
-----------------------------------------------------------------------------
function Array:indexOf(value)
	assert(value ~= nil, "value should not be nil")

	for i = 1, #self._entries do
		if self._entries[i] == value then
			return i
		end
	end
end

-----------------------------------------------------------------------------
---Inserts a value in a given index, following values will be shifted forward.
---If no index is given, it inserts at the end of the array.
---
---@param  value  any     Value to be inserted.
---@param  index? number  Index to insert the value in. Should be in range (1 .. #array + 1)
-----------------------------------------------------------------------------
function Array:insert(value, index)
	assert(value ~= nil, "value should not be nil")

	if index == nil then
		tinsert(self._entries, value)
		return
	end

	assert(type(index) == "number", "index should be a number")
	-- check for boundaries, but allow strictly over higher boundary
	assert(index > 0 and index <= #self + 1, "index out of bounds")

	tinsert(self._entries, index, value)
end

-----------------------------------------------------------------------------
---Removes a value at a given index.
---
---@param  index number
---
---@return any
-----------------------------------------------------------------------------
function Array:remove(index)
	assert(type(index) == "number", "index should be a number")
	assert(index > 0 and index <= #self, "index out of bounds")

	return tremove(self._entries, index)
end

-----------------------------------------------------------------------------
---Returns a new Array containing a slice of elements from start to finish.
---
---@param  start?  number Default is 1.
---@param  finish? number Default is #Array.
---
---@return Array
-----------------------------------------------------------------------------
function Array:slice(start, finish)
	start = start or 1
	assert(type(start) == "number", "start index should be a number")
	assert(start > 0 and start <= #self, "start index out of bounds")

	finish = finish or #self._entries
	assert(type(finish) == "number", "finish index should be a number")
	assert(finish > 0 and finish <= #self, "finish index out of bounds")

	assert(start <= finish, "start index must be lesser or equal to finish index")

	local res = Array.new()
	for i = start, finish do
		if self._entries[i] ~= nil then
			res:insert(self._entries[i])
		end
	end
	return res
end

-----------------------------------------------------------------------------
---Swap values at given indexes. Validates that both indices are within bounds
---(1..#Array) to prevent creating holes or corrupting array length.
---
---@param  index number
---@param  other number
-----------------------------------------------------------------------------
function Array:swap(index, other)
	assert(type(index) == "number", "index should be a number")
	assert(index > 0 and index <= #self, "index out of bounds")

	assert(type(other) == "number", "other index should be a number")
	assert(other > 0 and other <= #self, "other index out of bounds")

	self._entries[index], self._entries[other] = self._entries[other], self._entries[index]
end

-----------------------------------------------------------------------------
---Concatenate a given iterable to this array (in-place modification).
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Array
-----------------------------------------------------------------------------
function Array:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, item in pairs(iterable) do
			self:insert(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Deep equality check comparing elements of two Arrays or array-like tables.
---
---@param other any
---
---@return boolean
-----------------------------------------------------------------------------
function Array:__eq(other)
	if not Array.isArray(other) then
		return false
	end

	if #self ~= #other then
		return false
	end

	for i = 1, #self._entries do
		local otherVal = other._entries and other._entries[i] or other[i]
		if self._entries[i] ~= otherVal then
			return false
		end
	end
	return true
end

-----------------------------------------------------------------------------
---Returns the number of entries in the array.
---
---@return number
-----------------------------------------------------------------------------
function Array:__len()
	return #self._entries
end

-----------------------------------------------------------------------------
---Metamethod __newindex prevents adding new properties, methods, or functions.
---
---@param key   any Property name or index.
---@param value any Value to assign.
-----------------------------------------------------------------------------
function Array:__newindex(key, value)
	error("cannot add new properties, methods or functions")
end

-----------------------------------------------------------------------------
---Iterates through the array sequentially from index 1 to #Array.
---
---@return function Generator function yielding (index, value) pairs in order.
-----------------------------------------------------------------------------
function Array:__pairs()
	local i = 0
	return function()
		i = i + 1
		if i <= #self._entries then
			return i, self._entries[i]
		end
	end
end

-----------------------------------------------------------------------------
---String representation of this array.
---
---@return string
-----------------------------------------------------------------------------
function Array:__tostring()
	return sfmt("[ %s ]", tconcat(self._entries, ", "))
end

return Array
