local lu = require("luaunit")
local Array = require("ff.collections.array")

local append = table.insert

local function arrayValues(array)
	local values = {}
	for index, value in pairs(array) do
		values[index] = value
	end
	return values
end

local TestArray = {}

function TestArray:testTypeGuard_RecognizesArrayTablesAndInstances()
	lu.assertTrue(Array.isArray(Array.new()))
	lu.assertTrue(Array.isArray(Array.new({ 4, 5, 6 })))
end

function TestArray:testTypeGuard_RejectsValuesThatAreNotArrays()
	lu.assertFalse(Array.isArray(nil))
	lu.assertFalse(Array.isArray(true))
	lu.assertFalse(Array.isArray(123))
	lu.assertFalse(Array.isArray("abc"))
	lu.assertFalse(Array.isArray({}))
	lu.assertFalse(Array.isArray({ 1, 2, 3 }))
	lu.assertFalse(Array.isArray({ a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ 1, 2, 3, a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ [1] = "a", foo = "bar" }))
end

function TestArray:testNewArray_StartsEmpty()
	local array = Array.new()

	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

function TestArray:testConstructor_PreservesInitialValues()
	local array = Array.new({ 5, 6, 7 })

	lu.assertFalse(array:empty())
	lu.assertEquals(arrayValues(array), { 5, 6, 7 })
end

function TestArray:testClear_EmptiesPopulatedArray()
	local array = Array.new({ 5, 6, 7 })

	array:clear()

	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

function TestArray:testClearedArray_RejectsFormerIndexes()
	local array = Array.new({ 5, 6, 7 })

	array:clear()

	lu.assertErrorMsgContains("index out of bounds", function()
		array:get(1)
	end)
end

function TestArray:testEmpty_ReportsFalseAfterInsert()
	local array = Array.new()

	array:insert("first")

	lu.assertFalse(array:empty())
end

function TestArray:testGet_ReturnsValueAtOneBasedIndex()
	local array = Array.new({ 10, 20, 30 })

	lu.assertEquals(array:get(1), 10)
	lu.assertEquals(array:get(2), 20)
	lu.assertEquals(array:get(3), 30)
end

function TestArray:testGet_RejectsIndexesOutsideArrayBounds()
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

function TestArray:testGet_Rejects_NonNumericIndexes()
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

function TestArray:testSlice_ReturnsRequestedRange()
	local array = Array.new({ 10, 20, 30, 40, 50 })

	local slice = array:slice(2, 4)

	lu.assertEquals(arrayValues(slice), { 20, 30, 40 })
end

function TestArray:testIndexOf_ReturnsFirstMatchingPosition()
	local array = Array.new({ 10, 20, 30, 20 })

	lu.assertEquals(array:indexOf(10), 1)
	lu.assertEquals(array:indexOf(30), 3)
	lu.assertEquals(array:indexOf(20), 2)
end

function TestArray:testIndexOf_ReturnsNilWhenValueIsMissing()
	local array = Array.new({ 10, 20, 30 })

	lu.assertNil(array:indexOf(40))
end

function TestArray:testContains_ReportsStoredValueAsPresent()
	local array = Array.new({ 10, 20, 30 })

	lu.assertTrue(array:contains(20))
end

function TestArray:testContains_ReportsUnstoredValueAsAbsent()
	local array = Array.new({ 10, 20, 30 })

	lu.assertFalse(array:contains(40))
end

function TestArray:testEmptyArray_ReportsEveryValueAsAbsent()
	local array = Array.new()

	lu.assertFalse(array:contains(10))
end

function TestArray:testContains_ReportsDuplicateValueAsPresent()
	local array = Array.new({ 5, 5, 5 })

	lu.assertTrue(array:contains(5))
	lu.assertFalse(array:contains(1))
	lu.assertEquals(#array, 3)
end

function TestArray:testContains_RejectsNilValue()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("value should not be nil", function()
		array:contains(nil)
	end)
end

function TestArray:testBracketReads_DoNotExposeStoredValues()
	local array = Array.new({ 10, 20, 30 })

	lu.assertNil(array[1])
	lu.assertNil(array[2])
	lu.assertNil(array[3])
end

function TestArray:testIteration_YieldsOneBasedIndexesAndValues()
	local array = Array.new({ 10, 20, 30 })
	local entries = {}

	for index, value in pairs(array) do
		append(entries, index)
		append(entries, value)
	end

	lu.assertEquals(entries, { 1, 10, 2, 20, 3, 30 })
end

function TestArray:testInsertWithoutIndex_AppendsValue()
	local array = Array.new({ 10 })

	array:insert(20)

	lu.assertEquals(arrayValues(array), { 10, 20 })
end

function TestArray:testInsertAtFirstPosition_ShiftsExistingValues()
	local array = Array.new({ 10, 20 })

	array:insert(5, 1)

	lu.assertEquals(arrayValues(array), { 5, 10, 20 })
end

function TestArray:testInsertAtMiddlePosition_ShiftsFollowingValues()
	local array = Array.new({ 10, 20, 30 })

	array:insert(15, 2)

	lu.assertEquals(arrayValues(array), { 10, 15, 20, 30 })
end

function TestArray:testInsertAtEndPosition_AppendsValue()
	local array = Array.new({ 10, 20 })

	array:insert(30, 3)

	lu.assertEquals(arrayValues(array), { 10, 20, 30 })
end

function TestArray:testPut_OverwritesValueWithoutShifting()
	local array = Array.new({ 10, 20, 30 })

	array:put(2, 99)

	lu.assertEquals(arrayValues(array), { 10, 99, 30 })
	lu.assertEquals(#array, 3)
end

function TestArray:testPutAtNextIndex_AppendsValue()
	local array = Array.new({ 10, 20 })

	array:put(3, 30)

	lu.assertEquals(arrayValues(array), { 10, 20, 30 })
	lu.assertEquals(#array, 3)
end

function TestArray:testPut_RejectsIndexesOutsideAllowedBounds()
	local array = Array.new({ 10, 20 })

	lu.assertErrorMsgContains("index out of bounds", function()
		array:put(0, 1)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		array:put(4, 1)
	end)
end

function TestArray:testPut_RejectsInvalidIndexAndNilValue()
	local array = Array.new({ 10, 20 })

	lu.assertErrorMsgContains("index should be a number", function()
		array:put("1", 1)
	end)
	lu.assertErrorMsgContains("index should be an integer", function()
		array:put(1.5, 1)
	end)
	lu.assertErrorMsgContains("value should not be nil", function()
		array:put(1, nil)
	end)
end

function TestArray:testInsert_RejectsNilValue()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("value should not be nil", function()
		array:insert(nil)
	end)
end

function TestArray:testInsert_Rejects_IndexesOutsideValidRange()
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

function TestArray:testInsert_RejectsNonNumericIndex()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("index should be a number", function()
		array:insert(40, "1")
	end)
	lu.assertErrorMsgContains("index should be a number", function()
		array:insert(40, true)
	end)
end

function TestArray:testRemove_ReturnsValueAndShiftsFollowingValues()
	local array = Array.new({ 10, 20, 30 })

	local removed = array:remove(1)

	lu.assertEquals(removed, 10)
	lu.assertEquals(arrayValues(array), { 20, 30 })
end

function TestArray:testSwap_ExchangesValuesAtFirstIndexes()
	local array = Array.new({ 10, 20, 30 })

	array:swap(1, 2)

	lu.assertEquals(arrayValues(array), { 20, 10, 30 })
end

function TestArray:testSwap_ExchangesValuesAtLaterIndexes()
	local array = Array.new({ 10, 20, 30 })

	array:swap(2, 3)

	lu.assertEquals(arrayValues(array), { 10, 30, 20 })
end

function TestArray:testEqualArrays_CompareEqual()
	local first = Array.new({ 10, 20, 30 })
	local second = Array.new({ 10, 20, 30 })

	lu.assertEquals(arrayValues(first), arrayValues(second))
	lu.assertTrue(first == second)
end

function TestArray:testEqualArraysContainingFalse_CompareEqual()
	local first = Array.new({ false, 1 })
	local second = Array.new({ false, 1 })

	lu.assertTrue(first == second)
end

function TestArray:testArraysWithDifferentValues_CompareUnequal()
	local first = Array.new({ 10, 20, 30 })
	local second = Array.new({ 10, 20, 40 })

	lu.assertNotEquals(arrayValues(first), arrayValues(second))
	lu.assertFalse(first == second)
end

function TestArray:testArray_DoesNotCompareEqualToOtherValueTypes()
	local array = Array.new({ 10, 20, 30 })

	lu.assertNotEquals(array, "string")
end

function TestArray:testToString_FormatsPopulatedArray()
	local array = Array.new({ 1, 2, 3 })

	lu.assertEquals(tostring(array), "[ 1, 2, 3 ]")
end

function TestArray:testToString_FormatsEmptyArray()
	local array = Array.new()

	lu.assertEquals(tostring(array), "[  ]")
end

function TestArray:testNewProperties_CannotBeAdded()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.foo = "bar"
	end)
end

function TestArray:testNumericIndexes_CannotBeAdded()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array[1] = 99
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array[4] = 40
	end)
end

function TestArray:testNewMethods_CannotBeAdded()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.myFunc = function() end
	end)
end

function TestArray:testExistingMethods_CannotBeReplaced()
	local array = Array.new({ 10, 20, 30 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.get = function() end
	end)
end

function TestArray:testConcat_Appends_TableValues()
	local array = Array.new({ 10, 20, 30 })

	array = array .. { 40, 50, 60 }

	lu.assertEquals(arrayValues(array), { 10, 20, 30, 40, 50, 60 })
end

function TestArray:testConcatWithNil_PreservesArray()
	local array = Array.new({ 10, 20, 30 })

	array = array .. nil

	lu.assertEquals(arrayValues(array), { 10, 20, 30 })
end

function TestArray:testConcat_AppendsAnotherArrayValues()
	local array = Array.new({ 10, 20, 30 })

	array = array .. Array.new({ 40, 50, 60 })

	lu.assertEquals(arrayValues(array), { 10, 20, 30, 40, 50, 60 })
end

function TestArray:testConcat_AppendsSetValues()
	local array = Array.new({ 10, 20, 30 })
	local set = require("ff.collections.set").new()

	set:add(100)

	array = array .. set

	lu.assertEquals(arrayValues(array), { 10, 20, 30, 100 })
end

function TestArray:testConcat_CreatesNewArrayAndInsertAllMutates()
	local source = Array.new({ 1, 2 })
	local joined = source .. { 3 }
	lu.assertNotIs(joined, source)
	lu.assertEquals(arrayValues(source), { 1, 2 })
	lu.assertEquals(arrayValues(joined), { 1, 2, 3 })
	source:insertAll({ 4 })
	lu.assertEquals(arrayValues(source), { 1, 2, 4 })
end

function TestArray:testInsertAllRejectsNil()
	local collection = Array.new()
	lu.assertErrorMsgContains("iterable should be a table", function()
		collection:insertAll(nil)
	end)
end

return { TestArray = TestArray }
