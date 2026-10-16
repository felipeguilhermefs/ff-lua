-- Imports
local lu = require("luaunit")
local fibonacci = require("ff.math.fibonacci")

-- Suite definitions
local TestFibonacci = {}

-- Scenarios: sequence behavior
function TestFibonacci:testZeroInputReturnsOne()
	-- Given: the requested sequence index is 0.
	-- When: evaluate fibonacci(0).
	-- Then: index 0 maps to sequence value 1.
	lu.assertEquals(fibonacci(0), 1)
end

function TestFibonacci:testOneInputReturnsOne()
	-- Given: the requested sequence index is 1.
	-- When: evaluate fibonacci(1).
	-- Then: index 1 maps to sequence value 1.
	lu.assertEquals(fibonacci(1), 1)
end

function TestFibonacci:testTwoInputReturnsTwo()
	-- Given: the requested sequence index is 2.
	-- When: evaluate fibonacci(2).
	-- Then: the result is 2.
	lu.assertEquals(fibonacci(2), 2)
end

function TestFibonacci:testThreeInputReturnsThree()
	-- Given: the requested sequence index is 3.
	-- When: evaluate fibonacci(3).
	-- Then: the result is 3.
	lu.assertEquals(fibonacci(3), 3)
end

function TestFibonacci:testFourInputReturnsFive()
	-- Given: the requested sequence index is 4.
	-- When: evaluate fibonacci(4).
	-- Then: the result is 5.
	lu.assertEquals(fibonacci(4), 5)
end

function TestFibonacci:testFiveInputReturnsEight()
	-- Given: the requested sequence index is 5.
	-- When: evaluate fibonacci(5).
	-- Then: the result is 8.
	lu.assertEquals(fibonacci(5), 8)
end

function TestFibonacci:testSevenInputReturnsTwentyOne()
	-- Given: the requested sequence index is 7.
	-- When: evaluate fibonacci(7).
	-- Then: the result is 21.
	lu.assertEquals(fibonacci(7), 21)
end

function TestFibonacci:testHundredthInputReturnsExpectedValue()
	-- Given: the requested sequence index is 100.
	-- When: evaluate fibonacci(100).
	-- Then: the result matches the expected large sequence value.
	lu.assertEquals(fibonacci(100), 1298777728820984005)
end

-- Suite map
return { TestFibonacci = TestFibonacci }
