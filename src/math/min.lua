local function min(...)
	--TODO: Check types to choose a better min function
	local args = { ... }
	local res

	for _, val in pairs(args) do
		if type(val) == "number" then
			if not res or val < res then
				res = val
			end
		end
	end
	return res
end

return min
