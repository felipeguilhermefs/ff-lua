local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")

---@class Heap
---@field private _comparator fun(a: any, b: any): -1|0|1 Defaults to a "Natural Order".
---@field private _entries    Array                       Array holding the entries.
local Heap = {}
Heap.__index = Heap

-----------------------------------------------------------------------------
---Creates a new instance of the heap.
---
---@param comparator fun(a: any, b: any): -1|0|1 Defaults to "Natural Order".
---
---@return Heap
-----------------------------------------------------------------------------
function Heap.new(comparator)
	return setmetatable({
		_comparator = comparator or Comparator.natural,
		_entries = Array.new(),
	}, Heap)
end

-----------------------------------------------------------------------------
---Creates a new instance of a MIN Heap. (Minimum item is at the root)
---
---@return Heap
-----------------------------------------------------------------------------
function Heap.newMin()
	return Heap.new(Comparator.natural)
end

-----------------------------------------------------------------------------
---Creates a new instance of a MAX Heap. (Maximum item is at the root)
---
---@return Heap
-----------------------------------------------------------------------------
function Heap.newMax()
	return Heap.new(Comparator.reverse(Comparator.natural))
end

-----------------------------------------------------------------------------
---Returns whether the heap is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Heap:empty()
	return #self == 0
end

-----------------------------------------------------------------------------
---Swap heap entries by the provided array and mutates it into a heap structure.
---
---@param array table<any>|Array
-----------------------------------------------------------------------------
function Heap:heapify(array)
	self._entries = Array.new(array)
	for i = #self, 1, -1 do
		self:_siftDown(i)
	end
end

-----------------------------------------------------------------------------
---Returns the first entry of the heap, or `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function Heap:peek()
	if not self:empty() then
		return self._entries:get(1)
	end
end

-----------------------------------------------------------------------------
---Removes and returns the first entry of the heap, or `nil` if empty.
---
---@return any?
-----------------------------------------------------------------------------
function Heap:pop()
	if self:empty() then
		return nil
	end

	if #self == 1 then
		return self._entries:remove(1)
	end

	self._entries:swap(1, #self)
	local res = self._entries:remove(#self)
	self:_siftDown(1)
	return res
end

-----------------------------------------------------------------------------
---Adds a value to the heap, ignores if `nil`.
---
---@param value any?
---
---@return boolean   `true` if value was added to the heap.
-----------------------------------------------------------------------------
function Heap:push(value)
	if value == nil then
		return false
	end

	self._entries:insert(value)
	self:_siftUp(#self)
	return true
end

-----------------------------------------------------------------------------
---Fix the heap structure from index to root. (Bottom up)
---
---@param index number
---
---@private
-----------------------------------------------------------------------------
function Heap:_siftUp(index)
	local parent = index // 2
	while index > 1 and self:_before(index, parent) do
		self._entries:swap(index, parent)
		index = parent
		parent = index // 2
	end
end

-----------------------------------------------------------------------------
---Fix the heap structure from index to leaf. (Top down)
---
---@param index number
---
---@private
-----------------------------------------------------------------------------
function Heap:_siftDown(index)
	local child = index * 2
	while child <= #self do
		if child + 1 <= #self and self:_before(child + 1, child) then
			child = child + 1
		end

		if self:_before(index, child) then
			break
		end

		self._entries:swap(child, index)
		index = child
		child = index * 2
	end
end

-----------------------------------------------------------------------------
---Check if index `i` should come before `j` in the heap structure.
---
---@param i number
---@param j number
---
---@return boolean
---
---@private
-----------------------------------------------------------------------------
function Heap:_before(i, j)
	return self._comparator(self._entries:get(i), self._entries:get(j)) == Comparator.less
end

-----------------------------------------------------------------------------
---Pushes all items in a given iterable.
---
---@param iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Heap
-----------------------------------------------------------------------------
function Heap:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "Should be a table")

		for _, item in pairs(iterable) do
			self:push(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Returns the number of entries in the heap.
---
---@return number
---@private
-----------------------------------------------------------------------------
function Heap:__len()
	return #self._entries
end

-----------------------------------------------------------------------------
---Iterates through the heap in order. Same as:
---
---while not heap:empty() do
---   local item = heap:pop()
---end
---
---@return Iterator<1, any>, Heap<any>, nil
-----------------------------------------------------------------------------
function Heap:__pairs()
	return function()
		local item = self:pop()
		if item ~= nil then
			return 1, item
		end
	end, self, nil
end

-----------------------------------------------------------------------------
---String representation of this heap
---
---@return string
-----------------------------------------------------------------------------
function Heap:__tostring()
	return tostring(self._entries)
end

return Heap
