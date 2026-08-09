local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local quicksort = require("quicksort")

function TestArray()
	local a = Array.new({ 2, 6, 3, 4, 5, 1 })

	quicksort(a)

	lu.assertEquals(1, a[1])
	lu.assertEquals(2, a[2])
	lu.assertEquals(3, a[3])
	lu.assertEquals(4, a[4])
	lu.assertEquals(5, a[5])
	lu.assertEquals(6, a[6])

	quicksort(a, Comparator.reverse(Comparator.natural))

	lu.assertEquals(1, a[6])
	lu.assertEquals(2, a[5])
	lu.assertEquals(3, a[4])
	lu.assertEquals(4, a[3])
	lu.assertEquals(5, a[2])
	lu.assertEquals(6, a[1])
end

function TestTableArray()
	local a = { 2, 6, 3, 4, 5, 1 }

	quicksort(a)

	lu.assertEquals({ 1, 2, 3, 4, 5, 6 }, a)

	quicksort(a, Comparator.reverse(Comparator.natural))

	lu.assertEquals({ 6, 5, 4, 3, 2, 1 }, a)
end

os.exit(lu.LuaUnit.run())
