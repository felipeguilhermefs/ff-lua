local lu = require("luaunit")
local fibonacci = require("ff.math.fibonacci")

TestFibonacci = {}

function TestFibonacci:testWhen0Return1()
	lu.assertEquals(fibonacci(0), 1)
end

function TestFibonacci:testWhen1Return1()
	lu.assertEquals(fibonacci(1), 1)
end

function TestFibonacci:testWhen2Return2()
	lu.assertEquals(fibonacci(2), 2)
end

function TestFibonacci:testWhen3Return3()
	lu.assertEquals(fibonacci(3), 3)
end

function TestFibonacci:testWhen4Return5()
	lu.assertEquals(fibonacci(4), 5)
end

function TestFibonacci:testWhen5Return8()
	lu.assertEquals(fibonacci(5), 8)
end

function TestFibonacci:testWhen7Return21()
	lu.assertEquals(fibonacci(7), 21)
end

function TestFibonacci:testWhen100Return1298777728820984005()
	lu.assertEquals(fibonacci(100), 1298777728820984005)
end

