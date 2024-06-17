local function Node(value, left, right)
	return {
		value = value,
		left = left,
		right = right,
	}
end

local function LinkedList()
	local ll = {}

	ll.empty = function()
		return not ll.left
	end

	ll.clear = function()
		ll.left = nil
		ll.right = nil
	end

	ll.pushLeft = function(value)
		ll.left = Node(value, nil, ll.left)
		if ll.left.right then
			ll.left.right.left = ll.left
		end
		ll.right = ll.right or ll.left
	end

	ll.pushRight = function(value)
		ll.right = Node(value, ll.right, nil)
		if ll.right.left then
			ll.right.left.right = ll.right
		end
		ll.left = ll.left or ll.right
	end

	ll.popLeft = function()
		if not ll.left then
			return nil
		end

		local value = ll.left.value

		if ll.left == ll.right then
			ll.clear()
		else
			ll.left = ll.left.right
			ll.left.left = nil
		end

		return value
	end

	ll.popRight = function()
		if not ll.left then
			return nil
		end

		local value = ll.right.value

		if ll.left == ll.right then
			ll.clear()
		else
			ll.right = ll.right.left
			ll.right.right = nil
		end

		return value
	end

	ll.reverse = function()
		if not ll.left then
			return
		end

		if ll.left == ll.right then
			return
		end

		local cur = ll.left
		local left = nil
		local right = nil
		while cur do
			right = cur.right
			cur.right = left
			cur.left = right
			cur = right
		end

		cur = ll.left
		ll.left = ll.right
		ll.right = cur
	end

	return ll
end

return LinkedList
