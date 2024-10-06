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

local function quickselect(array, kth, cmp)
	assert(Array.isArray(array), "Should be an array")

	cmp = cmp or Comparator.natural

	local collection = array._entries or array

	local low = 1
	local high = #collection
	while true do
		if high == low then
			if high == kth then
				return collection[high]
			else
				return nil
			end
		end

		local pivot = partition(collection, low, high, cmp)

		if pivot == kth then
			return collection[pivot]
		end

		if kth < pivot then
			high = pivot - 1
		else
			low = pivot + 1
		end
	end
end

return quickselect
