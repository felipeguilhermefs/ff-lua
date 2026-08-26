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
local next = next
local pairs = pairs
local rawget = rawget
local setmetatable = setmetatable
local type = type

--------------------------------------------------------------------------------------
---@class HashMap
---@field private _entries table<any, any> Table that holds the values.
---                                        Delegates most of the implementation to it.
---@field private _len     number          Number of entries in the map.
--------------------------------------------------------------------------------------
local HashMap = {}

-----------------------------------------------------------------------------
---Creates a new instance of the hash map.
---
---@param  iterable? table<any, any> Optional table to initialise the map from.
---                                  Keys and values are shallow-copied.
---
---@return HashMap
-----------------------------------------------------------------------------
function HashMap.new(iterable)
	return setmetatable({
		_entries = {},
		_len = 0,
	}, HashMap) .. iterable
end

-----------------------------------------------------------------------------
---Empties the map.
-----------------------------------------------------------------------------
function HashMap:clear()
	self._entries = {}
	self._len = 0
end

-----------------------------------------------------------------------------
---Returns the value associated with the key. Computes and stores the value
---if it was not present already.
---
---@param  key any                Key used to look up the value.
---@param  fn fun(key: any): any Function used to compute a missing value.
---
---@return any                    Value associated with key, or newly computed.
-----------------------------------------------------------------------------
function HashMap:compute(key, fn)
	assert(key ~= nil, "key should not be nil")
	assert(type(fn) == "function", "fn should be a function")

	local value = self._entries[key]
	if value == nil then
		value = fn(key)
		self[key] = value
	end
	return value
end

-----------------------------------------------------------------------------
---Checks if there is a value associated with the key.
---
---@param  key any Key used to look up the value.
---
---@return boolean
-----------------------------------------------------------------------------
function HashMap:contains(key)
	assert(key ~= nil, "key should not be nil")
	return self._entries[key] ~= nil
end

-----------------------------------------------------------------------------
---Returns whether the map is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function HashMap:empty()
	return self._len == 0
end

-----------------------------------------------------------------------------
---Merge an iterable into this HashMap. When keys conflict a merge function
---is called to resolve the new value.
---
---@param  other table<any, any> Other table to merge into this.
---@param  fn    fun(a: any, b: any): any?
---                                Merge function called on conflict.
---                                Receives (existing, incoming); its return
---                                value becomes the new stored value.
---                                Defaults to an override function
---                                (returns `incoming`).
---
---@return HashMap                 Returns this HashMap after the merge.
-----------------------------------------------------------------------------
function HashMap:merge(other, fn)
	assert(type(other) == "table", "other should be a table")
	assert(fn == nil or type(fn) == "function", "fn should be a function")

	fn = fn or function(_, b)
		return b
	end

	for k, v in pairs(other) do
		local thisValue = self[k]
		if thisValue == nil then
			self[k] = v
		else
			local resolved = fn(thisValue, v)
			self[k] = resolved
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Removes the entry associated with the key.
---
---@param  key any Key to be removed.
---
---@return any?    Previous value associated with key, or `nil` if not found.
-----------------------------------------------------------------------------
function HashMap:remove(key)
	assert(key ~= nil, "key should not be nil")

	local value = self[key]
	if value ~= nil then
		self._entries[key] = nil
		self._len = self._len - 1
	end

	return value
end

-----------------------------------------------------------------------------
---Concatenate a given iterable into this HashMap (in-place modification).
---
---@param iterable? table<any, any> Entries to concatenate.
---                                 Defaults to an empty list if `nil`.
---
---@return HashMap Returns this map instance.
-----------------------------------------------------------------------------
function HashMap:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for key, value in pairs(iterable) do
			self[key] = value
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when they contain the same set of
---key-value pairs (shallow value comparison).
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function HashMap:__eq(other)
	if other == nil then
		return false
	end

	if type(other) ~= "table" then
		return false
	end

	if self._len ~= #other then
		return false
	end

	for k, v in pairs(self._entries) do
		if other[k] ~= v then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Metamethod __index controls bracket (a[key]) read access to internals.
---
---@param key any Index or field name, should not be nil.
---
---@return any Value at index or fallback field.
-----------------------------------------------------------------------------
function HashMap:__index(key)
	assert(key ~= nil, "key should not be nil")

	local val = self._entries[key]
	if val ~= nil then
		return val
	end

	return rawget(HashMap, key)
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---Returns the number of entries in the map.
---
---@return number
-----------------------------------------------------------------------------
function HashMap:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Metamethod __newindex controls bracket (a[key]) write access to internals.
---
---@param self  HashMap
---@param key   any Key used for lookup, should not be nil.
---@param value any Value to be stored, should not be nil.
-----------------------------------------------------------------------------
function HashMap:__newindex(key, value)
	assert(key ~= nil, "index should not be nil")
	assert(value ~= nil, "value should not be nil")

	if self._entries[key] == nil then
		self._len = self._len + 1
	end
	self._entries[key] = value
end

-----------------------------------------------------------------------------
---Iterates through the map in an undefined order.
---
---@return fun(t: table, k: any): any, any, table, nil
-----------------------------------------------------------------------------
function HashMap:__pairs()
	return function(_, index)
		return next(self._entries, index)
	end, self, nil
end

-----------------------------------------------------------------------------
---String representation of this HashMap.
---
---@return string
-----------------------------------------------------------------------------
function HashMap:__tostring()
	local sb = {}
	for k, v in pairs(self) do
		tinsert(sb, sfmt("%s = %s", k, v))
	end
	return sfmt("{ %s }", tconcat(sb, ", "))
end

return HashMap
