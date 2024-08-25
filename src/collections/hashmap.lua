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
---Returns the number of entries in the map.
---
---@return number
-----------------------------------------------------------------------------
function HashMap:len()
	return self._len
end

-----------------------------------------------------------------------------
---Returns whether the map is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function HashMap:empty()
	return self:len() == 0
end

-----------------------------------------------------------------------------
---Empties the map
-----------------------------------------------------------------------------
function HashMap:clear()
	self._entries = {}
	self._len = 0
end

-----------------------------------------------------------------------------
---Adds a value to the map associated by a lookup key.
---
---@param  key    any Key that will be used for lookup the value, `nil` will be ignored.
---@param  value  any Value to be stored, `nil` will be ignored.
-----------------------------------------------------------------------------
function HashMap:put(key, value)
	if key == nil or value == nil then
		return
	end

	self._entries[key] = value
	self._len = self._len + 1
end

-----------------------------------------------------------------------------
---Returns the value that is associated with the key.
---
---@param  key      any  Key used for lookup the value.
---@param  default? any?  Value to be returned if an entry is not found.
---
---@return any?      Value associated with key, or default if notthing is found
-----------------------------------------------------------------------------
function HashMap:get(key, default)
	return self._entries[key] or default
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

--		fn: (key) -> any
--
-----------------------------------------------------------------------------
---Returns the value that is associated with the key. Computes and stores the value if it was not present already.
---
---@param  key  any                Key used for lookup the value.
---@param  fun  fun(key: any): any Function used to compute/generate the value.
---
---@return any                     Value associated with key, or computed by the fn.
-----------------------------------------------------------------------------
function HashMap:compute(key, fun)
	local value = self:get(key)
	if value == nil then
		value = fun(key)
		self:put(key, value)
	end
	return value
end

return HashMap
