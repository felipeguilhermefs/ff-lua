local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")

-----------------------------------------------------------------------------
---Binary searches in an array, assuming an already sorted array.
---
---@param array       Array      Array to be searched.
---@param value       any        Value to be looked up.
---@param comparator? Comparator Defaults to natural order.
---
---@return number|nil Index of the value, or `nil` if not found.
-----------------------------------------------------------------------------
local function binarysearch(array, value, comparator)
	assert(Array.isArray(array), "Should be an array")

	if value == nil then
		return
	end

	if #array == 0 then
		return
	end

	comparator = comparator or Comparator.natural

	local low = 1
	local high = #array

	while high >= low do
		local mid = (high + low) // 2

		local cmp = comparator(value, array:get(mid))
		if cmp == Comparator.equal then
			return mid
		end

		if cmp == Comparator.greater then
			low = mid + 1
		else
			high = mid - 1
		end
	end
end

return binarysearch
