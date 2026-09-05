local lu = require("luaunit")
local RadixTree = require("radixtree")
local Array = require("ff.collections.array")
local Set = require("ff.collections.set")

function TestIsRadixTree()
	lu.assertTrue(RadixTree.isRadixTree(RadixTree.new()))
	lu.assertTrue(RadixTree.isRadixTree(RadixTree.new({ "a", "b" })))
	lu.assertFalse(RadixTree.isRadixTree({}))
	lu.assertFalse(RadixTree.isRadixTree(nil))
	lu.assertFalse(RadixTree.isRadixTree("radixtree"))
	lu.assertFalse(RadixTree.isRadixTree(123))
	lu.assertFalse(RadixTree.isRadixTree(true))
end

function TestConstructor()
	-- Default constructor
	local t = RadixTree.new()
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)

	-- Constructor with table iterable
	local t2 = RadixTree.new({ "apple", "banana", "apricot" })
	lu.assertFalse(t2:empty())
	lu.assertEquals(3, #t2)
	lu.assertTrue(t2:contains("apple", true))
	lu.assertTrue(t2:contains("banana", true))
	lu.assertTrue(t2:contains("apricot", true))

	-- Constructor with Array
	local arr = Array.new({ "cat", "dog" })
	local t3 = RadixTree.new(arr)
	lu.assertEquals(2, #t3)
	lu.assertTrue(t3:contains("cat", true))
	lu.assertTrue(t3:contains("dog", true))

	-- Constructor not caseSensitive
	local tCase = RadixTree.new(nil, false)
	lu.assertEquals(0, #tCase)
	tCase:insert("Wolf")
	tCase:insert("wolf")
	lu.assertEquals(1, #tCase)
	lu.assertTrue(tCase:contains("WOLF", true))

	-- Constructor with iterable and not caseSensitive
	local tCaseIterable = RadixTree.new({ "Wolf", "wolf", "WOLF" }, false)
	lu.assertEquals(1, #tCaseIterable)
	lu.assertTrue(tCaseIterable:contains("wolf", true))

	-- Constructor with another RadixTree
	local tCopy = RadixTree.new(t2)
	lu.assertEquals(3, #tCopy)
	lu.assertTrue(tCopy == t2)

	-- Validation
	lu.assertError(RadixTree.new, nil, 123)
	lu.assertError(RadixTree.new, nil, "invalid")
end

function TestEmptyAndClear()
	local t = RadixTree.new()

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
	local t = RadixTree.new()

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
	local t = RadixTree.new()

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
	lu.assertFalse(t:contains(""))
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
	local t = RadixTree.new()

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
	lu.assertEquals("cat", words:get(1))

	-- Bugfix test: exact match when prefix exists but is NOT a stored word
	local tBug = RadixTree.new({ "category", "cataclysm" })
	words = tBug:find("cat", true)
	lu.assertEquals(0, #words)

	-- Prefix search returns all matching words
	words = t:find("cat")
	lu.assertEquals(3, #words)
	lu.assertFalse(words:indexOf("cat") == nil)
	lu.assertFalse(words:indexOf("category") == nil)
	lu.assertFalse(words:indexOf("cataclysm") == nil)

	-- Find nothing when prefix is empty
	words = t:find("")
	lu.assertEquals(0, #words)

	-- Non-existent prefix returns empty Array
	words = t:find("nonexistent")
	lu.assertEquals(0, #words)

	-- Type validations
	lu.assertError(t.find, t, nil)
	lu.assertError(t.find, t, 123)
	lu.assertError(t.find, t, true)
end

function TestRemove()
	local t = RadixTree.new()

	-- Removing from empty trie returns false
	lu.assertEquals(0, t:remove("dog"))
	lu.assertEquals(0, t:remove("dog", true))

	t:insert("dog")
	t:insert("do")
	t:insert("doodle")
	t:insert("doggy")
	lu.assertEquals(4, #t)

	-- Remove non-matching word returns false
	lu.assertEquals(0, t:remove("zebra", true))
	lu.assertEquals(0, t:remove("zebra", false))
	lu.assertEquals(4, #t)

	-- Remove exact word that is prefix of another
	lu.assertEquals(1, t:remove("dog", true))
	lu.assertEquals(3, #t)
	lu.assertFalse(t:contains("dog", true))
	lu.assertTrue(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	-- Prefix removal deletes all words under "dog"
	t:insert("dog")
	lu.assertEquals(4, #t)
	lu.assertEquals(2, t:remove("dog", false))
	lu.assertEquals(2, #t)
	lu.assertFalse(t:contains("dog", true))
	lu.assertFalse(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	-- Remove exact word "do"
	lu.assertEquals(1, t:remove("do", true))
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))
	lu.assertEquals(1, #t)

	-- Remove final word
	lu.assertEquals(1, t:remove("doodle", true))
	lu.assertTrue(t:empty())
	lu.assertEquals(0, #t)

	-- Remove empty string exact vs prefix
	t:insert("hell")
	t:insert("hello")
	lu.assertEquals(2, #t)
	lu.assertEquals(1, t:remove("hell", true))
	lu.assertEquals(1, #t)
	lu.assertFalse(t:contains("hell", true))
	lu.assertTrue(t:contains("hello", true))

	-- Do not remove when given an empty string
	lu.assertEquals(0, t:remove("", false))
	lu.assertEquals(1, #t)

	-- Validations
	lu.assertError(t.remove, t, 123)
	lu.assertError(t.remove, t, nil)
end

function TestConcat()
	local t = RadixTree.new()

	t = t .. { "mouse", "mousse" }

	lu.assertTrue(t:contains("mouse"))
	lu.assertTrue(t:contains("mousse"))
	lu.assertEquals(2, #t)

	local t2 = RadixTree.new()
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
	local t1 = RadixTree.new({ "apple", "banana", "cherry" })
	local t2 = RadixTree.new({ "cherry", "apple", "banana" })
	local t3 = RadixTree.new({ "apple", "banana" })
	local t4 = RadixTree.new({ "apple", "banana", "citrus" })
	local t5 = RadixTree.new({ "apple", "banana", "cherry" }, false)

	lu.assertTrue(t1 == t2)
	lu.assertFalse(t1 == t3)
	lu.assertFalse(t1 == t4)
	lu.assertFalse(t1 == t5) -- Different case sensitivity

	lu.assertFalse(t1 == nil)
	lu.assertFalse(t1 == {})
	lu.assertFalse(t1 == "apple")
	lu.assertFalse(t1 == 123)

	local empty1 = RadixTree.new()
	local empty2 = RadixTree.new()
	lu.assertTrue(empty1 == empty2)
end

function TestLen()
	local t = RadixTree.new()
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
	local t = RadixTree.new({ "alpha", "beta", "gamma" })

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
	local empty = RadixTree.new()
	lu.assertEquals("{  }", tostring(empty))

	local t = RadixTree.new({ "dog", "cat", "bird" })
	lu.assertEquals("{ bird, cat, dog }", tostring(t))
end

function TestCaseSensitivity()
	local ts = RadixTree.new()

	ts:insert("wolf")
	lu.assertTrue(ts:contains("wo"))
	lu.assertFalse(ts:contains("Wo"))

	ts:insert("Wolf")
	lu.assertTrue(ts:contains("Wo"))
	lu.assertEquals(2, #ts)

	local ti = RadixTree.new(nil, false)

	ti:insert("wolf")
	lu.assertTrue(ti:contains("wo"))
	lu.assertTrue(ti:contains("Wo"))

	lu.assertFalse(ti:insert("Wolf"))
	lu.assertEquals(1, #ti)
	lu.assertTrue(ti:contains("WOLF", true))
	lu.assertTrue(ti:contains("wolf", true))
end

function TestRadixSplittingAndMerging()
	local t = RadixTree.new()

	-- Complex branch splitting
	lu.assertTrue(t:insert("romane"))
	lu.assertTrue(t:insert("romanus"))
	lu.assertTrue(t:insert("romis"))
	lu.assertTrue(t:insert("rubicon"))
	lu.assertTrue(t:insert("rubicundus"))
	lu.assertTrue(t:insert("rubens"))
	lu.assertEquals(6, #t)

	-- Prefix contains checks
	lu.assertTrue(t:contains("ro"))
	lu.assertTrue(t:contains("rom"))
	lu.assertTrue(t:contains("roman"))
	lu.assertTrue(t:contains("romane"))
	lu.assertTrue(t:contains("romanus"))
	lu.assertTrue(t:contains("rub"))
	lu.assertTrue(t:contains("rubi"))
	lu.assertTrue(t:contains("rubic"))

	-- Non-existent prefix checks
	lu.assertFalse(t:contains("rox"))
	lu.assertFalse(t:contains("roma_"))
	lu.assertFalse(t:contains("rubez"))

	-- Exact checks
	lu.assertFalse(t:contains("roman", true))
	lu.assertFalse(t:contains("rub", true))
	lu.assertTrue(t:contains("romane", true))
	lu.assertTrue(t:contains("romanus", true))

	-- Insert intermediate prefix as a word
	lu.assertTrue(t:insert("roman"))
	lu.assertEquals(7, #t)
	lu.assertTrue(t:contains("roman", true))

	-- Delete exact word that was a split point
	lu.assertEquals(1, t:remove("roman", true))
	lu.assertEquals(6, #t)
	lu.assertFalse(t:contains("roman", true))
	lu.assertTrue(t:contains("romane", true))
	lu.assertTrue(t:contains("romanus", true))

	-- Delete one branch causing edge collapse/merge
	lu.assertEquals(1, t:remove("romis", true))
	lu.assertEquals(5, #t)
	lu.assertTrue(t:contains("romane", true))
	lu.assertTrue(t:contains("romanus", true))

	-- Delete all "ro" words by prefix
	lu.assertEquals(2, t:remove("ro", false))
	lu.assertEquals(3, #t)
	lu.assertFalse(t:contains("ro"))
	lu.assertFalse(t:contains("romane", true))
	lu.assertFalse(t:contains("romanus", true))
	lu.assertTrue(t:contains("rubicon", true))
	lu.assertTrue(t:contains("rubicundus", true))
	lu.assertTrue(t:contains("rubens", true))
end

function TestRadixPrefixRemoval()
	local t = RadixTree.new({ "test", "testing", "tester", "team", "toast" })
	lu.assertEquals(5, #t)

	-- Prefix remove "test" removes "test", "testing", "tester"
	lu.assertEquals(3, t:remove("test", false))
	lu.assertEquals(2, #t)
	lu.assertFalse(t:contains("test", true))
	lu.assertFalse(t:contains("testing", true))
	lu.assertFalse(t:contains("tester", true))
	lu.assertTrue(t:contains("team", true))
	lu.assertTrue(t:contains("toast", true))

	-- Find on remaining
	local words = t:find("t")
	lu.assertEquals(2, #words)

	-- Remove non-existent prefix
	lu.assertEquals(0, t:remove("xyz", false))
	lu.assertEquals(2, #t)
end

function TestRadixLongSharedPrefixes()
	local t = RadixTree.new({
		"internationalization",
		"international",
		"internet",
		"internal",
	})
	lu.assertEquals(4, #t)

	-- Partial prefix queries
	local words = t:find("intern")
	lu.assertEquals(4, #words)

	words = t:find("interna")
	lu.assertEquals(3, #words)

	words = t:find("internat")
	lu.assertEquals(2, #words)

	words = t:find("international")
	lu.assertEquals(2, #words)

	words = t:find("internationali")
	lu.assertEquals(1, #words)
	lu.assertEquals("internationalization", words:get(1))

	-- Remove intermediate exact word
	lu.assertEquals(1, t:remove("international", true))
	lu.assertEquals(3, #t)
	lu.assertFalse(t:contains("international", true))
	lu.assertTrue(t:contains("internationalization", true))
	lu.assertTrue(t:contains("internet", true))
	lu.assertTrue(t:contains("internal", true))
end

function TestRadixSingleCharacterWords()
	local t = RadixTree.new({ "a", "ab", "abc", "abcd", "b", "ba", "bc" })
	lu.assertEquals(7, #t)

	lu.assertEquals(1, t:remove("a", true))
	lu.assertEquals(6, #t)
	lu.assertFalse(t:contains("a", true))
	lu.assertTrue(t:contains("ab", true))
	lu.assertTrue(t:contains("abc", true))
	lu.assertTrue(t:contains("abcd", true))

	lu.assertEquals(1, t:remove("ab", true))
	lu.assertEquals(5, #t)
	lu.assertFalse(t:contains("ab", true))
	lu.assertTrue(t:contains("abc", true))
	lu.assertTrue(t:contains("abcd", true))
end

os.exit(lu.LuaUnit.run())
