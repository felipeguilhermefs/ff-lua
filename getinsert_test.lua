lu = require "luaunit"
getinsert = require "getinsert"

function test_keyAbsent_useCompute()
  local dict = {}

  local computed = false
  local compute = function(key)
    computed = true
    return 123
  end

  lu.assertEquals(getinsert(dict, "absent", compute), 123)
  lu.assertTrue(computed)
end

function test_keyPresent_doNotUseCompute()
  local dict = {["present"] = 456}

  local computed = false
  local compute = function(key)
    computed = true
    return 123
  end

  lu.assertEquals(getinsert(dict, "present", compute), 456)
  lu.assertFalse(computed)
end

function test_nonTable_returnNil()
  lu.assertNil(getinsert(nil, "nil", nil))
  lu.assertNil(getinsert(true, "nil", nil))
  lu.assertNil(getinsert("abc", "nil", nil))
end

os.exit(lu.LuaUnit.run())

