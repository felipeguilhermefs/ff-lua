local lu = require("luaunit")
local Trie = require("trie")

function TestEmpty()
	local t = Trie.new()

	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)

	t:insert("apple")
	lu.assertFalse(t:empty())
	lu.assertEquals(1, #t)

	t:remove("apple")
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)
end

function TestBasic()
	local t = Trie.new()

	t:insert("dog")
	lu.assertTrue(t:contains("dog"))
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("do"))
	lu.assertEquals(1, #t)

	t:insert("do")
	lu.assertTrue(t:contains("dog"))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("do"))
	lu.assertEquals(2, #t)

	t:insert("doodle")
	t:insert("doggy")
	lu.assertTrue(t:contains("doggy"))
	lu.assertTrue(t:contains("doodle"))
	lu.assertEquals(4, #t)

	t:remove("dog")
	lu.assertFalse(t:contains("doggy"))
	lu.assertFalse(t:contains("dog"))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle"))
	lu.assertEquals(2, #t)

	t:remove("do", true)
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("doodle"))
	lu.assertEquals(1, #t)

	t:remove("doodle", true)
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)
end

function TestFind()
	local t = Trie.new()

	local words = t:find("cat")
	lu.assertTrue(words:empty())

	t:insert("cat")
	t:insert("category")
	t:insert("concat")
	t:insert("cataclysm")
	lu.assertEquals(4, #t)

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
	lu.assertEquals(2, #t)

	local t2 = Trie.new()
	t2:insert("moose")

	t = t .. t2
	lu.assertTrue(t:contains("mouse"))
	lu.assertTrue(t:contains("mousse"))
	lu.assertTrue(t:contains("moose"))
	lu.assertEquals(3, #t)

	t:remove("mo")
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)
end

function TestString()
	local t = Trie.new()

	lu.assertError(t.insert, t, true)
	lu.assertError(t.insert, t, 2)
	lu.assertError(t.insert, t, nil)

	lu.assertError(t.contains, t, true)
	lu.assertError(t.contains, t, 2)
	lu.assertError(t.contains, t, nil)

	lu.assertEquals(0, #t)
end

os.exit(lu.LuaUnit.run())
