local function empty(value)
  if type(value) == "string" then
    return #value == 0
  end

  if type(value) == "table" then
    for k,v in pairs(value) do
      return false
    end
    return true
  end

  return false
end

return empty

