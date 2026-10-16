-- Imports
local lu = require("luaunit")
local trunc = require("ff.math.trunc")

-- Suite definitions
local TestTrunc = {}

-- Scenarios: truncation behavior
function TestTrunc:testZeroInputReturnsZero()
	-- Given: inputs are zero and fractions between -1 and 1.
	-- When: truncate zero and fractions whose magnitude is below one.
	-- Then: each result is zero.
	lu.assertEquals(trunc(0), 0)
	lu.assertEquals(trunc(0.5), 0)
	lu.assertEquals(trunc(-0.1), 0)
end

function TestTrunc:testPositiveInputTruncatesTowardZero()
	-- Given: inputs are positive integers and fractions.
	-- When: truncate positive fractions and preserve positive integers.
	-- Then: fractional parts are discarded and integers stay unchanged.
	lu.assertEquals(trunc(1.1), 1)
	lu.assertEquals(trunc(4.234), 4)
	lu.assertEquals(trunc(6.0), 6)
	lu.assertEquals(trunc(8), 8)
	lu.assertEquals(trunc(10.6), 10)
end

function TestTrunc:testNegativeInputTruncatesTowardZero()
	-- Given: inputs are negative integers and fractions.
	-- When: truncate negative fractions and preserve negative integers.
	-- Then: fractional parts are discarded toward zero.
	lu.assertEquals(trunc(-4.8), -4)
	lu.assertEquals(trunc(-15.2), -15)
	lu.assertEquals(trunc(-18), -18)
end

function TestTrunc:testNonNumericInputReturnsNil()
	-- Given: inputs include nil, booleans, strings, tables, and a function.
	-- When: pass each value to trunc.
	-- Then: every call returns nil.
	lu.assertNil(trunc(nil))
	lu.assertNil(trunc(true))
	lu.assertNil(trunc("something"))
	lu.assertNil(trunc({ 1, 2, 3 }))
	lu.assertNil(trunc({ a = 1, b = 2 }))
	lu.assertNil(trunc(function()
		return 1
	end))
end

-- Suite map
return { TestTrunc = TestTrunc }
