local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")

-----------------------------------------------------------------------------
---Sorts an Array or Table Array In-Place. Uses lua default `table.sort`.
---
---@param array       Array|table<any> Collection to be sorted.
---@param comparator? Comparator       Defaults to natural order.
-----------------------------------------------------------------------------
local function sort(array, comparator)
	assert(Array.isArray(array), "Should be an array")

	local cmp
	if comparator then
		cmp = function(a, b)
			return comparator(a, b) == Comparator.greater
		end
	end

	local collection = array._entries or array

	table.sort(collection, cmp)
end

return sort
