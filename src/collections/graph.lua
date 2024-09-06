local HashMap = require("ff.collections.hashmap")
local Queue = require("ff.collections.queue")
local Set = require("ff.collections.set")
local Stack = require("ff.collections.stack")

local GraphNode = {}
GraphNode.__index = GraphNode

function GraphNode.new(value)
	assert(value ~= nil, "Should not be nil")

	return setmetatable({ value = value, neighbors = Set.new() })
end

function GraphNode:addNeighbor(neighbor)
	return self.neighbors:add(neighbor)
end

function GraphNode:removeNeighbor(neighbor)
	return self.neighbors:remove(neighbor)
end

local Graph = {}
Graph.__index = Graph

function Graph.new(adjacencyList)
	local new = setmetatable({ __vertices = HashMap.new() }, Graph)

	if adjacencyList then
		for value, neighbors in pairs(adjacencyList) do
			for _, neighbor in ipairs(neighbors) do
				new:addEdge(value, neighbor)
			end
		end
	end

	return new
end

function Graph:addEdge(value, neighbor)
	local curVertex = self.__vertices:compute(value, GraphNode.new)
	self.__vertices:compute(neighbor, GraphNode.new)

	return curVertex:addNeighbor(neighbor)
end

function Graph:removeEdge(value, neighbor)
	local curVertex = self.__vertices:get(value)
	if curVertex == nil then
		return false
	end

	return curVertex:removeNeighbor(neighbor)
end

function Graph:hasPath(src, dst)
	return self:bfs(src, dst)
end

function Graph:bfs(src, dst)
	local srcVertex = self.__vertices:get(src)
	if srcVertex == nil then
		return false
	end

	local dstVertex = self.__vertices:get(dst)
	if dstVertex == nil then
		return false
	end

	local toVisit = Queue.new()
	toVisit:enqueue(srcVertex)
	local visited = Set.new()
	visited:add(srcVertex.value)

	while not toVisit:empty() do
		local levelSize = #toVisit
		while levelSize > 0 do
			local curVertex = toVisit:dequeue()
			if curVertex.value == dst then
				return true
			end
			for _, neighbor in ipairs(curVertex.neighbors) do
				if visited:add(neighbor) then
					toVisit:enqueue(self.__vertices:get(neighbor))
				end
			end
			levelSize = levelSize - 1
		end
	end

	return false
end

function Graph:dfs(src, dst)
	local srcVertex = self.__vertices:get(src)
	if srcVertex == nil then
		return false
	end

	local dstVertex = self.__vertices:get(dst)
	if dstVertex == nil then
		return false
	end

	local toVisit = Stack.new()
	toVisit:push(srcVertex)
	local visited = Set.new()
	visited:add(srcVertex.value)

	while not toVisit:empty() do
		local curVertex = toVisit:pop()
		if curVertex.value == dst then
			return true
		end
		for _, neighbor in ipairs(curVertex.neighbors) do
			if visited:add(neighbor) then
				toVisit:push(self.__vertices:get(neighbor))
			end
		end
	end

	return false
end

return Graph
