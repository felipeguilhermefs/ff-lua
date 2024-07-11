local function trunc(n)
	if type(n) ~= "number" then
		return nil
	end

	if n > 0 then
		return math.floor(n)
	else
		return math.ceil(n)
	end
end

return trunc
