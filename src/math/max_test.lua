-- Imports
local lu = require("luaunit")
local max = require("ff.math.max")

-- Suite definitions
local TestMax = {}

-- Scenarios: maximum behavior
function TestMax:testSingleNumber_Returns_ThatNumber()
	-- Given: each call receives one numeric argument.
	-- When: evaluate max with each single value.
	-- Then: each result equals its sole argument.
	lu.assertEquals(max(1), 1)
	lu.assertEquals(max(-2), -2)
	lu.assertEquals(max(45.9), 45.9)
end

function TestMax:testVariadicInput_Returns_LargestNumber()
	-- Given: calls receive positive and negative numeric tuples.
	-- When: evaluate max for each tuple.
	-- Then: each result is the greatest value in its tuple.
	lu.assertEquals(max(1, 5), 5)
	lu.assertEquals(max(4, 2, 9), 9)
	lu.assertEquals(max(-5, -8, -2), -2)
end

function TestMax:testUnpackedValues_Return_LargestNumber()
	-- Given: a table contains four numbers for unpacking.
	-- When: pass the unpacked values to max.
	-- Then: the result is 9, greatest value in the table.
	lu.assertEquals(max(table.unpack({ 7, 4, 9, 3 })), 9)
end

function TestMax:testNonNumericInput_Returns_Nil()
	-- Given: inputs include nil, booleans, strings, tables, and a function.
	-- When: pass each value to max.
	-- Then: every call returns nil.
	lu.assertNil(max(nil))
	lu.assertNil(max(true))
	lu.assertNil(max("something"))
	lu.assertNil(max({ 1, 2, 3 }))
	lu.assertNil(max({ a = 1, b = 2 }))
	lu.assertNil(max(function()
		return 1
	end))
end

function TestMax:testUnpackedValues_Ignore_NonNumbersWhenFindingLargest()
	-- Given: the unpacked table mixes numbers with non-numeric values.
	-- When: pass all unpacked values to max.
	-- Then: non-numbers are ignored and result is 8.
	lu.assertEquals(max(table.unpack({ 8, true, "1", 5, {} })), 8)
end

-- Suite map
return { TestMax = TestMax }
