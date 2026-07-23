-- cache function references
local sfmt = string.format
local tremove = table.remove
local tinsert = table.insert
local tconcat = table.concat

---@class Array
---@field private _entries table<any> Table array that holds the values.
---                                   Delegates most of the implementation to it.
local Array = {}

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
---
---@param  index number   Index to insert the value in. Should in in range (1 .. #array +1)
---@param  value any      Value to be inserted.
-----------------------------------------------------------------------------
function Array:insert(index, value)
	assert(type(index) == "number", "index should be a number")
	-- check for boundaries, but allow strictly over higher boundary
	assert(index > 0 and index <= #self + 1, "index out of bounds")
	assert(value ~= nil, "value should not be nil")

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
			res[#res + 1] = self._entries[i]
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
			self[#self + 1] = item
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
		if self._entries[i] ~= other[i] then
			return false
		end
	end
	return true
end

-----------------------------------------------------------------------------
---Metamethod __index controls bracket (a[key]) read access to internals.
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
function Array:__index(key)
	if type(key) == "number" then
		return self._entries[key]
	end
	return rawget(Array, key)
end

-----------------------------------------------------------------------------
---Iterates through the array sequentially from index 1 to #Array for ipairs.
---
---@return function Generator function yielding (index, value) pairs in order.
-----------------------------------------------------------------------------
function Array:__ipairs()
	local i = 0
	return function()
		i = i + 1
		if i <= #self._entries then
			return i, self._entries[i]
		end
	end
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
---Metamethod __newindex controls bracket (a[key]) write access to internals.
---
---@param self Array
---@param index number Index or field name.
---@param value number Value to assign.
-----------------------------------------------------------------------------
function Array:__newindex(index, value)
	assert(value ~= nil, "value should not be nil")
	assert(type(index) == "number", "index should be a number")
	-- check for boundaries, but allow strictly over higher boundary
	assert(index >= 1 and (index <= #self._entries + 1), "index out of bounds")

	self._entries[index] = value
end

-----------------------------------------------------------------------------
---Iterates through the array sequentially from index 1 to #Array.
---
---@return function Generator function yielding (index, value) pairs in order.
-----------------------------------------------------------------------------
function Array:__pairs()
	return self:__ipairs()
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
