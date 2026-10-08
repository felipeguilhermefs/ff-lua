local lu = require("luaunit")
local factorial = require("ff.math.factorial")

TestFactorial = {}

function TestFactorial:testZero()
	lu.assertEquals(factorial(0), 0)
end

function TestFactorial:testPositive()
	lu.assertEquals(factorial(1), 1)
	lu.assertEquals(factorial(4), 24)
	lu.assertEquals(factorial(10), 3628800)
	lu.assertEquals(factorial(25), 7034535277573963776)
end

function TestFactorial:testNegative()
	lu.assertErrorMsgContains("Should be positive", factorial, -4)
	lu.assertErrorMsgContains("Should be positive", factorial, -4.2)
end

function TestFactorial:testNonInteger()
	lu.assertEquals(factorial(4.0), 24)
	lu.assertEquals(factorial(4.2), 24)
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

