local lu = require("luaunit")
local trunc = require("ff.math.trunc")

TestTrunc = {}

function TestTrunc:testZero()
	lu.assertEquals(0, trunc(0))
	lu.assertEquals(0, trunc(0.5))
	lu.assertEquals(0, trunc(-0.1))
end

function TestTrunc:testPositive()
	lu.assertEquals(1, trunc(1.1))
	lu.assertEquals(4, trunc(4.234))
	lu.assertEquals(6, trunc(6.0))
	lu.assertEquals(8, trunc(8))
	lu.assertEquals(10, trunc(10.6))
end

function TestTrunc:testNegative()
	lu.assertEquals(-4, trunc(-4.8))
	lu.assertEquals(-15, trunc(-15.2))
	lu.assertEquals(-18, trunc(-18))
end

function TestTrunc:testNonNumber()
	lu.assertNil(trunc(nil))
	lu.assertNil(trunc(true))
	lu.assertNil(trunc("something"))
	lu.assertNil(trunc({ 1, 2, 3 }))
	lu.assertNil(trunc({ a = 1, b = 2 }))
	lu.assertNil(trunc(function()
		return 1
	end))
end

