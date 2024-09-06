local Array = require("ff.collections.array")

---@class Set
---
---@field private _entries table<any, boolean> Table that holds the entries.
---@field private _len     number              Number of entries in the set.
local Set = {}
Set.__index = Set

-----------------------------------------------------------------------------
---Creates a new instance of the set.
---
---@param array  table<any>? Array to initialize the set. Ignored if `nil`.
---
---@return Set
-----------------------------------------------------------------------------
function Set.new(array)
	local new = setmetatable({ _entries = {}, _len = 0 }, Set)

	if array then
		assert(Array.isTableArray(array), "Should be an array")

		for _, value in ipairs(array) do
			new:add(value)
		end
	end

	return new
end

-----------------------------------------------------------------------------
---Adds an entry to the set.
---
---@param  entry any
-----------------------------------------------------------------------------
function Set:add(entry)
	if entry == nil or self._entries[entry] then
		return false
	end

	self._entries[entry] = true
	self._len = self._len + 1
	return true
end

-----------------------------------------------------------------------------
---Empties the set.
-----------------------------------------------------------------------------
function Set:clear()
	self._entries = {}
	self._len = 0
end

-----------------------------------------------------------------------------
---Returns true if entry is in the set.
---
---@param  entry any
---
---@return boolean
-----------------------------------------------------------------------------
function Set:contains(entry)
	return self._entries[entry] ~= nil
end

-----------------------------------------------------------------------------
---Returns a set containing the difference between this set and the given.
---
---@param  other Set?  Set to differ from this, `nil` is treated as empty.
---
---@return Set
-----------------------------------------------------------------------------
function Set:diff(other)
	local res = Set.new()
	for entry, _ in pairs(self._entries) do
		if other == nil or not other:contains(entry) then
			res:add(entry)
		end
	end
	return res
end

-----------------------------------------------------------------------------
---Returns whether the set is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Set:empty()
	return #self == 0
end

-----------------------------------------------------------------------------
---Returns a set containing the intersection between this set and the given.
---
---@param  other Set?  Set to intersect with this, `nil` is treated as empty.
---
---@return Set
-----------------------------------------------------------------------------
function Set:intersection(other)
	local res = Set.new()
	if other == nil then
		return res
	end

	for entry, _ in pairs(self._entries) do
		if other:contains(entry) then
			res:add(entry)
		end
	end

	return res
end

-----------------------------------------------------------------------------
---Removes a given value and returns if it was contained by the set before.
---
---@param  entry any
---
---@return boolean
-----------------------------------------------------------------------------
function Set:remove(entry)
	if self._entries[entry] then
		self._entries[entry] = nil
		self._len = self._len - 1
		return true
	end
	return false
end

-----------------------------------------------------------------------------
---Returns a set containing the union between this set and the given.
---
---@param  other Set?  Set to unite with this, `nil` is treated as empty.
---
---@return Set
-----------------------------------------------------------------------------
function Set:union(other)
	local res = Set.new()

	for entry, _ in pairs(self._entries) do
		res:add(entry)
	end

	if other then
		for entry, _ in pairs(other._entries) do
			res:add(entry)
		end
	end
	return res
end

-----------------------------------------------------------------------------
---Returns the number of entries in the set.
---
---@return number
---@private
-----------------------------------------------------------------------------
function Set:__len()
	return self._len
end

return Set
