-- Imports
local lu = require("luaunit")
local RadixTree = require("ff.collections.radixtree")
local Array = require("ff.collections.array")
local Set = require("ff.collections.set")

-- Suite definitions
local TestRadixTree = {}

-- Scenarios: construction and type recognition

function TestRadixTree:testTypeGuard_Recognizes_RadixTreesAndRejectsOtherValues()
	-- Given: candidates include a RadixTree, a table, and scalars.
	-- When: check each candidate with RadixTree.isRadixTree.
	-- Then: only the RadixTree instance returns true.
	lu.assertTrue(RadixTree.isRadixTree(RadixTree.new()))
	lu.assertTrue(RadixTree.isRadixTree(RadixTree.new({ "a", "b" })))
	lu.assertFalse(RadixTree.isRadixTree({}))
	lu.assertFalse(RadixTree.isRadixTree(nil))
	lu.assertFalse(RadixTree.isRadixTree("radixtree"))
	lu.assertFalse(RadixTree.isRadixTree(123))
	lu.assertFalse(RadixTree.isRadixTree(true))
end

function TestRadixTree:testConstructor_Preserves_InsertedWords()
	-- Given: table input has apple, banana, apricot; Array input has cat, dog.
	-- When: construct a RadixTree without arguments.
	local t = RadixTree.new()

	-- Then: the no-argument tree has no words.
	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)

	-- When: construct from the table of three words.
	local t2 = RadixTree.new({ "apple", "banana", "apricot" })
	-- Then: all three table words are searchable.
	lu.assertFalse(t2:empty())
	lu.assertEquals(#t2, 3)
	lu.assertTrue(t2:contains("apple", true))
	lu.assertTrue(t2:contains("banana", true))
	lu.assertTrue(t2:contains("apricot", true))

	-- When: construct from the Array containing cat and dog.
	local arr = Array.new({ "cat", "dog" })
	local t3 = RadixTree.new(arr)
	-- Then: both Array words are searchable.
	lu.assertEquals(#t3, 2)
	lu.assertTrue(t3:contains("cat", true))
	lu.assertTrue(t3:contains("dog", true))

	-- When: construct case-insensitive tree and insert Wolf with two casings.
	local tCase = RadixTree.new(nil, false)
	lu.assertEquals(#tCase, 0)
	tCase:insert("Wolf")
	tCase:insert("wolf")
	-- Then: casings share one entry and WOLF matches it.
	lu.assertEquals(#tCase, 1)
	lu.assertTrue(tCase:contains("WOLF", true))

	-- When: construct a case-insensitive tree from three casing variants.
	local tCaseIterable = RadixTree.new({ "Wolf", "wolf", "WOLF" }, false)
	-- Then: variants collapse into one searchable entry.
	lu.assertEquals(#tCaseIterable, 1)
	lu.assertTrue(tCaseIterable:contains("wolf", true))

	-- When: copy the table-backed tree into a new RadixTree.
	local tCopy = RadixTree.new(t2)
	-- Then: the copy has three entries and compares equal to its source.
	lu.assertEquals(#tCopy, 3)
	-- This assertion exercises RadixTree.__eq; assertEquals compares table structure.
	lu.assertTrue(tCopy == t2)

	-- When: pass non-boolean values for caseSensitive.
	-- Then: both constructor calls report the caseSensitive validation error.
	lu.assertErrorMsgContains("caseSensitive should be a boolean", RadixTree.new, nil, 123)
	lu.assertErrorMsgContains("caseSensitive should be a boolean", RadixTree.new, nil, "invalid")
end

-- Scenarios: reads and inspection

function TestRadixTree:testContains_ReportsInsertedWords_AndRejectsMissingWords()
	-- Given: the RadixTree starts empty.
	local t = RadixTree.new()

	-- When: check cat and empty-string membership before insertion.
	-- Then: every query returns false on the empty tree.
	lu.assertFalse(t:contains("cat"))
	lu.assertFalse(t:contains(""))
	lu.assertFalse(t:contains("", true))

	-- When: insert "cat" and check exact and prefix queries.
	t:insert("cat")

	-- Then: exact and prefix modes distinguish stored words from prefixes.
	lu.assertTrue(t:contains("cat"))
	lu.assertTrue(t:contains("cat", true))
	lu.assertTrue(t:contains("ca"))
	lu.assertFalse(t:contains("ca", true))
	lu.assertTrue(t:contains("c"))
	lu.assertFalse(t:contains("c", true))
	lu.assertFalse(t:contains("dog"))
	lu.assertFalse(t:contains(""))
	lu.assertFalse(t:contains("", true))

	-- When: insert "category" and check word and prefix queries.
	t:insert("category")

	-- Then: full word matches exactly; prefix matches only in prefix mode.
	lu.assertTrue(t:contains("category", true))
	lu.assertTrue(t:contains("cate"))
	lu.assertFalse(t:contains("cate", true))

	-- When: pass non-string prefixes to contains.
	-- Then: each query reports that prefix must be a string.
	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, true)
	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, 2)
	lu.assertErrorMsgContains("prefix should be a string", t.contains, t, nil)
end

function TestRadixTree:testFind_Returns_WordsMatchingPrefix()
	-- Given: the RadixTree starts empty; cat-related words are used for lookup.
	local t = RadixTree.new()

	-- When: search empty tree for prefix cat.
	local words = t:find("cat")

	-- Then: no words are returned.
	lu.assertTrue(words:empty())

	-- When: insert four words, then find exact word cat.
	t:insert("cat")
	t:insert("category")
	t:insert("concat")
	t:insert("cataclysm")
	lu.assertEquals(#t, 4)

	-- Then: exact lookup returns cat alone.
	words = t:find("cat", true)
	lu.assertEquals(#words, 1)
	lu.assertEquals(words:get(1), "cat")

	-- When: request exact match for cat in a tree containing only longer words.
	local tBug = RadixTree.new({ "category", "cataclysm" })
	words = tBug:find("cat", true)
	-- Then: no exact word is returned for that prefix.
	lu.assertEquals(#words, 0)

	-- When: request prefix matches for cat.
	words = t:find("cat")
	-- Then: cat, category, and cataclysm are returned; concat is excluded.
	lu.assertEquals(#words, 3)
	lu.assertNotNil(words:indexOf("cat"))
	lu.assertNotNil(words:indexOf("category"))
	lu.assertNotNil(words:indexOf("cataclysm"))

	-- When: request an empty prefix and a prefix absent from the tree.
	words = t:find("")
	lu.assertEquals(#words, 0)
	words = t:find("nonexistent")
	-- Then: both searches return empty Arrays.
	lu.assertEquals(#words, 0)

	-- When: call find with nil, a number, and a boolean prefix.
	-- Then: each call reports that prefix must be a string.
	lu.assertErrorMsgContains("prefix should be a string", t.find, t, nil)
	lu.assertErrorMsgContains("prefix should be a string", t.find, t, 123)
	lu.assertErrorMsgContains("prefix should be a string", t.find, t, true)
end

function TestRadixTree:testWordLookup_Is_CaseSensitive()
	-- Given: default and case-insensitive trees will store wolf and Wolf.
	local ts = RadixTree.new()

	-- When: insert lowercase wolf into the default tree.
	ts:insert("wolf")

	-- Then: lowercase prefix matches and uppercase prefix does not.
	lu.assertTrue(ts:contains("wo"))
	lu.assertFalse(ts:contains("Wo"))

	-- When: insert uppercase Wolf into the default tree.
	ts:insert("Wolf")
	-- Then: both spellings occupy separate entries and match their casing.
	lu.assertTrue(ts:contains("Wo"))
	lu.assertEquals(#ts, 2)

	-- When: insert both casings into a case-insensitive tree.
	local ti = RadixTree.new(nil, false)

	ti:insert("wolf")
	lu.assertTrue(ti:contains("wo"))
	lu.assertTrue(ti:contains("Wo"))

	lu.assertFalse(ti:insert("Wolf"))
	-- Then: case variants share one entry and either casing finds it.
	lu.assertEquals(#ti, 1)
	lu.assertTrue(ti:contains("WOLF", true))
	lu.assertTrue(ti:contains("wolf", true))
end

function TestRadixTree:testIteration_Yields_StoredWords()
	-- Given: the tree contains three words.
	local t = RadixTree.new({ "alpha", "beta", "gamma" })

	local words = {}
	local count = 0

	-- When: collect words yielded by pairs.
	for i, word in pairs(t) do
		count = count + 1

		-- Then: the collected values include each stored word.
		lu.assertEquals(i, count)
		table.insert(words, word)
	end
	lu.assertEquals(count, 3)
	lu.assertItemsEquals(words, { "alpha", "beta", "gamma" })
end

-- Scenarios: state changes

function TestRadixTree:testClear_RemovesAllWords_AndAllowsReuse()
	-- Given: the RadixTree starts empty.
	local t = RadixTree.new()

	-- When: inspect the new tree.
	-- Then: it reports empty with length zero.
	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)

	-- When: insert apple, then clear the tree.
	t:insert("apple")
	lu.assertFalse(t:empty())
	lu.assertEquals(#t, 1)

	t:clear()
	-- Then: apple is gone and length returns to zero.
	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)
	lu.assertFalse(t:contains("apple"))

	-- When: insert banana after clear.
	lu.assertTrue(t:insert("banana"))
	-- Then: the reused tree contains only banana.
	lu.assertEquals(#t, 1)
	lu.assertTrue(t:contains("banana", true))
end

function TestRadixTree:testInsert_AddsWords_AndRejectsDuplicates()
	-- Given: the RadixTree is empty; cat is the word to insert twice.
	local t = RadixTree.new()

	-- When: insert cat for the first time.
	lu.assertTrue(t:insert("cat"))
	-- Then: insertion succeeds and length becomes one.
	lu.assertEquals(#t, 1)

	-- When: insert cat again.
	lu.assertFalse(t:insert("cat"))
	-- Then: duplicate insertion does not change length.
	lu.assertEquals(#t, 1)

	-- When: insert an empty string and non-string values.
	-- Then: each input reports its specific validation error.
	lu.assertErrorMsgContains("word should not be an empty string", t.insert, t, "")

	lu.assertErrorMsgContains("word should be a string", t.insert, t, true)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, 2)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, nil)
	lu.assertErrorMsgContains("word should be a string", t.insert, t, {})
end

function TestRadixTree:testRemove_DeletesWords_AndPreservesOtherWords()
	-- Given: an empty RadixTree.
	local t = RadixTree.new()

	-- When: attempt removal on empty tree.
	-- Then: remove returns 0.
	lu.assertEquals(t:remove("dog"), 0)
	lu.assertEquals(t:remove("dog", true), 0)

	-- When: insert words "dog", "do", "doodle", "doggy" and attempt removing non-matching "zebra".
	t:insert("dog")
	t:insert("do")
	t:insert("doodle")
	t:insert("doggy")

	-- Then: non-matching removal returns 0 and size remains 4.
	lu.assertEquals(t:remove("zebra", true), 0)
	lu.assertEquals(t:remove("zebra", false), 0)
	lu.assertEquals(#t, 4)

	-- When: remove exact word "dog" that is a prefix of "doggy".
	local removedDog = t:remove("dog", true)

	-- Then: only "dog" is removed while "doggy", "do", and "doodle" remain.
	lu.assertEquals(removedDog, 1)
	lu.assertEquals(#t, 3)
	lu.assertFalse(t:contains("dog", true))
	lu.assertTrue(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	-- When: re-insert "dog" and perform prefix removal on "dog".
	t:insert("dog")
	local removedPrefix = t:remove("dog", false)

	-- Then: all words under "dog" are deleted.
	lu.assertEquals(removedPrefix, 2)
	lu.assertEquals(#t, 2)
	lu.assertFalse(t:contains("dog", true))
	lu.assertFalse(t:contains("doggy", true))
	lu.assertTrue(t:contains("do", true))
	lu.assertTrue(t:contains("doodle", true))

	-- When: remove exact words "do" and "doodle".
	local removedDo = t:remove("do", true)
	local removedDoodle = t:remove("doodle", true)

	-- Then: both words are removed and tree becomes empty.
	lu.assertEquals(removedDo, 1)
	lu.assertEquals(removedDoodle, 1)
	lu.assertTrue(t:empty())
	lu.assertEquals(#t, 0)

	-- When: insert "hell" and "hello", then remove exact word "hell" and empty string.
	t:insert("hell")
	t:insert("hello")
	local removedHell = t:remove("hell", true)
	local removedEmpty = t:remove("", false)

	-- Then: "hell" is removed, empty string removal does nothing, and "hello" remains.
	lu.assertEquals(removedHell, 1)
	lu.assertEquals(removedEmpty, 0)
	lu.assertEquals(#t, 1)
	lu.assertFalse(t:contains("hell", true))
	lu.assertTrue(t:contains("hello", true))

	-- Validations
	lu.assertErrorMsgContains("prefix should be a string", t.remove, t, 123)
	lu.assertErrorMsgContains("prefix should be a string", t.remove, t, nil)
end

function TestRadixTree:testInsertAndRemove_SplitAndMerge_SharedPrefixes()
	-- Given: the RadixTree is empty; input words share ro-, rom-, and rub- prefixes.
	local t = RadixTree.new()

	-- Complex branch splitting

	-- When: insert and remove words through the shared-prefix branches.
	-- Then: all remaining words stay searchable as nodes split and merge.
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

function TestRadixTree:testRemovingPrefixWord_Preserves_LongerWords()
	-- Given: the tree contains one word that prefixes longer stored words.
	local t = RadixTree.new({ "test", "testing", "tester", "team", "toast" })

	-- When: remove only the prefix word.
	-- Then: longer words remain stored and searchable.
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

function TestRadixTree:testLongSharedPrefixes_Remain_Searchable()
	-- Given: several words share a long initial sequence of characters.
	local t = RadixTree.new({
		"internationalization",
		"international",
		"internet",
		"internal",
	})

	-- When: look up each complete word.
	-- Then: every word remains searchable after path compression.
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

function TestRadixTree:testSingleCharacterWords_Remain_Searchable()
	-- Given: the tree includes words made of one character and longer forms.
	local t = RadixTree.new({ "a", "ab", "abc", "abcd", "b", "ba", "bc" })

	-- When: look up each single-character word.
	-- Then: each one-character entry remains searchable.
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

-- Scenarios: metamethods and formatting

function TestRadixTree:testConcat_Appends_WordsFromIterableValues()
	-- Given: an empty RadixTree.
	local t = RadixTree.new()

	-- When: concatenate with table of words.
	t = t .. { "mouse", "mousse" }

	-- Then: words are present and length is 2.
	lu.assertTrue(t:contains("mouse"))
	lu.assertTrue(t:contains("mousse"))
	lu.assertEquals(#t, 2)

	-- When: concatenate with another RadixTree containing "moose".
	local t2 = RadixTree.new()
	t2:insert("moose")
	t = t .. t2

	-- Then: all words are present and length is 3.
	lu.assertTrue(t:contains("mouse"))
	lu.assertTrue(t:contains("mousse"))
	lu.assertTrue(t:contains("moose"))
	lu.assertEquals(#t, 3)

	-- When: concatenate with a Set containing "rat" and "rabbit".
	local s = Set.new({ "rat", "rabbit" })
	t = t .. s

	-- Then: all five words are present and length is 5.
	lu.assertEquals(#t, 5)
	lu.assertTrue(t:contains("rat", true))
	lu.assertTrue(t:contains("rabbit", true))

	-- When: concatenate with nil.
	t = t .. nil

	-- Then: tree contents and length remain unchanged.
	lu.assertEquals(#t, 5)

	-- When: concatenate with non-table types.
	-- Then: each operation raises an iterable table type error.
	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = t .. 123
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = t .. "string"
	end)
end

function TestRadixTree:testRadixTreesWithSameWords_Compare_Equal()
	-- Given: trees have matching words in different orders and differing contents.
	local t1 = RadixTree.new({ "apple", "banana", "cherry" })
	local t2 = RadixTree.new({ "cherry", "apple", "banana" })
	local t3 = RadixTree.new({ "apple", "banana" })
	local t4 = RadixTree.new({ "apple", "banana", "citrus" })
	local t5 = RadixTree.new({ "apple", "banana", "cherry" }, false)

	-- Boolean assertions here intentionally exercise RadixTree.__eq.

	-- When: compare the trees with ==.
	-- Then: only trees containing the same words compare equal.
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
	-- This assertion exercises RadixTree.__eq; assertEquals compares table structure.
	lu.assertTrue(empty1 == empty2)
end

function TestRadixTree:testLength_Tracks_InsertedAndRemovedWords()
	-- Given: an empty RadixTree.
	local t = RadixTree.new()
	lu.assertEquals(#t, 0)

	-- When: insert word "a".
	t:insert("a")

	-- Then: length is 1.
	lu.assertEquals(#t, 1)

	-- When: insert distinct word "ab" and duplicate "ab".
	t:insert("ab")
	t:insert("ab")

	-- Then: length reflects unique words and reports 2.
	lu.assertEquals(#t, 2)

	-- When: remove exact word "ab".
	t:remove("ab", true)

	-- Then: length decreases to 1.
	lu.assertEquals(#t, 1)

	-- When: clear the tree.
	t:clear()

	-- Then: length resets to 0.
	lu.assertEquals(#t, 0)
end

function TestRadixTree:testToString_Formats_StoredWords()
	-- Given: the RadixTree contains several words.
	local empty = RadixTree.new()

	-- When: format it with tostring.
	-- Then: formatted text includes each stored word.
	lu.assertEquals(tostring(empty), "{  }")

	local t = RadixTree.new({ "dog", "cat", "bird" })
	lu.assertEquals(tostring(t), "{ bird, cat, dog }")
end

function TestRadixTree:testNewPropertiesAndMethods_CannotBe_AddedOrReplaced()
	-- Given: a RadixTree defines its public methods and has no added fields.
	local rt = RadixTree.new()

	-- disallow adding properties

	-- When: assign a property, numeric key, function, and replacement method.
	-- Then: every assignment raises the property-protection error.
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

-- Suite map
return { TestRadixTree = TestRadixTree }
