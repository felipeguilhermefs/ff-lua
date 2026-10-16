-- Imports
local lu = require("luaunit")
local tail = require("ff.func.tail")

-- Suite definitions
local TestTailString = {}
local TestTailNoop = {}

-- Scenarios: string inputs
function TestTailString:testTailOfEmptyStringReturnsEmptyString()
	-- Given: the input contains no characters.
	-- When: call tail with that input.
	-- Then: the returned string is empty.
	lu.assertEquals(tail(""), "")
end

function TestTailString:testTailOfSingleCharacterStringReturnsEmptyString()
	-- Given: each input contains exactly one character.
	-- When: call tail with each input.
	-- Then: removing the first character leaves an empty string.
	lu.assertEquals(tail("a"), "")
	lu.assertEquals(tail(" "), "")
end

function TestTailString:testTailOfStringReturnsCharactersAfterFirst()
	-- Given: inputs contain several characters, including a leading tab.
	-- When: call tail with each string.
	-- Then: each result contains all characters after the first.
	lu.assertEquals(tail("flores"), "lores")
	lu.assertEquals(tail("1234"), "234")
	lu.assertEquals(tail("\tlol"), "lol")
end

-- Scenarios: unsupported inputs
function TestTailNoop:testUnsupportedInputsReturnNil()
	-- Given: inputs include nil, numbers, booleans, and tables.
	-- When: pass each unsupported value to tail.
	-- Then: every call returns nil.
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
