local lu = require("luaunit")
local Trie = require("trie")
local Array = require("ff.collections.array")
local Set = require("ff.collections.set")

function TestIsTrie()
	lu.assertTrue(Trie.isTrie(Trie.new()))
	lu.assertTrue(Trie.isTrie(Trie.new({ "a", "b" })))
	lu.assertFalse(Trie.isTrie({}))
	lu.assertFalse(Trie.isTrie(nil))
	lu.assertFalse(Trie.isTrie("trie"))
	lu.assertFalse(Trie.isTrie(123))
	lu.assertFalse(Trie.isTrie(true))
end

function TestConstructor()
	-- Default constructor
	local t = Trie.new()
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)

	-- Constructor with table iterable
	local t2 = Trie.new({ "apple", "banana", "apricot" })
	lu.assertFalse(t2:empty())
	lu.assertEquals(3, #t2)
	lu.assertTrue(t2:contains("apple", true))
	lu.assertTrue(t2:contains("banana", true))
	lu.assertTrue(t2:contains("apricot", true))

	-- Constructor with Array
	local arr = Array.new({ "cat", "dog" })
	local t3 = Trie.new(arr)
	lu.assertEquals(2, #t3)
	lu.assertTrue(t3:contains("cat", true))
	lu.assertTrue(t3:contains("dog", true))

	-- Constructor with boolean caseSensitive
	local tCase = Trie.new(nil, false)
	lu.assertEquals(0, #tCase)
	tCase:insert("Wolf")
	tCase:insert("wolf")
	lu.assertEquals(1, #tCase)
	lu.assertTrue(tCase:contains("WOLF", true))

	-- Constructor with iterable and caseSensitive false
	local tCaseIterable = Trie.new({ "Wolf", "wolf", "WOLF" }, false)
	lu.assertEquals(1, #tCaseIterable)
	lu.assertTrue(tCaseIterable:contains("wolf", true))

	-- Constructor with another Trie
	local tCopy = Trie.new(t2)
	lu.assertEquals(3, #tCopy)
	lu.assertTrue(tCopy == t2)

	-- Validation
	lu.assertError(Trie.new, nil, 123)
	lu.assertError(Trie.new, nil, "invalid")
end

function TestEmptyAndClear()
	local t = Trie.new()

	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)

	t:insert("apple")
	lu.assertFalse(t:empty())
	lu.assertEquals(1, #t)

	t:clear()
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)
	lu.assertFalse(t:contains("apple"))

	-- Re-use after clear
	lu.assertTrue(t:insert("banana"))
	lu.assertEquals(1, #t)
	lu.assertTrue(t:contains("banana", true))
end

function TestInsert()
	local t = Trie.new()

	-- First insert returns true
	lu.assertTrue(t:insert("cat"))
	lu.assertEquals(1, #t)

	-- Duplicate insert returns false
	lu.assertFalse(t:insert("cat"))
	lu.assertEquals(1, #t)

	-- Empty string insert
	lu.assertError(t.insert, t, "")

	-- Type validations
	lu.assertError(t.insert, t, true)
	lu.assertError(t.insert, t, 2)
	lu.assertError(t.insert, t, nil)
	lu.assertError(t.insert, t, {})
end

function TestContains()
	local t = Trie.new()

	-- Empty trie contains behavior
	lu.assertFalse(t:contains("cat"))
	lu.assertFalse(t:contains("cat", true))
	lu.assertFalse(t:contains(""))
	lu.assertFalse(t:contains("", true))

	t:insert("cat")
	lu.assertTrue(t:contains("cat"))
	lu.assertTrue(t:contains("cat", true))
	lu.assertTrue(t:contains("ca"))
	lu.assertFalse(t:contains("ca", true))
	lu.assertTrue(t:contains("c"))
	lu.assertFalse(t:contains("c", true))
	lu.assertFalse(t:contains("dog"))
	lu.assertTrue(t:contains(""))
	lu.assertFalse(t:contains("", true))

	t:insert("category")
	lu.assertTrue(t:contains("category", true))
	lu.assertTrue(t:contains("cate"))
	lu.assertFalse(t:contains("cate", true))

	-- Type assertions
	lu.assertError(t.contains, t, true)
	lu.assertError(t.contains, t, 2)
	lu.assertError(t.contains, t, nil)
end

function TestFind()
	local t = Trie.new()

	-- Find on empty trie
	local words = t:find("cat")
	lu.assertTrue(words:empty())

	t:insert("cat")
	t:insert("category")
	t:insert("concat")
	t:insert("cataclysm")
	lu.assertEquals(4, #t)

	-- Exact match returns single word
	words = t:find("cat", true)
	lu.assertEquals(1, #words)
	lu.assertEquals("cat", words[1])

	-- Bugfix test: exact match when prefix exists but is NOT a stored word
	local tBug = Trie.new({ "category", "cataclysm" })
	words = tBug:find("cat", true)
	lu.assertEquals(0, #words)

	-- Prefix search returns all matching words
	words = t:find("cat")
	lu.assertEquals(3, #words)
	lu.assertFalse(words:indexOf("cat") == nil)
	lu.assertFalse(words:indexOf("category") == nil)
	lu.assertFalse(words:indexOf("cataclysm") == nil)

	-- Find all words when prefix is empty or nil
	words = t:find("")
	lu.assertEquals(4, #words)

	words = t:find()
	lu.assertEquals(4, #words)

	-- Non-existent prefix returns empty Array
	words = t:find("nonexistent")
	lu.assertEquals(0, #words)

	-- Type validations
	lu.assertError(t.find, t, 123)
	lu.assertError(t.find, t, true)
end

function TestRemove()
	local t = Trie.new()

	-- Removing from empty trie returns false
	lu.assertFalse(t:remove("dog"))
	lu.assertFalse(t:remove("dog", true))

	t:insert("dog")
	t:insert("do")
	t:insert("doodle")
	t:insert("doggy")
	lu.assertEquals(4, #t)

	-- Remove non-matching word returns false
	lu.assertFalse(t:remove("zebra", true))
	lu.assertFalse(t:remove("zebra", false))
	lu.assertEquals(4, #t)

	-- Remove exact word that is prefix of another
	lu.assertTrue(t:remove("dog", true))
	lu.assertEquals(3, #t)
	lu.assertFalse(t:contains("dog", true))
	lu.assertTrue(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	-- Prefix removal deletes all words under "dog"
	t:insert("dog")
	lu.assertEquals(4, #t)
	lu.assertTrue(t:remove("dog", false))
	lu.assertEquals(2, #t)
	lu.assertFalse(t:contains("dog", true))
	lu.assertFalse(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	-- Remove exact word "do"
	lu.assertTrue(t:remove("do", true))
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))
	lu.assertEquals(1, #t)

	-- Remove final word
	lu.assertTrue(t:remove("doodle", true))
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)

	-- Remove empty string exact vs prefix
	t:insert("hell")
	t:insert("hello")
	lu.assertEquals(2, #t)
	lu.assertTrue(t:remove("hell", true))
	lu.assertEquals(1, #t)
	lu.assertFalse(t:contains("hell", true))
	lu.assertTrue(t:contains("hello", true))

	-- Validations
	lu.assertError(t.remove, t, "")
	lu.assertError(t.remove, t, 123)
	lu.assertError(t.remove, t, nil)
end

function TestConcat()
	local t = Trie.new()

	t = t .. { "mouse", "mousse" }

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

	-- Concat with Set
	local s = Set.new({ "rat", "rabbit" })
	t = t .. s
	lu.assertEquals(5, #t)
	lu.assertTrue(t:contains("rat", true))
	lu.assertTrue(t:contains("rabbit", true))

	-- Concat with nil
	t = t .. nil
	lu.assertEquals(5, #t)

	-- Error on invalid type
	lu.assertError(function()
		local _ = t .. 123
	end)
	lu.assertError(function()
		local _ = t .. "string"
	end)
end

function TestEquality()
	local t1 = Trie.new({ "apple", "banana", "cherry" })
	local t2 = Trie.new({ "cherry", "apple", "banana" })
	local t3 = Trie.new({ "apple", "banana" })
	local t4 = Trie.new({ "apple", "banana", "citrus" })
	local t5 = Trie.new({ "apple", "banana", "cherry" }, false)

	lu.assertTrue(t1 == t2)
	lu.assertFalse(t1 == t3)
	lu.assertFalse(t1 == t4)
	lu.assertFalse(t1 == t5) -- Different case sensitivity

	lu.assertFalse(t1 == nil)
	lu.assertFalse(t1 == {})
	lu.assertFalse(t1 == "apple")
	lu.assertFalse(t1 == 123)

	local empty1 = Trie.new()
	local empty2 = Trie.new()
	lu.assertTrue(empty1 == empty2)
end

function TestLen()
	local t = Trie.new()
	lu.assertEquals(0, #t)

	t:insert("a")
	lu.assertEquals(1, #t)

	t:insert("ab")
	lu.assertEquals(2, #t)

	t:insert("ab")
	lu.assertEquals(2, #t)

	t:remove("ab", true)
	lu.assertEquals(1, #t)

	t:clear()
	lu.assertEquals(0, #t)
end

function TestPairs()
	local t = Trie.new({ "alpha", "beta", "gamma" })

	local words = {}
	local count = 0
	for i, word in pairs(t) do
		count = count + 1
		lu.assertEquals(count, i)
		table.insert(words, word)
	end
	table.sort(words)

	lu.assertEquals(3, count)
	lu.assertEquals({ "alpha", "beta", "gamma" }, words)
end

function TestToString()
	local empty = Trie.new()
	lu.assertEquals("{  }", tostring(empty))

	local t = Trie.new({ "dog", "cat", "bird" })
	lu.assertEquals("{ bird, cat, dog }", tostring(t))
end

function TestCaseSensitivity()
	local ts = Trie.new()

	ts:insert("wolf")
	lu.assertTrue(ts:contains("wo"))
	lu.assertFalse(ts:contains("Wo"))

	ts:insert("Wolf")
	lu.assertTrue(ts:contains("Wo"))
	lu.assertEquals(2, #ts)

	local ti = Trie.new(nil, false)

	ti:insert("wolf")
	lu.assertTrue(ti:contains("wo"))
	lu.assertTrue(ti:contains("Wo"))

	lu.assertFalse(ti:insert("Wolf"))
	lu.assertEquals(1, #ti)
	lu.assertTrue(ti:contains("WOLF", true))
	lu.assertTrue(ti:contains("wolf", true))
end

os.exit(lu.LuaUnit.run())
