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

function TestIsArray()
	lu.assertFalse(Array.isArray(true))
	lu.assertFalse(Array.isArray(123))
	lu.assertFalse(Array.isArray("abc"))
	lu.assertFalse(Array.isArray({ a = 1, b = 2, c = 3 }))
	lu.assertFalse(Array.isArray({ 1, 2, 3, a = 1, b = 2, c = 3 }))

	lu.assertTrue(Array.isArray({ 1, 2, 3 }))
	lu.assertTrue(Array.isArray(Array.new({ 4, 5, 6 })))
end

function TestConcat()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(3, #a)

	a = a .. { 40, 50, 60 }

	lu.assertEquals(10, a:get(1))
	lu.assertEquals(20, a:get(2))
	lu.assertEquals(30, a:get(3))
	lu.assertEquals(40, a:get(4))
	lu.assertEquals(50, a:get(5))
	lu.assertEquals(60, a:get(6))
	lu.assertEquals(6, #a)

	a = a .. nil
	lu.assertEquals(6, #a)

	a = a .. Array.new({ 70, 80, 90 })
	lu.assertEquals(70, a:get(7))
	lu.assertEquals(80, a:get(8))
	lu.assertEquals(90, a:get(9))
	lu.assertEquals(9, #a)
end

function TestIterator()
	local a = Array.new({ 10, 20, 30 })

	local tpairs = {}
	for key, value in pairs(a) do
		table.insert(tpairs, key)
		table.insert(tpairs, value)
	end

	lu.assertEquals({ 1, 10, 2, 20, 3, 30 }, tpairs)
end

os.exit(lu.LuaUnit.run())
