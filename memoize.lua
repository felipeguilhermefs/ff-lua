local function get(cache, args)
  local level = cache
  for i=1, #args do
    level = level.entries and level.entries[args[i]]
    if not level then
      return nil
    end
  end
  return level.value
end

local function put(cache, args, value)
  local level = cache
  for i=1, #args do
    local arg = args[i]
    level.entries = level.entries or {}
    level.entries[arg] = level.entries[arg] or {}
    level = level.entries[arg]
  end
  level.value = value
end

function memoize(fn, cache)
  if type(fn) ~= 'function' then
    error("Expected a function")
  end

  cache = cache or {}

  return function (...)
    local args = {...}
    local value = get(cache, args)
    if not value then
      value = fn(...)
      put(cache, args, value)
    end

    return value
  end
end

return memoize
