local chcp = require("liv.import.charset")

local csvreader = {}

csvreader.required_headers = {
  ["gan"] = {
    "PŘÍSTROJ =", "PŘÍSTROJ +", "PŘÍSTROJ -", "PŘÍSTROJ -1", "PŘÍSTROJ -AN", "PŘÍSTROJ :1", "PRŮŘEZ", "CÍL =", "CÍL +", "CÍL -", "CÍL -1", "CÍL -AN", "CÍL :1"
  }
}

local function containsall(t, what)
  for _, k in pairs(what) do
    local found = false
    for __, v in pairs(t) do
      if k == v then
        found = true
        break
      end
    end

    if not found then
      return false
    end
  end
  return true
end

function csvreader.gettype(header)
  for k, v in pairs(csvreader.required_headers) do
    if containsall(header, v) then
      return k
    end
  end
  return nil
end

function csvreader.parse(header, lines)
  local csvtype = csvreader.gettype(header)
  if not csvtype then error("Unkown type") end
  local parse = require("liv.import.csv." .. csvtype)

  return parse(header, lines)
end

local function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

function csvreader.read(path)
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
  end

  return csvreader.parse(head, lns)
end

return csvreader
