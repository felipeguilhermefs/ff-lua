local lu = require("luaunit")
local trunc = require("ff.math.trunc")

TestTrunc = {}

function TestTrunc:testZero()
	lu.assertEquals(trunc(0), 0)
	lu.assertEquals(trunc(0.5), 0)
	lu.assertEquals(trunc(-0.1), 0)
end

function TestTrunc:testPositive()
	lu.assertEquals(trunc(1.1), 1)
	lu.assertEquals(trunc(4.234), 4)
	lu.assertEquals(trunc(6.0), 6)
	lu.assertEquals(trunc(8), 8)
	lu.assertEquals(trunc(10.6), 10)
end

function TestTrunc:testNegative()
	lu.assertEquals(trunc(-4.8), -4)
	lu.assertEquals(trunc(-15.2), -15)
	lu.assertEquals(trunc(-18), -18)
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

