local Array = require("ff.collections.array")

-----------------------------------------------------------------------------
---Sorts a NUMERIC Array or Table Array.
---
---@param array   Array<number>|table<number> Collection to be sorted.
---@param min?    number                      Mininum value in the array.
---                                           Calculated if not provided.
---@param max?    number                      Maximum value in the array.
---                                           Calculated if not provided.
-----------------------------------------------------------------------------
local function bucketsort(array, min, max)
	assert(Array.isArray(array), "Should be an array")

	local collection = array._entries or array

	if not min or not max then
		for _, value in pairs(collection) do
			assert(type(value) == "number", "Should only contain numbers")
			if not min or value < min then
				min = value
			end

			if not max or value > max then
				max = value
			end
		end
	end

	local offset = 1 - min

	local buckets = {}
	for _ = 1, max + offset do
		table.insert(buckets, 0)
	end

	for _, value in pairs(collection) do
		buckets[value + offset] = buckets[value + offset] + 1
	end

	local index = 1
	for value, count in pairs(buckets) do
		for _ = 1, count do
			collection[index] = value - offset
			index = index + 1
		end
	end
end

return bucketsort
