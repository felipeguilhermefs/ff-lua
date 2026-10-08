lu = require "luaunit"
tail = require("ff.func.tail")

-------------------------------
-- String Test Suite [begin] --
-------------------------------

TestTailString = {}

function TestTailString:testTail_Empty()
  lu.assertEquals(tail(""), "")
end

function TestTailString:testTail_SingleChar()
  lu.assertEquals(tail("a"), "")
  lu.assertEquals(tail(" "), "")
end

function TestTailString:testTail_MultiChar()
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

TestTailNoop = {}

function TestTailNoop:testTail_Nil()
  lu.assertNil(tail(0))
  lu.assertNil(tail(true))
  lu.assertNil(tail({"a"}))
  lu.assertNil(tail({b = 2}))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------


