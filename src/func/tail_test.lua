local lu = require("luaunit")
local tail = require("ff.func.tail")

local TestTailString = {}
local TestTailNoop = {}

function TestTailString:testTailOfEmptyString_ReturnsEmptyString()
	lu.assertEquals(tail(""), "")
end

function TestTailString:testTailOfSingleCharacterString_ReturnsEmptyString()
	lu.assertEquals(tail("a"), "")
	lu.assertEquals(tail(" "), "")
end

function TestTailString:testTailOfString_ReturnsCharactersAfterFirst()
	lu.assertEquals(tail("flores"), "lores")
	lu.assertEquals(tail("1234"), "234")
	lu.assertEquals(tail("\tlol"), "lol")
end

function TestTailNoop:testUnsupportedInputs_ReturnsNil()
	lu.assertNil(tail(nil))
	lu.assertNil(tail(0))
	lu.assertNil(tail(true))
	lu.assertNil(tail({ "a" }))
	lu.assertNil(tail({ b = 2 }))
end

return {
	TestTailString = TestTailString,
	TestTailNoop = TestTailNoop,
}
