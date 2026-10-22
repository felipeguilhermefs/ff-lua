-- Imports
local lu = require("luaunit")
local min = require("ff.math.min")

-- Suite definitions
local TestMin = {}

-- Scenarios: minimum behavior
function TestMin:testSingleNumber_Returns_ThatNumber()
	-- Given: each call receives one numeric argument.
	-- When: evaluate min with each single value.
	-- Then: each result equals its sole argument.
	lu.assertEquals(min(1), 1)
	lu.assertEquals(min(-2), -2)
	lu.assertEquals(min(45.9), 45.9)
end

function TestMin:testVariadicInput_Returns_SmallestNumber()
	-- Given: calls receive positive and negative numeric tuples.
	-- When: evaluate min for each tuple.
	-- Then: each result is the least value in its tuple.
	lu.assertEquals(min(1, 5), 1)
	lu.assertEquals(min(4, 2, 9), 2)
	lu.assertEquals(min(-5, -8, 2), -8)
end

function TestMin:testUnpackedValues_Return_SmallestNumber()
	-- Given: a table contains four numbers for unpacking.
	-- When: pass the unpacked values to min.
	-- Then: the result is 3, least value in the table.
	lu.assertEquals(min(table.unpack({ 7, 4, 9, 3 })), 3)
end

function TestMin:testNonNumericInput_Returns_Nil()
	-- Given: inputs include nil, booleans, strings, tables, and a function.
	-- When: pass each value to min.
	-- Then: every call returns nil.
	lu.assertNil(min(nil))
	lu.assertNil(min(true))
	lu.assertNil(min("something"))
	lu.assertNil(min({ 1, 2, 3 }))
	lu.assertNil(min({ a = 1, b = 2 }))
	lu.assertNil(min(function()
		return 1
	end))
end

function TestMin:testUnpackedValues_Ignore_NonNumbersWhenFindingSmallest()
	-- Given: the unpacked table mixes numbers with non-numeric values.
	-- When: pass all unpacked values to min.
	-- Then: non-numbers are ignored and result is 5.
	lu.assertEquals(min(table.unpack({ 8, true, "1", 5, {} })), 5)
end

-- Suite map
return { TestMin = TestMin }
