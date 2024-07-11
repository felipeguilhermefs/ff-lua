local trunc = require("trunc")

local function factorial(n)
	if type(n) ~= "number" then
		return nil
	end
	if n < 0 then
		return nil
	end

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
