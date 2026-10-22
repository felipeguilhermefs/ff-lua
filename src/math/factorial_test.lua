-- Imports
local lu = require("luaunit")
local factorial = require("ff.math.factorial")

-- Suite definitions
local TestFactorial = {}

-- Scenarios: factorial behavior
function TestFactorial:testFactorialOfZero_Returns_Zero()
	-- Given: the input is 0.
	-- When: evaluate factorial(0).
	-- Then: the result is 0.
	lu.assertEquals(factorial(0), 0)
end

function TestFactorial:testPositiveIntegerFactorial_Matches_ExpectedProduct()
	-- Given: inputs are positive integers from 1 through 25.
	-- When: evaluate factorial for each input.
	-- Then: results match the corresponding products.
	lu.assertEquals(factorial(1), 1)
	lu.assertEquals(factorial(4), 24)
	lu.assertEquals(factorial(10), 3628800)
	lu.assertEquals(factorial(25), 7034535277573963776)
end

function TestFactorial:testNegativeInput_Raises_ValidationError()
	-- Given: inputs are negative integers and fractions.
	-- When: evaluate factorial for each negative input.
	-- Then: each call reports that the input must be positive.
	lu.assertErrorMsgContains("Should be positive", factorial, -4)
	lu.assertErrorMsgContains("Should be positive", factorial, -4.2)
end

function TestFactorial:testNonIntegerInput_IsTruncated_BeforeFactorial()
	-- Given: inputs are 4.0 and 4.2.
	-- When: evaluate factorial for each fractional input.
	-- Then: both calls produce the factorial of 4.
	lu.assertEquals(factorial(4.0), 24)
	lu.assertEquals(factorial(4.2), 24)
end

function TestFactorial:testNonNumberInput_Raises_ValidationError()
	-- Given: inputs include nil, booleans, strings, tables, and a function.
	-- When: pass each value to factorial.
	-- Then: each call reports that the input must be a number.
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
