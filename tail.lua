local function tail(text)
  if type(text) == "string" then
    return text:sub(2, #text)
  end
  return nil
end

return tail
