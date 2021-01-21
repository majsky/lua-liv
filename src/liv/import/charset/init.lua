local utf8 = require("lua-utf8")

local iconv = {
  CP1250 = require("liv.import.charset.cp1250")
}

local function convert(what, from)
  local cp = iconv[from]

  local done = {}
  for i=1, #what do
    local char = cp[what:byte(i, i)]
    table.insert(done, char)
  end

  return table.concat(done)
end

return convert
