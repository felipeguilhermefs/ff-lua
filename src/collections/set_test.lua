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
	lu.assertTrue(set:contains("d", "c"))
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
	lu.assertFalse(set:contains())
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

	local setDiff3 = set1:diff(Set.new())
	lu.assertTrue(setDiff3:contains("a", "b", "c"))
	lu.assertEquals(3, #setDiff3)
end

function TestIntersection()
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	local setInter1 = set1:intersection(set2)
	lu.assertTrue(setInter1:contains("b", "c"))
	lu.assertEquals(2, #setInter1)

	local setInter2 = set2:intersection(set1)
	lu.assertTrue(setInter2:contains("b", "c"))
	lu.assertEquals(2, #setInter2)

	local setInter3 = set1:intersection(Set.new())
	lu.assertEquals(0, #setInter3)
end

function TestUnion()
	local set1 = Set.new({ "a", "b", "c" })
	local set2 = Set.new({ "b", "c", "d" })

	local setUnion1 = set1:union(set2)
	lu.assertTrue(setUnion1:contains("a", "b", "c", "d"))
	lu.assertEquals(4, #setUnion1)

	local setUnion2 = set2:union(set1)
	lu.assertTrue(setUnion2:contains("a", "b", "c", "d"))
	lu.assertEquals(4, #setUnion2)

	local setUnion3 = set1:union(Set.new())
	lu.assertTrue(setUnion3:contains("a", "b", "c"))
	lu.assertEquals(3, #setUnion3)
end

function TestIterator()
	local set = Set.new({ 1, 2, 3, 4, 5 })

	local res = {}
	for item in pairs(set) do
		table.insert(res, item)
	end
	table.sort(res)

	lu.assertEquals({ 1, 2, 3, 4, 5 }, res)
end

function TestConcat()
	local set = Set.new({ 10, 20, 30 })
	lu.assertEquals(3, #set)

	set = set .. { 40, 50, 60 }

	lu.assertTrue(set:contains(10, 20, 30, 40, 50, 60))
	lu.assertEquals(6, #set)

	set = set .. nil
	lu.assertEquals(6, #set)

	set = set .. Set.new({ 70, 80, 90 })
	lu.assertTrue(set:contains(70, 80, 90))
	lu.assertEquals(9, #set)

	local q = require("queue").new()
	q:enqueue(100)
	set = set .. q

	lu.assertTrue(set:contains(100))
	lu.assertEquals(10, #set)
end

function TestIsSet()
	lu.assertTrue(Set.isSet(Set.new()))
	lu.assertTrue(Set.isSet(Set.new({ 1, 2, 3 })))
	lu.assertFalse(Set.isSet({ 1, 2, 3 }))
	lu.assertFalse(Set.isSet(nil))
	lu.assertFalse(Set.isSet("set"))
	lu.assertFalse(Set.isSet(123))
end

function TestBooleanValues()
	local set = Set.new()
	lu.assertTrue(set:add(false))
	lu.assertEquals(1, #set)
	lu.assertTrue(set:contains(false))

	lu.assertFalse(set:add(false))
	lu.assertEquals(1, #set)

	lu.assertTrue(set:remove(false))
	lu.assertEquals(0, #set)
	lu.assertFalse(set:contains(false))
	lu.assertFalse(set:remove(false))
end

function TestSymmetricDiff()
	local set1 = Set.new({ 1, 2, 3, 4 })
	local set2 = Set.new({ 3, 4, 5, 6 })

	local sym = set1:symdiff(set2)
	lu.assertEquals(4, #sym)
	lu.assertTrue(sym:contains(1, 2, 5, 6))
	lu.assertFalse(sym:contains(3))
	lu.assertFalse(sym:contains(4))
end

function TestSubsetSupersetDisjoint()
	local sub = Set.new({ 1, 2 })
	local super = Set.new({ 1, 2, 3, 4 })
	local other = Set.new({ 5, 6 })

	lu.assertTrue(sub:subset(super))
	lu.assertFalse(super:subset(sub))
	lu.assertTrue(super:superset(sub))
	lu.assertFalse(sub:superset(super))

	lu.assertTrue(sub:disjoint(other))
	lu.assertFalse(sub:disjoint(super))
end

function TestEquals()
	local s1 = Set.new({ 1, 2, 3 })
	local s2 = Set.new({ 3, 2, 1 })
	local s3 = Set.new({ 1, 2, 4 })
	local s4 = Set.new({ 1, 2 })

	lu.assertTrue(s1 == s2)
	lu.assertFalse(s1 == s3)
	lu.assertFalse(s1 == s4)

	lu.assertFalse(s1 == { 1, 2, 3 })
	lu.assertFalse(s1 == nil)
	lu.assertFalse(s1 == 42)
end

function TestToString()
	local set = Set.new({ "hello", 123, true })
	local str = tostring(set)

	lu.assertTrue(str:find("hello") ~= nil)
	lu.assertTrue(str:find("123") ~= nil)
	lu.assertTrue(str:find("true") ~= nil)
end

os.exit(lu.LuaUnit.run())
