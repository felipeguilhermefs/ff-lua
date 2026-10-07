local lu = require("luaunit")
local spy = require("ff.test.spy")
local memoize = require("ff.func.memoize")

TestMemoize = {}

function TestMemoize:testRepeatedCallsSingleArgShouldCallOnce()
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

function TestMemoize:testRepeatedCallsMultipleArgShouldCallOnce()
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

function TestMemoize:testDifferentCallsShouldCallAll()
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

function TestMemoize:testNonFunctionReturnNil()
	lu.assertNil(memoize(nil))
	lu.assertNil(memoize(true))
	lu.assertNil(memoize("abc"))
	lu.assertNil(memoize(9))
	lu.assertNil(memoize({ 1, 2, 3 }))
end

function TestMemoize:testCacheNonTableReturnNil()
	local fn = function()
		return 1
	end

	lu.assertNil(memoize(fn, true))
	lu.assertNil(memoize(fn, "abc"))
	lu.assertNil(memoize(fn, 9))
end
