local chcp = require("liv.import.charset")

local _import = {}
local import = setmetatable({}, _import)

local function guesstype(firstline)
  -- body
end

local function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

local function _coread(hndl,type)
  while true do
    local line = hndl:read("*l")
    line = iconv.convert(line, "CP1250")

    if not type then
      type = guesstype("")
    end
  end
end

local gan = require("liv.import.csv.gan")
local csvP = require("liv.import.csv")
function _import.__call(t, path, type)
  local count = 1
  local head = nil
  local lns = {}

  for l in io.lines(path) do
    l = chcp(l, "CP1250")

    local tkns = {}
    for tkn in l:gmatch("%s*([^;]+)%s*;") do
      table.insert(tkns, trim(tkn))
    end

    if not head then
      head = tkns
    else
      table.insert(lns, tkns)
    end
    count = count + 1
    if count == 101 then
      break
    end
  end

  print("READ DONE")
  csvP.parse(head, lns)
end


import("C:/Users/oresany/Desktop/WTEMP/vcs/2021-01-21-sucany/kable-6-7/GAN_SUCA_6_7.CSV")

return import
