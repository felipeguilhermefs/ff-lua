local lu = require("luaunit")
local Array = require("ff.collections.array")
local bucketsort = require("bucketsort")

function TestArray()
	local a = Array.new({ 2, 6, 3, 4, 5, 1 })

	bucketsort(a)

	lu.assertEquals(1, a:get(1))
	lu.assertEquals(2, a:get(2))
	lu.assertEquals(3, a:get(3))
	lu.assertEquals(4, a:get(4))
	lu.assertEquals(5, a:get(5))
	lu.assertEquals(6, a:get(6))

	a = Array.new({ -2, -6, 3, -4, 5, 1 })

	bucketsort(a)

	lu.assertEquals(-6, a:get(1))
	lu.assertEquals(-4, a:get(2))
	lu.assertEquals(-2, a:get(3))
	lu.assertEquals(1, a:get(4))
	lu.assertEquals(3, a:get(5))
	lu.assertEquals(5, a:get(6))
end

function TestTableArray()
	local a = { 2, 6, 3, 4, 5, 1 }

	bucketsort(a)

	lu.assertEquals({ 1, 2, 3, 4, 5, 6 }, a)

	a = { -2, -6, 3, -4, 5, 1 }

	bucketsort(a, -6, 5)

	lu.assertEquals({ -6, -4, -2, 1, 3, 5 }, a)
end

os.exit(lu.LuaUnit.run())
