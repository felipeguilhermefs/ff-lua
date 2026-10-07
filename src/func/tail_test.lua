lu = require "luaunit"
tail = require("ff.func.tail")

-------------------------------
-- String Test Suite [begin] --
-------------------------------

TestTailString = {}

function TestTailString:test_empty()
  lu.assertEquals(tail(""), "")
end

function TestTailString:test_singleChar()
  lu.assertEquals(tail("a"), "")
  lu.assertEquals(tail(" "), "")
end

function TestTailString:test_multiChar()
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

function TestTailNoop:test_nil()
  lu.assertNil(tail(0))
  lu.assertNil(tail(true))
  lu.assertNil(tail({"a"}))
  lu.assertNil(tail({b = 2}))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------


