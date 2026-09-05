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
local error  = error
local next   = next
local pairs  = pairs
local rawget = rawget
local setmetatable = setmetatable
local tostring     = tostring
local type   = type

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
		self:put(key, value)
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
---Returns the value associated with the key.
---
---@param  key any Key used to look up the value, should not be nil.
---
---@return any?   Value stored under key, or nil when absent.
-----------------------------------------------------------------------------
function HashMap:get(key)
	assert(key ~= nil, "key should not be nil")
	return self._entries[key]
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
		local thisValue = self:get(k)
		if thisValue == nil then
			self:put(k, v)
		else
			local resolved = fn(thisValue, v)
			self:put(k, resolved)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Stores a value under the given key. Increments the entry count when key
---is new.
---
---@param key   any Key to store under, should not be nil.
---@param value any Value to store, should not be nil.
-----------------------------------------------------------------------------
function HashMap:put(key, value)
	assert(key   ~= nil, "key should not be nil")
	assert(value ~= nil, "value should not be nil")

	if self._entries[key] == nil then
		self._len = self._len + 1
	end
	self._entries[key] = value
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

	local value = self:get(key)
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
			self:put(key, value)
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

	local otherEntries = rawget(other, "_entries") or other
	for k, v in pairs(self._entries) do
		if otherEntries[k] ~= v then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Metamethod __index: resolves methods via the HashMap class table.
-----------------------------------------------------------------------------
HashMap.__index = HashMap

-----------------------------------------------------------------------------
---Returns the number of entries in the map.
---
---@return number
-----------------------------------------------------------------------------
function HashMap:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Metamethod __newindex prevents new fields or methods from being added to
---a HashMap instance at runtime.
---
---@param key   any Attempted field name.
---@param value any Attempted value.
-----------------------------------------------------------------------------
function HashMap:__newindex(key, value)
	error(
		sfmt(
			"attempt to add new field '%s' (value: %s) to HashMap instance",
			tostring(key),
			tostring(value)
		),
		2
	)
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
