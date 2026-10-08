lu = require "luaunit"
head = require("ff.func.head")

-------------------------------
-- String Test Suite [begin] --
-------------------------------

TestHeadString = {}

function TestHeadString:testHead_Empty()
  lu.assertEquals(head(""), "")
end

function TestHeadString:testHead_SingleChar()
  lu.assertEquals(head("a"), "a")
  lu.assertEquals(head(" "), " ")
end

function TestHeadString:testHead_MultiChar()
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

TestHeadNoop = {}

function TestHeadNoop:testHead_Nil()
  lu.assertNil(head(0))
  lu.assertNil(head(true))
  lu.assertNil(head({"a"}))
  lu.assertNil(head({b = 2}))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------


