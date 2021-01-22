local buffstr = require("liv.import.bufferedstream")
local chcp = require("liv.import.charset")
local convstr = require("liv.import.charset.stream")

local csvreader = {
  types = {
    gan = require("liv.import.csv.gan"),
    klo = require("liv.import.csv.klo")
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
  for type, reader in pairs(csvreader.types) do
    if containsall(header, reader.headers) then
      return type
    end
  end

  return nil
end

function csvreader.parse(header, lines)
  local csvtype = csvreader.gettype(header)
  if not csvtype or not csvreader.types[csvtype] then
    error("Unkown type")
  end

  return csvreader.types[csvtype].process(header, lines)
end

local function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

function csvreader.read(path)
  local fh = io.open(path, "r")
  local br = buffstr.new(fh)
  local cs = convstr.new(br, "CP1250")
  local head = csvreader.tokenize(cs:read("*l"))
  local line = cs:read("*l")
  local tkns = {}
  repeat
    local ltkns = csvreader.tokenize(line)
    table.insert(tkns, ltkns)
    line = cs:read("*l")
  until not line
  cs.base.base:close()

  return csvreader.parse(head, tkns)
end

function csvreader.tokenize(str)
  local tkns = {}

  if not str then
    return tkns
  end

  for tkn in str:gmatch("%s*([^;]+)%s*;") do
    table.insert(tkns, trim(tkn))
  end

  return tkns
end

return csvreader
