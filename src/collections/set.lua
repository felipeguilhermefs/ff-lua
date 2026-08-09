------------------------------
-- Cache function references
------------------------------

-- String
local sfmt = string.format

-- Table
local tconcat = table.concat
local tinsert = table.insert

-- General
local assert = assert
local getmetatable = getmetatable
local next = next
local pairs = pairs
local select = select
local setmetatable = setmetatable
local tostring = tostring
local type = type

--------------------------------------------------------------------------------------
---@class Set
---@field private _entries table<any, boolean> Table that holds the entries.
---                                        Delegates most of the implementation to it.
---@field private _len     number          Number of entries in the set.
--------------------------------------------------------------------------------------
local Set = {}
Set.__index = Set

-----------------------------------------------------------------------------
---Checks if it is a Set instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function Set.isSet(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == Set
end

-----------------------------------------------------------------------------
---Creates a new instance of the set.
---
---@param  iterable? table<any, any>|Set Optional table or Set to initialize
---                                      the set from.
---
---@return Set
-----------------------------------------------------------------------------
function Set.new(iterable)
	return setmetatable({
		_entries = {},
		_len = 0,
	}, Set) .. iterable
end

-----------------------------------------------------------------------------
---Adds an entry to the set.
---
---@param  entry any Entry to be added.
---
---@return boolean   `true` if entry was added, `false` if already present.
-----------------------------------------------------------------------------
function Set:add(entry)
	assert(entry ~= nil, "entry should not be nil")

	if self._entries[entry] ~= nil then
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
---Returns true if all specified entries are present in the set.
---
---@param  ... any Entries to check for existence in the set.
---
---@return boolean
-----------------------------------------------------------------------------
function Set:contains(...)
	local count = select("#", ...)
	if count == 0 then
		return false
	end

	for i = 1, count do
		local item = select(i, ...)
		if item == nil or self._entries[item] == nil then
			return false
		end
	end
	return true
end

-----------------------------------------------------------------------------
---Returns a set containing the difference between this set and the given (this \ other).
---
---@param  other Set Set to differ from this.
---
---@return Set       A new Set with elements in this set but not in other.
-----------------------------------------------------------------------------
function Set:diff(other)
	assert(Set.isSet(other), "other should also be a Set")

	local res = Set.new()

	for entry in pairs(self) do
		if other._entries[entry] == nil then
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
	return self._len == 0
end

-----------------------------------------------------------------------------
---Returns a set containing the intersection between this set and the given.
---
---@param  other Set Set to intersect with this.
---
---@return Set  A new Set with elements present in both sets.
-----------------------------------------------------------------------------
function Set:intersection(other)
	assert(Set.isSet(other), "other should also be a Set")

	local res = Set.new()

	local source = self._len <= other._len and self or other
	local target = source == self and other or self

	for entry in pairs(source) do
		if target._entries[entry] ~= nil then
			res:add(entry)
		end
	end

	return res
end

-----------------------------------------------------------------------------
---Checks if this set has no elements in common with another set.
---
---@param  other Set Set to check against.
---
---@return boolean   `true` if intersection is empty.
-----------------------------------------------------------------------------
function Set:disjoint(other)
	assert(Set.isSet(other), "other should also be a Set")

	local source = self._len <= other._len and self or other
	local target = source == self and other or self

	for entry in pairs(source) do
		if target._entries[entry] ~= nil then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Checks if this set is a subset of another set.
---
---@param  other Set Set to check against.
---
---@return boolean  `true` if all elements of this set are in `other`.
-----------------------------------------------------------------------------
function Set:subset(other)
	assert(Set.isSet(other), "other should also be a Set")

	if self._len > other._len then
		return false
	end

	for entry in pairs(self) do
		if other._entries[entry] == nil then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Checks if this set is a superset of another set.
---
---@param  other Set Set to check against.
---
---@return boolean   `true` if this set contains all elements of `other`.
-----------------------------------------------------------------------------
function Set:superset(other)
	assert(Set.isSet(other), "other should also be a Set")

	return other:subset(self)
end

-----------------------------------------------------------------------------
---Removes a given value and returns true if it was contained by the set.
---
---@param  entry any Entry to remove from the set.
---
---@return boolean   `true` if entry was removed, `false` otherwise.
-----------------------------------------------------------------------------
function Set:remove(entry)
	assert(entry ~= nil, "entry should not be nil")
	if self._entries[entry] == nil then
		return false
	end

	self._entries[entry] = nil
	self._len = self._len - 1
	return true
end

-----------------------------------------------------------------------------
---Returns a new set containing elements present in either set, but not in both.
---
---@param  other Set Set to compute symmetric difference with.
---
---@return Set       A new Set with symmetric difference.
-----------------------------------------------------------------------------
function Set:symdiff(other)
	assert(Set.isSet(other), "other should also be a Set")

	local res = Set.new()

	for entry in pairs(self._entries) do
		if other._entries[entry] == nil then
			res:add(entry)
		end
	end

	for entry in pairs(other._entries) do
		if self._entries[entry] == nil then
			res:add(entry)
		end
	end

	return res
end

-----------------------------------------------------------------------------
---Returns a set containing the union between this set and the given.
---
---@param  other Set Set or table to unite with this.
---
---@return Set   A new Set with elements from both sets.
-----------------------------------------------------------------------------
function Set:union(other)
	assert(Set.isSet(other), "other shoudl also be a Set")
	return Set.new(self) .. other
end

-----------------------------------------------------------------------------
---Concatenate a given iterable into this Set (in-place modification).
---
---@param  iterable? table<any, any>|Set Any table or Set that can be iterated over.
---                                      Defaults to an empty table if `nil`.
---
---@return Set                           Returns this Set instance.
-----------------------------------------------------------------------------
function Set:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, item in pairs(iterable) do
			self:add(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when both are Sets with the same size
---and containing the same elements.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function Set:__eq(other)
	if not Set.isSet(other) then
		return false
	end

	if self._len ~= #other then
		return false
	end

	for entry in pairs(self) do
		if other._entries[entry] == nil then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Returns the number of entries in the set.
---
---@return number
-----------------------------------------------------------------------------
function Set:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Prevents the Set class to be modified
-----------------------------------------------------------------------------
function Set:__newindex()
	error("'Set' class should not be modified")
end

-----------------------------------------------------------------------------
---Iterates through the set in an undefined order.
---
---@return fun(t: table, k: any): any, boolean, table, nil
-----------------------------------------------------------------------------
function Set:__pairs()
	return function(_, index)
		return next(self._entries, index)
	end, self, nil
end

-----------------------------------------------------------------------------
---String representation of this set.
---
---@return string
-----------------------------------------------------------------------------
function Set:__tostring()
	local entries = {}
	for item in pairs(self._entries) do
		tinsert(entries, tostring(item))
	end
	return sfmt("{ %s }", tconcat(entries, ", "))
end

return Set
