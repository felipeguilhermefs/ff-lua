local lu = require("luaunit")
local RadixTree = require("ff.collections.radixtree")
local Array = require("ff.collections.array")
local Set = require("ff.collections.set")

local append = table.insert

local TestRadixTree = {}

function TestRadixTree:testTypeGuard_RecognizesRadixTreesAndRejectsOtherValues()
	lu.assertTrue(RadixTree.isRadixTree(RadixTree.new()))
	lu.assertTrue(RadixTree.isRadixTree(RadixTree.new({ "a", "b" })))
	lu.assertFalse(RadixTree.isRadixTree({}))
	lu.assertFalse(RadixTree.isRadixTree(nil))
	lu.assertFalse(RadixTree.isRadixTree("radixtree"))
	lu.assertFalse(RadixTree.isRadixTree(123))
	lu.assertFalse(RadixTree.isRadixTree(true))
end

function TestRadixTree:testConstructor_PreservesInsertedWords()
	local t = RadixTree.new()

	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)

	local t2 = RadixTree.new({ "apple", "banana", "apricot" })
	lu.assertFalse(t2:empty())
	lu.assertEquals(#t2, 3)
	lu.assertTrue(t2:contains("apple", true))
	lu.assertTrue(t2:contains("banana", true))
	lu.assertTrue(t2:contains("apricot", true))

	local arr = Array.new({ "cat", "dog" })
	local t3 = RadixTree.new(arr)
	lu.assertEquals(#t3, 2)
	lu.assertTrue(t3:contains("cat", true))
	lu.assertTrue(t3:contains("dog", true))

	local tCase = RadixTree.new(nil, false)
	lu.assertEquals(#tCase, 0)
	tCase:insert("Wolf")
	tCase:insert("wolf")
	lu.assertEquals(#tCase, 1)
	lu.assertTrue(tCase:contains("WOLF", true))

	local tCaseIterable = RadixTree.new({ "Wolf", "wolf", "WOLF" }, false)
	lu.assertEquals(#tCaseIterable, 1)
	lu.assertTrue(tCaseIterable:contains("wolf", true))

	local tCopy = RadixTree.new(t2)
	lu.assertEquals(#tCopy, 3)
	lu.assertTrue(tCopy == t2)

	lu.assertErrorMsgContains("caseSensitive should be a boolean", RadixTree.new, nil, 123)
	lu.assertErrorMsgContains("caseSensitive should be a boolean", RadixTree.new, nil, "invalid")
end

function TestRadixTree:testContains_ReportsInsertedWordsAndRejectsMissingWords()
	local t = RadixTree.new()

	lu.assertFalse(t:contains("cat"))
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

	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, true)
	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, 2)
	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, nil)
end

function TestRadixTree:testFind_ReturnsWordsMatchingPrefix()
	local t = RadixTree.new()

	local words = t:find("cat")

	lu.assertTrue(words:empty())

	t:insert("cat")
	t:insert("category")
	t:insert("concat")
	t:insert("cataclysm")
	lu.assertEquals(#t, 4)

	words = t:find("cat", true)
	lu.assertEquals(#words, 1)
	lu.assertEquals(words:get(1), "cat")

	local tBug = RadixTree.new({ "category", "cataclysm" })
	words = tBug:find("cat", true)
	lu.assertEquals(#words, 0)

	words = t:find("cat")
	lu.assertEquals(#words, 3)
	lu.assertNotNil(words:indexOf("cat"))
	lu.assertNotNil(words:indexOf("category"))
	lu.assertNotNil(words:indexOf("cataclysm"))

	words = t:find("")
	lu.assertEquals(#words, 0)
	words = t:find("nonexistent")
	lu.assertEquals(#words, 0)

	lu.assertErrorMsgContains("prefix should be a string", t.find, t, nil)
	lu.assertErrorMsgContains("prefix should be a string", t.find, t, 123)
	lu.assertErrorMsgContains("prefix should be a string", t.find, t, true)
end

function TestRadixTree:testWordLookup_IsCaseSensitive()
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

function TestRadixTree:testIteration_YieldsStoredWords()
	local t = RadixTree.new({ "alpha", "beta", "gamma" })

	local words = {}
	local count = 0

	for i, word in pairs(t) do
		count = count + 1

		lu.assertEquals(i, count)
		append(words, word)
	end
	lu.assertEquals(count, 3)
	lu.assertItemsEquals(words, { "alpha", "beta", "gamma" })
end

function TestRadixTree:testClear_RemovesAllWordsAndAllowsReuse()
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

	lu.assertTrue(t:insert("banana"))
	lu.assertEquals(#t, 1)
	lu.assertTrue(t:contains("banana", true))
end

function TestRadixTree:testInsert_AddsWordsAndRejectsDuplicates()
	local t = RadixTree.new()

	lu.assertTrue(t:insert("cat"))
	lu.assertEquals(#t, 1)

	lu.assertFalse(t:insert("cat"))
	lu.assertEquals(#t, 1)

	lu.assertErrorMsgContains("word should not be an empty string", t.insert, t, "")

	lu.assertErrorMsgContains("word should be a string", t.insert, t, true)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, 2)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, nil)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, {})
end

function TestRadixTree:testRemove_DeletesWordsAndPreservesOtherWords()
	local t = RadixTree.new()

	lu.assertEquals(t:remove("dog"), 0)
	lu.assertEquals(t:remove("dog", true), 0)

	t:insert("dog")
	t:insert("do")
	t:insert("doodle")
	t:insert("doggy")

	lu.assertEquals(t:remove("zebra", true), 0)
	lu.assertEquals(t:remove("zebra", false), 0)
	lu.assertEquals(#t, 4)

	local removedDog = t:remove("dog", true)

	lu.assertEquals(removedDog, 1)
	lu.assertEquals(#t, 3)
	lu.assertFalse(t:contains("dog", true))
	lu.assertTrue(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	t:insert("dog")
	local removedPrefix = t:remove("dog", false)

	lu.assertEquals(removedPrefix, 2)
	lu.assertEquals(#t, 2)
	lu.assertFalse(t:contains("dog", true))
	lu.assertFalse(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	local removedDo = t:remove("do", true)
	local removedDoodle = t:remove("doodle", true)

	lu.assertEquals(removedDo, 1)
	lu.assertEquals(removedDoodle, 1)
	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)

	t:insert("hell")
	t:insert("hello")
	local removedHell = t:remove("hell", true)
	local removedEmpty = t:remove("", false)

	lu.assertEquals(removedHell, 1)
	lu.assertEquals(removedEmpty, 0)
	lu.assertEquals(#t, 1)
	lu.assertFalse(t:contains("hell", true))
	lu.assertTrue(t:contains("hello", true))

	lu.assertErrorMsgContains("prefix should be a string", t.remove, t, 123)
	lu.assertErrorMsgContains("prefix should be a string", t.remove, t, nil)
end

function TestRadixTree:testInsertAndRemove_SplitAndMergeSharedPrefixes()
	local t = RadixTree.new()

	lu.assertTrue(t:insert("romane"))
	lu.assertTrue(t:insert("romanus"))
	lu.assertTrue(t:insert("romis"))
	lu.assertTrue(t:insert("rubicon"))
	lu.assertTrue(t:insert("rubicundus"))
	lu.assertTrue(t:insert("rubens"))
	lu.assertEquals(#t, 6)

	lu.assertTrue(t:contains("ro"))
	lu.assertTrue(t:contains("rom"))
	lu.assertTrue(t:contains("roman"))
	lu.assertTrue(t:contains("romane"))
	lu.assertTrue(t:contains("romanus"))
	lu.assertTrue(t:contains("rub"))
	lu.assertTrue(t:contains("rubi"))
	lu.assertTrue(t:contains("rubic"))

	lu.assertFalse(t:contains("rox"))
	lu.assertFalse(t:contains("roma_"))
	lu.assertFalse(t:contains("rubez"))

	lu.assertFalse(t:contains("roman", true))
	lu.assertFalse(t:contains("rub", true))
	lu.assertTrue(t:contains("romane", true))
	lu.assertTrue(t:contains("romanus", true))

	lu.assertTrue(t:insert("roman"))
	lu.assertEquals(#t, 7)
	lu.assertTrue(t:contains("roman", true))

	lu.assertEquals(t:remove("roman", true), 1)
	lu.assertEquals(#t, 6)
	lu.assertFalse(t:contains("roman", true))
	lu.assertTrue(t:contains("romane", true))
	lu.assertTrue(t:contains("romanus", true))

	lu.assertEquals(t:remove("romis", true), 1)
	lu.assertEquals(#t, 5)
	lu.assertTrue(t:contains("romane", true))
	lu.assertTrue(t:contains("romanus", true))

	lu.assertEquals(t:remove("ro", false), 2)
	lu.assertEquals(#t, 3)
	lu.assertFalse(t:contains("ro"))
	lu.assertFalse(t:contains("romane", true))
	lu.assertFalse(t:contains("romanus", true))
	lu.assertTrue(t:contains("rubicon", true))
	lu.assertTrue(t:contains("rubicundus", true))
	lu.assertTrue(t:contains("rubens", true))
end

function TestRadixTree:testRemovingPrefixWord_PreservesLongerWords()
	local t = RadixTree.new({ "test", "testing", "tester", "team", "toast" })

	lu.assertEquals(#t, 5)

	lu.assertEquals(t:remove("test", false), 3)
	lu.assertEquals(#t, 2)
	lu.assertFalse(t:contains("test", true))
	lu.assertFalse(t:contains("testing", true))
	lu.assertFalse(t:contains("tester", true))
	lu.assertTrue(t:contains("team", true))
	lu.assertTrue(t:contains("toast", true))

	local words = t:find("t")
	lu.assertEquals(#words, 2)

	lu.assertEquals(t:remove("xyz", false), 0)
	lu.assertEquals(#t, 2)
end

function TestRadixTree:testLongSharedPrefixes_RemainSearchable()
	local t = RadixTree.new({
		"internationalization",
		"international",
		"internet",
		"internal",
	})

	lu.assertEquals(#t, 4)

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

	lu.assertEquals(t:remove("international", true), 1)
	lu.assertEquals(#t, 3)
	lu.assertFalse(t:contains("international", true))
	lu.assertTrue(t:contains("internationalization", true))
	lu.assertTrue(t:contains("internet", true))
	lu.assertTrue(t:contains("internal", true))
end

function TestRadixTree:testSingleCharacterWords_RemainSearchable()
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

function TestRadixTree:testConcat_AppendsWordsFromIterableValues()
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

	local s = Set.new({ "rat", "rabbit" })
	t = t .. s

	lu.assertEquals(#t, 5)
	lu.assertTrue(t:contains("rat", true))
	lu.assertTrue(t:contains("rabbit", true))

	t = t .. nil

	lu.assertEquals(#t, 5)

	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = t .. 123
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = t .. "string"
	end)
end

function TestRadixTree:testRadixTreesWithSameWords_CompareEqual()
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

function TestRadixTree:testLength_TracksInsertedAndRemovedWords()
	local t = RadixTree.new()
	lu.assertEquals(#t, 0)

	t:insert("a")

	lu.assertEquals(#t, 1)

	t:insert("ab")
	t:insert("ab")

	lu.assertEquals(#t, 2)

	t:remove("ab", true)

	lu.assertEquals(#t, 1)

	t:clear()

	lu.assertEquals(#t, 0)
end

function TestRadixTree:testToString_FormatsStoredWords()
	local empty = RadixTree.new()

	lu.assertEquals(tostring(empty), "{  }")

	local t = RadixTree.new({ "dog", "cat", "bird" })
	lu.assertEquals(tostring(t), "{ bird, cat, dog }")
end

function TestRadixTree:testNewPropertiesAndMethods_CannotBeAddedOrReplaced()
	local rt = RadixTree.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to RadixTree", function()
		rt.foo = "bar"
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to RadixTree", function()
		rt[1] = 99
	end)

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to RadixTree", function()
		rt.myFunc = function() end
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to RadixTree", function()
		rt.insert = function() end
	end)
end

return { TestRadixTree = TestRadixTree }
