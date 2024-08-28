local lu = require("luaunit")
local Array = require("array")

function TestInsert()
	local a = Array.new()

	lu.assertNil(a:get(1))
	lu.assertEquals(0, #a)

	a:insert(10)
	lu.assertEquals(10, a:get(1))
	lu.assertEquals(1, #a)

	a:insert(20)
	lu.assertEquals(20, a:get(2))
	lu.assertEquals(2, #a)

	a:insert(30, 1)
	lu.assertEquals(30, a:get(1))
	lu.assertEquals(10, a:get(2))
	lu.assertEquals(20, a:get(3))
	lu.assertEquals(3, #a)

	a:insert(nil)
	lu.assertEquals(3, #a)
end

function TestRemove()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(3, #a)

	lu.assertEquals(10, a:remove(1))
	lu.assertEquals(2, #a)

	lu.assertNil(a:remove(nil))
	lu.assertEquals(2, #a)
	lu.assertEquals(20, a:get(1))
	lu.assertEquals(30, a:get(2))
end

function TestSwap()
	local a = Array.new({ 10, 20, 30 })

	a:swap(1, 2)
	lu.assertEquals(20, a:get(1))
	lu.assertEquals(10, a:get(2))

	a:swap(2, 3)
	lu.assertEquals(30, a:get(2))
	lu.assertEquals(10, a:get(3))

	-- swap out of bounds
	a:swap(4, 1)
	lu.assertNil(a:get(1))
	lu.assertEquals(30, a:get(2))
	lu.assertEquals(10, a:get(3))
	lu.assertEquals(20, a:get(4))
end

function TestInitialize()
	lu.assertError(Array.new, true)
	lu.assertError(Array.new, "abc")
	lu.assertError(Array.new, { a = 1, b = 2, c = 3 })
	lu.assertError(Array.new, { 1, 2, 3, a = 1, b = 2, c = 3 })
end

os.exit(lu.LuaUnit.run())
