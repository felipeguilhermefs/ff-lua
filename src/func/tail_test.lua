-- Imports
local lu = require("luaunit")
local tail = require("ff.func.tail")

-- Suite definitions
local TestTailString = {}
local TestTailNoop = {}

-- Scenarios: string inputs
function TestTailString:testTailOfEmptyStringReturnsEmptyString()
	lu.assertEquals(tail(""), "")
end

function TestTailString:testTailOfSingleCharacterStringReturnsEmptyString()
	lu.assertEquals(tail("a"), "")
	lu.assertEquals(tail(" "), "")
end

function TestTailString:testTailOfStringReturnsCharactersAfterFirst()
	lu.assertEquals(tail("flores"), "lores")
	lu.assertEquals(tail("1234"), "234")
	lu.assertEquals(tail("\tlol"), "lol")
end

-- Scenarios: unsupported inputs
function TestTailNoop:testUnsupportedInputsReturnNil()
	lu.assertNil(tail(nil))
	lu.assertNil(tail(0))
	lu.assertNil(tail(true))
	lu.assertNil(tail({ "a" }))
	lu.assertNil(tail({ b = 2 }))
end

-- Suite map
return {
	TestTailString = TestTailString,
	TestTailNoop = TestTailNoop,
}
