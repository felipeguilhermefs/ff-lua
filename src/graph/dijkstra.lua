local HashMap = require("ff.collections.hashmap")
local Heap = require("ff.collections.heap")

local function minDistance(a, b)
	if a[2] > b[2] then
		return 1
	end

	if a[2] < b[2] then
		return -1
	end

	return 0
end

-----------------------------------------------------------------------------
---Calculates the shortest distance to each vertex from source.
---
---@param  graph	Graph		Graph to calculate the shortest distance.
---@param  source	any		Value that identifies the source Vertex.
---
---@return HashMap<Vertex, number>	Map of distances from source Vertex to all other that it has a path to.
-----------------------------------------------------------------------------
local function dijkstra(graph, source)
	local from = assert(graph._vertices:get(source), "source should be present in graph")

	local distances = HashMap.new()
	distances:put(from, 0)

	local closest = Heap.new(minDistance)
	closest:put({ from, 0 })

	while not closest:empty() do
		local cur = closest:pop()
		local cur_distance = distances:get(cur[1])

		for neighbor, distance_to in pairs(cur[1]._edges) do
			local new_distance = cur_distance + distance_to
			local old_distance = distances:get(neighbor)
			if old_distance == nil or new_distance < old_distance then
				distances:put(neighbor, new_distance)
				closest:put({ neighbor, new_distance })
			end
		end
	end

	return distances
end

return dijkstra
