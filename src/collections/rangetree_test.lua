local lu = require("luaunit")
local RangeTree = require("rangetree")

function TestEmpty()
	local rt = RangeTree.new()

	lu.assertTrue(rt:empty())
	lu.assertEquals(0, #rt)

	rt:insert(1, 2)
	lu.assertFalse(rt:empty())
	lu.assertEquals(1, #rt)

	rt:clear()
	lu.assertTrue(rt:empty())
	lu.assertEquals(0, #rt)

	rt:insert(3, 4)
	rt:insert(8, 9)
	lu.assertFalse(rt:empty())
	lu.assertEquals(2, #rt)
end

function TestInsert()
	local rt = RangeTree.new()

	rt:insert(4, 8)
	rt:insert(5, 10)
	rt:insert(1, 3)

	lu.assertEquals(2, #rt)

	rt:insert(2, 7)
	lu.assertEquals(1, #rt)

	for low, high in pairs(rt) do
		lu.assertEquals(1, low)
		lu.assertEquals(10, high)
	end
end

function TestContains()
	local rt = RangeTree.new()
	lu.assertFalse(rt:contains(0))

	rt:insert(7, 10)
	rt:insert(1, 3)

	lu.assertTrue(rt:contains(8))
	lu.assertTrue(rt:contains(10))
	lu.assertTrue(rt:contains(1))

	lu.assertFalse(rt:contains(4))
	lu.assertFalse(rt:contains(5))
	lu.assertFalse(rt:contains(11))
end

os.exit(lu.LuaUnit.run())
