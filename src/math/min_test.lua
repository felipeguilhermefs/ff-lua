local lu = require("luaunit")
local min = require("min")

function test_SingleNumber()
	lu.assertEquals(min(1), 1)
	lu.assertEquals(min(-2), -2)
	lu.assertEquals(min(45.9), 45.9)
end

function test_MultipleNumbers()
	lu.assertEquals(min(1, 5), 1)
	lu.assertEquals(min(4, 2, 9), 2)
	lu.assertEquals(min(-5, -8, 2), -8)
end

function test_ArrayOfNumbers()
	lu.assertEquals(min(table.unpack({ 7, 4, 9, 3 })), 3)
end

function test_NonNumbers()
	lu.assertNil(min(nil))
	lu.assertNil(min(true))
	lu.assertNil(min("something"))
	lu.assertNil(min({ 1, 2, 3 }))
	lu.assertNil(min({ a = 1, b = 2 }))
	lu.assertNil(min(function()
		return 1
	end))
end

function test_ArrayWithNumbersAndNonNumbers()
	lu.assertEquals(min(table.unpack({ 8, true, "1", 5, {} })), 5)
end

os.exit(lu.LuaUnit.run())
