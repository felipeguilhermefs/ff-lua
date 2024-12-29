local lu = require("luaunit")
local Set = require("set")

function TestEmpty()
	local set = Set.new()
	lu.assertTrue(set:empty())

	set:add("a")
	lu.assertFalse(set:empty())

	set:clear()
	lu.assertTrue(set:empty())
end

function TestAdd()
	local set = Set.new()

	lu.assertTrue(set:add("c"))
	lu.assertTrue(set:contains("c"))

	lu.assertFalse(set:add("c"))
	lu.assertTrue(set:contains("c"))

	lu.assertTrue(set:add("d"))
	lu.assertTrue(set:contains("d"))
	lu.assertTrue(set:contains("c"))
end

function TestContains()
	local set = Set.new()

	lu.assertFalse(set:contains("e"))

	set:add("e")
	lu.assertTrue(set:contains("e"))

	set:remove("e")
	lu.assertFalse(set:contains("e"))

	set:add("f")
	set:add("g")
	set:add("h")

	lu.assertTrue(set:contains("f", "g", "h"))
	lu.assertTrue(set:contains("f", "h"))
	lu.assertFalse(set:contains("f", "i"))
end

function TestRemove()
	local set = Set.new({ "f", "g" })
	lu.assertEquals(2, #set)

	set:remove("f")

	lu.assertFalse(set:contains("f"))
	lu.assertTrue(set:contains("g"))

	lu.assertEquals(1, #set)
end

function TestDiff()
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	local setDiff1 = set1:diff(set2)
	lu.assertTrue(setDiff1:contains("a"))
	lu.assertEquals(1, #setDiff1)

	local setDiff2 = set2:diff(set1)
	lu.assertTrue(setDiff2:contains("d"))
	lu.assertEquals(1, #setDiff2)

	local setNil = set1:diff(nil)
	lu.assertTrue(setNil:contains("a"))
	lu.assertTrue(setNil:contains("b"))
	lu.assertTrue(setNil:contains("c"))
	lu.assertEquals(3, #setNil)
end

function TestIntersection()
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	local setInter1 = set1:intersection(set2)
	lu.assertTrue(setInter1:contains("b"))
	lu.assertTrue(setInter1:contains("c"))
	lu.assertEquals(2, #setInter1)

	local setInter2 = set2:intersection(set1)
	lu.assertTrue(setInter2:contains("b"))
	lu.assertTrue(setInter2:contains("c"))
	lu.assertEquals(2, #setInter2)

	local setNil = set1:intersection(nil)
	lu.assertEquals(0, #setNil)
end

function TestUnion()
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	local setUnion1 = set1:union(set2)
	lu.assertTrue(setUnion1:contains("a"))
	lu.assertTrue(setUnion1:contains("b"))
	lu.assertTrue(setUnion1:contains("c"))
	lu.assertTrue(setUnion1:contains("d"))
	lu.assertEquals(4, #setUnion1)

	local setUnion2 = set2:union(set1)
	lu.assertTrue(setUnion2:contains("a"))
	lu.assertTrue(setUnion2:contains("b"))
	lu.assertTrue(setUnion2:contains("c"))
	lu.assertTrue(setUnion2:contains("d"))
	lu.assertEquals(4, #setUnion2)

	local setNil = set1:union(nil)
	lu.assertTrue(setNil:contains("a"))
	lu.assertTrue(setNil:contains("b"))
	lu.assertTrue(setNil:contains("c"))
	lu.assertEquals(3, #setNil)
end

function TestIterator()
	local set = Set.new()

	set:add("a")
	set:add("b")
	set:add("c")
	set:add("d")

	local res = {}
	for item in pairs(set) do
		table.insert(res, item)
	end
	table.sort(res)

	lu.assertEquals({ "a", "b", "c", "d" }, res)
end

function TestNil()
	local set = Set.new()

	set:add(nil)
	lu.assertFalse(set:contains(nil))

	lu.assertEquals(0, #set)
	set:remove(nil)
	lu.assertEquals(0, #set)
end

function TestConcat()
	local set = Set.new({ 10, 20, 30 })
	lu.assertEquals(3, #set)

	set = set .. { 40, 50, 60 }

	lu.assertTrue(set:contains(10))
	lu.assertTrue(set:contains(20))
	lu.assertTrue(set:contains(30))
	lu.assertTrue(set:contains(40))
	lu.assertTrue(set:contains(50))
	lu.assertTrue(set:contains(60))
	lu.assertEquals(6, #set)

	set = set .. nil
	lu.assertEquals(6, #set)

	set = set .. Set.new({ 70, 80, 90 })
	lu.assertTrue(set:contains(70))
	lu.assertTrue(set:contains(80))
	lu.assertTrue(set:contains(90))
	lu.assertEquals(9, #set)

	local q = require("queue").new()
	q:enqueue(100)
	set = set .. q

	lu.assertTrue(set:contains(100))
	lu.assertEquals(10, #set)
end

os.exit(lu.LuaUnit.run())
