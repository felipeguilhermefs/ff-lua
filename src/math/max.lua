local function max(...)
	local args = { ... }
	local res

	for _, val in pairs(args) do
		if type(val) == "number" then
			if not res or val > res then
				res = val
			end
		end
	end
	return res
end

return max
