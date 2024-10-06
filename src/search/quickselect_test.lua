local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local quickselect = require("quickselect")

function TestArray()
	local a = Array.new({ 1, 2, 3, 4, 5, 6 })

	lu.assertEquals(1, quickselect(a, 1))
	lu.assertEquals(2, quickselect(a, 2))
	lu.assertEquals(3, quickselect(a, 3))
	lu.assertEquals(4, quickselect(a, 4))
	lu.assertEquals(5, quickselect(a, 5))
	lu.assertEquals(6, quickselect(a, 6))
	lu.assertNil(quickselect(a, 7))
end

function TestTableArray()
	local a = { 6, 5, 4, 3, 2, 1 }

	local cmp = Comparator.reverse(Comparator.natural)

	lu.assertEquals(1, quickselect(a, 6, cmp))
	lu.assertEquals(2, quickselect(a, 5, cmp))
	lu.assertEquals(3, quickselect(a, 4, cmp))
	lu.assertEquals(4, quickselect(a, 3, cmp))
	lu.assertEquals(5, quickselect(a, 2, cmp))
	lu.assertEquals(6, quickselect(a, 1, cmp))
	lu.assertNil(quickselect(a, 7, cmp))
end

os.exit(lu.LuaUnit.run())
