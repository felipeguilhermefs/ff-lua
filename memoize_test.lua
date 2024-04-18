lu = require "luaunit"
spy = require "spy"
memoize = require "memoize"


function test_repeatedCallsSingleArg_shouldCallOnce()
  local fn = spy(function (a) return 1 end)

  lu.assertEquals(fn.calls, 0)

  local mfn = memoize(fn)
  mfn("a")
  mfn("a")
  mfn("a")
  mfn("a")

  lu.assertEquals(fn.calls, 1)
end

function test_repeatedCallsMultipleArg_shouldCallOnce()
  local fn = spy(function (a, b, c) return 1 end)

  lu.assertEquals(fn.calls, 0)

  local mfn = memoize(fn)
  mfn("a", "b", "c")
  mfn("a", "b", "c")
  mfn("a", "b", "c")
  mfn("a", "b", "c")

  lu.assertEquals(fn.calls, 1)
end

function test_differentCalls_shouldCallAll()
  local fn = spy(function (a, b, c) return 1 end)

  lu.assertEquals(fn.calls, 0)

  local mfn = memoize(fn)
  mfn("a", "b", "c")
  mfn("b", "c", "a")
  mfn("c", "a", "b")

  lu.assertEquals(fn.calls, 3)
end

function test_nonFunction_returnNil()
  lu.assertNil(memoize(nil))
  lu.assertNil(memoize(true))
  lu.assertNil(memoize("abc"))
  lu.assertNil(memoize(9))
  -- lu.assertNil(memoize({1, 2, 3}))
end

function test_cacheNonTable_returnNil()
  local fn = function () return 1 end

  lu.assertNil(memoize(fn, true))
  lu.assertNil(memoize(fn, "abc"))
  lu.assertNil(memoize(fn, 9))
end

os.exit(lu.LuaUnit.run())

