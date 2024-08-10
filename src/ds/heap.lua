local function less(a, b)
	return a < b
end

local function Heap(items, comparator)
	local heap = {
		_before = comparator or less,
		_items = items or {},
	}

	heap.size = function()
		return #heap._items
	end

	heap.empty = function()
		return heap.size() == 0
	end

	heap.push = function(item)
		table.insert(heap._items, item)
		heap._siftUp(heap.size())
	end

	heap.pop = function()
		if heap.empty() then
			return nil
		end

		if heap.size() == 1 then
			return table.remove(heap._items, 1)
		end

		local root = heap._items[1]
		heap._items[1] = table.remove(heap._items, heap.size())
		heap._siftDown(1)
		return root
	end

	heap.peek = function()
		if heap.empty() then
			return nil
		end
		return heap._items[1]
	end

	heap._heapify = function()
		for i = heap.size(), 1, -1 do
			heap._siftDown(i)
		end
	end

	heap._siftUp = function(index)
		local parent = index // 2
		while index > 1 and heap._before(heap._items[index], heap._items[parent]) do
			heap._swap(index, parent)
			index = parent
			parent = index // 2
		end
	end

	heap._siftDown = function(index)
		local child = index * 2
		while child <= heap.size() do
			if child + 1 <= heap.size() and heap._before(heap._items[child + 1], heap._items[child]) then
				child = child + 1
			end

			if heap._before(heap._items[index], heap._items[child]) then
				break
			end

			heap._swap(child, index)
			index = child
			child = 2 * index
		end
	end

	heap._swap = function(a, b)
		local temp = heap._items[a]
		heap._items[a] = heap._items[b]
		heap._items[b] = temp
	end

	heap._heapify()

	return heap
end

return Heap
