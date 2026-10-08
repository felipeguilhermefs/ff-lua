local lu = require("luaunit")
local factorial = require("ff.math.factorial")

TestFactorial = {}

function TestFactorial:testZero()
	lu.assertEquals(0, factorial(0))
end

function TestFactorial:testPositive()
	lu.assertEquals(1, factorial(1))
	lu.assertEquals(24, factorial(4))
	lu.assertEquals(3628800, factorial(10))
	lu.assertEquals(7034535277573963776, factorial(25))
end

function TestFactorial:testNegative()
	lu.assertErrorMsgContains("Should be positive", factorial, -4)
	lu.assertErrorMsgContains("Should be positive", factorial, -4.2)
end

function TestFactorial:testNonInteger()
	lu.assertEquals(24, factorial(4.0))
	lu.assertEquals(24, factorial(4.2))
end

function TestFactorial:testNonNumber()
	lu.assertErrorMsgContains("Should be a number", factorial, nil)
	lu.assertErrorMsgContains("Should be a number", factorial, true)
	lu.assertErrorMsgContains("Should be a number", factorial, "something")
	lu.assertErrorMsgContains("Should be a number", factorial, { 1, 2, 3 })
	lu.assertErrorMsgContains("Should be a number", factorial, { a = 1, b = 2 })
	lu.assertErrorMsgContains("Should be a number", factorial, function()
		return 1
	end)
end

