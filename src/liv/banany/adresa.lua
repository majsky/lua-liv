local base64 = require("base64")

local addr = { _proto = {}}
local _addr = {
  __index=addr._proto,
  __tostring = addr._proto.text
}

local controlChars = {
  {z="=", n="pole"},
  {z="%+", n="skrina"},
  {z="-", n="pristroj"},
  {z="%+", n="pristroj2"},
  {z="-", n="pristroj3"},
  {z=":", n="svorka"}
}

local function rmprefix(str)
  return str and str:match("[=%+-]?(.+)") or ""
end

---@return Addresa
---@param pole string @Pole / Text adresy
---@param skrina string|nil
---@param pristroj string|nil
---@param svorka string|nil
function addr.new(pole, skrina, pristroj, pristroj2, pristroj3, svorka)
  ---@class Addresa
  ---@field pole string
  ---@field skrina string
  ---@field pristroj string
  ---@field pristroj2 string
  ---@field pristroj3 string
  ---@field svorka string
  local o = nil

  if not skrina and not pristroj and not pristroj2 and not pristroj3 and not svorka and type(pole) == "string" then
    o = addr.spracuj(pole)
  else
    pole = rmprefix(pole)
    skrina = rmprefix(skrina)
    pristroj = rmprefix(pristroj)
    pristroj2 = rmprefix(pristroj2)
    pristroj3 = rmprefix(pristroj3)
    svorka = rmprefix(svorka)

    o = {
      pole = pole,
      skrina = skrina,
      pristroj = pristroj,
      pristroj2 = pristroj2,
      pristroj3 = pristroj3,
      svorka = svorka
    }
  end

  return setmetatable(o, _addr)
end

function addr.spracuj(adresa)
  local d={}
  local chi = 1
  for i=1, #controlChars do
    local tknd = controlChars[i]

    local zac, kon = string.find(adresa, tknd.z .. "[%a%d%.]+", chi)
    if zac then
      local tkn = string.sub(adresa, zac + 1, kon)
      chi = kon + 1
      d[tknd.n] = tkn
    end
  end

  return d
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

  for _, cast in ipairs(controlChars) do
    if string.len(self[cast.n]) > 0 then
      local char = cast.z:gsub("%%", "")
      table.insert(b, char)
      table.insert(b, self[cast.n])
    end
  end

  return table.concat(b)
end

---@return string Hash adresy
function addr._proto:hash()
  return base64.encode(self:text())
end

return addr
