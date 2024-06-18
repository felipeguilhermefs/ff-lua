local function Node(value, next)
	return {
		value = value,
		next = next,
	}
end

local function Queue()
	local q = {}

	q.empty = function()
		return not q.front
	end

	q.enqueue = function(value)
		local newNode = Node(value, nil)
		if q.back then
			q.back.next = newNode
		else
			q.front = newNode
		end
		q.back = newNode
	end

	q.dequeue = function()
		if not q.front then
			return nil
		end

		local value = q.front.value

		if q.front == q.back then
			q.front = nil
			q.back = nil
		else
			q.front = q.front.next
		end

		return value
	end

	q.peek = function()
		if not q.front then
			return nil
		else
			return q.front.value
		end
	end

	return q
end

return Queue
