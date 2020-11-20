local tab = {}
local sn = require("supernova")

function tab.keys(t)
  if type(t) ~= "table" then
    return nil, "not a table"
  end
  local ks = {}

  for k in pairs(t) do
    table.insert(ks, k)
  end

  return ks
end

function tab.haskey(t, k)
  for tk in pairs(t) do
    if k == tk then
      return true
    end
  end
  return false
end

function tab.cp(t)
  assert(type(t) == "table", "t isnt table")
  local n = {}

  for k, v in pairs(t) do
    if type(v) == "table" then
      n[k] = tab.cp(v)
    else
      n[k] = v
    end
  end

  return n
end

function tab.dump(t, name, recursive)
    if type(t) == "table" then
      for k, v in pairs(t) do
        if type(v) == "table" and recursive then
          tab.dump(v, string.format("%s[%s]", name, k), true)
        else
          print(string.format("%s[%s] = %s", name or "", k, tostring(v)))
        end
      end
    else
      if name then
        print(string.format("%s = %s", name, tostring(t)))
      else
        print(tostring(t))
      end
    end
end


return tab
