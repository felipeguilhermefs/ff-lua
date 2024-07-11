local function empty(value)
	if not value then
		return nil
	end

	if type(value) == "string" then
		return #value == 0
	end

	if type(value) == "table" then
		if type(value.empty) == "function" then
			return value.empty()
		else
			for _, _ in pairs(value) do
				return false
			end
			return true
		end
	end

	return nil
end

return empty
