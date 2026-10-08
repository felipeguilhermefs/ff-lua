local lu = require("luaunit")
local RadixTree = require("ff.collections.radixtree")
local Array = require("ff.collections.array")
local Set = require("ff.collections.set")

TestRadixTree = {}

function TestRadixTree:testIsRadixTree()
	lu.assertTrue(RadixTree.isRadixTree(RadixTree.new()))
	lu.assertTrue(RadixTree.isRadixTree(RadixTree.new({ "a", "b" })))
	lu.assertFalse(RadixTree.isRadixTree({}))
	lu.assertFalse(RadixTree.isRadixTree(nil))
	lu.assertFalse(RadixTree.isRadixTree("radixtree"))
	lu.assertFalse(RadixTree.isRadixTree(123))
	lu.assertFalse(RadixTree.isRadixTree(true))
end

function TestRadixTree:testConstructor()
	-- Default constructor
	local t = RadixTree.new()
	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)

	-- Constructor with table iterable
	local t2 = RadixTree.new({ "apple", "banana", "apricot" })
	lu.assertFalse(t2:empty())
	lu.assertEquals(#t2, 3)
	lu.assertTrue(t2:contains("apple", true))
	lu.assertTrue(t2:contains("banana", true))
	lu.assertTrue(t2:contains("apricot", true))

	-- Constructor with Array
	local arr = Array.new({ "cat", "dog" })
	local t3 = RadixTree.new(arr)
	lu.assertEquals(#t3, 2)
	lu.assertTrue(t3:contains("cat", true))
	lu.assertTrue(t3:contains("dog", true))

	-- Constructor not caseSensitive
	local tCase = RadixTree.new(nil, false)
	lu.assertEquals(#tCase, 0)
	tCase:insert("Wolf")
	tCase:insert("wolf")
	lu.assertEquals(#tCase, 1)
	lu.assertTrue(tCase:contains("WOLF", true))

	-- Constructor with iterable and not caseSensitive
	local tCaseIterable = RadixTree.new({ "Wolf", "wolf", "WOLF" }, false)
	lu.assertEquals(#tCaseIterable, 1)
	lu.assertTrue(tCaseIterable:contains("wolf", true))

	-- Constructor with another RadixTree
	local tCopy = RadixTree.new(t2)
	lu.assertEquals(#tCopy, 3)
	lu.assertEquals(tCopy == t2, true)

	-- Validation
	lu.assertErrorMsgContains("caseSensitive should be a boolean", RadixTree.new, nil, 123)
	lu.assertErrorMsgContains("caseSensitive should be a boolean", RadixTree.new, nil, "invalid")
end

function TestRadixTree:testEmptyAndClear()
	local t = RadixTree.new()

	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)

	t:insert("apple")
	lu.assertFalse(t:empty())
	lu.assertEquals(#t, 1)

	t:clear()
	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)
	lu.assertFalse(t:contains("apple"))

	-- Re-use after clear
	lu.assertTrue(t:insert("banana"))
	lu.assertEquals(#t, 1)
	lu.assertTrue(t:contains("banana", true))
end

function TestRadixTree:testInsert()
	local t = RadixTree.new()

	-- First insert returns true
	lu.assertTrue(t:insert("cat"))
	lu.assertEquals(#t, 1)

	-- Duplicate insert returns false
	lu.assertFalse(t:insert("cat"))
	lu.assertEquals(#t, 1)

	-- Empty string insert
	lu.assertErrorMsgContains("word should not be an empty string", t.insert, t, "")

	-- Type validations
	lu.assertErrorMsgContains("word should be a string", t.insert, t, true)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, 2)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, nil)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, {})
end

function TestRadixTree:testContains()
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
	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, true)
	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, 2)
	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, nil)
end

function TestRadixTree:testFind()
	local t = RadixTree.new()

	-- Find on empty trie
	local words = t:find("cat")
	lu.assertTrue(words:empty())

	t:insert("cat")
	t:insert("category")
	t:insert("concat")
	t:insert("cataclysm")
	lu.assertEquals(#t, 4)

	-- Exact match returns single word
	words = t:find("cat", true)
	lu.assertEquals(#words, 1)
	lu.assertEquals(words:get(1), "cat")

	-- Bugfix test: exact match when prefix exists but is NOT a stored word
	local tBug = RadixTree.new({ "category", "cataclysm" })
	words = tBug:find("cat", true)
	lu.assertEquals(#words, 0)

	-- Prefix search returns all matching words
	words = t:find("cat")
	lu.assertEquals(#words, 3)
	lu.assertEquals(words:indexOf("cat") == nil, false)
	lu.assertEquals(words:indexOf("category") == nil, false)
	lu.assertEquals(words:indexOf("cataclysm") == nil, false)

	-- Find nothing when prefix is empty
	words = t:find("")
	lu.assertEquals(#words, 0)

	-- Non-existent prefix returns empty Array
	words = t:find("nonexistent")
	lu.assertEquals(#words, 0)

	-- Type validations
	lu.assertErrorMsgContains("prefix should be a string", t.find, t, nil)
	lu.assertErrorMsgContains("prefix should be a string", t.find, t, 123)
	lu.assertErrorMsgContains("prefix should be a string", t.find, t, true)
end

function TestRadixTree:testRemove()
	local t = RadixTree.new()

	-- Removing from empty trie returns false
	lu.assertEquals(t:remove("dog"), 0)
	lu.assertEquals(t:remove("dog", true), 0)

	t:insert("dog")
	t:insert("do")
	t:insert("doodle")
	t:insert("doggy")
	lu.assertEquals(#t, 4)

	-- Remove non-matching word returns false
	lu.assertEquals(t:remove("zebra", true), 0)
	lu.assertEquals(t:remove("zebra", false), 0)
	lu.assertEquals(#t, 4)

	-- Remove exact word that is prefix of another
	lu.assertEquals(t:remove("dog", true), 1)
	lu.assertEquals(#t, 3)
	lu.assertFalse(t:contains("dog", true))
	lu.assertTrue(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	-- Prefix removal deletes all words under "dog"
	t:insert("dog")
	lu.assertEquals(#t, 4)
	lu.assertEquals(t:remove("dog", false), 2)
	lu.assertEquals(#t, 2)
	lu.assertFalse(t:contains("dog", true))
	lu.assertFalse(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	-- Remove exact word "do"
	lu.assertEquals(t:remove("do", true), 1)
	lu.assertFalse(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))
	lu.assertEquals(#t, 1)

	-- Remove final word
	lu.assertEquals(t:remove("doodle", true), 1)
	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)

	-- Remove empty string exact vs prefix
	t:insert("hell")
	t:insert("hello")
	lu.assertEquals(#t, 2)
	lu.assertEquals(t:remove("hell", true), 1)
	lu.assertEquals(#t, 1)
	lu.assertFalse(t:contains("hell", true))
	lu.assertTrue(t:contains("hello", true))

	-- Do not remove when given an empty string
	lu.assertEquals(t:remove("", false), 0)
	lu.assertEquals(#t, 1)

	-- Validations
	lu.assertErrorMsgContains("prefix should be a string", t.remove, t, 123)
	lu.assertErrorMsgContains("prefix should be a string", t.remove, t, nil)
end

function TestRadixTree:testConcat()
	local t = RadixTree.new()

	t = t .. { "mouse", "mousse" }

	lu.assertTrue(t:contains("mouse"))
	lu.assertTrue(t:contains("mousse"))
	lu.assertEquals(#t, 2)

	local t2 = RadixTree.new()
	t2:insert("moose")

	t = t .. t2
	lu.assertTrue(t:contains("mouse"))
	lu.assertTrue(t:contains("mousse"))
	lu.assertTrue(t:contains("moose"))
	lu.assertEquals(#t, 3)

	-- Concat with Set
	local s = Set.new({ "rat", "rabbit" })
	t = t .. s
	lu.assertEquals(#t, 5)
	lu.assertTrue(t:contains("rat", true))
	lu.assertTrue(t:contains("rabbit", true))

	-- Concat with nil
	t = t .. nil
	lu.assertEquals(#t, 5)

	-- Error on invalid type
	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = t .. 123
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = t .. "string"
	end)
end

function TestRadixTree:testEquality()
	local t1 = RadixTree.new({ "apple", "banana", "cherry" })
	local t2 = RadixTree.new({ "cherry", "apple", "banana" })
	local t3 = RadixTree.new({ "apple", "banana" })
	local t4 = RadixTree.new({ "apple", "banana", "citrus" })
	local t5 = RadixTree.new({ "apple", "banana", "cherry" }, false)

	lu.assertEquals(t1 == t2, true)
	lu.assertEquals(t1 == t3, false)
	lu.assertEquals(t1 == t4, false)
	lu.assertEquals(t1 == t5, false) -- Different case sensitivity

	lu.assertEquals(t1 == nil, false)
	lu.assertEquals(t1 == {}, false)
	lu.assertEquals(t1 == "apple", false)
	lu.assertEquals(t1 == 123, false)

	local empty1 = RadixTree.new()
	local empty2 = RadixTree.new()
	lu.assertEquals(empty1 == empty2, true)
end

function TestRadixTree:testLen()
	local t = RadixTree.new()
	lu.assertEquals(#t, 0)

	t:insert("a")
	lu.assertEquals(#t, 1)

	t:insert("ab")
	lu.assertEquals(#t, 2)

	t:insert("ab")
	lu.assertEquals(#t, 2)

	t:remove("ab", true)
	lu.assertEquals(#t, 1)

	t:clear()
	lu.assertEquals(#t, 0)
end

function TestRadixTree:testPairs()
	local t = RadixTree.new({ "alpha", "beta", "gamma" })

	local words = {}
	local count = 0
	for i, word in pairs(t) do
		count = count + 1
		lu.assertEquals(i, count)
		table.insert(words, word)
	end
	table.sort(words)

	lu.assertEquals(count, 3)
	lu.assertEquals(words, { "alpha", "beta", "gamma" })
end

function TestRadixTree:testToString()
	local empty = RadixTree.new()
	lu.assertEquals(tostring(empty), "{  }")

	local t = RadixTree.new({ "dog", "cat", "bird" })
	lu.assertEquals(tostring(t), "{ bird, cat, dog }")
end

function TestRadixTree:testCaseSensitivity()
	local ts = RadixTree.new()

	ts:insert("wolf")
	lu.assertTrue(ts:contains("wo"))
	lu.assertFalse(ts:contains("Wo"))

	ts:insert("Wolf")
	lu.assertTrue(ts:contains("Wo"))
	lu.assertEquals(#ts, 2)

	local ti = RadixTree.new(nil, false)

	ti:insert("wolf")
	lu.assertTrue(ti:contains("wo"))
	lu.assertTrue(ti:contains("Wo"))

	lu.assertFalse(ti:insert("Wolf"))
	lu.assertEquals(#ti, 1)
	lu.assertTrue(ti:contains("WOLF", true))
	lu.assertTrue(ti:contains("wolf", true))
end

function TestRadixTree:testRadix_SplittingAndMerging()
	local t = RadixTree.new()

	-- Complex branch splitting
	lu.assertTrue(t:insert("romane"))
	lu.assertTrue(t:insert("romanus"))
	lu.assertTrue(t:insert("romis"))
	lu.assertTrue(t:insert("rubicon"))
	lu.assertTrue(t:insert("rubicundus"))
	lu.assertTrue(t:insert("rubens"))
	lu.assertEquals(#t, 6)

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
	lu.assertEquals(#t, 7)
	lu.assertTrue(t:contains("roman", true))

	-- Delete exact word that was a split point
	lu.assertEquals(t:remove("roman", true), 1)
	lu.assertEquals(#t, 6)
	lu.assertFalse(t:contains("roman", true))
	lu.assertTrue(t:contains("romane", true))
	lu.assertTrue(t:contains("romanus", true))

	-- Delete one branch causing edge collapse/merge
	lu.assertEquals(t:remove("romis", true), 1)
	lu.assertEquals(#t, 5)
	lu.assertTrue(t:contains("romane", true))
	lu.assertTrue(t:contains("romanus", true))

	-- Delete all "ro" words by prefix
	lu.assertEquals(t:remove("ro", false), 2)
	lu.assertEquals(#t, 3)
	lu.assertFalse(t:contains("ro"))
	lu.assertFalse(t:contains("romane", true))
	lu.assertFalse(t:contains("romanus", true))
	lu.assertTrue(t:contains("rubicon", true))
	lu.assertTrue(t:contains("rubicundus", true))
	lu.assertTrue(t:contains("rubens", true))
end

function TestRadixTree:testRadix_PrefixRemoval()
	local t = RadixTree.new({ "test", "testing", "tester", "team", "toast" })
	lu.assertEquals(#t, 5)

	-- Prefix remove "test" removes "test", "testing", "tester"
	lu.assertEquals(t:remove("test", false), 3)
	lu.assertEquals(#t, 2)
	lu.assertFalse(t:contains("test", true))
	lu.assertFalse(t:contains("testing", true))
	lu.assertFalse(t:contains("tester", true))
	lu.assertTrue(t:contains("team", true))
	lu.assertTrue(t:contains("toast", true))

	-- Find on remaining
	local words = t:find("t")
	lu.assertEquals(#words, 2)

	-- Remove non-existent prefix
	lu.assertEquals(t:remove("xyz", false), 0)
	lu.assertEquals(#t, 2)
end

function TestRadixTree:testRadix_LongSharedPrefixes()
	local t = RadixTree.new({
		"internationalization",
		"international",
		"internet",
		"internal",
	})
	lu.assertEquals(#t, 4)

	-- Partial prefix queries
	local words = t:find("intern")
	lu.assertEquals(#words, 4)

	words = t:find("interna")
	lu.assertEquals(#words, 3)

	words = t:find("internat")
	lu.assertEquals(#words, 2)

	words = t:find("international")
	lu.assertEquals(#words, 2)

	words = t:find("internationali")
	lu.assertEquals(#words, 1)
	lu.assertEquals(words:get(1), "internationalization")

	-- Remove intermediate exact word
	lu.assertEquals(t:remove("international", true), 1)
	lu.assertEquals(#t, 3)
	lu.assertFalse(t:contains("international", true))
	lu.assertTrue(t:contains("internationalization", true))
	lu.assertTrue(t:contains("internet", true))
	lu.assertTrue(t:contains("internal", true))
end

function TestRadixTree:testRadix_SingleCharacterWords()
	local t = RadixTree.new({ "a", "ab", "abc", "abcd", "b", "ba", "bc" })
	lu.assertEquals(#t, 7)

	lu.assertEquals(t:remove("a", true), 1)
	lu.assertEquals(#t, 6)
	lu.assertFalse(t:contains("a", true))
	lu.assertTrue(t:contains("ab", true))
	lu.assertTrue(t:contains("abc", true))
	lu.assertTrue(t:contains("abcd", true))

	lu.assertEquals(t:remove("ab", true), 1)
	lu.assertEquals(#t, 5)
	lu.assertFalse(t:contains("ab", true))
	lu.assertTrue(t:contains("abc", true))
	lu.assertTrue(t:contains("abcd", true))
end

function TestRadixTree:testNewIndex_PreventsModifications()
	local rt = RadixTree.new()

	-- disallow adding properties
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to RadixTree", function()
		rt.foo = "bar"
	end)

	-- disallow adding numeric indices
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to RadixTree", function()
		rt[1] = 99
	end)

	-- disallow adding methods or functions
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to RadixTree", function()
		rt.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to RadixTree", function()
		rt.insert = function() end
	end)
end

