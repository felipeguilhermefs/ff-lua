-- HashMap:
--	.new() - Creates a new instance of a hash map
--	:put(key, value) - Adds the value to the map, indexed by the key
--		key: any hashable non nil key
--		value: any non nil value
--	:get(key, default) - Returns the value associated with a key in the map. Uses default if nothing is found.
--		key: any hashable non nil key
--		default: any value
--	:contains(key) - Checks if there is a value associated with a key in the map.
--		key: any hashable non nil key
--	:remove(key) - Removes the value assioated with the key.
--		key: any hashable non nil key
--	:compute(key, fn) - Returns the value associated with a key, but computes a value and stores it using the provieded fn if nothing is found.
--		key: any hashable non nil key
--		fn: (key) -> any
--	:empty() - Returns if the map is empty or not
--	:clear() - Empties the map
--

local HashMap = { __items = nil }
HashMap.__index = HashMap

function HashMap:empty()
	local next = next -- optimization to use local array of upvalues to lookup next
	return next(self.__items) == nil
end

function HashMap:clear()
	self.__items = {}
end

function HashMap:put(key, value)
	self.__items[key] = value
end

function HashMap:get(key, default)
	return self.__items[key] or default
end

function HashMap:contains(key)
	return self.__items[key] ~= nil
end

function HashMap:remove(key)
	self.__items[key] = nil
end

function HashMap:compute(key, fn)
	local value = self:get(key)
	if value == nil then
		value = fn(key)
		self:put(key, value)
	end
	return value
end

function HashMap.new()
	local new = {}
	setmetatable(new, HashMap)
	new.__items = {}
	return new
end

return HashMap
