local d = {}

local _TOKEN = "@FILENAME@"
local cache = {}

function d.getPath(f)
  if cache.user[f] then
    return cache.user[f]
  end

  if not cache.base then
    local tf = package.searchpath("liv.resources", package.path)
    cache.base = tf:gsub("init.lua", _TOKEN)
  end

  cache.user[f] = cache.base:gsub(_TOKEN, f)
  return cache.user[f]
end

return d
