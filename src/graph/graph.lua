local HashMap = require("ff.collections.hashmap")
local Heap = require("ff.collections.heap")
local LinkedList = require("ff.collections.linkedlist")

---@class Vertex
---@field private _value any			Some value that identifies the vertex
---@field private _edges HashMap<Vertex, number>Edges of this vertex.
---
---
local Vertex = {}
Vertex.__index = Vertex

-----------------------------------------------------------------------------
---Creates a new instance of the vertex.
---
---@param value any Any value that identifies the vertex.
---
---@return Vertex
-----------------------------------------------------------------------------
function Vertex.new(value)
	assert(value, "value is required")
	return setmetatable({
		_value = value,
		_edges = HashMap.new(),
	}, Vertex)
end

-----------------------------------------------------------------------------
---Adds an edge to this vertex.
---
---@param  to		Vertex	Vertex at the other side of the edge.
---@param  weight	number	Weight of the edge.
-----------------------------------------------------------------------------
function Vertex:addEdge(to, weight)
	assert(to, "to is required")
	assert(type(weight) == "number", "weight should be a number")

	self._edges:put(to, weight)
end

-----------------------------------------------------------------------------
---Iterates through the edges in no particular order.
---
---@return Iterator<Vertex, number>, HashMap<Vertex, number>, nil
-----------------------------------------------------------------------------
function Vertex:edges()
	return pairs(self._edges)
end

---@class Graph
---@field private _vertices HashMap<any, Vertex>	Lookup for all vertices in this graph
---@field private _directed boolean			Is this a directed graph or not.
---
local Graph = {}
Graph.__index = Graph

-----------------------------------------------------------------------------
---Creates a new instance of the graph.
---
---@param directed boolean?	Should this be a directed graph?
---				Defaults `false`.
---
---@return Graph
-----------------------------------------------------------------------------
function Graph.new(directed)
	directed = directed or false
	return setmetatable({
		_directed = directed,
		_vertices = HashMap.new(),
	}, Graph)
end

-----------------------------------------------------------------------------
---Adds an edge between 2 vertices. Creates the vertex if absent from graph.
---
---@param  from		any		Value that identifies a vertex.
---@param  to		any?		Value that identifies a vertex.
---					If `nil`, only the `from` vertex will be created.
---@param  weight	number?		Weight of the edge. Defaults to 1.
-----------------------------------------------------------------------------
function Graph:addEdge(from, to, weight)
	assert(from, "from is required")
	weight = weight or 1
	assert(type(weight) == "number", "weight should be a number")

	local from_v = self._vertices:compute(from, Vertex.new)

	if to == nil then
		return
	end

	local to_v = self._vertices:compute(to, Vertex.new)
	from_v:addEdge(to_v, weight)

	if not self._directed then
		to_v:addEdge(from_v, weight)
	end
end

-----------------------------------------------------------------------------
---Find the shortest path between 2 vertices.
---
---@param  from		any		Value that identifies a vertex.
---@param  to		any		Value that identifies a vertex.
---
---@return number, LinkedList	Total distance and sequenced list of vertices
---				to visit.
-----------------------------------------------------------------------------
function Graph:shortestPath(from, to)
	assert(from, "from is required")
	assert(to, "to is required")

	local from_v = assert(self._vertices:get(from), "source should be present in graph")
	local to_v = assert(self._vertices:get(to), "source should be present in graph")

	if from == to then
		return 0, LinkedList.new() .. { from }
	end

	local distances = HashMap.new()
	distances:put(from_v, 0)

	local minDistance = function(a, b)
		if a[2] > b[2] then
			return 1
		end

		if a[2] < b[2] then
			return -1
		end

		return 0
	end

	local closest = Heap.new(minDistance)
	closest:put({ from_v, 0 })

	local previous = HashMap.new()
	while not closest:empty() do
		local cur = closest:pop()

		if cur[1] == to_v then
			break
		end

		local cur_distance = distances:get(cur[1])

		for neighbor, distance_to in cur[1]:edges() do
			local new_distance = cur_distance + distance_to
			local old_distance = distances:get(neighbor)
			if old_distance == nil or new_distance < old_distance then
				distances:put(neighbor, new_distance)
				closest:put({ neighbor, new_distance })
				previous:put(neighbor, cur[1])
			end
		end
	end

	local total_distance = distances:get(to_v)
	if total_distance == nil then
		return 0, LinkedList.new()
	end

	local path = LinkedList.new()
	local cur = to_v
	while cur do
		path:pushFront(cur.value)
		cur = previous:get(cur)
	end

	return total_distance, path
end

return Graph
