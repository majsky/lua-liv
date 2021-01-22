local bnn = require("liv.gen.banany")
local addr = require("liv.banany.adresa")
local ui = require("liv.ui")
--local dev = require("liv.gen.banany.pristroj")

local zap = {proto = {}}
local _zap = {__index=zap.proto}

---@param adresa Addresa
---@param gan Gan
---@param klo Klo
function zap.new(adresa, gan, klo)
  local o = {
    pole = adresa.pole,
    skrina = adresa.skrina,
    data = {},
    pristroje = {},
    svorkovnice = {}
  }

  for k, v in pairs(gan[o.pole][o.skrina]) do
    o.data[k] = v
    table.insert(o.pristroje, k)
  end

  for k, v in pairs(klo[o.pole][o.skrina]) do
    if o.data[k] then
      for _, svorka in pairs(v) do
        table.insert(o.data[k], svorka)
      end
    else
      o.data[k] = v
      table.insert(o.svorkovnice, k)
    end
  end

  --table.sort(o.data)
  table.sort(o.pristroje)

  return setmetatable(o, _zap)
end

function zap.proto:generuj()
  local banany = {}
  local index = {}
  for i, pristroj in ipairs(self.pristroje) do
    local svorky = self.data[pristroj]
    table.sort(svorky, function(a, b)
      local an, bn = tonumber(a.svorka), tonumber(b.svorka)

      if an and bn then
        return an < bn
      end
      return a.svorka < b.svorka
    end)

    for n, svorka in ipairs(svorky) do
      local smer = svorka.smer

      if not smer then
        smer = bnn.LAVY
      end

      local k1 = {
        svorka = svorka.svorka,
        pristroj = pristroj
      }

      local k2 =  {
        svorka = svorka.csvorka,
        pristroj = svorka.cpristroj
      }

      local tu = addr(nil, nil, pristroj, svorka.svorka)
      local tam = addr(nil, nil, svorka.cpristroj, svorka.csvorka)

      local h1 = tu:text() .. "->" .. tam:text()
      local h2 = tam:text() .. "->" .. tu:text()

      if not index[h1] and not index[h2] then
        local prierez = svorka.prierez

        if not prierez and not os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") then
          prierez = ui.actual:prompt("Prierez pre ", tu:text(), " chýba, zadaj ho prosím\nprierez: ")
        end

        if not prierez then
          prierez = "-"
        end

        if not banany[prierez] then
          banany[prierez] = {}
        end

        table.insert(banany[prierez], bnn.sprav(smer, k2, k1))
        table.insert(banany[prierez], bnn.sprav(smer, k1, k2))
        index[h1] = true
        index[h2] = true
      end
    end
  end

  return banany
end

function zap.proto:banany()
  if not self.banany then
    self.banany = self:generuj()
  end

  return self.banany
end

return zap
