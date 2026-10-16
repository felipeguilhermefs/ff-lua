-- Imports
local lu = require("luaunit")
local Array = require("ff.collections.array")

-- Test helpers
-- Snapshot values for useful LuaUnit diffs without exposing Array internals.
local function arrayValues(array)
	local values = {}
	for index, value in pairs(array) do
		values[index] = value
	end
	return values
end

-- Suite definitions
local TestArray = {}

-- Scenarios: type and construction behavior

function TestArray:testRecognizesArrayTablesAndInstances()
	-- Given: candidates are empty and populated sequences or Array objects.
	-- When: check empty and populated sequences plus Array objects with Array.isArray.
	-- Then: every sequence and Array object is accepted.
	lu.assertTrue(Array.isArray({}))
	lu.assertTrue(Array.isArray({ 1, 2, 3 }))
	lu.assertTrue(Array.isArray(Array.new()))
	lu.assertTrue(Array.isArray(Array.new({ 4, 5, 6 })))
end

function TestArray:testRejectsValuesThatAreNotArrays()
	-- Given: candidates are nil, scalars, maps, and mixed-key tables.
	-- When: check nil, scalars, maps, and mixed-key tables with Array.isArray.
	-- Then: every candidate is rejected as a non-array.
	lu.assertFalse(Array.isArray(nil))
	lu.assertFalse(Array.isArray(true))
	lu.assertFalse(Array.isArray(123))
	lu.assertFalse(Array.isArray("abc"))
	lu.assertFalse(Array.isArray({ a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ 1, 2, 3, a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ [1] = "a", foo = "bar" }))
end

function TestArray:testNewArrayStartsEmpty()
	-- Given: construction receives no values.

	-- When: create an Array with no arguments.
	local array = Array.new()

	-- Then: the instance reports empty and has length zero.
	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

function TestArray:testConstructorPreservesInitialValues()
	-- Given: the constructor receives { 5, 6, 7 }.

	-- When: initialize an Array from that table.
	local array = Array.new({ 5, 6, 7 })

	-- Then: iteration returns 5, 6, and 7 in input order.
	lu.assertFalse(array:empty())
	lu.assertEquals(arrayValues(array), { 5, 6, 7 })
end

function TestArray:testClearEmptiesPopulatedArray()
	-- Given: the Array contains 5, 6, and 7.
	local array = Array.new({ 5, 6, 7 })

	-- When: call clear on the populated Array.
	array:clear()

	-- Then: it reports empty and has length zero.
	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

function TestArray:testClearedArrayRejectsFormerIndexes()
	-- Given: the Array contains values at indexes 1 through 3.
	local array = Array.new({ 5, 6, 7 })

	-- When: clear the Array and request its former first index.
	array:clear()

	-- Then: get reports an out-of-bounds error.
	lu.assertErrorMsgContains("index out of bounds", function()
		array:get(1)
	end)
end

-- Scenarios: empty-state behavior

function TestArray:testEmptyReportsFalseAfterInsert()
	-- Given: the Array has length zero.
	local array = Array.new()

	-- When: insert "first" at the default position.
	array:insert("first")

	-- Then: empty reports false.
	lu.assertFalse(array:empty())
end

-- Scenarios: reading and inspection

function TestArray:testGetReturnsValueAtOneBasedIndex()
	-- Given: indexes 1, 2, and 3 contain 10, 20, and 30.
	local array = Array.new({ 10, 20, 30 })

	-- When: read each valid one-based index with get.
	-- Then: each lookup returns the value stored at that index.
	lu.assertEquals(array:get(1), 10)
	lu.assertEquals(array:get(2), 20)
	lu.assertEquals(array:get(3), 30)
end

function TestArray:testGetRejectsIndexesOutsideArrayBounds()
	-- Given: the Array contains three values at indexes 1 through 3.
	local array = Array.new({ 10, 20, 30 })

	-- When: request indexes 0, 4, and -1 with get.
	-- Then: every request reports an out-of-bounds error.
	lu.assertErrorMsgContains("index out of bounds", function()
		array:get(0)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		array:get(4)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		array:get(-1)
	end)
end

function TestArray:testGetRejectsNonNumericIndexes()
	-- Given: the Array contains three values at numeric indexes.
	local array = Array.new({ 10, 20, 30 })

	-- When: request indexes "1", nil, and true with get.
	-- Then: every request reports that index must be numeric.
	lu.assertErrorMsgContains("index should be a number", function()
		array:get("1")
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		array:get(nil)
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		array:get(true)
	end)
end

function TestArray:testSliceReturnsRequestedRange()
	-- Given: the Array contains 10, 20, 30, 40, and 50.
	local array = Array.new({ 10, 20, 30, 40, 50 })

	-- When: take the inclusive slice from index 2 through 4.
	local slice = array:slice(2, 4)

	-- Then: the slice contains 20, 30, and 40 in order.
	lu.assertEquals(arrayValues(slice), { 20, 30, 40 })
end

function TestArray:testIndexOfReturnsFirstMatchingPosition()
	-- Given: 20 appears at indexes 2 and 4 among four values.
	local array = Array.new({ 10, 20, 30, 20 })

	-- When: locate values 10, 30, and 20 with indexOf.
	-- Then: each lookup returns its first matching index.
	lu.assertEquals(array:indexOf(10), 1)
	lu.assertEquals(array:indexOf(30), 3)
	lu.assertEquals(array:indexOf(20), 2)
end

function TestArray:testIndexOfReturnsNilWhenValueIsMissing()
	-- Given: the Array contains 10, 20, and 30; 40 is absent.
	local array = Array.new({ 10, 20, 30 })

	-- When: locate absent value 40 with indexOf.
	-- Then: no index is returned.
	lu.assertNil(array:indexOf(40))
end

function TestArray:testContainsReportsStoredValueAsPresent()
	-- Given: the Array contains membership target 20.
	local array = Array.new({ 10, 20, 30 })

	-- When: check membership of stored value 20.
	-- Then: contains returns true.
	lu.assertTrue(array:contains(20))
end

function TestArray:testContainsReportsUnstoredValueAsAbsent()
	-- Given: the Array contains 10, 20, and 30; membership target 40 is absent.
	local array = Array.new({ 10, 20, 30 })

	-- When: check membership of absent value 40.
	-- Then: contains returns false for absent value 40.
	lu.assertFalse(array:contains(40))
end

function TestArray:testEmptyArrayReportsEveryValueAsAbsent()
	-- Given: an empty Array is queried for membership of 10.
	local array = Array.new()

	-- When: check membership of value 10.
	-- Then: contains returns false when the Array has no elements.
	lu.assertFalse(array:contains(10))
end

function TestArray:testContainsReportsDuplicateValueAsPresent()
	-- Given: the Array stores 5 at all three indexes.
	local array = Array.new({ 5, 5, 5 })

	-- When: check membership of 5 and absent value 1.
	-- Then: contains finds 5, rejects 1, and leaves length unchanged.
	lu.assertTrue(array:contains(5))
	lu.assertFalse(array:contains(1))
	lu.assertEquals(#array, 3)
end

function TestArray:testContainsRejectsNilValue()
	-- Given: the Array contains values; nil is the invalid membership query.
	local array = Array.new({ 10, 20, 30 })

	-- When: check membership of nil.
	-- Then: contains reports that values cannot be nil.
	lu.assertErrorMsgContains("value should not be nil", function()
		array:contains(nil)
	end)
end

function TestArray:testBracketReadsDoNotExposeStoredValues()
	-- Given: indexes 1 through 3 contain stored values.
	local array = Array.new({ 10, 20, 30 })

	-- When: read indexes 1, 2, and 3 with brackets.
	-- Then: each direct table lookup returns nil.
	lu.assertNil(array[1])
	lu.assertNil(array[2])
	lu.assertNil(array[3])
end

function TestArray:testIterationYieldsOneBasedIndexesAndValues()
	-- Given: the Array stores 10, 20, and 30 at indexes 1, 2, and 3.
	local array = Array.new({ 10, 20, 30 })
	local entries = {}

	-- When: collect every key-value pair from pairs.
	for index, value in pairs(array) do
		table.insert(entries, index)
		table.insert(entries, value)
	end

	-- Then: collected entries preserve one-based indexes and stored values.
	lu.assertEquals(entries, { 1, 10, 2, 20, 3, 30 })
end

-- Scenarios: insertion and removal

function TestArray:testInsertWithoutIndexAppendsValue()
	-- Given: the Array contains only 10.
	local array = Array.new({ 10 })

	-- When: insert 20 without an index.
	array:insert(20)

	-- Then: iteration yields 10 followed by 20.
	lu.assertEquals(arrayValues(array), { 10, 20 })
end

function TestArray:testInsertAtFirstPositionShiftsExistingValues()
	-- Given: the Array holds 10 and 20; insertion target is index 1.
	local array = Array.new({ 10, 20 })

	-- When: insert 5 at index 1.
	array:insert(5, 1)

	-- Then: 5 leads the Array and both prior values shift right.
	lu.assertEquals(arrayValues(array), { 5, 10, 20 })
end

function TestArray:testInsertAtMiddlePositionShiftsFollowingValues()
	-- Given: the Array holds 10, 20, 30; insertion target is index 2.
	local array = Array.new({ 10, 20, 30 })

	-- When: insert 15 at index 2.
	array:insert(15, 2)

	-- Then: 15 occupies index 2 and later values shift right.
	lu.assertEquals(arrayValues(array), { 10, 15, 20, 30 })
end

function TestArray:testInsertAtEndPositionAppendsValue()
	-- Given: the Array holds 10 and 20; insertion target is the final index.
	local array = Array.new({ 10, 20 })

	-- When: insert 30 at index 3.
	array:insert(30, 3)

	-- Then: 30 becomes the final value.
	lu.assertEquals(arrayValues(array), { 10, 20, 30 })
end

function TestArray:testInsertRejectsNilValue()
	-- Given: the Array contains three existing values.
	local array = Array.new({ 10, 20, 30 })

	-- When: insert nil without an index.
	-- Then: insert reports that values cannot be nil.
	lu.assertErrorMsgContains("value should not be nil", function()
		array:insert(nil)
	end)
end

function TestArray:testInsertRejectsIndexesOutsideValidRange()
	-- Given: the Array has length 3; attempted indexes are 0, -1, and 5.
	local array = Array.new({ 10, 20, 30 })

	-- When: insert at indexes 0, -1, and 5.
	-- Then: each request reports an out-of-bounds error.
	lu.assertErrorMsgContains("index out of bounds", function()
		array:insert(40, 0)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		array:insert(40, -1)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		array:insert(40, 5)
	end)
end

function TestArray:testInsertRejectsNonNumericIndex()
	-- Given: the Array has length 3; attempted indexes are "1" and true.
	local array = Array.new({ 10, 20, 30 })

	-- When: insert with indexes "1" and true.
	-- Then: each request reports that index must be numeric.
	lu.assertErrorMsgContains("index should be a number", function()
		array:insert(40, "1")
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		array:insert(40, true)
	end)
end

function TestArray:testRemoveReturnsValueAndShiftsFollowingValues()
	-- Given: the Array holds 10, 20, 30 before removing index 1.
	local array = Array.new({ 10, 20, 30 })

	-- When: remove the value at index 1.
	local removed = array:remove(1)

	-- Then: removal returns 10 and leaves 20, 30 in order.
	lu.assertEquals(removed, 10)
	lu.assertEquals(arrayValues(array), { 20, 30 })
end

function TestArray:testSwapExchangesValuesAtFirstIndexes()
	-- Given: the Array holds 10, 20, 30; the first two indexes are targeted.
	local array = Array.new({ 10, 20, 30 })

	-- When: swap values at the first two indexes.
	array:swap(1, 2)

	-- Then: indexes 1 and 2 contain 20 and 10; index 3 stays 30.
	lu.assertEquals(arrayValues(array), { 20, 10, 30 })
end

function TestArray:testSwapExchangesValuesAtLaterIndexes()
	-- Given: the Array holds 10, 20, 30; indexes 2 and 3 are targeted.
	local array = Array.new({ 10, 20, 30 })

	-- When: swap the values at indexes 2 and 3.
	array:swap(2, 3)

	-- Then: indexes 2 and 3 contain 30 and 20; index 1 stays 10.
	lu.assertEquals(arrayValues(array), { 10, 30, 20 })
end

-- Scenarios: equality and formatting

function TestArray:testEqualArraysCompareEqual()
	-- Given: both Arrays contain 10, 20, and 30.
	local first = Array.new({ 10, 20, 30 })
	local second = Array.new({ 10, 20, 30 })

	-- When: compare the two Arrays with ==.
	-- Then: their values match and equality returns true.
	lu.assertEquals(arrayValues(first), arrayValues(second))
	lu.assertTrue(first == second)
end

function TestArray:testArraysWithDifferentValuesCompareUnequal()
	-- Given: the Arrays differ only at their final value.
	local first = Array.new({ 10, 20, 30 })
	local second = Array.new({ 10, 20, 40 })

	-- When: compare the Arrays with ==.
	-- Then: their snapshots differ and equality returns false.
	lu.assertNotEquals(arrayValues(first), arrayValues(second))
	lu.assertFalse(first == second)
end

function TestArray:testArrayComparesEqualToPlainTableWithSameValues()
	-- Given: an Array and plain table contain the same three values.
	local array = Array.new({ 10, 20, 30 })

	-- When: compare the Array directly with the table.
	-- Then: equality returns true.
	lu.assertTrue(array == { 10, 20, 30 })
end

function TestArray:testArrayDoesNotCompareEqualToOtherValueTypes()
	-- Given: an Array contains three values and the other candidate is a string.
	local array = Array.new({ 10, 20, 30 })

	-- When: compare the Array with the string.
	-- Then: the values are not equal.
	lu.assertNotEquals(array, "string")
end

function TestArray:testToStringFormatsPopulatedArray()
	-- Given: the Array contains 1, 2, and 3.
	local array = Array.new({ 1, 2, 3 })

	-- When: format the populated Array with tostring.
	-- Then: text is formatted as [ 1, 2, 3 ].
	lu.assertEquals(tostring(array), "[ 1, 2, 3 ]")
end

function TestArray:testToStringFormatsEmptyArray()
	-- Given: an empty Array is prepared for text formatting.
	local array = Array.new()

	-- When: format the empty Array with tostring.
	-- Then: text is formatted as [  ].
	lu.assertEquals(tostring(array), "[  ]")
end

function TestArray:testNewPropertiesCannotBeAdded()
	-- Given: an Array contains three values; assignment targets a new string key.
	local array = Array.new({ 10, 20, 30 })

	-- When: assign a previously undefined string key.
	-- Then: assignment to an undefined string key raises the protection error.
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.foo = "bar"
	end)
end

function TestArray:testNumericIndexesCannotBeAdded()
	-- Given: an Array contains three values; assignments target indexes 1 and 4.
	local array = Array.new({ 10, 20, 30 })

	-- When: assign indexes 1 and 4 directly.
	-- Then: numeric assignments raise the property-protection error.
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array[1] = 99
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array[4] = 40
	end)
end

function TestArray:testNewMethodsCannotBeAdded()
	-- Given: an Array contains three values; assignment targets a new function key.
	local array = Array.new({ 10, 20, 30 })

	-- When: assign a previously undefined function key.
	-- Then: assignment to an undefined method key raises the protection error.
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.myFunc = function() end
	end)
end

function TestArray:testExistingMethodsCannotBeReplaced()
	-- Given: an Array contains three values and defines get.
	local array = Array.new({ 10, 20, 30 })

	-- When: assign a replacement for get.
	-- Then: replacing get raises the property-protection error.
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.get = function() end
	end)
end

-- Scenarios: concatenation

function TestArray:testConcatAppendsTableValues()
	-- Given: the left Array contains 10, 20, 30; the right table contains 40, 50, 60.
	local array = Array.new({ 10, 20, 30 })

	-- When: concatenate the Array with table { 40, 50, 60 }.
	array = array .. { 40, 50, 60 }

	-- Then: the result contains the original values followed by 40, 50, and 60.
	lu.assertEquals(arrayValues(array), { 10, 20, 30, 40, 50, 60 })
end

function TestArray:testConcatWithNilPreservesArray()
	-- Given: the Array contains 10, 20, and 30; the right operand is nil.
	local array = Array.new({ 10, 20, 30 })

	-- When: concatenate the array with nil.
	array = array .. nil

	-- Then: the result still contains only 10, 20, and 30.
	lu.assertEquals(arrayValues(array), { 10, 20, 30 })
end

function TestArray:testConcatAppendsAnotherArrayValues()
	-- Given: the Array contains 10, 20, and 30; another Array contains 40, 50, and 60.
	local array = Array.new({ 10, 20, 30 })

	-- When: concatenate the two Arrays.
	array = array .. Array.new({ 40, 50, 60 })

	-- Then: the result contains all six values in order.
	lu.assertEquals(arrayValues(array), { 10, 20, 30, 40, 50, 60 })
end

function TestArray:testConcatAppendsSetValues()
	-- Given: the Array contains 10, 20, and 30; the Set contains 100.
	local array = Array.new({ 10, 20, 30 })
	local set = require("ff.collections.set").new()

	-- When: concatenate the Array with that Set.
	set:add(100)

	array = array .. set

	-- Then: the result contains 100 after the original values.
	lu.assertEquals(arrayValues(array), { 10, 20, 30, 100 })
end

-- Suite map
return { TestArray = TestArray }
