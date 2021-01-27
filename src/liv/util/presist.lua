local lfs = require("lfs")
local presisit = {}

local function savetable(t, fh, pre)
  if type(t) == "table" then
    for k, v in pairs(t) do
      savetable(v, fh, pre .. "|" .. k)
    end
  else
    local p = ""
    if #pre > 1 then
      p = pre
    end
    fh:write(p, "|<", type(t),">", tostring(t), "\n")
  end
end

local function mkdirs(path)
--  path = path:sub(#lfs.currentdir(), #path)
  local drive = path:match("([A-Z]):") or ""
  local cpth = drive .. ":"
  for tkn in path:gmatch("[\\/]([^\\/]+)") do
    cpth = cpth .. "/" .. tkn
    lfs.mkdir(cpth)
  end
  local pwd = lfs.currentdir()
end

local function split(path)
  local rev = path:reverse()
  local coloni = rev:find("[/\\]")
  if not coloni then
    return nil, path
  end
  local dir = rev:sub(1, coloni - 1):reverse()
  local file = rev:sub(coloni + 1,#path):reverse()

  return dir, file
end

function presisit.save(what, where)
  local fn, dir = split(where)
  mkdirs(dir)
  local fh = io.open(where, "w")
  savetable(what, fh, "")
  fh:flush()
  fh:close()
end

local conv = {
  boolean = function(v) return v == "true" end,
  number = tonumber
}
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
    --require("dbgload").waitIDE()

    local ctx = data
    for i=1, #tkns - 2 do
      if not ctx[tkns[i]] then
        ctx[tkns[i]] = {}
      end
      ctx = ctx[tkns[i]]
    end


    local t, v = tkns[#tkns]:match("<(.+)>(.+)")
    if conv[t] then
      v = conv[t](v)
    end
    ctx[tkns[#tkns - 1]] = v
    line = fh:read("*l")
  end

  fh:close()
  return data
end

function presisit.exists(path)
  local fn, dir = split(path)

  for f in lfs.dir(dir) do
    if f == fn then
      return true
    end
  end

  return false
end

return presisit
