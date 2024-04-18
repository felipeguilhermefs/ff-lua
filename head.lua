local function head(text)
  if type(text) == "string" then
    return text:sub(1, 1)
  end
  return nil
end

return head

