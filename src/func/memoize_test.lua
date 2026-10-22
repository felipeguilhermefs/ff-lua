-- Imports
local lu = require("luaunit")
local spy = require("ff.test.spy")
local memoize = require("ff.func.memoize")

-- Suite definitions
local TestMemoize = {}

-- Scenarios: memoization behavior
function TestMemoize:testRepeatedSingleArgumentCalls_Use_CachedResult()
	-- Given: the spy observes calls keyed by one repeated argument.
	local fn = spy(function()
		return 1
	end)

	-- When: call the memoized wrapper four times with the same key.
	-- Then: the wrapped function runs once for that key.
	lu.assertEquals(fn.calls, 0)

	local mfn = memoize(fn)
	mfn("a")
	mfn("a")
	mfn("a")
	mfn("a")

	lu.assertEquals(fn.calls, 1)
end

function TestMemoize:testRepeatedMultipleArgumentCalls_Use_CachedResult()
	-- Given: the spy observes calls keyed by one repeated three-argument tuple.
	local fn = spy(function()
		return 1
	end)

	-- When: repeat the same three-argument tuple through the wrapper.
	-- Then: the wrapped function runs once for that tuple.
	lu.assertEquals(fn.calls, 0)

	local mfn = memoize(fn)
	mfn("a", "b", "c")
	mfn("a", "b", "c")
	mfn("a", "b", "c")
	mfn("a", "b", "c")

	lu.assertEquals(fn.calls, 1)
end

function TestMemoize:testCallsWithDifferentArguments_Compute_SeparateResults()
	-- Given: the spy observes calls keyed by three distinct argument tuples.
	local fn = spy(function()
		return 1
	end)

	-- When: call the wrapper with three distinct argument tuples.
	-- Then: the wrapped function runs once for each tuple.
	lu.assertEquals(fn.calls, 0)

	local mfn = memoize(fn)
	mfn("a", "b", "c")
	mfn("b", "c", "a")
	mfn("c", "a", "b")

	lu.assertEquals(fn.calls, 3)
end

function TestMemoize:testNonCallableInputs_Return_Nil()
	-- Given: inputs include nil, booleans, strings, numbers, and tables.
	-- When: pass each value as memoize's function argument.
	-- Then: memoize returns nil for every non-callable value.
	lu.assertNil(memoize(nil))
	lu.assertNil(memoize(true))
	lu.assertNil(memoize("abc"))
	lu.assertNil(memoize(9))
	lu.assertNil(memoize({ 1, 2, 3 }))
end

function TestMemoize:testMemoize_Rejects_NonTableCache()
	-- Given: a valid function is paired with boolean, string, and number caches.
	local fn = function()
		return 1
	end

	-- When: pass each invalid cache to memoize.
	-- Then: memoize returns nil for each invalid cache.
	lu.assertNil(memoize(fn, true))
	lu.assertNil(memoize(fn, "abc"))
	lu.assertNil(memoize(fn, 9))
end

-- Suite map
return { TestMemoize = TestMemoize }
