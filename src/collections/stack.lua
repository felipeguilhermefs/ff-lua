-- Stack:
--	.new() - Creates a new instance of a stack
--	:push(item) - Adds an item to the top of the stack
--		item: any item
--	:pop() - Removes and returns the item in the top of the stack
--		Returns nil if empty.
--	:top() - Returns the item in the top of the stack
--		Returns nil if empty.
--	:empty() - Returns if the stack is empty or not
--

local Stack = { __items = nil }
Stack.__index = Stack

function Stack:push(item)
	table.insert(self.__items, item)
end

function Stack:pop()
	if not self:empty() then
		return table.remove(self.__items, #self.__items)
	end
end

function Stack:top()
	if not self:empty() then
		return self.__items[#self.__items]
	end
end

function Stack:empty()
	return #self.__items == 0
end

function Stack.new()
	local new = {}
	setmetatable(new, Stack)
	new.__items = {}
	return new
end

return Stack
