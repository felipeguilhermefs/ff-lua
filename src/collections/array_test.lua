local lu = require("luaunit")
local Array = require("ff.collections.array")

local function valuesOf(array)
	local values = {}
	for index, value in pairs(array) do
		values[index] = value
	end
	return values
end

local TestArrayClear = {}
local TestArrayConcat = {}
local TestArrayContains = {}
local TestArrayEmpty = {}
local TestArrayEq = {}
local TestArrayGet = {}
local TestArrayIndexOf = {}
local TestArrayInsert = {}
local TestArrayInsertAll = {}
local TestArrayIsArray = {}
local TestArrayLen = {}
local TestArrayNew = {}
local TestArrayNewIndex = {}
local TestArrayPairs = {}
local TestArrayPut = {}
local TestArrayRemove = {}
local TestArraySlice = {}
local TestArraySwap = {}
local TestArrayToString = {}

function TestArrayClear:testAllowsReuse()
	local array = Array.new({ 1, 2 })

	array:clear()
	array:insert(3)

	lu.assertEquals(valuesOf(array), { 3 })
end

function TestArrayClear:testCanClearRepeatedly()
	local array = Array.new({ 1 })

	array:clear()
	array:clear()

	lu.assertTrue(array:empty())
end

function TestArrayClear:testEmptiesPopulatedArray()
	local array = Array.new({ 1, 2, 3 })

	array:clear()

	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
	lu.assertEquals(valuesOf(array), {})
end

function TestArrayClear:testIsSafeOnEmptyArray()
	local array = Array.new()

	array:clear()

	lu.assertTrue(array:empty())
end

function TestArrayConcat:testAppendsAnotherArray()
	local left = Array.new({ 1, 2 })
	local right = Array.new({ 3, 4 })

	local result = left .. right

	lu.assertEquals(valuesOf(result), { 1, 2, 3, 4 })
	lu.assertEquals(valuesOf(left), { 1, 2 })
	lu.assertEquals(valuesOf(right), { 3, 4 })
end

function TestArrayConcat:testAppendsPlainTableValues()
	local array = Array.new({ 1, 2 })

	local result = array .. { 3, 4 }

	lu.assertEquals(valuesOf(result), { 1, 2, 3, 4 })
end

function TestArrayConcat:testEmptyOperandsProduceIndependentEmptyResult()
	local left = Array.new()
	local right = Array.new()
	local result = left .. right

	lu.assertTrue(result:empty())
	lu.assertFalse(rawequal(result, left))
	lu.assertFalse(rawequal(result, right))
end

function TestArrayConcat:testNilReturnsUnchangedCopy()
	local source = Array.new({ 1, 2 })

	local result = source .. nil

	lu.assertFalse(rawequal(result, source))
	lu.assertEquals(valuesOf(result), { 1, 2 })
	lu.assertEquals(valuesOf(source), { 1, 2 })
end

function TestArrayConcat:testPreservesFalseValues()
	local result = Array.new({ false }) .. { true, false }

	lu.assertEquals(valuesOf(result), { false, true, false })
end

function TestArrayConcat:testRejectsNonTableRightOperand()
	local array = Array.new({ 1 })

	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = array .. 2
	end)
	lu.assertErrorMsgContains("iterable should be a table", function()
		local _ = array .. "text"
	end)
end

function TestArrayConcat:testSelfConcatenationProducesFiniteCopy()
	local source = Array.new({ 1, 2 })

	local result = source .. source

	lu.assertEquals(valuesOf(source), { 1, 2 })
	lu.assertEquals(valuesOf(result), { 1, 2, 1, 2 })
end

function TestArrayContains:testDoesNotChangeArray()
	local array = Array.new({ 1, 2, 3 })

	lu.assertTrue(array:contains(2))
	lu.assertEquals(valuesOf(array), { 1, 2, 3 })
end

function TestArrayContains:testFindsPresentValue()
	lu.assertTrue(Array.new({ "a", "b" }):contains("b"))
end

function TestArrayContains:testHandlesDuplicatesAndFalse()
	local array = Array.new({ false, false, true })

	lu.assertTrue(array:contains(false))
	lu.assertTrue(array:contains(true))
	lu.assertEquals(#array, 3)
end

function TestArrayContains:testRejectsNil()
	lu.assertErrorMsgContains("value should not be nil", function()
		Array.new():contains(nil)
	end)
end

function TestArrayContains:testReturnsFalseForMissingValue()
	lu.assertFalse(Array.new({ "a", "b" }):contains("c"))
end

function TestArrayEmpty:testReportsFalseAfterInsertion()
	lu.assertFalse(Array.new({ 1 }):empty())
end

function TestArrayEmpty:testReportsTrueAfterRemovalOfLastValue()
	local array = Array.new({ 1 })
	array:remove(1)

	lu.assertTrue(array:empty())
end

function TestArrayEmpty:testReportsTrueForEmptyArray()
	lu.assertTrue(Array.new():empty())
end

function TestArrayEq:testComparesFalseAndTrueAsDifferentValues()
	lu.assertFalse(Array.new({ false }) == Array.new({ true }))
end

function TestArrayEq:testComparesSameInstanceEqual()
	local array = Array.new({ 1, false })

	lu.assertTrue(array == array)
end

function TestArrayEq:testDifferentLengthsCompareFalse()
	lu.assertFalse(Array.new({ 1 }) == Array.new({ 1, 2 }))
end

function TestArrayEq:testDifferentValuesCompareFalse()
	lu.assertFalse(Array.new({ 1, 2 }) == Array.new({ 1, 3 }))
end

function TestArrayEq:testEqualArraysCompareTrue()
	lu.assertTrue(Array.new({ 1, 2 }) == Array.new({ 1, 2 }))
end

function TestArrayEq:testEqualArraysWithFalseCompareTrue()
	lu.assertTrue(Array.new({ false, 1 }) == Array.new({ false, 1 }))
end

function TestArrayEq:testNonArrayOperandsCompareFalse()
	local array = Array.new({ 1, 2 })

	lu.assertFalse(array == {})
	lu.assertFalse(array == { 1, 2 })
	lu.assertFalse(array == "array")
	lu.assertFalse(array == nil)
end

function TestArrayGet:testRejectsAnyIndexOnEmptyArray()
	lu.assertErrorMsgContains("index out of bounds", function()
		Array.new():get(1)
	end)
end

function TestArrayGet:testRejectsIndexesOutsideArrayBounds()
	local array = Array.new({ 10, 20 })

	for _, index in ipairs({ 0, -1, 3 }) do
		lu.assertErrorMsgContains("index out of bounds", function()
			array:get(index)
		end)
	end
end

function TestArrayGet:testRejectsNonIntegerIndexes()
	local array = Array.new({ 10, 20 })

	for _, index in ipairs({ "1", true, 1.5, math.huge, 0 / 0 }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:get(index)
		end)
	end
	lu.assertErrorMsgContains("index should be an integer", function()
		array:get(nil)
	end)
end

function TestArrayGet:testRejectsOtherInvalidIndexTypes()
	local array = Array.new({ 10 })

	for _, index in ipairs({ {}, function() end }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:get(index)
		end)
	end
end

function TestArrayGet:testReturnsFalseValue()
	lu.assertFalse(Array.new({ false }):get(1))
end

function TestArrayGet:testReturnsFirstMiddleAndLastValues()
	local array = Array.new({ 10, 20, 30 })

	lu.assertEquals(array:get(1), 10)
	lu.assertEquals(array:get(2), 20)
	lu.assertEquals(array:get(3), 30)
end

function TestArrayIndexOf:testDoesNotChangeArray()
	local array = Array.new({ "a", "b" })

	array:indexOf("b")

	lu.assertEquals(valuesOf(array), { "a", "b" })
end

function TestArrayIndexOf:testRejectsNil()
	lu.assertErrorMsgContains("value should not be nil", function()
		Array.new():indexOf(nil)
	end)
end

function TestArrayIndexOf:testReturnsFirstDuplicatePosition()
	lu.assertEquals(Array.new({ "x", "y", "x" }):indexOf("x"), 1)
end

function TestArrayIndexOf:testReturnsFirstPositionWhenFalseIsDuplicated()
	lu.assertEquals(Array.new({ false, true, false }):indexOf(false), 1)
end

function TestArrayIndexOf:testReturnsNilForEmptyArray()
	lu.assertNil(Array.new():indexOf("missing"))
end

function TestArrayIndexOf:testReturnsNilWhenValueIsMissing()
	lu.assertNil(Array.new({ 1, 2 }):indexOf(3))
end

function TestArrayIndexOf:testReturnsPositionOfFalse()
	lu.assertEquals(Array.new({ true, false }):indexOf(false), 2)
end

function TestArrayInsert:testAcceptsFalseValue()
	local array = Array.new()

	array:insert(false)

	lu.assertEquals(#array, 1)
	lu.assertFalse(array:get(1))
end

function TestArrayInsert:testAppendsWhenIndexIsOmitted()
	local array = Array.new({ 1 })

	array:insert(2)

	lu.assertEquals(valuesOf(array), { 1, 2 })
end

function TestArrayInsert:testRejectsIndexesOutsideInsertionBounds()
	local array = Array.new({ 1, 2 })

	for _, index in ipairs({ 0, -1, 4 }) do
		lu.assertErrorMsgContains("index out of bounds", function()
			array:insert(3, index)
		end)
	end
end

function TestArrayInsert:testRejectsInvalidIndexTypesAndFractions()
	local array = Array.new({ 1, 2 })

	for _, index in ipairs({ "1", true, 1.5, math.huge, 0 / 0 }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:insert(3, index)
		end)
	end
end

function TestArrayInsert:testRejectsNilValue()
	lu.assertErrorMsgContains("value should not be nil", function()
		Array.new():insert(nil)
	end)
end

function TestArrayInsert:testRejectsNonNumericIndexTypes()
	local array = Array.new({ 1 })

	for _, index in ipairs({ {}, function() end }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:insert(2, index)
		end)
	end
end

function TestArrayInsert:testShiftsValuesAtBeginningMiddleAndEnd()
	local first = Array.new({ 2, 3 })
	local middle = Array.new({ 1, 3 })
	local last = Array.new({ 1, 2 })

	first:insert(1, 1)
	middle:insert(2, 2)
	last:insert(3, 3)

	lu.assertEquals(valuesOf(first), { 1, 2, 3 })
	lu.assertEquals(valuesOf(middle), { 1, 2, 3 })
	lu.assertEquals(valuesOf(last), { 1, 2, 3 })
end

function TestArrayInsert:testWorksOnEmptyArrayAtIndexOne()
	local array = Array.new()

	array:insert("first", 1)

	lu.assertEquals(valuesOf(array), { "first" })
end

function TestArrayInsertAll:testAcceptsArrayAsEmptyInput()
	local array = Array.new({ 1, 2 })

	array:insertAll(Array.new())

	lu.assertEquals(valuesOf(array), { 1, 2 })
end

function TestArrayInsertAll:testAppendsValuesInSequenceOrder()
	local array = Array.new({ 1 })

	array:insertAll({ 2, 3, 4 })

	lu.assertEquals(valuesOf(array), { 1, 2, 3, 4 })
end

function TestArrayInsertAll:testCopiesValuesFromAnotherArray()
	local source = Array.new({ 2, 3 })
	local target = Array.new({ 1 })

	target:insertAll(source)

	lu.assertEquals(valuesOf(target), { 1, 2, 3 })
	lu.assertEquals(valuesOf(source), { 2, 3 })
end

function TestArrayInsertAll:testEmptyInputLeavesArrayUnchanged()
	local array = Array.new({ 1, 2 })

	array:insertAll({})

	lu.assertEquals(valuesOf(array), { 1, 2 })
end

function TestArrayInsertAll:testPreservesFalseValues()
	local array = Array.new({ 1 })

	array:insertAll({ false, true })

	lu.assertEquals(#array, 3)
	lu.assertEquals(array:get(1), 1)
	lu.assertFalse(array:get(2))
	lu.assertTrue(array:get(3))
end

function TestArrayInsertAll:testRejectsNonTableInputs()
	local array = Array.new()

	for _, input in ipairs({ "text", 42, true }) do
		lu.assertErrorMsgContains("iterable should be a table", function()
			array:insertAll(input)
		end)
	end
	lu.assertErrorMsgContains("iterable should be a table", function()
		array:insertAll(nil)
	end)
end

function TestArrayIsArray:testRecognizesEmptyAndPopulatedInstances()
	lu.assertTrue(Array.isArray(Array.new()))
	lu.assertTrue(Array.isArray(Array.new({ 1, 2 })))
end

function TestArrayIsArray:testRejectsNonInstances()
	for _, value in ipairs({ {}, { 1, 2 }, "text", 42, true }) do
		lu.assertFalse(Array.isArray(value))
	end
	lu.assertFalse(Array.isArray(nil))
end

function TestArrayIsArray:testRejectsTableWithDifferentMetatable()
	lu.assertFalse(Array.isArray(setmetatable({}, {})))
end

function TestArrayLen:testTracksEmptyAndPopulatedArrays()
	local array = Array.new()
	lu.assertEquals(#array, 0)

	array:insert(1)
	array:insert(2)
	lu.assertEquals(#array, 2)

	array:remove(1)
	lu.assertEquals(#array, 1)
	array:clear()
	lu.assertEquals(#array, 0)
end

function TestArrayNew:testConstructsIndependentArraysFromSameSource()
	local source = { 1, 2 }
	local first = Array.new(source)
	local second = Array.new(source)

	first:put(1, 9)

	lu.assertEquals(valuesOf(second), { 1, 2 })
	lu.assertEquals(source, { 1, 2 })
end

function TestArrayNew:testCopiesAnotherArrayIndependently()
	local source = Array.new({ 1, 2 })
	local copy = Array.new(source)
	copy:put(1, 9)

	lu.assertEquals(valuesOf(source), { 1, 2 })
	lu.assertEquals(valuesOf(copy), { 9, 2 })
end

function TestArrayNew:testCopiesPlainTableValues()
	local source = { 1, 2, 3 }
	local array = Array.new(source)

	source[1] = 99
	lu.assertEquals(valuesOf(array), { 1, 2, 3 })
end

function TestArrayNew:testDefaultsToEmptyArray()
	local array = Array.new()

	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

function TestArrayNew:testNilIterableCreatesEmptyArray()
	lu.assertTrue(Array.new(nil):empty())
end

function TestArrayNew:testRejectsFunctionIterable()
	lu.assertErrorMsgContains("iterable should be a table", function()
		Array.new(function() end)
	end)
end

function TestArrayNew:testRejectsNonTableIterables()
	for _, input in ipairs({ "text", 42, true }) do
		lu.assertErrorMsgContains("iterable should be a table", function()
			Array.new(input)
		end)
	end
end

function TestArrayNewIndex:testRejectsArbitraryProperties()
	local array = Array.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.extra = true
	end)
end

function TestArrayNewIndex:testRejectsMethodReplacement()
	local array = Array.new()

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array.get = function() end
	end)
end

function TestArrayNewIndex:testRejectsNumericWrites()
	local array = Array.new({ 1 })

	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array[1] = 2
	end)
	lu.assertErrorMsgContains("cannot add new properties, methods or functions to Array", function()
		array[2] = 3
	end)
end

function TestArrayPairs:testEmptyArrayYieldsNothing()
	local count = 0
	for _ in pairs(Array.new()) do
		count = count + 1
	end
	lu.assertEquals(count, 0)
end

function TestArrayPairs:testRepeatedTraversalDoesNotConsumeArray()
	local array = Array.new({ 1, 2 })
	local firstPass = valuesOf(array)
	local secondPass = valuesOf(array)

	lu.assertEquals(firstPass, { 1, 2 })
	lu.assertEquals(secondPass, { 1, 2 })
	lu.assertEquals(#array, 2)
end

function TestArrayPairs:testStopsAfterLastEntry()
	local array = Array.new({ "only" })
	local iterator, state, key = pairs(array)

	local firstIndex, firstValue = iterator(state, key)
	local nextIndex, nextValue = iterator(state, firstIndex)

	lu.assertEquals(firstIndex, 1)
	lu.assertEquals(firstValue, "only")
	lu.assertNil(nextIndex)
	lu.assertNil(nextValue)
end

function TestArrayPairs:testYieldsOneBasedIndexesInOrder()
	local array = Array.new({ "a", "b", "c" })
	local keys, values = {}, {}

	for key, value in pairs(array) do
		table.insert(keys, key)
		table.insert(values, value)
	end

	lu.assertEquals(keys, { 1, 2, 3 })
	lu.assertEquals(values, { "a", "b", "c" })
end

function TestArrayPut:testAcceptsFalseValue()
	local array = Array.new({ true })
	array:put(1, false)

	lu.assertFalse(array:get(1))
end

function TestArrayPut:testAtNextIndexAppends()
	local array = Array.new({ 1, 2 })

	array:put(3, 3)

	lu.assertEquals(valuesOf(array), { 1, 2, 3 })
end

function TestArrayPut:testOverwritesWithoutShifting()
	local array = Array.new({ 10, 20, 30 })

	array:put(2, 99)

	lu.assertEquals(valuesOf(array), { 10, 99, 30 })
	lu.assertEquals(#array, 3)
end

function TestArrayPut:testRejectsInvalidIndexesAndNilValues()
	local array = Array.new({ 1, 2 })

	for _, index in ipairs({ 0, -1, 4 }) do
		lu.assertErrorMsgContains("index out of bounds", function()
			array:put(index, 3)
		end)
	end
	for _, index in ipairs({ "1", true, 1.5, math.huge, 0 / 0 }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:put(index, 3)
		end)
	end
	lu.assertErrorMsgContains("value should not be nil", function()
		array:put(1, nil)
	end)
end

function TestArrayPut:testRejectsOtherInvalidIndexTypes()
	local array = Array.new({ 1 })

	for _, index in ipairs({ {}, function() end }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:put(index, 2)
		end)
	end
end

function TestArrayPut:testReplacesFirstAndLastValues()
	local array = Array.new({ 1, 2, 3 })

	array:put(1, 10)
	array:put(3, 30)

	lu.assertEquals(valuesOf(array), { 10, 2, 30 })
end

function TestArrayPut:testWritesAtFirstIndexOfEmptyArray()
	local array = Array.new()
	array:put(1, "first")

	lu.assertEquals(valuesOf(array), { "first" })
end

function TestArrayRemove:testRejectsIndexesOutsideBounds()
	local array = Array.new({ 1, 2 })

	for _, index in ipairs({ 0, -1, 3 }) do
		lu.assertErrorMsgContains("index out of bounds", function()
			array:remove(index)
		end)
	end
	lu.assertErrorMsgContains("index out of bounds", function()
		Array.new():remove(1)
	end)
end

function TestArrayRemove:testRejectsNonIntegerIndexes()
	local array = Array.new({ 1, 2 })

	for _, index in ipairs({ "1", true, 1.5, math.huge, 0 / 0 }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:remove(index)
		end)
	end
	lu.assertErrorMsgContains("index should be an integer", function()
		array:remove(nil)
	end)
end

function TestArrayRemove:testRejectsOtherInvalidIndexTypes()
	local array = Array.new({ 1 })

	for _, index in ipairs({ {}, function() end }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:remove(index)
		end)
	end
end

function TestArrayRemove:testRemovesOnlyEntry()
	local array = Array.new({ "only" })

	lu.assertEquals(array:remove(1), "only")
	lu.assertTrue(array:empty())
	lu.assertEquals(#array, 0)
end

function TestArrayRemove:testReturnsAndRemovesFirstMiddleAndLastValues()
	local first = Array.new({ 1, 2, 3 })
	local middle = Array.new({ 1, 2, 3 })
	local last = Array.new({ 1, 2, 3 })

	lu.assertEquals(first:remove(1), 1)
	lu.assertEquals(middle:remove(2), 2)
	lu.assertEquals(last:remove(3), 3)
	lu.assertEquals(valuesOf(first), { 2, 3 })
	lu.assertEquals(valuesOf(middle), { 1, 3 })
	lu.assertEquals(valuesOf(last), { 1, 2 })
end

function TestArrayRemove:testReturnsFalseValue()
	local array = Array.new({ false, true })

	lu.assertFalse(array:remove(1))
	lu.assertEquals(valuesOf(array), { true })
end

function TestArraySlice:testCopiesInclusiveRange()
	local source = Array.new({ 10, 20, 30, 40 })
	local slice = source:slice(2, 3)
	slice:put(1, 99)

	lu.assertEquals(valuesOf(slice), { 99, 30 })
	lu.assertEquals(valuesOf(source), { 10, 20, 30, 40 })
end

function TestArraySlice:testDefaultsStartAndFinish()
	local array = Array.new({ 1, 2, 3 })

	lu.assertEquals(valuesOf(array:slice()), { 1, 2, 3 })
	lu.assertEquals(valuesOf(array:slice(2)), { 2, 3 })
	lu.assertEquals(valuesOf(array:slice(nil, 2)), { 1, 2 })
end

function TestArraySlice:testEmptySourceCurrentlyRejectsDefaultRange()
	lu.assertErrorMsgContains("start index out of bounds", function()
		Array.new():slice()
	end)
end

function TestArraySlice:testRejectsInvalidStartAndFinishTypes()
	local array = Array.new({ 1, 2, 3 })

	for _, index in ipairs({ "1", true, {}, function() end, math.huge, 0 / 0 }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:slice(index, 2)
		end)
		lu.assertErrorMsgContains("index should be an integer", function()
			array:slice(1, index)
		end)
	end
end

function TestArraySlice:testRejectsNonIntegerBounds()
	local array = Array.new({ 1, 2, 3 })

	lu.assertErrorMsgContains("index should be an integer", function()
		array:slice(1.5, 3)
	end)
	lu.assertErrorMsgContains("index should be an integer", function()
		array:slice(1, 2.5)
	end)
end

function TestArraySlice:testRejectsOutOfBoundsAndReversedRanges()
	local array = Array.new({ 1, 2, 3 })

	lu.assertErrorMsgContains("start index out of bounds", function()
		array:slice(0, 2)
	end)
	lu.assertErrorMsgContains("start index out of bounds", function()
		array:slice(4, 4)
	end)
	lu.assertErrorMsgContains("finish index out of bounds", function()
		array:slice(1, 0)
	end)
	lu.assertErrorMsgContains("start index must be lesser or equal to finish index", function()
		array:slice(3, 2)
	end)
end

function TestArraySlice:testSingleElementRangeReturnsSingleElement()
	local slice = Array.new({ 1, 2, 3 }):slice(2, 2)

	lu.assertEquals(valuesOf(slice), { 2 })
end

function TestArraySwap:testAcceptsFalseValues()
	local array = Array.new({ false, true })

	array:swap(1, 2)

	lu.assertTrue(array:get(1))
	lu.assertFalse(array:get(2))
end

function TestArraySwap:testExchangesValues()
	local array = Array.new({ 1, 2, 3 })

	array:swap(1, 3)

	lu.assertEquals(valuesOf(array), { 3, 2, 1 })
end

function TestArraySwap:testRejectsNonIntegerIndexes()
	local array = Array.new({ 1, 2 })

	lu.assertErrorMsgContains("index should be an integer", function()
		array:swap(1.5, 2)
	end)
	lu.assertErrorMsgContains("index should be an integer", function()
		array:swap(1, 1.5)
	end)
end

function TestArraySwap:testRejectsOtherInvalidIndexTypes()
	local array = Array.new({ 1, 2 })

	for _, index in ipairs({ "1", true, {}, function() end, math.huge, 0 / 0 }) do
		lu.assertErrorMsgContains("index should be an integer", function()
			array:swap(index, 2)
		end)
		lu.assertErrorMsgContains("index should be an integer", function()
			array:swap(1, index)
		end)
	end
end

function TestArraySwap:testRejectsOutOfBoundsIndexes()
	local array = Array.new({ 1, 2 })

	lu.assertErrorMsgContains("index out of bounds", function()
		array:swap(0, 1)
	end)
	lu.assertErrorMsgContains("other index out of bounds", function()
		array:swap(1, 3)
	end)
	lu.assertErrorMsgContains("index out of bounds", function()
		Array.new():swap(1, 1)
	end)
end

function TestArraySwap:testSameIndexLeavesArrayUnchanged()
	local array = Array.new({ 1, 2 })
	array:swap(2, 2)

	lu.assertEquals(valuesOf(array), { 1, 2 })
end

function TestArrayToString:testFormatsEmptyArray()
	lu.assertEquals(tostring(Array.new()), "[  ]")
end

function TestArrayToString:testFormatsMultipleNumbers()
	lu.assertEquals(tostring(Array.new({ 0, -2, 3.5 })), "[ 0, -2, 3.5 ]")
end

function TestArrayToString:testFormatsStringAndNumberValues()
	lu.assertEquals(tostring(Array.new({ "one", 2, "three" })), "[ one, 2, three ]")
end

function TestArrayToString:testUnsupportedValuesRaiseFromTableConcat()
	lu.assertErrorMsgContains("invalid value", function()
		tostring(Array.new({ false }))
	end)
	lu.assertErrorMsgContains("invalid value", function()
		tostring(Array.new({ {} }))
	end)
end

return {
	TestArrayClear = TestArrayClear,
	TestArrayConcat = TestArrayConcat,
	TestArrayContains = TestArrayContains,
	TestArrayEmpty = TestArrayEmpty,
	TestArrayEq = TestArrayEq,
	TestArrayGet = TestArrayGet,
	TestArrayIndexOf = TestArrayIndexOf,
	TestArrayInsert = TestArrayInsert,
	TestArrayInsertAll = TestArrayInsertAll,
	TestArrayIsArray = TestArrayIsArray,
	TestArrayLen = TestArrayLen,
	TestArrayNew = TestArrayNew,
	TestArrayNewIndex = TestArrayNewIndex,
	TestArrayPairs = TestArrayPairs,
	TestArrayPut = TestArrayPut,
	TestArrayRemove = TestArrayRemove,
	TestArraySlice = TestArraySlice,
	TestArraySwap = TestArraySwap,
	TestArrayToString = TestArrayToString,
}
