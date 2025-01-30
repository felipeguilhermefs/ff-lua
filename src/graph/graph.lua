local HashMap = require("ff.collections.hashmap")

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
	assert(from ~= nil, "from is required")
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

return Graph
