local lu = require("luaunit")
local Array = require("ff.collections.array")
local Comparator = require("ff.func.comparator")
local quickselect = require("ff.search.quickselect")

TestQuickSelect = {}

function TestQuickSelect:testArray()
	local a = Array.new({ 1, 2, 3, 4, 5, 6 })

	lu.assertEquals(quickselect(a, 1), 1)
	lu.assertEquals(quickselect(a, 2), 2)
	lu.assertEquals(quickselect(a, 3), 3)
	lu.assertEquals(quickselect(a, 4), 4)
	lu.assertEquals(quickselect(a, 5), 5)
	lu.assertEquals(quickselect(a, 6), 6)
	lu.assertNil(quickselect(a, 7))
end

function TestQuickSelect:testTableArray()
	local a = { 6, 5, 4, 3, 2, 1 }

	local cmp = Comparator.reverse(Comparator.natural)

	lu.assertEquals(quickselect(a, 6, cmp), 1)
	lu.assertEquals(quickselect(a, 5, cmp), 2)
	lu.assertEquals(quickselect(a, 4, cmp), 3)
	lu.assertEquals(quickselect(a, 3, cmp), 4)
	lu.assertEquals(quickselect(a, 2, cmp), 5)
	lu.assertEquals(quickselect(a, 1, cmp), 6)
	lu.assertNil(quickselect(a, 7, cmp))
end

