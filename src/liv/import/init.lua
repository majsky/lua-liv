local csvreader = require("liv.import.csv")

local _import = {}
local import = setmetatable({}, _import)

local function getext(path)
  local rev = path:reverse()
  local dotpos = rev:find("%.")
  return path:sub(#path - dotpos + 2, #path):lower()
end


function _import.__call(t, path, type)
  local _ext = getext(path)

  if _ext == "csv" then
    return csvreader.read(path)
  else
    error("Nemozno importovat: Neznamy subor: " .. path)
  end
end

return import
