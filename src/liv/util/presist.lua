local presisit = {}

local function savetable(t, fh, pre)
  if type(t) == "table" then
    for k, v in pairs(t) do
      savetable(v, fh, pre .. "|" .. k)
    end
  else
    fh:write(#pre > 1 and pre or "", "|", t, "\n")
  end
end
function presisit.save(what, where)
  local fh = io.open(where, "w")
  savetable(what, fh, "")
  fh:flush()
  fh:close()
end

function presisit.load(where, def)
  local fh = io.open(where, "r")
  local data = {}

  if not fh then
    return def or {}
  end

  local line = fh:read("*l")
  while line do
    local tkns = {}
    for tkn in line:gmatch("([^|]+)|?") do
      table.insert(tkns, tkn)
    end
    local ctx = data
    for i=1, #tkns - 2 do
      if not ctx[tkns[i]] then
        ctx[tkns[i]] = {}
      end
      ctx = ctx[tkns[i]]
    end

    ctx[tkns[#tkns - 1]] = tkns[#tkns]
    line = fh:read("*l")
  end

  fh:close()
  return data
end

return presisit
