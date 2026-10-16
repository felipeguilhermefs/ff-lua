-- Imports
local lu = require("luaunit")
local head = require("ff.func.head")

-- Suite definitions
local TestHeadString = {}
local TestHeadNoop = {}

-- Scenarios: string inputs
function TestHeadString:testHeadOfEmptyStringReturnsEmptyString()
	-- Given: the input contains no characters.
	-- When: call head with that input.
	-- Then: the returned string is empty.
	lu.assertEquals(head(""), "")
end

function TestHeadString:testHeadOfSingleCharacterStringReturnsThatCharacter()
	-- Given: each input contains exactly one character.
	-- When: call head with each input.
	-- Then: each result matches its input character.
	lu.assertEquals(head("a"), "a")
	lu.assertEquals(head(" "), " ")
end

function TestHeadString:testHeadOfStringReturnsFirstCharacter()
	-- Given: inputs contain several characters, including a leading tab.
	-- When: call head with each string.
	-- Then: each result contains only the first character.
	lu.assertEquals(head("flores"), "f")
	lu.assertEquals(head("1234"), "1")
	lu.assertEquals(head("\tlol"), "\t")
end

-- Scenarios: unsupported inputs
function TestHeadNoop:testUnsupportedInputsReturnNil()
	-- Given: inputs include nil, numbers, booleans, and tables.
	-- When: pass each unsupported value to head.
	-- Then: every call returns nil.
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
