local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local binarysearch = require("binarysearch")

function TestArray()
	local a = Array.new({ 1, 2, 3, 4, 5, 6 })

	lu.assertEquals(1, binarysearch(a, 1))
	lu.assertEquals(2, binarysearch(a, 2))
	lu.assertEquals(3, binarysearch(a, 3))
	lu.assertEquals(4, binarysearch(a, 4))
	lu.assertEquals(5, binarysearch(a, 5))
	lu.assertEquals(6, binarysearch(a, 6))
	lu.assertNil(binarysearch(a, 7))
end

function TestTableArray()
	local a = { 6, 5, 4, 3, 2, 1 }

	local cmp = Comparator.reverse(Comparator.natural)

	lu.assertEquals(1, binarysearch(a, 6, cmp))
	lu.assertEquals(2, binarysearch(a, 5, cmp))
	lu.assertEquals(3, binarysearch(a, 4, cmp))
	lu.assertEquals(4, binarysearch(a, 3, cmp))
	lu.assertEquals(5, binarysearch(a, 2, cmp))
	lu.assertEquals(6, binarysearch(a, 1, cmp))
	lu.assertNil(binarysearch(a, 7, cmp))
end

os.exit(lu.LuaUnit.run())
