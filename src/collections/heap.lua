local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")

------------------------------
-- Cache function references
------------------------------

-- General
local assert = assert
local getmetatable = getmetatable
local pairs = pairs
local setmetatable = setmetatable
local tostring = tostring
local type = type

--------------------------------------------------------------------------------------
---@class Heap
---@field private _capacity   number?                     Maximum number of items allowed in the heap.
---@field private _comparator fun(a: any, b: any): -1|0|1 Defaults to a "Natural Order".
---@field private _entries    Array                       Array holding the entries.
--------------------------------------------------------------------------------------
local Heap = {}
Heap.__index = Heap

-----------------------------------------------------------------------------
---Checks if it is a Heap instance.
---
---@param  maybe any
---
---@return boolean
-----------------------------------------------------------------------------
function Heap.isHeap(maybe)
	if maybe == nil then
		return false
	end

	if type(maybe) ~= "table" then
		return false
	end

	return getmetatable(maybe) == Heap
end

-----------------------------------------------------------------------------
---Creates a new instance of the heap.
---
---@param  iterable?   table<any, any>             Optional table or Heap to initialize
---                                                the heap from.
---@param  comparator? fun(a: any, b: any): -1|0|1 Defaults to "Natural Order".
---@param  capacity?   number                      Maximum size desired for this heap. If
---                                                not provided, there will be no maximum.
---
---@return Heap
-----------------------------------------------------------------------------
function Heap.new(iterable, comparator, capacity)
	if comparator ~= nil then
		assert(type(comparator) == "function", "comparator should be a function")
	end

	if capacity ~= nil then
		assert(type(capacity) == "number", "capacity should be a number")
		assert(capacity > 0, "capacity should be positive")
	end

	return setmetatable({
		_capacity = capacity,
		_comparator = comparator or Comparator.natural,
		_entries = Array.new(),
	}, Heap) .. iterable
end

-----------------------------------------------------------------------------
---Creates a new instance of a MAX Heap. (Maximum item is at the root)
---
---@param  iterable? table<any, any> Optional table or Heap to initialize
---                                  the heap from.
---@param  capacity? number          Maximum size desired for this heap. If
---                                  not provided, there will be no maximum.
---
---@return Heap
-----------------------------------------------------------------------------
function Heap.newMax(iterable, capacity)
	return Heap.new(iterable, Comparator.reverse(Comparator.natural), capacity)
end

-----------------------------------------------------------------------------
---Creates a new instance of a MIN Heap. (Minimum item is at the root)
---
---@param  iterable? table<any, any> Optional table or Heap to initialize
---                                  the heap from.
---@param  capacity? number          Maximum size desired for this heap. If
---                                  not provided, there will be no maximum.
---
---@return Heap
-----------------------------------------------------------------------------
function Heap.newMin(iterable, capacity)
	return Heap.new(iterable, Comparator.natural, capacity)
end

-----------------------------------------------------------------------------
---Empties the heap.
-----------------------------------------------------------------------------
function Heap:clear()
	self._entries:clear()
end

-----------------------------------------------------------------------------
---Check the heap returns `true` if the entry is found.
---Does not consume or modify the heap.
---
---@param  value any Value to search for (compared with `==`).
---
---@return boolean
-----------------------------------------------------------------------------
function Heap:contains(value)
	return self:indexOf(value) ~= nil
end

-----------------------------------------------------------------------------
---Returns whether the heap is empty or not.
---
---@return boolean
-----------------------------------------------------------------------------
function Heap:empty()
	return #self._entries == 0
end

-----------------------------------------------------------------------------
---Check if the heap is at capacity. If the heap does not have a limit
---this will always return false.
---
---@return boolean
-----------------------------------------------------------------------------
function Heap:full()
	return self._capacity ~= nil and #self._entries >= self._capacity
end

-----------------------------------------------------------------------------
---Returns the index of the first entry with a given value.
---It will return `nil` if nothing is found.
---
---@param  value  any     Value to search.
---@param  index? number  Index to start searching from.
---                       Defaults to 1 if not provided.
---
---@return number|nil
-----------------------------------------------------------------------------
function Heap:indexOf(value, index)
	assert(value ~= nil, "value should not be nil")

	index = index or 1
	assert(type(index) == "number", "index should be a number")
	assert(index > 0, "index should be positive")

	if index > #self then
		return nil
	end

	local comp = self._comparator(value, self._entries:get(index))

	if comp == Comparator.equal then
		return index
	end

	if comp == Comparator.less then
		-- when it is before the current index then it is not in the heap
		return nil
	end

	-- When it is greater then the current index, we can check the children

	-- search in the left side first
	local left = self:indexOf(value, index * 2)
	if left ~= nil then
		return left
	end

	-- then we can check the right side
	return self:indexOf(value, index * 2 + 1)
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
---Adds a value to the heap.
---
---@param  value any Value to be added to the heap.
---
---@return boolean   `true` if value was added to the heap.
-----------------------------------------------------------------------------
function Heap:push(value)
	assert(value ~= nil, "value should not be nil")

	if self:full() then
		return false
	end

	self._entries:insert(value)
	self:_siftUp(#self)
	return true
end

-----------------------------------------------------------------------------
---Check if index `i` should come before `j` in the heap structure.
---
---@param  i number
---@param  j number
---
---@return boolean
---
---@private
-----------------------------------------------------------------------------
function Heap:_before(i, j)
	return self._comparator(self._entries:get(i), self._entries:get(j)) == Comparator.less
end

-----------------------------------------------------------------------------
---Fix the heap structure from index to leaf. (Top down)
---
---@param  index number
---
---@private
-----------------------------------------------------------------------------
function Heap:_siftDown(index)
	local child = index * 2
	while child <= #self do
		if child + 1 <= #self and self:_before(child + 1, child) then
			child = child + 1
		end

		if not self:_before(child, index) then
			break
		end

		self._entries:swap(child, index)
		index = child
		child = index * 2
	end
end

-----------------------------------------------------------------------------
---Fix the heap structure from index to root. (Bottom up)
---
---@param  index number
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
---Pushes all items from a given iterable into this Heap (in-place modification).
---
---@param  iterable? table<any, any> Any table that can be iterated over.
---                                 Defaults to an empty table if `nil`.
---
---@return Heap                     Returns this Heap instance.
-----------------------------------------------------------------------------
function Heap:__concat(iterable)
	if iterable ~= nil then
		assert(type(iterable) == "table", "iterable should be a table")

		for _, item in pairs(iterable) do
			self:push(item)
		end
	end

	return self
end

-----------------------------------------------------------------------------
---Structural equality: Considers equal when both are Heaps with the same size
---and containing the same elements in the underlying array structure.
---
---@param  other any?
---
---@return boolean
-----------------------------------------------------------------------------
function Heap:__eq(other)
	if not Heap.isHeap(other) then
		return false
	end

	return self._entries == other._entries
end

-----------------------------------------------------------------------------
---Returns the number of entries in the heap.
---
---@return number
-----------------------------------------------------------------------------
function Heap:__len()
	return #self._entries
end

-----------------------------------------------------------------------------
---Iterates through the heap in priority order by consuming items. Same as:
---
---while not heap:empty() do
---   local item = heap:pop()
---end
---
---@return fun(): number?, any? Generator function yielding (1, item) until empty.
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
---String representation of this heap.
---
---@return string
-----------------------------------------------------------------------------
function Heap:__tostring()
	return tostring(self._entries)
end

return Heap
