local lu = require("luaunit")
local fibonacci = require("ff.math.fibonacci")

local TestFibonacci = {}
function TestFibonacci:testZeroInputReturnsOne()
	lu.assertEquals(fibonacci(0), 1)
end

function TestFibonacci:testOneInputReturnsOne()
	lu.assertEquals(fibonacci(1), 1)
end

function TestFibonacci:testTwoInputReturnsTwo()
	lu.assertEquals(fibonacci(2), 2)
end

function TestFibonacci:testThreeInputReturnsThree()
	lu.assertEquals(fibonacci(3), 3)
end

function TestFibonacci:testFourInputReturnsFive()
	lu.assertEquals(fibonacci(4), 5)
end

function TestFibonacci:testFiveInputReturnsEight()
	lu.assertEquals(fibonacci(5), 8)
end

function TestFibonacci:testSevenInputReturnsTwentyOne()
	lu.assertEquals(fibonacci(7), 21)
end

function TestFibonacci:testHundredthInputReturnsExpectedValue()
	lu.assertEquals(fibonacci(100), 1298777728820984005)
end

return { TestFibonacci = TestFibonacci }
