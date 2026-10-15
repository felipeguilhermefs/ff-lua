local lu = require "luaunit"
local head = require("ff.func.head")

-------------------------------
-- String Test Suite [begin] --
-------------------------------

local TestHeadString = {}
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

------------------------------
-- String Test Suite [end] ---
------------------------------

--------------------------------------
-- Non Supported Test Suite [begin] --
--------------------------------------

local TestHeadNoop = {}
function TestHeadNoop:testHeadOfNilReturnsNil()
  lu.assertNil(head(0))
  lu.assertNil(head(true))
  lu.assertNil(head({"a"}))
  lu.assertNil(head({b = 2}))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------

return {
	TestHeadString = TestHeadString,
	TestHeadNoop = TestHeadNoop,
}
