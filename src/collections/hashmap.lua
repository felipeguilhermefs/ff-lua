---@class HashMap
---@field private _entries   table<any, any> Table that holds the values.
---                                          Delegates most of the implementation to it.
---@field private _len     number            Number of entries in the map.
local HashMap = {}
HashMap.__index = HashMap

-----------------------------------------------------------------------------
---Creates a new instance of the hash map.
---
---@return HashMap
-----------------------------------------------------------------------------
function HashMap.new()
	return setmetatable({
		_entries = {},
		_len = 0,
	}, HashMap)
end

-----------------------------------------------------------------------------
---Empties the map
-----------------------------------------------------------------------------
function HashMap:clear()
	self._entries = {}
	self._len = 0
end

-----------------------------------------------------------------------------
---Returns the value that is associated with the key. Computes and stores
---the value if it was not present already.
---
---@param  key  any                Key used for lookup the value.
---@param  fun  fun(key: any): any Function used to compute the value.
---
---@return any                     Value associated with key, or computed.
-----------------------------------------------------------------------------
function HashMap:compute(key, fun)
	local value = self:get(key)
	if value == nil then
		value = fun(key)
		self:put(key, value)
	end
	return value
end

-----------------------------------------------------------------------------
---Checks if there is a value associated with the key.
---
---@param  key     any  Key used for lookup the value.
---
---@return boolean
-----------------------------------------------------------------------------
function HashMap:contains(key)
	return self._entries[key] ~= nil
end

-----------------------------------------------------------------------------
---Returns whether the map is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function HashMap:empty()
	return #self == 0
end

-----------------------------------------------------------------------------
---Returns the value that is associated with the key.
---
---@param  key      any   Key used for lookup the value.
---@param  default  any?  Value to be returned if an entry is not found.
---
---@return any?           Value associated with key, or default if nothing
---                       is found.
-----------------------------------------------------------------------------
function HashMap:get(key, default)
	return self._entries[key] or default
end

-----------------------------------------------------------------------------
---Merge an iterable into this HashMap, if keys conflict, then merge use
---a merge function to compute a value.
---
---@param  other table<any, any>?  Other table to merge into this.
---                                If nil this is ignored.
---@param  fn    fun(any, any)?    Merge function to be called when in conflict.
---                                Defaults to an override function.
---
---@return HashMap                 Returns this HashMap after the merge
-----------------------------------------------------------------------------
function HashMap:merge(other, fn)
	if other == nil then
		return self
	end

	-- We iterate over key and values of this "other"
	assert(type(other) == "table", "Should be a table")

	-- If no merge function is given, we default to "override"
	fn = fn or function(_, b)
		return b
	end

	for k, v in pairs(other) do
		local value = self:get(k)
		-- Just need to call the merge function if there is a conflict
		if value then
			value = fn(value, v)
		else
			value = v
		end
		self:put(k, value)
	end

	return self
end

-----------------------------------------------------------------------------
---Adds a value to the map associated by a lookup key.
---
---@param  key    any Key used for lookup the value, `nil` will be ignored.
---@param  value  any Value to be stored, `nil` will be ignored.
-----------------------------------------------------------------------------
function HashMap:put(key, value)
	if key == nil or value == nil then
		return
	end

	if self._entries[key] == nil then
		self._len = self._len + 1
	end
	self._entries[key] = value
end

-----------------------------------------------------------------------------
---Removes a value associated with the key.
---
---@param  key any Key used for lookup the value.
-----------------------------------------------------------------------------
function HashMap:remove(key)
	if self._entries[key] == nil then
		return
	end

	self._entries[key] = nil
	self._len = self._len - 1
end

-----------------------------------------------------------------------------
---Concatenate a given iterable to this.
---
---@param iterable HashMap Entries to be concatenated.
---			   Defaults to an empty list if `nil`.
---
---@return HashMap
-----------------------------------------------------------------------------
function HashMap:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "Should be a table")
		for key, value in pairs(iterable) do
			self:put(key, value)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Returns the number of entries in the map.
---
---@return number
---@private
-----------------------------------------------------------------------------
function HashMap:__len()
	return self._len
end

-----------------------------------------------------------------------------
---Iterates through the map in a undefined order.
---
---@return Iterator<any, any>, HashMap<any, any>, nil
-----------------------------------------------------------------------------
function HashMap:__pairs()
	return function(_, index)
		return next(self._entries, index)
	end, self, nil
end

-----------------------------------------------------------------------------
---String representation of this hashmap
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
