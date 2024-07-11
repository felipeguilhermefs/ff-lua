local function getinsert(dest, key, compute)
  if type(dest) ~= "table" then
    return nil
  end

  local value = dest[key]
  if not value then
    value = compute(key)
    dest[key] = value
  end
  return value
end

return getinsert

