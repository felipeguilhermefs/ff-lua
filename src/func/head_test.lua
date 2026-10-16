-- Imports
local lu = require("luaunit")
local head = require("ff.func.head")

-- Suite definitions
local TestHeadString = {}
local TestHeadNoop = {}

-- Scenarios: string inputs
function TestHeadString:testHeadOfEmptyStringReturnsEmptyString()
	lu.assertEquals(head(""), "")
end

function TestHeadString:testHeadOfSingleCharacterStringReturnsThatCharacter()
	lu.assertEquals(head("a"), "a")
	lu.assertEquals(head(" "), " ")
end

function TestHeadString:testHeadOfStringReturnsFirstCharacter()
	lu.assertEquals(head("flores"), "f")
	lu.assertEquals(head("1234"), "1")
	lu.assertEquals(head("\tlol"), "\t")
end

-- Scenarios: unsupported inputs
function TestHeadNoop:testUnsupportedInputsReturnNil()
	lu.assertNil(head(nil))
	lu.assertNil(head(0))
	lu.assertNil(head(true))
	lu.assertNil(head({ "a" }))
	lu.assertNil(head({ b = 2 }))
end

-- Suite map
return {
	TestHeadString = TestHeadString,
	TestHeadNoop = TestHeadNoop,
}
