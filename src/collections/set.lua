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
---@param iterable?  table<any> Iterable to initialize the set.
---                             Ignored if `nil`.
---
---@return Set
-----------------------------------------------------------------------------
function Set.new(iterable)
	return setmetatable({ _entries = {}, _len = 0 }, Set) .. iterable
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

	self._entries[entry] = entry
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
---Returns true if all entries are in the set.
---
---@param  ... ...any
---
---@return boolean
-----------------------------------------------------------------------------
function Set:contains(...)
	local items = { ... }
	if #items == 0 then
		return false
	end

	for _, item in pairs(items) do
		if not self._entries[item] then
			return false
		end
	end
	return true
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
	for entry, _ in pairs(self) do
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

	for entry, _ in pairs(self) do
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
	return Set.new(self) .. other
end

-----------------------------------------------------------------------------
---Concatenate a given iterable to this.
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Set
-----------------------------------------------------------------------------
function Set:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "Should be a table")

		for _, item in pairs(iterable) do
			self:add(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Iterates through the set in a undefined order.
---
---@return Iterator<any, boolean>, Set<any>, nil
-----------------------------------------------------------------------------
function Set:__pairs()
	return function(_, index)
		return next(self._entries, index)
	end, self, nil
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
