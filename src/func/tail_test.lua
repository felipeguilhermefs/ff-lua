local lu = require "luaunit"
local tail = require("ff.func.tail")

-------------------------------
-- String Test Suite [begin] --
-------------------------------

local TestTailString = {}
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

------------------------------
-- String Test Suite [end] ---
------------------------------

--------------------------------------
-- Non Supported Test Suite [begin] --
--------------------------------------

local TestTailNoop = {}
function TestTailNoop:testTailOfNilReturnsNil()
  lu.assertNil(tail(0))
  lu.assertNil(tail(true))
  lu.assertNil(tail({"a"}))
  lu.assertNil(tail({b = 2}))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------

return {
	TestTailString = TestTailString,
	TestTailNoop = TestTailNoop,
}
