local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")

local function partition(array, low, high, cmp)
	local pivot = array[(high + low) // 2]

	local i = low - 1
	local j = high + 1
	while true do
		while true do
			i = i + 1
			if cmp(array[i], pivot) ~= Comparator.less then
				break
			end
		end

		while true do
			j = j - 1
			if cmp(array[j], pivot) ~= Comparator.greater then
				break
			end
		end

		if i >= j then
			return j
		end

		array[i], array[j] = array[j], array[i]
	end
end

local function sort(array, low, high, cmp)
	if high - low < 1 then
		return
	end

	local pivot = partition(array, low, high, cmp)

	sort(array, low, pivot, cmp)
	sort(array, pivot + 1, high, cmp)
end

-----------------------------------------------------------------------------
---Sorts an Array or Table Array In-Place. Uses Hoare's QuickSort.
---
---@param array       Array|table<any> Collection to be sorted.
---@param comparator? Comparator       Defaults to natural order.
-----------------------------------------------------------------------------
local function quicksort(array, comparator)
	assert(Array.isArray(array), "Should be an array")
	comparator = comparator or Comparator.natural

	local collection = array._entries or array

	sort(collection, 1, #collection, comparator)
end

return quicksort
