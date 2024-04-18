lu = require "luaunit"
empty = require "empty"

-------------------------------
-- String Test Suite [begin] --
-------------------------------

TestString = {}

function TestString:test_empty()
  lu.assertTrue(empty(""))
end

function TestString:test_nonEmpty()
  lu.assertFalse(empty("a"))
  lu.assertFalse(empty(" "))
end

------------------------------
-- String Test Suite [end] ---
------------------------------

------------------------------
-- Array Test Suite [start] --
------------------------------

TestArray = {}

function TestArray:test_empty()
  lu.assertTrue(empty({}))
  lu.assertTrue(empty({nil}))
end

function TestArray:test_nonEmpty()
  lu.assertFalse(empty({0}))
  lu.assertFalse(empty({false}))
  lu.assertFalse(empty({""}))
  lu.assertFalse(empty({{}}))
  lu.assertFalse(empty({1, true, "s", {1}}))
end

----------------------------
-- Array Test Suite [end] --
----------------------------

----------------------------
-- Map Test Suite [begin] --
----------------------------

TestMap = {}

function TestMap:test_empty()
  lu.assertTrue(empty({}))
  lu.assertTrue(empty({["a"] = nil}))
end

function TestMap:test_nonEmpty()
  lu.assertFalse(empty({a = 0}))
  lu.assertFalse(empty({[false] = true}))
  lu.assertFalse(empty({[""] = "v"}))
  lu.assertFalse(empty({["l"] = {}}))
  lu.assertFalse(empty({[1] = true, [10] = {1}}))
end

--------------------------
-- Map Test Suite [end] --
--------------------------

--------------------------------------
-- Non Supported Test Suite [begin] --
--------------------------------------

TestNoop = {}

function TestNoop:test_nil()
  lu.assertNil(empty(0))
  lu.assertNil(empty(true))
  lu.assertNil(empty(1.6))
end
------------------------------------
-- Non Supported Test Suite [end] --
------------------------------------
os.exit(lu.LuaUnit.run())

