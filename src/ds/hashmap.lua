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

function HashMap.new()
	local new = {}
	setmetatable(new, HashMap)
	new.__items = {}
	return new
end

return HashMap
