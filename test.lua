-- test.lua: Test runner for ff-lua (requires Lua 5.5+)
pcall(require, "luarocks.loader")

local home = os.getenv("HOME") or ""
if home ~= "" then
	package.path = home
		.. "/.luarocks/share/lua/5.5/?.lua;"
		.. home
		.. "/.luarocks/share/lua/5.5/?/init.lua;"
		.. package.path
	package.cpath = home .. "/.luarocks/lib/lua/5.5/?.so;" .. package.cpath
end

local major, minor = _VERSION:match("Lua (%d+)%.(%d+)")
if not major or tonumber(major) < 5 or (tonumber(major) == 5 and tonumber(minor) < 5) then
	error("ff-lua requires Lua 5.5 or higher. Current version: " .. _VERSION)
end

local lu = require("luaunit")

-- Configure package.path to resolve src modules
package.path = "src/?.lua;src/aoc/?.lua;src/cache/?.lua;src/collections/?.lua;src/func/?.lua;src/graph/?.lua;src/iter/?.lua;src/math/?.lua;src/search/?.lua;src/sort/?.lua;src/test/?.lua;"
	.. package.path

local test_files = {
	"src/cache/lru_test.lua",
	"src/collections/array_test.lua",
	"src/collections/binarytree_test.lua",
	"src/collections/hashmap_test.lua",
	"src/collections/heap_test.lua",
	"src/collections/linkedlist_test.lua",
	"src/collections/queue_test.lua",
	"src/collections/rangetree_test.lua",
	"src/collections/set_test.lua",
	"src/collections/stack_test.lua",
	"src/collections/trie_test.lua",
	"src/func/comparator_test.lua",
	"src/func/empty_test.lua",
	"src/func/head_test.lua",
	"src/func/memoize_test.lua",
	"src/func/tail_test.lua",
	"src/iter/permutations_test.lua",
	"src/math/factorial_test.lua",
	"src/math/fibonacci_test.lua",
	"src/math/max_test.lua",
	"src/math/min_test.lua",
	"src/math/trunc_test.lua",
	"src/search/binarysearch_test.lua",
	"src/search/quickselect_test.lua",
	"src/sort/bucketsort_test.lua",
	"src/sort/quicksort_test.lua",
}

local real_exit = os.exit
os.exit = function() end

for _, file in ipairs(test_files) do
	dofile(file)
end

os.exit = real_exit
os.exit(lu.LuaUnit.run())
