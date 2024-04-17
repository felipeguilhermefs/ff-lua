local function getinsert(dest, key, generate)
  local value = dest[key]
  if not value then
    value = generate(key)
    dest[key] = value
  end
  return value
end

return getinsert

