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

function TestOverwrite()
	local t = RadixTree.new()

	-- Insert with overwrite = false
	local old1 = t:insert("apple", 1, false)
	lu.assertNil(old1)
	lu.assertEquals(1, #t)

	-- Try inserting again with overwrite = false
	local old2 = t:insert("apple", 2, false)
	lu.assertEquals(1, old2)
	lu.assertEquals(1, #t)
	lu.assertEquals(1, t:find("apple", true):get(1))

	-- Insert with overwrite = true (default)
	local old3 = t:insert("apple", 3)
	lu.assertEquals(1, old3)
	lu.assertEquals(1, #t)
	lu.assertEquals(3, t:find("apple", true):get(1))
end

function TestPrefixRemoval()
	local t = RadixTree.new()

	t:insert("apple", 1)
	t:insert("application", 2)
	t:insert("apricot", 3)
	t:insert("banana", 4)
	lu.assertEquals(4, #t)

	-- Remove prefix "app" (non-exact removal)
	t:remove("app", false)

	-- Should remove "apple" and "application", but keep "apricot" and "banana"
	lu.assertFalse(t:contains("apple"))
	lu.assertFalse(t:contains("application"))
	lu.assertTrue(t:contains("apricot"))
	lu.assertTrue(t:contains("banana"))
	lu.assertEquals(2, #t)

	-- Let's remove prefix "ap"
	t:remove("ap", false)
	lu.assertFalse(t:contains("apricot"))
	lu.assertTrue(t:contains("banana"))
	lu.assertEquals(1, #t)
end

function TestAssertions()
	local t = RadixTree.new()

	-- Key type validation
	lu.assertErrorMsgContains("Key should be a string", t.insert, t, 123, 1)
	lu.assertErrorMsgContains("Key should be a string", t.insert, t, nil, 1)

	-- Empty key validation
	lu.assertErrorMsgContains("Key should not be empty", t.insert, t, "", 1)

	-- Value cannot be nil validation
	lu.assertErrorMsgContains("Value should not be nil", t.insert, t, "key", nil)
end

function TestPairsIterator()
	local t = RadixTree.new()
	t:insert("apple", 1)
	t:insert("banana", 2)
	t:insert("orange", 3)

	local found = {}
	for _, v in pairs(t) do
		found[v] = true
	end

	lu.assertEquals(3, #t)
	lu.assertTrue(found[1])
	lu.assertTrue(found[2])
	lu.assertTrue(found[3])
end

function TestPrettyPrint()
	local t = RadixTree.new()
	t:insert("apple", 1)
	t:insert("application", 2)

	local expected = '[Root]\n└── "appl"\n    ├── "e" (value: 1)\n    └── "ication" (value: 2)\n'
	lu.assertEquals(expected, t:prettyPrint())
end

os.exit(lu.LuaUnit.run())
