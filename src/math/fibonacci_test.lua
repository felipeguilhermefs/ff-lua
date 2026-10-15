local lu = require("luaunit")
local fibonacci = require("ff.math.fibonacci")

local TestFibonacci = {}

function TestFibonacci:testZero_IsOne()
	lu.assertEquals(fibonacci(0), 1)
end

function TestFibonacci:testOne_IsOne()
	lu.assertEquals(fibonacci(1), 1)
end

function TestFibonacci:testTwo_IsTwo()
	lu.assertEquals(fibonacci(2), 2)
end

function TestFibonacci:testThree_IsThree()
	lu.assertEquals(fibonacci(3), 3)
end

function TestFibonacci:testFour_IsFive()
	lu.assertEquals(fibonacci(4), 5)
end

function TestFibonacci:testFive_IsEight()
	lu.assertEquals(fibonacci(5), 8)
end

function TestFibonacci:testSeven_IsTwentyOne()
	lu.assertEquals(fibonacci(7), 21)
end

function TestFibonacci:testHundred_IsLargeNumber()
	lu.assertEquals(fibonacci(100), 1298777728820984005)
end

return { TestFibonacci = TestFibonacci }
