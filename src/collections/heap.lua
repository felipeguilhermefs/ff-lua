-- Heap:
--	.new(comparator) - Creates a new instance of heap
--		comparator: (a,b) -> boolean. Default: MinComparator
--			Comparator should return true if "a" should appear before "b"
--	:heapify(array) - Swap heap items by the provided array and mutates it into a heap structure.
--		array: Table array. Default: {}
--	:push(item) - Adds an item to the heap
--		item: Any non nil item
--	:pop() - Removes and returns the first item of the heap.
--		Returns nil if empty.
--	:peek() - Returns the first item of the heap.
--		Returns nil if empty.
--	:size() - Returns the number of items in the heap.
--	:empty() - Returns if the heap is empty or not
--

local Heap = { __items = nil, __comparator = nil }
Heap.__index = Heap

local function MinComparator(a, b)
	return a < b
end

function Heap:size()
	return #self.__items
end

function Heap:empty()
	return self:size() == 0
end

function Heap:push(item)
	if item then
		table.insert(self.__items, item)
		self:__siftUp(self:size())
	end
end

function Heap:pop()
	if self:empty() then
		return nil
	end

	if self:size() == 1 then
		return table.remove(self.__items, 1)
	end

	local root = self.__items[1]
	self.__items[1] = table.remove(self.__items, self:size())
	self:__siftDown(1)
	return root
end

function Heap:peek()
	if self:empty() then
		return nil
	end
	return self.__items[1]
end

function Heap:heapify(items)
	self.__items = items or {}
	for i = self:size(), 1, -1 do
		self:__siftDown(i)
	end
end

function Heap:__siftUp(index)
	local parent = index // 2
	while index > 1 and self:__before(index, parent) do
		self:__swap(index, parent)
		index = parent
		parent = index // 2
	end
end

function Heap:__siftDown(index)
	local child = index * 2
	while child <= self:size() do
		if child + 1 <= self:size() and self:__before(child + 1, child) then
			child = child + 1
		end

		if self:__before(index, child) then
			break
		end

		self:__swap(child, index)
		index = child
		child = index * 2
	end
end

function Heap:__before(i, j)
	return self.__comparator(self.__items[i], self.__items[j])
end

function Heap:__swap(i, j)
	local temp = self.__items[i]
	self.__items[i] = self.__items[j]
	self.__items[j] = temp
end

function Heap.new(comparator)
	local new = {}
	setmetatable(new, Heap)

	new.__comparator = comparator or MinComparator
	new.__items = {}

	return new
end

return Heap
