lu = require "luaunit"
stack = require "stack"

function test_empty()
  local s = stack()
  lu.assertTrue(s.empty())
  lu.assertNil(s.pop())
end

function test_singleItem()
  local s = stack()
  s.push(1)

  lu.assertFalse(s.empty())
  lu.assertEquals(s.pop(), 1)
  lu.assertTrue(s.empty())
end

function test_multipleItems()
  local s = stack()
  s.push(1)
  s.push(true)
  s.push("abc")
  s.push({4, 5, 6})

  lu.assertFalse(s.empty())
  lu.assertEquals(s.pop(), {4, 5, 6})
  lu.assertEquals(s.pop(), "abc")
  lu.assertEquals(s.pop(), true)
  lu.assertEquals(s.pop(), 1)
  lu.assertTrue(s.empty())
end

os.exit(lu.LuaUnit.run())

