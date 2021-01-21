local ftcsv = require("ftcsv")

local csvp = {
  proto = {},
  _proto = {}
}

csvp.required_headers = {
  ["gan"] = {
    "PŘÍSTROJ =", "PŘÍSTROJ +", "PŘÍSTROJ -", "PŘÍSTROJ -1", "PŘÍSTROJ -AN", "PŘÍSTROJ :1",
    "PRŮŘEZ",
    "CÍL =", "CÍL +", "CÍL -", "CÍL -1", "CÍL -AN", "CÍL :1"
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

function csvp.parse(header, lines, csvtype)
  if not csvtype then
    for k, v in pairs(csvp.required_headers) do
      if containsall(header, v) then
        csvtype = k
        break
      end
    end

    if not csvtype then
      error("Nepoznam typ csv.")
    end
  end

  local parse = require("liv.import.csv." .. csvtype)

  return parse(header, lines)
end

function csvp.proto:line()
  local status, l = coroutine.resume(self.reader)
  return l
end

function csvp.proto:parse(line)

end


return csvp
