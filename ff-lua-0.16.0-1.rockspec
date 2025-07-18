rockspec_format = "3.0"
package = "ff-lua"
version = "scm-1"
version = "0.16.0-1"
source = {
	url = "git+https://github.com/felipeguilhermefs/ff-lua",
	tag = "v0.16.0",
}
description = {
	homepage = "https://github.com/felipeguilhermefs/ff-lua",
	license = "MIT",
	summary = "Personal package with useful code for playful coding",
	detailed = [[
      Created this package for personal usage and learning of Lua.

      This is intended for mostly avoid reimplementing Data Structures and
      Algorithms.

      Please don't use it for anything serious... (I don't).
   ]],
	maintainer = "Felipe Flores <felipeguilhermefs@gmail.com>",
}
dependencies = {
	"lua >= 5.4",
}
test_dependencies = {
	"luaunit >= 3.4",
}
build = {
	type = "builtin",
	modules = {
		["ff.aoc.matrix"] = "src/aoc/matrix.lua",
		["ff.cache.lru"] = "src/cache/lru.lua",
		["ff.collections.array"] = "src/collections/array.lua",
		["ff.collections.binarytree"] = "src/collections/binarytree.lua",
		["ff.collections.hashmap"] = "src/collections/hashmap.lua",
		["ff.collections.heap"] = "src/collections/heap.lua",
		["ff.collections.linkedlist"] = "src/collections/linkedlist.lua",
		["ff.collections.queue"] = "src/collections/queue.lua",
		["ff.collections.stack"] = "src/collections/stack.lua",
		["ff.collections.set"] = "src/collections/set.lua",
		["ff.collections.trie"] = "src/collections/trie.lua",
		["ff.empty"] = "src/func/empty.lua",
		["ff.func.comparator"] = "src/func/comparator.lua",
		["ff.factorial"] = "src/math/factorial.lua",
		["ff.fibonacci"] = "src/math/fibonacci.lua",
		["ff.head"] = "src/func/head.lua",
		["ff.max"] = "src/math/max.lua",
		["ff.memoize"] = "src/func/memoize.lua",
		["ff.min"] = "src/math/min.lua",
		["ff.search.binarysearch"] = "src/search/binarysearch.lua",
		["ff.search.quickselect"] = "src/search/quickselect.lua",
		["ff.sort.bucketsort"] = "src/sort/bucketsort.lua",
		["ff.sort.quicksort"] = "src/sort/quicksort.lua",
		["ff.spy"] = "src/test/spy.lua",
		["ff.tail"] = "src/func/tail.lua",
		["ff.trunc"] = "src/math/trunc.lua",
	},
}
