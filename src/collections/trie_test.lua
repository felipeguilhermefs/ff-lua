local lu = require("luaunit")
local Trie = require("trie")

function TestEmpty()
	local t = Trie.new()

	lu.assertTrue(t:empty())

	t:insert("apple")
	lu.assertFalse(t:empty())
end

function TestBasic()
	local t = Trie.new()

	t:insert("dog")
	lu.assertTrue(t:contains("dog"))
	lu.assertFalse(t:contains("do"))
	lu.assertTrue(t:contains("do", true))

	t:insert("do")
	lu.assertTrue(t:contains("dog"))
	lu.assertTrue(t:contains("do"))
	lu.assertTrue(t:contains("do", true))
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
