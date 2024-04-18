local function spy(fn)
  if type(fn) ~= 'function' then
    return nil
  end

  local spy = { calls = 0, fn = fn }

  setmetatable(spy, {
    __call = function (s, ...)
      s.calls = s.calls + 1
      return spy.fn(...)
    end
  })

  return spy
end

return spy

