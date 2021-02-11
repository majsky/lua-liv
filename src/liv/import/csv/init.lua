local ftcsv = require("ftcsv")
local buffstr = require("liv.import.bufferedstream")
local chcp = require("liv.import.charset")
local convstr = require("liv.import.charset.stream")

local csvreader = {
  types = {
    gan = require("liv.import.csv.gan"),
    klo = require("liv.import.csv.klo"),
    kab = require("liv.import.csv.kab"),
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

  return csvreader.types[csvtype].process(header, lines), csvtype
end

local function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

local function grenamef(map)
  return function(s)
    local ts = trim(s)
    return map[ts] or ts
  end
end

local function chceckstream(stream)
  local head = csvreader.tokenize(stream:read("*l"))
  if csvreader.gettype(head) then
    return true
  end
  return false
end

local function odstranBordel(str)
  str = str:match("[=%+-%.]*(%S+)") or ""
  return str
end

function csvreader.read(path)
  local csv = nil
  local typ = nil
  local stream = io.open(path, "r")
  if chceckstream(stream) then
    stream:close()
    stream = io.open(path, "r")

    local txt = stream:read("*a")

    local htxt = txt:match("[^\r\n]+")
    typ = csvreader.gettype(csvreader.tokenize(htxt))
    csv = ftcsv.parse(path, ";", {
      headerFunc = grenamef(csvreader.types[typ].map)
    })
  else
    stream:close()
    stream = convstr.new(io.open(path, "r"), "CP1250")
    local txt = stream:read("*a")
    stream:close()
    local htxt = txt:match("[^\r\n]+")
    typ = csvreader.gettype(csvreader.tokenize(htxt))
    csv = ftcsv.parse(txt, ";", {
      loadFromString = true,
      headerFunc = grenamef(csvreader.types[typ].map),
    })
  end

  local ncsv = {}

  for ln, l in ipairs(csv) do
    ncsv[ln] = {}
    for k, v in pairs(l) do
      ncsv[ln][k] = odstranBordel(v)
    end
  end

  return csvreader.types[typ].process(ncsv), typ
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
