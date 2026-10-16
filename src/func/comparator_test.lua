-- Imports
local lu = require("luaunit")
local Comparator = require("ff.func.comparator")

-- Suite definitions
local TestComparator = {}

-- Scenarios: ordering behavior
function TestComparator:testNaturalComparatorOrdersNumbersAndStrings()
	-- Given: numeric and string pairs cover less, equal, and greater cases.
	local cmp = Comparator.natural

	-- When: pass each pair to the natural comparator.
	-- Then: results are less, equal, or greater according to value order.
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

function TestComparator:testReverseComparatorInvertsNaturalOrdering()
	-- Given: the natural comparator and the same ordered pairs are used.
	local cmp = Comparator.reverse(Comparator.natural)

	-- When: pass each pair to the reversed comparator.
	-- Then: less and greater results swap while equal results stay equal.
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

-- Suite map
return { TestComparator = TestComparator }
