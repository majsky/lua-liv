local base64 = require("base64")

local addr = { _proto = {}}
local _addr = {__index=addr._proto}

local function rmprefix(str)
  if not str then
    return ""
  end
  if str:match("[=%+-].+") then
    return str:sub(2, #str)
  end
  return str
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

---@return string Text adresy
function addr._proto:text()
  local b = {}
  if #self.svorka > 0 then
    if #self.pristroj > 0 then
      if #self.skrina > 0 then
        if #self.pole > 0 then
          table.insert(b, "=")
          table.insert(b, self.pole)
        end

        table.insert(b, "+")
        table.insert(b, self.skrina)
      end

      table.insert(b, "-")
      table.insert(b, self.pristroj)
    end

    table.insert(b, ":")
    table.insert(b, self.svorka)
  end

  return table.concat(b)
end

---@return string Hash adresy
function addr._proto:hash()
  return base64.encode(self:text())
end

return addr.new
