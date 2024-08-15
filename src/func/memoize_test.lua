local lu = require("luaunit")
local spy = require("ff.spy")
local memoize = require("memoize")

function Test_RepeatedCallsSingleArg_ShouldCallOnce()
	local fn = spy(function()
		return 1
	end)

	lu.assertEquals(fn.calls, 0)

	local mfn = memoize(fn)
	mfn("a")
	mfn("a")
	mfn("a")
	mfn("a")

	lu.assertEquals(fn.calls, 1)
end

function Test_RepeatedCallsMultipleArg_ShouldCallOnce()
	local fn = spy(function()
		return 1
	end)

	lu.assertEquals(fn.calls, 0)

	local mfn = memoize(fn)
	mfn("a", "b", "c")
	mfn("a", "b", "c")
	mfn("a", "b", "c")
	mfn("a", "b", "c")

	lu.assertEquals(fn.calls, 1)
end

function Test_DifferentCalls_ShouldCallAll()
	local fn = spy(function()
		return 1
	end)

	lu.assertEquals(fn.calls, 0)

	local mfn = memoize(fn)
	mfn("a", "b", "c")
	mfn("b", "c", "a")
	mfn("c", "a", "b")

	lu.assertEquals(fn.calls, 3)
end

function Test_NonFunction_ReturnNil()
	lu.assertNil(memoize(nil))
	lu.assertNil(memoize(true))
	lu.assertNil(memoize("abc"))
	lu.assertNil(memoize(9))
	lu.assertNil(memoize({ 1, 2, 3 }))
end

function Test_CacheNonTable_ReturnNil()
	local fn = function()
		return 1
	end

	lu.assertNil(memoize(fn, true))
	lu.assertNil(memoize(fn, "abc"))
	lu.assertNil(memoize(fn, 9))
end

os.exit(lu.LuaUnit.run())
