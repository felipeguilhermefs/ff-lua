local lu = require("luaunit")
local Trie = require("trie")

function TestEmpty()
	local t = Trie.new()

	lu.assertTrue(t:empty())

	t:insert("apple")
	lu.assertFalse(t:empty())

	t:remove("apple")
	lu.assertTrue(t:empty())
end

function TestBasic()
	local t = Trie.new()

	t:insert("dog")
	lu.assertTrue(t:contains("dog"))
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("do"))

	t:insert("do")
	lu.assertTrue(t:contains("dog"))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("do"))

	t:insert("doodle")
	t:insert("doggy")
	lu.assertTrue(t:contains("doggy"))
	lu.assertTrue(t:contains("doodle"))

	t:remove("dog")
	lu.assertFalse(t:contains("doggy"))
	lu.assertFalse(t:contains("dog"))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle"))

	t:remove("do", true)
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("doodle"))

	t:remove("doodle", true)
	lu.assertTrue(t:empty())
end

function TestFind()
	local t = Trie.new()

	local words = t:find("cat")
	lu.assertTrue(words:empty())

	t:insert("cat")
	t:insert("category")
	t:insert("concat")
	t:insert("cataclysm")

	words = t:find("cat", true)
	lu.assertEquals(1, #words)
	lu.assertEquals("cat", words:get(1))

	words = t:find("cat")
	lu.assertEquals(3, #words)
	lu.assertFalse(words:indexOf("cat") == nil)
	lu.assertFalse(words:indexOf("category") == nil)
	lu.assertFalse(words:indexOf("cataclysm") == nil)
end

function TestConcat()
	local t = Trie.new()

	t = t .. { 1, "mouse", true, "mousse" }

	lu.assertTrue(t:contains("mouse"))
	lu.assertTrue(t:contains("mousse"))

	local t2 = Trie.new()
	t2:insert("moose")

	t = t .. t2
	lu.assertTrue(t:contains("mouse"))
	lu.assertTrue(t:contains("mousse"))
	lu.assertTrue(t:contains("moose"))

	t:remove("mo")
	lu.assertTrue(t:empty())
end

function TestString()
	local t = Trie.new()

	lu.assertError(t.insert, t, true)
	lu.assertError(t.insert, t, 2)
	lu.assertError(t.insert, t, nil)

	lu.assertError(t.contains, t, true)
	lu.assertError(t.contains, t, 2)
	lu.assertError(t.contains, t, nil)
end

os.exit(lu.LuaUnit.run())
