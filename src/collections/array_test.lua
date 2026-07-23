local lu = require("luaunit")
local Array = require("array")

function TestIndexedRead()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(10, a[1])
	lu.assertEquals(20, a[2])
	lu.assertEquals(30, a[3])
	lu.assertNil(a[4])

	a[1] = 99
	lu.assertEquals(99, a[1])
	lu.assertEquals(99, a[1])
end

function TestIndexedWrite()
	local a = Array.new({ 10, 20, 30 })

	-- numeric override
	a[2] = 99
	lu.assertEquals(99, a[2])

	-- string override
	a[1] = "hello"
	lu.assertEquals("hello", a[1])

	-- boolean override
	a[3] = false
	lu.assertFalse(a[3])

	-- nil value will be ignored
	a[1] = nil
	lu.assertEquals("hello", a[1])

	-- nil key will be ignored
	a[nil] = 50
	lu.assertEquals("hello", a[1])

	-- new key is the higher bound +1, expands the array
	a[4] = "world"
	lu.assertEquals("world", a[4])

	-- new key is too much over  over the higher bound, errors out
	lu.assertErrorMsgContains("index out of bounds", function()
		a[6] = "yolo"
	end)

	-- new key before lower bound, errors out
	lu.assertErrorMsgContains("index out of bounds", function()
		a[0] = "rofl"
	end)
end

function TestInsert()
	local a = Array.new()

	lu.assertNil(a[1])
	lu.assertEquals(0, #a)

	a:insert(10)
	lu.assertEquals(10, a[1])
	lu.assertEquals(1, #a)

	a:insert(20)
	lu.assertEquals(20, a[2])
	lu.assertEquals(2, #a)

	a:insert(30, 1)
	lu.assertEquals(30, a[1])
	lu.assertEquals(10, a[2])
	lu.assertEquals(20, a[3])
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
	lu.assertEquals(20, a[1])
	lu.assertEquals(30, a[2])

end

function TestSwap()
	local a = Array.new({ 10, 20, 30 })

	a:swap(1, 2)
	lu.assertEquals(20, a[1])
	lu.assertEquals(10, a[2])

	a:swap(2, 3)
	lu.assertEquals(30, a[2])
	lu.assertEquals(10, a[3])

	-- swap out of bounds
	a:swap(4, 1)
	lu.assertEquals(20, a[1])
	lu.assertEquals(30, a[2])
	lu.assertEquals(10, a[3])
	lu.assertEquals(3, #a)
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

function TestIndexOf()
	local a = Array.new({ 10, 20, 30, 20 })

	lu.assertEquals(1, a:indexOf(10))
	lu.assertEquals(3, a:indexOf(30))
	lu.assertEquals(2, a:indexOf(20))

	lu.assertNil(a:indexOf(40))
	lu.assertNil(a:indexOf(nil))
end

function TestConcat()
	local a = Array.new({ 10, 20, 30 })
	lu.assertEquals(3, #a)

	a = a .. { 40, 50, 60 }

	lu.assertEquals(10, a[1])
	lu.assertEquals(20, a[2])
	lu.assertEquals(30, a[3])
	lu.assertEquals(40, a[4])
	lu.assertEquals(50, a[5])
	lu.assertEquals(60, a[6])
	lu.assertEquals(6, #a)

	a = a .. nil
	lu.assertEquals(6, #a)

	a = a .. Array.new({ 70, 80, 90 })
	lu.assertEquals(70, a[7])
	lu.assertEquals(80, a[8])
	lu.assertEquals(90, a[9])
	lu.assertEquals(9, #a)

	local set = require("set").new()
	set:add(100)
	a = a .. set

	lu.assertEquals(100, a[10])
	lu.assertEquals(10, #a)
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
