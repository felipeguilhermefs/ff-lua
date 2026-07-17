local lu = require("luaunit")

local RadixTree = require("radixtree")

function TestEmpty()
	local t = RadixTree.new()

	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)

	t:insert("apple", 1)
	lu.assertFalse(t:empty())
	lu.assertEquals(1, #t)

	t:remove("apple", true)
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)
end

function TestBasic()
	local t = RadixTree.new()

	t:insert("dog", 1)
	lu.assertTrue(t:contains("dog"))
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("do"))
	lu.assertEquals(1, #t)

	t:insert("do", 2)
	lu.assertTrue(t:contains("dog"))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("do"))
	lu.assertEquals(2, #t)

	t:insert("doodle", 3)
	t:insert("doggy", 4)
	lu.assertTrue(t:contains("doggy"))
	lu.assertTrue(t:contains("doodle"))
	lu.assertEquals(4, #t)

	t:remove("dog", true)
	lu.assertFalse(t:contains("dog", true))
	lu.assertTrue(t:contains("doggy"))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle"))
	lu.assertEquals(3, #t)

	t:remove("do", true)
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("doodle"))
	lu.assertEquals(2, #t)

	t:remove("doggy", true)
	lu.assertFalse(t:contains("doggy", true))
	lu.assertTrue(t:contains("doodle"))
	lu.assertEquals(1, #t)

	t:remove("doodle", true)
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)
end

function TestFind()
	local t = RadixTree.new()

	local results = t:find("cat")
	lu.assertEquals(0, #results)

	t:insert("cat", 10)
	t:insert("category", 20)
	t:insert("cataclysm", 30)
	lu.assertEquals(3, #t)

	results = t:find("cat", true)
	lu.assertEquals(1, #results)
	lu.assertEquals(10, results:get(1))

	results = t:find("cat")
	lu.assertEquals(3, #results)
	lu.assertFalse(results:indexOf(10) == nil)
	lu.assertFalse(results:indexOf(20) == nil)
	lu.assertFalse(results:indexOf(30) == nil)
end

function TestSplitAndMerge()
	local t = RadixTree.new()

	t:insert("test", 1)
	t:insert("team", 2)

	lu.assertTrue(t:contains("test", true))
	lu.assertTrue(t:contains("team", true))
	lu.assertTrue(t:contains("te", false))
	lu.assertEquals(2, #t)

	t:insert("tea", 3)
	lu.assertTrue(t:contains("tea", true))
	lu.assertEquals(3, #t)

	t:remove("tea", true)
	lu.assertFalse(t:contains("tea", true))
	lu.assertTrue(t:contains("team", true))
	lu.assertEquals(2, #t)
end

function TestCaseInsensitive()
	local t = RadixTree.new(false)

	t:insert("Apple", 1)
	lu.assertTrue(t:contains("apple", true))
	lu.assertTrue(t:contains("APPLE", true))

	t:insert("app", 2)
	lu.assertEquals(2, #t)

	local results = t:find("APP")
	lu.assertEquals(2, #results)
end

function TestMergeOnRemove()
	local t = RadixTree.new()

	t:insert("apple", 1)
	t:insert("apply", 2)

	-- Structure should be: root -> "appl" -> ("e", 1), ("y", 2)

	t:remove("apple", true)

	-- Now "appl" node has only one child "y".
	-- It should be merged into root -> "apply" (value 2)

	lu.assertTrue(t:contains("apply", true))
	lu.assertFalse(t:contains("apple", true))
	lu.assertEquals(1, #t)

	t:insert("application", 3)
	-- root -> "appl" -> ("y", 2), ("ication", 3)
	lu.assertTrue(t:contains("apply", true))
	lu.assertTrue(t:contains("application", true))
	lu.assertEquals(2, #t)
end

os.exit(lu.LuaUnit.run())
