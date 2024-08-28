local lu = require("luaunit")
local Comparator = require("comparator")

function TestNaturalOrder()
	local cmp = Comparator.natural

	lu.assertEquals(Comparator.less, cmp(1, 2))
	lu.assertEquals(Comparator.less, cmp(-2, 1))
	lu.assertEquals(Comparator.less, cmp(0, 1))
	lu.assertEquals(Comparator.less, cmp("1", "2"))
	lu.assertEquals(Comparator.less, cmp("a", "b"))
	lu.assertEquals(Comparator.less, cmp("A", "b"))
	lu.assertEquals(Comparator.less, cmp("1", "A"))

	lu.assertEquals(Comparator.equal, cmp(3, 3))
	lu.assertEquals(Comparator.equal, cmp(-3, -3))
	lu.assertEquals(Comparator.equal, cmp(0, 0))
	lu.assertEquals(Comparator.equal, cmp("3", "3"))
	lu.assertEquals(Comparator.equal, cmp("c", "c"))

	lu.assertEquals(Comparator.greater, cmp(1, 0))
	lu.assertEquals(Comparator.greater, cmp(-2, -10))
	lu.assertEquals(Comparator.greater, cmp(0, -1))
	lu.assertEquals(Comparator.greater, cmp("6", "4"))
	lu.assertEquals(Comparator.greater, cmp("z", "h"))
	lu.assertEquals(Comparator.greater, cmp("r", "R"))
end

function TestReverseNaturalOrder()
	local cmp = Comparator.reverse(Comparator.natural)

	lu.assertEquals(Comparator.greater, cmp(1, 2))
	lu.assertEquals(Comparator.greater, cmp(-2, 1))
	lu.assertEquals(Comparator.greater, cmp(0, 1))
	lu.assertEquals(Comparator.greater, cmp("1", "2"))
	lu.assertEquals(Comparator.greater, cmp("a", "b"))
	lu.assertEquals(Comparator.greater, cmp("A", "b"))
	lu.assertEquals(Comparator.greater, cmp("1", "A"))

	lu.assertEquals(Comparator.equal, cmp(3, 3))
	lu.assertEquals(Comparator.equal, cmp(-3, -3))
	lu.assertEquals(Comparator.equal, cmp(0, 0))
	lu.assertEquals(Comparator.equal, cmp("3", "3"))
	lu.assertEquals(Comparator.equal, cmp("c", "c"))

	lu.assertEquals(Comparator.less, cmp(1, 0))
	lu.assertEquals(Comparator.less, cmp(-2, -10))
	lu.assertEquals(Comparator.less, cmp(0, -1))
	lu.assertEquals(Comparator.less, cmp("6", "4"))
	lu.assertEquals(Comparator.less, cmp("z", "h"))
	lu.assertEquals(Comparator.less, cmp("r", "R"))
end

os.exit(lu.LuaUnit.run())
