local d = {}

function d.getPath(f)
  local tf = package.searchpath("liv.resources", package.path)
  tf = tf:gsub("init.lua", f)
  return tf
end

return d
