lu = require "luaunit"
tail = require "tail"

-------------------------------
-- String Test Suite [begin] --
-------------------------------

TestString = {}

function TestString:test_empty()
  lu.assertEquals(tail(""), "")
end

function TestString:test_singleChar()
  lu.assertEquals(tail("a"), "")
  lu.assertEquals(tail(" "), "")
end

function TestString:test_multiChar()
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

TestNoop = {}

function TestNoop:test_nil()
  lu.assertNil(tail(0))
  lu.assertNil(tail(true))
  lu.assertNil(tail({"a"}))
  lu.assertNil(tail({b = 2}))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------

os.exit(lu.LuaUnit.run())

