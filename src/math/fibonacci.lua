local trunc = require("trunc")

local function fibonacci(n)
	assert(type(n) == "number", "Should be a number")
	assert(n >= 0, "Should be positive")

	n = trunc(n)

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
