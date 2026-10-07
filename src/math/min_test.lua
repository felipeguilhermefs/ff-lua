local lu = require("luaunit")
local min = require("ff.math.min")

TestMin = {}

function TestMin:testSingleNumber()
	lu.assertEquals(min(1), 1)
	lu.assertEquals(min(-2), -2)
	lu.assertEquals(min(45.9), 45.9)
end

function TestMin:testMultipleNumbers()
	lu.assertEquals(min(1, 5), 1)
	lu.assertEquals(min(4, 2, 9), 2)
	lu.assertEquals(min(-5, -8, 2), -8)
end

function TestMin:testArrayOfNumbers()
	lu.assertEquals(min(table.unpack({ 7, 4, 9, 3 })), 3)
end

function TestMin:testNonNumbers()
	lu.assertNil(min(nil))
	lu.assertNil(min(true))
	lu.assertNil(min("something"))
	lu.assertNil(min({ 1, 2, 3 }))
	lu.assertNil(min({ a = 1, b = 2 }))
	lu.assertNil(min(function()
		return 1
	end))
end

function TestMin:testArrayWithNumbersAndNonNumbers()
	lu.assertEquals(min(table.unpack({ 8, true, "1", 5, {} })), 5)
end

