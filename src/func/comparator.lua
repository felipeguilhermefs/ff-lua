local _LESS = -1
local _EQUAL = 0
local _GREATER = 1

---@class Comparator
---
---@field less    number alias for "less than" comparison result.
---@field equal   number alias for "equal" comparison result.
---@field greater number alias for "greater than" comparison result.
local Comparator = { less = _LESS, equal = _EQUAL, greater = _GREATER }
Comparator.__index = Comparator

-----------------------------------------------------------------------------
---Compares 2 using "natural order"
---	Ex: Numbers in natural order [1, 2, 3, 4, 5]
---	    Strings in natural order ["a", "b", "c"]
---
---@param a any
---@param b any
---
---@return -1|0|1 Meaning <|=|>
-----------------------------------------------------------------------------
function Comparator.natural(a, b)
	if a < b then
		return _LESS
	end

	if a > b then
		return _GREATER
	end

	return _EQUAL
end

-----------------------------------------------------------------------------
---Decorate a comparator reversing its output.
---
---@param comparator fun(a,b): -1|0|1
---
---@return fun(a,b): -1|0|1
-----------------------------------------------------------------------------
function Comparator.reverse(comparator)
	return function(a, b)
		local cmp = comparator(a, b)
		if cmp == _LESS then
			return _GREATER
		end

		if cmp == _GREATER then
			return _LESS
		end

		return _EQUAL
	end
end

return Comparator
