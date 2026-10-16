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
	lu.assertTrue(Array.isArray({}))
	lu.assertTrue(Array.isArray({ 1, 2, 3 }))
	lu.assertTrue(Array.isArray(Array.new()))
	lu.assertTrue(Array.isArray(Array.new({ 4, 5, 6 })))
end

function TestArray:testRejectsValuesThatAreNotArrays()
	lu.assertFalse(Array.isArray(nil))
	lu.assertFalse(Array.isArray(true))
	lu.assertFalse(Array.isArray(123))
	lu.assertFalse(Array.isArray("abc"))
	lu.assertFalse(Array.isArray({ a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ 1, 2, 3, a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ [1] = "a", foo = "bar" }))
end

function TestArray:testNewArrayStartsEmpty()
	local array = Array.new()

	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

function TestArray:testConstructorPreservesInitialValues()
	local array = Array.new({ 5, 6, 7 })

	lu.assertFalse(array:empty())
	lu.assertEquals(arrayValues(array), { 5, 6, 7 })
end

function TestArray:testClearEmptiesPopulatedArray()
	local array = Array.new({ 5, 6, 7 })

	array:clear()

	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

function TestArray:testClearedArrayRejectsFormerIndexes()
	local array = Array.new({ 5, 6, 7 })

	array:clear()

	lu.assertErrorMsgContains("index out of bounds", function()
		array:get(1)
	end)
end

-- Scenarios: empty-state behavior

function TestArray:testEmptyReportsFalseAfterInsert()
	local array = Array.new()

	array:insert("first")

	lu.assertFalse(array:empty())
end

-- Scenarios: reading and inspection

function TestArray:testGetReturnsValueAtOneBasedIndex()
	local array = Array.new({ 10, 20, 30 })

	lu.assertEquals(array:get(1), 10)
	lu.assertEquals(array:get(2), 20)
	lu.assertEquals(array:get(3), 30)
end

function TestArray:testGetRejectsIndexesOutsideArrayBounds()
	local array = Array.new({ 10, 20, 30 })

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
	local array = Array.new({ 10, 20, 30 })

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
	local array = Array.new({ 10, 20, 30, 40, 50 })
	local slice = array:slice(2, 4)

	lu.assertEquals(arrayValues(slice), { 20, 30, 40 })
end

function TestArray:testIndexOfReturnsFirstMatchingPosition()
	local array = Array.new({ 10, 20, 30, 20 })

	lu.assertEquals(array:indexOf(10), 1)
	lu.assertEquals(array:indexOf(30), 3)
	lu.assertEquals(array:indexOf(20), 2)
end

function TestArray:testIndexOfReturnsNilWhenValueIsMissing()
	local array = Array.new({ 10, 20, 30 })

	lu.assertNil(array:indexOf(40))
end

function TestArray:testContainsReportsStoredValueAsPresent()
	local array = Array.new({ 10, 20, 30 })

	lu.assertTrue(array:contains(20))
end

function TestArray:testContainsReportsUnstoredValueAsAbsent()
	local array = Array.new({ 10, 20, 30 })

	lu.assertFalse(array:contains(40))
end

function TestArray:testEmptyArrayReportsEveryValueAsAbsent()
	local array = Array.new()

	lu.assertFalse(array:contains(10))
end

function TestArray:testContainsReportsDuplicateValueAsPresent()
	local array = Array.new({ 5, 5, 5 })

	lu.assertTrue(array:contains(5))
	lu.assertFalse(array:contains(1))
	lu.assertEquals(#array, 3)
end

function TestArray:testContainsRejectsNilValue()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("value should not be nil", function()
		array:contains(nil)
	end)
end

function TestArray:testBracketReadsDoNotExposeStoredValues()
	local array = Array.new({ 10, 20, 30 })

	lu.assertNil(array[1])
	lu.assertNil(array[2])
	lu.assertNil(array[3])
end

function TestArray:testIterationYieldsOneBasedIndexesAndValues()
	local array = Array.new({ 10, 20, 30 })
	local entries = {}

	for index, value in pairs(array) do
		table.insert(entries, index)
		table.insert(entries, value)
	end

	lu.assertEquals(entries, { 1, 10, 2, 20, 3, 30 })
end

-- Scenarios: insertion and removal

function TestArray:testInsertWithoutIndexAppendsValue()
	local array = Array.new({ 10 })

	array:insert(20)

	lu.assertEquals(arrayValues(array), { 10, 20 })
end

function TestArray:testInsertAtFirstPositionShiftsExistingValues()
	local array = Array.new({ 10, 20 })

	array:insert(5, 1)

	lu.assertEquals(arrayValues(array), { 5, 10, 20 })
end

function TestArray:testInsertAtMiddlePositionShiftsFollowingValues()
	local array = Array.new({ 10, 20, 30 })

	array:insert(15, 2)

	lu.assertEquals(arrayValues(array), { 10, 15, 20, 30 })
end

function TestArray:testInsertAtEndPositionAppendsValue()
	local array = Array.new({ 10, 20 })

	array:insert(30, 3)

	lu.assertEquals(arrayValues(array), { 10, 20, 30 })
end

function TestArray:testInsertRejectsNilValue()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("value should not be nil", function()
		array:insert(nil)
	end)
end

function TestArray:testInsertRejectsIndexesOutsideValidRange()
	local array = Array.new({ 10, 20, 30 })

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
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("index should be a number", function()
		array:insert(40, "1")
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		array:insert(40, true)
	end)
end

function TestArray:testRemoveReturnsValueAndShiftsFollowingValues()
	local array = Array.new({ 10, 20, 30 })

	local removed = array:remove(1)

	lu.assertEquals(removed, 10)
	lu.assertEquals(arrayValues(array), { 20, 30 })
end

function TestArray:testSwapExchangesValuesAtFirstIndexes()
	local array = Array.new({ 10, 20, 30 })

	array:swap(1, 2)

	lu.assertEquals(arrayValues(array), { 20, 10, 30 })
end

function TestArray:testSwapExchangesValuesAtLaterIndexes()
	local array = Array.new({ 10, 20, 30 })

	array:swap(2, 3)

	lu.assertEquals(arrayValues(array), { 10, 30, 20 })
end

-- Scenarios: equality and formatting

function TestArray:testEqualArraysCompareEqual()
	local first = Array.new({ 10, 20, 30 })
	local second = Array.new({ 10, 20, 30 })

	lu.assertEquals(arrayValues(first), arrayValues(second))
	lu.assertTrue(first == second)
end

function TestArray:testArraysWithDifferentValuesCompareUnequal()
	local first = Array.new({ 10, 20, 30 })
	local second = Array.new({ 10, 20, 40 })

	lu.assertNotEquals(arrayValues(first), arrayValues(second))
	lu.assertFalse(first == second)
end

function TestArray:testArrayComparesEqualToPlainTableWithSameValues()
	local array = Array.new({ 10, 20, 30 })

	lu.assertTrue(array == { 10, 20, 30 })
end

function TestArray:testArrayDoesNotCompareEqualToOtherValueTypes()
	local array = Array.new({ 10, 20, 30 })

	lu.assertNotEquals(array, "string")
end

function TestArray:testToStringFormatsPopulatedArray()
	local array = Array.new({ 1, 2, 3 })

	lu.assertEquals(tostring(array), "[ 1, 2, 3 ]")
end

function TestArray:testToStringFormatsEmptyArray()
	local array = Array.new()

	lu.assertEquals(tostring(array), "[  ]")
end

function TestArray:testNewPropertiesCannotBeAdded()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.foo = "bar"
	end)
end

function TestArray:testNumericIndexesCannotBeAdded()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array[1] = 99
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array[4] = 40
	end)
end

function TestArray:testNewMethodsCannotBeAdded()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.myFunc = function() end
	end)
end

function TestArray:testExistingMethodsCannotBeReplaced()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.get = function() end
	end)
end

-- Scenarios: concatenation

function TestArray:testConcatAppendsTableValues()
	local array = Array.new({ 10, 20, 30 })

	array = array .. { 40, 50, 60 }

	lu.assertEquals(arrayValues(array), { 10, 20, 30, 40, 50, 60 })
end

function TestArray:testConcatWithNilPreservesArray()
	local array = Array.new({ 10, 20, 30 })

	array = array .. nil

	lu.assertEquals(arrayValues(array), { 10, 20, 30 })
end

function TestArray:testConcatAppendsAnotherArrayValues()
	local array = Array.new({ 10, 20, 30 })

	array = array .. Array.new({ 40, 50, 60 })

	lu.assertEquals(arrayValues(array), { 10, 20, 30, 40, 50, 60 })
end

function TestArray:testConcatAppendsSetValues()
	local array = Array.new({ 10, 20, 30 })
	local set = require("ff.collections.set").new()
	set:add(100)

	array = array .. set

	lu.assertEquals(arrayValues(array), { 10, 20, 30, 100 })
end

-- Suite map
return { TestArray = TestArray }
