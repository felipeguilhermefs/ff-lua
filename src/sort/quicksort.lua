local Array = require("ff.collections.array")

local function partition(array, low, high)
	local mid = (high + low) // 2
	local pivot = array[mid]

	local i = low - 1
	local j = high + 1
	while true do
		while true do
			i = i + 1
			if array[i] >= pivot then
				break
			end
		end

		while true do
			j = j - 1
			if array[j] <= pivot then
				break
			end
		end

		if i >= j then
			return j
		end

		local tmp = array[i]
		array[i] = array[j]
		array[j] = tmp
	end
end

local function sort(array, low, high)
	if high - low < 1 then
		return
	end

	local pivot = partition(array, low, high)

	sort(array, low, pivot)
	sort(array, pivot + 1, high)
end

-----------------------------------------------------------------------------
---Sorts an Array or Table Array In-Place. Uses Hoare's QuickSort.
---
---@param array       Array|table<any> Collection to be sorted.
-----------------------------------------------------------------------------
local function quicksort(array)
	assert(Array.isArray(array), "Should be an array")

	local collection = array._entries or array

	sort(collection, 1, #collection)
end

return quicksort
