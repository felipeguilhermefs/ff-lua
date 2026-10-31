local lu = require("luaunit")
local min = require("ff.math.min")

local TestMin = {}

function TestMin:testSingleNumber_IsMinValue()
	lu.assertEquals(min(1), 1)
	lu.assertEquals(min(-2), -2)
	lu.assertEquals(min(45.9), 45.9)
end

function TestMin:testVariadicInput_FindMinValue()
	lu.assertEquals(min(1, 5), 1)
	lu.assertEquals(min(4, 2, 9), 2)
	lu.assertEquals(min(-5, -8, 2), -8)
end

function TestMin:testUnpackedNumbers_FindMinValue()
	lu.assertEquals(min(table.unpack({ 7, 4, 9, 3 })), 3)
end

function TestMin:testNonNumericInput_ReturnsNil()
	lu.assertNil(min(nil))
	lu.assertNil(min(true))
	lu.assertNil(min("something"))
	lu.assertNil(min({ 1, 2, 3 }))
	lu.assertNil(min({ a = 1, b = 2 }))
	lu.assertNil(min(function()
		return 1
	end))
end

function TestMin:testUnpackedMixNumbersAndNonNumbers_FindMinValueIgnoringNonNumeric()
	lu.assertEquals(min(table.unpack({ 8, true, "1", 5, {} })), 5)
end

return { TestMin = TestMin }
