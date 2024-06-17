local function Node(value, next)
	return {
		value = value,
		next = next,
	}
end

local function LinkedList()
	local ll = {}

	ll.empty = function()
		return not ll.head
	end

	ll.clear = function()
		ll.head = nil
		ll.tail = nil
	end

	ll.prepend = function(value)
		ll.head = Node(value, ll.head)
		ll.tail = ll.tail or ll.head
	end

	ll.append = function(value)
		if not ll.tail then
			ll.prepend(value)
		else
			ll.tail.next = Node(value)
			ll.tail = ll.tail.next
		end
	end

	ll.drop = function()
		if not ll.head then
			return nil
		end

		local value = ll.head.value

		if ll.head == ll.tail then
			ll.clear()
		else
			ll.head = ll.head.next
		end

		return value
	end

	ll.pop = function()
		if not ll.head then
			return nil
		end

		local value = ll.tail.value

		if ll.head == ll.tail then
			ll.clear()
		else
			local cur = ll.head
			while cur do
				if cur.next == ll.tail then
					ll.tail = cur
					cur.next = nil
					break
				else
					cur = cur.next
				end
			end
		end

		return value
	end

	ll.reverse = function()
		if not ll.head then
			return
		end

		if ll.head == ll.tail then
			return
		end

		local cur = ll.head
		local prev = nil
		local next = nil
		ll.tail = ll.head
		while cur do
			next = cur.next
			cur.next = prev
			prev = cur
			cur = next
		end
		ll.head = prev
	end

	return ll
end

return LinkedList
