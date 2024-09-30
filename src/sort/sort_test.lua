local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local sort = require("sort")

function TestArray()
	local a = Array.new({ 2, 6, 3, 4, 5, 1 })

	sort(a)

	lu.assertEquals(1, a:get(1))
	lu.assertEquals(2, a:get(2))
	lu.assertEquals(3, a:get(3))
	lu.assertEquals(4, a:get(4))
	lu.assertEquals(5, a:get(5))
	lu.assertEquals(6, a:get(6))

	sort(a, Comparator.reverse(Comparator.natural))

	lu.assertEquals(1, a:get(6))
	lu.assertEquals(2, a:get(5))
	lu.assertEquals(3, a:get(4))
	lu.assertEquals(4, a:get(3))
	lu.assertEquals(5, a:get(2))
	lu.assertEquals(6, a:get(1))
end

function TestTableArray()
	local a = { 2, 6, 3, 4, 5, 1 }

	sort(a)

	lu.assertEquals(1, a:get(1))
	lu.assertEquals(2, a:get(2))
	lu.assertEquals(3, a:get(3))
	lu.assertEquals(4, a:get(4))
	lu.assertEquals(5, a:get(5))
	lu.assertEquals(6, a:get(6))

	sort(a, Comparator.reverse(Comparator.natural))

	lu.assertEquals(1, a:get(6))
	lu.assertEquals(2, a:get(5))
	lu.assertEquals(3, a:get(4))
	lu.assertEquals(4, a:get(3))
	lu.assertEquals(5, a:get(2))
	lu.assertEquals(6, a:get(1))
end

os.exit(lu.LuaUnit.run())
