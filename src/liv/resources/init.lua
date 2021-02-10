local d = {}

local _TOKEN = "@FILENAME@"
local cache = {
  user = {}
}

function d.getPath(f)
  if cache.user[f] then
    return cache.user[f]
  end

  if not cache.base then
    local tf = package.searchpath("liv.resources", package.path)
    if not tf then return f end
    cache.base = tf:gsub("init.lua", _TOKEN)
  end

  cache.user[f] = cache.base:gsub(_TOKEN, f)
  return cache.user[f]
end

return d
