-- Imports
local lu = require("luaunit")
local factorial = require("ff.math.factorial")

-- Suite definitions
local TestFactorial = {}

-- Scenarios: factorial behavior
function TestFactorial:testFactorialOfZeroReturnsZero()
	lu.assertEquals(factorial(0), 0)
end

function TestFactorial:testPositiveIntegerFactorialMatchesExpectedProduct()
	lu.assertEquals(factorial(1), 1)
	lu.assertEquals(factorial(4), 24)
	lu.assertEquals(factorial(10), 3628800)
	lu.assertEquals(factorial(25), 7034535277573963776)
end

function TestFactorial:testNegativeInputRaisesValidationError()
	lu.assertErrorMsgContains("Should be positive", factorial, -4)
	lu.assertErrorMsgContains("Should be positive", factorial, -4.2)
end

function TestFactorial:testNonIntegerInputIsTruncatedBeforeFactorial()
	lu.assertEquals(factorial(4.0), 24)
	lu.assertEquals(factorial(4.2), 24)
end

function TestFactorial:testNonNumberInputRaisesValidationError()
	lu.assertErrorMsgContains("Should be a number", factorial, nil)
	lu.assertErrorMsgContains("Should be a number", factorial, true)
	lu.assertErrorMsgContains("Should be a number", factorial, "something")
	lu.assertErrorMsgContains("Should be a number", factorial, { 1, 2, 3 })
	lu.assertErrorMsgContains("Should be a number", factorial, { a = 1, b = 2 })
	lu.assertErrorMsgContains("Should be a number", factorial, function()
		return 1
	end)
end

-- Suite map
return { TestFactorial = TestFactorial }
