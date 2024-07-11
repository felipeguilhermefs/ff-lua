local lu = require("luaunit")
local fibonacci = require("fibonacci")

function test_When0Return1()
	lu.assertEquals(fibonacci(0), 1)
end

function test_When1Return1()
	lu.assertEquals(fibonacci(1), 1)
end

function test_When2Return2()
	lu.assertEquals(fibonacci(2), 2)
end

function test_When3Return3()
	lu.assertEquals(fibonacci(3), 3)
end

function test_When4Return5()
	lu.assertEquals(fibonacci(4), 5)
end

function test_When5Return8()
	lu.assertEquals(fibonacci(5), 8)
end

function test_When7Return21()
	lu.assertEquals(fibonacci(7), 21)
end

function test_When100Return1298777728820984005()
	lu.assertEquals(fibonacci(100), 1298777728820984005)
end

os.exit(lu.LuaUnit.run())
