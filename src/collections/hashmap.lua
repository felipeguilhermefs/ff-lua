local function assertValidKey(key)
	assert(key ~= nil, "key should not be nil")
	assert(type(key) ~= "number" or key == key, "key should not be NaN")
end

--------------------------------------------------------------------------------------
---@class HashMap
---@field private _entries table<any, any> Table that holds the values.
---                                        Delegates most of the implementation to it.
---@field private _len     number          Number of entries in the map.
--------------------------------------------------------------------------------------
local HashMap = {}
HashMap.__index = HashMap

-----------------------------------------------------------------------------
---Checks if it is a HashMap instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function HashMap.isHashMap(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == HashMap
end

-----------------------------------------------------------------------------
---Creates a new instance of the hash map.
---
---@param  iterable? table<any, any> Optional table to initialise the map from.
---                                  Keys and values are shallow-copied.
---
---@return HashMap
-----------------------------------------------------------------------------
function HashMap.new(iterable)
	local new = setmetatable({ _entries = {}, _len = 0 }, HashMap)
	if iterable ~= nil then
		new:putAll(iterable)
	end
	return new
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
	assertValidKey(key)
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
	assertValidKey(key)
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
	assertValidKey(key)
	return self._entries[key]
end

-----------------------------------------------------------------------------
---Stores a value under the given key.
---
---@param key   any Key to store under, should not be nil.
---@param value any Value to store, should not be nil.
-----------------------------------------------------------------------------
function HashMap:put(key, value)
	assertValidKey(key)
	assert(value ~= nil, "value should not be nil")

	if self._entries[key] == nil then
		self._len = self._len + 1
	end
	self._entries[key] = value
end

-----------------------------------------------------------------------------
---Stores key/values from iterable. When keys conflict, an optional resolver
---computes the value to store.
---
---@param iterable table<any, any> Entries to add.
---@param fn? fun(existing: any, incoming: any): any
---                                  Resolver called only for existing keys.
---                                  Defaults to incoming value.
-----------------------------------------------------------------------------
function HashMap:putAll(iterable, fn)
	assert(type(iterable) == "table", "iterable should be a table")
	assert(fn == nil or type(fn) == "function", "fn should be a function")

	fn = fn or function(_, incoming)
		return incoming
	end

	for k, v in pairs(iterable) do
		local thisValue = self:get(k)
		if thisValue == nil then
			self:put(k, v)
		else
			local resolved = fn(thisValue, v)
			self:put(k, resolved)
		end
	end
end

-----------------------------------------------------------------------------
---Removes the entry associated with the key.
---
---@param  key any Key to be removed.
---
---@return any?    Previous value associated with key, or `nil` if not found.
-----------------------------------------------------------------------------
function HashMap:remove(key)
	assertValidKey(key)

	local value = self:get(key)
	if value ~= nil then
		self._entries[key] = nil
		self._len = self._len - 1
	end

	return value
end

-----------------------------------------------------------------------------
---Returns a new HashMap containing this collection and iterable entries.
---Does not mutate either operand.
---
---@param iterable table<any, any> Entries to add.
---@return HashMap
-----------------------------------------------------------------------------
function HashMap:__concat(iterable)
	local result = HashMap.new(self)
	if iterable == nil then
		return result
	end
	result:putAll(iterable)
	return result
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
	if not HashMap.isHashMap(other) then
		return false
	end

	if self._len ~= other._len then
		return false
	end

	for k, v in pairs(self._entries) do
		if other._entries[k] ~= v then
			return false
		end
	end

	return true
end

-----------------------------------------------------------------------------
---Returns the number of entries in the map.
---
---@return number
-----------------------------------------------------------------------------
function HashMap:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Metamethod __newindex prevents adding new properties, methods, or functions.
---
-----------------------------------------------------------------------------
function HashMap:__newindex()
	error("cannot add new properties, methods or functions to HashMap")
end

-----------------------------------------------------------------------------
---Iterates through the map in an undefined order.
---
---@return fun(state: table, key: any): any?, any?
---@return table
---@return nil
-----------------------------------------------------------------------------
function HashMap:__pairs()
	return next, self._entries, nil
end

-----------------------------------------------------------------------------
---String representation of this HashMap.
---
---@return string
-----------------------------------------------------------------------------
function HashMap:__tostring()
	local sb = {}
	for k, v in pairs(self) do
		table.insert(sb, string.format("%s = %s", k, v))
	end
	return string.format("{ %s }", table.concat(sb, ", "))
end

return HashMap
