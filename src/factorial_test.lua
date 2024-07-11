local lu = require("luaunit")
local factorial = require("factorial")

function test_Zero()
	lu.assertEquals(0, factorial(0))
end

function test_Positive()
	lu.assertEquals(1, factorial(1))
	lu.assertEquals(24, factorial(4))
	lu.assertEquals(3628800, factorial(10))
	lu.assertEquals(7034535277573963776, factorial(25))
end

function test_Negative()
	lu.assertNil(factorial(-4))
	lu.assertNil(factorial(-4.2))
end

function test_NonInteger()
	lu.assertEquals(24, factorial(4.0))
	lu.assertEquals(24, factorial(4.2))
end

function test_NonNumber()
	lu.assertNil(factorial(nil))
	lu.assertNil(factorial(true))
	lu.assertNil(factorial("something"))
	lu.assertNil(factorial({ 1, 2, 3 }))
	lu.assertNil(factorial({ a = 1, b = 2 }))
	lu.assertNil(factorial(function()
		return 1
	end))
end

os.exit(lu.LuaUnit.run())
