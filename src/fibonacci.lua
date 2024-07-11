local function fibonacci(n)
	if type(n) ~= "number" then
		return nil
	end

	if n < 0 then
		return nil
	end

	local prev = 0
	local cur = 1
	for _ = n, 1, -1 do
		local next = prev + cur
		prev = cur
		cur = next
	end
	return cur
end

return fibonacci
