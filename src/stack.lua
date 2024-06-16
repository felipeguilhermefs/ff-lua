local function stack()
	local s = {}

	s.push = function(item)
		table.insert(s, item)
	end

	s.pop = function()
		if #s > 0 then
			return table.remove(s, #s)
		end
	end

	s.top = function()
		return s[#s]
	end

	s.empty = function()
		return #s == 0
	end

	return s
end

return stack
