local function toArray(text)
	local chars = {}
	for i = 1, #text do
		chars[i] = string.char(text:byte(i))
	end
	return chars
end

-----------------------------------------------------------------------------
---Yields each permutation using Heap's algorithm.
---
---@param array table<number> array to permute on
---@param k     number        permutation limit, k <= #array
---
---@yield table<any>
-----------------------------------------------------------------------------
local function permute(array, k)
	if k <= 1 then
		coroutine.yield(array)
	else
		permute(array, k - 1)
		for i = 1, k - 1 do
			if k % 2 == 0 then
				array[i], array[k] = array[k], array[i]
			else
				array[1], array[k] = array[k], array[1]
			end
			permute(array, k - 1)
		end
	end
end

-----------------------------------------------------------------------------
---Generates permutations of iterables like string or arrays.
---
---The order is important so {a, b, c} is different from {a, c, b}.
---
---@param sequence table<any>|string
---
---@return Iterator<table<any>|string>
-----------------------------------------------------------------------------
local function permutations(sequence)
	local isString = type(sequence) == "string"

	assert(type(sequence) == "table" or isString, "Only arrays and strings are accepted")

	assert(#sequence <= 15, "It shouldn't be bigger than 15 characters")

	local array = sequence
	if isString then
		array = toArray(sequence)
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
