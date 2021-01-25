local base64 = require("base64")

local addr = { _proto = {}}
local _addr = {
  __index=addr._proto,
  __tostring = addr._proto.text
}

local controlChars = {
  ["="] = "pole",
  ["%+"] = "skrina",
  ["-"] = "pristroj",
  [":"] = "svorka"
}

local function rmprefix(str)
  return str and str:match("[=%+-]?(.+)") or ""
end

---@return Addresa
---@param pole string @Pole / Text adresy
---@param skrina string|nil
---@param pristroj string|nil
---@param svorka string|nil
function addr.new(pole, skrina, pristroj, svorka)
  if not skrina and not pristroj and not svorka and type(pole) == "string" then
    pole, skrina, pristroj, svorka = string.match(pole, "=?([A-Z0-9]*)%+?([A-Z0-9]*)-?([A-Z0-9]*):?([A-Z0-9]*)")
  end

  pole = rmprefix(pole)
  skrina = rmprefix(skrina)
  pristroj = rmprefix(pristroj)
  svorka = rmprefix(svorka)

  ---@class Addresa
  ---@field pole string
  ---@field skrina string
  ---@field pristroj string
  ---@field svorka string
  local o = {
    pole = pole,
    skrina = skrina,
    pristroj = pristroj,
    svorka = svorka
  }

  return setmetatable(o, _addr)
end

function addr.vyber(text)
  local d = {}
  for char, data in pairs(controlChars) do
    local i = text:match(string.format("%s([A-Z0-9]+)", char))

    if i then
      d[data] = i
    end
  end

  return addr.new(d.pole, d.skrina, d.pristroj, d.svorka)
end

---@return string Text adresy
function addr._proto:text()
  local b = {}

  if #self.pole > 0 then
    table.insert(b, "=")
    table.insert(b, self.pole)
  end

  if #self.skrina > 0 then
    table.insert(b, "+")
    table.insert(b, self.skrina)
  end

  if #self.pristroj > 0 then
    table.insert(b, "-")
    table.insert(b, self.pristroj)
  end

  if #self.svorka > 0 then
    table.insert(b, ":")
    table.insert(b, self.svorka)
  end

  return table.concat(b)
end

---@return string Hash adresy
function addr._proto:hash()
  return base64.encode(self:text())
end

return addr
