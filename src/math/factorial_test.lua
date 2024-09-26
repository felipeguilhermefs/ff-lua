local lu = require("luaunit")
local factorial = require("factorial")

function TestZero()
	lu.assertEquals(0, factorial(0))
end

function TestPositive()
	lu.assertEquals(1, factorial(1))
	lu.assertEquals(24, factorial(4))
	lu.assertEquals(3628800, factorial(10))
	lu.assertEquals(7034535277573963776, factorial(25))
end

function TestNegative()
	lu.assertError(factorial, -4)
	lu.assertError(factorial, -4.2)
end

function TestNonInteger()
	lu.assertEquals(24, factorial(4.0))
	lu.assertEquals(24, factorial(4.2))
end

function TestNonNumber()
	lu.assertError(factorial, nil)
	lu.assertError(factorial, true)
	lu.assertError(factorial, "something")
	lu.assertError(factorial, { 1, 2, 3 })
	lu.assertError(factorial, { a = 1, b = 2 })
	lu.assertError(factorial, function()
		return 1
	end)
end

os.exit(lu.LuaUnit.run())
