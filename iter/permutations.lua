local function toArray(text)
	local chars = {}
	for i = 1, #text do
		chars[i] = string.char(text:byte(i))
	end
	return chars
end

local function permute(array, limit)
	if limit == 0 then
		coroutine.yield(array)
	else
		for i = 1, limit do
			array[limit], array[i] = array[i], array[limit]

			permute(array, limit - 1)

			array[limit], array[i] = array[i], array[limit]
		end
	end
end

-----------------------------------------------------------------------------
---Generates permutations of iterables like string or arrays.
---
---The order is important so {a, b, c} is different from {a, c, b}.
---
---@return Iterator<any>
-----------------------------------------------------------------------------
function permutations(array)
	local isString = type(array) == "string"

	assert(type(array) == "table" or isString, "Only arrays and strings are accepted")

	assert(#array <= 15, "It shouldn't be bigger than 15 characters")

	if isString then
		array = toArray(array)
	end

	local co = coroutine.create(function()
		permute(array, #array)
	end)
	return function()
		local _, res = coroutine.resume(co)

		if isString and res ~= nil then
			return table.concat(res)
		else
			return res
		end
	end
end

return permutations
