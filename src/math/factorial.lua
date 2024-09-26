local trunc = require("trunc")

local function factorial(n)
	assert(type(n) == "number", "Should be a number")
	assert(n >= 0, "Should be positive")

	n = trunc(n)
	if n == 0 then
		return 0
	end

	local res = n
	while n > 1 do
		n = n - 1
		res = res * n
	end

	return res
end

return factorial
