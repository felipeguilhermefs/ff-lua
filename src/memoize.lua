local function is_callable(fn)
  local tfn = type(fn)
  if tfn == 'function' then
    return true
  end
  if tfn == 'table' then
    local mt = getmetatable(fn)
    return mt and is_callable(mt.__call)
  end
  return false
end

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
  if not is_callable(fn) then
    return nil
  end
  if cache and type(cache) ~= 'table' then
    return nil
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
