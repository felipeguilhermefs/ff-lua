local lu = require("luaunit")
local max = require("ff.math.max")

TestMax = {}

function TestMax:testSingleNumber()
	lu.assertEquals(max(1), 1)
	lu.assertEquals(max(-2), -2)
	lu.assertEquals(max(45.9), 45.9)
end

function TestMax:testMultipleNumbers()
	lu.assertEquals(max(1, 5), 5)
	lu.assertEquals(max(4, 2, 9), 9)
	lu.assertEquals(max(-5, -8, -2), -2)
end

function TestMax:testArrayOfNumbers()
	lu.assertEquals(max(table.unpack({ 7, 4, 9, 3 })), 9)
end

function TestMax:testNonNumbers()
	lu.assertNil(max(nil))
	lu.assertNil(max(true))
	lu.assertNil(max("something"))
	lu.assertNil(max({ 1, 2, 3 }))
	lu.assertNil(max({ a = 1, b = 2 }))
	lu.assertNil(max(function()
		return 1
	end))
end

function TestMax:testArrayWithNumbersAndNonNumbers()
	lu.assertEquals(max(table.unpack({ 8, true, "1", 5, {} })), 8)
end

