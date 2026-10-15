local lu = require("luaunit")
local head = require("ff.func.head")

local TestHeadString = {}
local TestHeadNoop = {}

function TestHeadString:testHeadOfEmptyString_ReturnsEmptyString()
	lu.assertEquals(head(""), "")
end

function TestHeadString:testHeadOfSingleCharacterString_ReturnsThatCharacter()
	lu.assertEquals(head("a"), "a")
	lu.assertEquals(head(" "), " ")
end

function TestHeadString:testHeadOfString_ReturnsFirstCharacter()
	lu.assertEquals(head("flores"), "f")
	lu.assertEquals(head("1234"), "1")
	lu.assertEquals(head("\tlol"), "\t")
end

function TestHeadNoop:testUnsupportedInputs_ReturnsNil()
	lu.assertNil(head(nil))
	lu.assertNil(head(0))
	lu.assertNil(head(true))
	lu.assertNil(head({ "a" }))
	lu.assertNil(head({ b = 2 }))
end

return {
	TestHeadString = TestHeadString,
	TestHeadNoop = TestHeadNoop,
}
