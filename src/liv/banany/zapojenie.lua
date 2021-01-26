local bnn = require("liv.gen.banany")
local addr = require("liv.banany.adresa")
local ui = require("liv.ui")
local dev = require("liv.gen.pristroje")
local presist = require("liv.util.presist")

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
    svorkovnice = {},
    doplnene = {
      prierezy = {}
    }
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

local function gen(self, lst, pristroje, banany, index)
  for i, pristroj in ipairs(lst) do
    local svorky = self.data[pristroj]
    table.sort(svorky, function(a, b)
      local an, bn = tonumber(a.svorka), tonumber(b.svorka)

      if an and bn then
        return an < bn
      end
      return a.svorka < b.svorka
    end)

    for n, svorka in ipairs(svorky) do
      if svorka.obsadena then
        local k1 = {
          svorka = svorka.svorka,
          pristroj = pristroj
        }

        local k2 =  {
          svorka = svorka.csvorka,
          pristroj = svorka.cpristroj
        }

        local tu = addr.new(nil, nil, pristroj, svorka.svorka)
        local tam = addr.new(nil, nil, svorka.cpristroj, svorka.csvorka)

        local smer = svorka.smer

        if not smer and pristroje then
          smer = pristroje:nasmeruj(pristroj, svorka)
        end

        if not smer then
          smer = ui.actual:prompt("Smer pre ", tu:text(), " chýba, zadaj ho prosím\nsmer [L|P]: ")
        end

        if not smer then
          smer = bnn.LAVY
        end

        local h1 = tu:text() .. "->" .. tam:text()
        local h2 = tam:text() .. "->" .. tu:text()

        if not index[h1] and not index[h2] then
          local prierez = svorka.prierez

          if not prierez then
            local d = self.doplnene.prierezy[tu:text()]
            if d then
              prierez = d
            end
          end

          if not prierez then
            prierez = ui.actual:prompt("Prierez pre ", tu:text(), " chýba, zadaj ho prosím\nprierez: ")

            if prierez then
              self.doplnene.prierezy[tu:text()] = prierez
            end
          end

          if not prierez then
            prierez = "-"
          else
            if not prierez:find("mm") then
              prierez = prierez .. "mm"
            end
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
  end
end

local function copyto(src, dest)
  if not dest then
    dest = {}
  end

  for k, v in pairs(src) do
    if type(v) == "table" then
      dest[k] = copyto(v, dest[k])
    else
      dest[k] = v
    end
  end

  return dest
end
function zap.proto:generuj(pristroje)
  local banany = {}
  local index = {}

  gen(self, self.pristroje, pristroje, banany, index)
  gen(self, self.svorkovnice, pristroje, banany, index)


  return banany
end

function zap.proto:banany()
  if not self.banany then
    self.banany = self:generuj()
  end

  return self.banany
end

function zap.proto:ulozDoplnene(path)
  presist.save(self.doplnene, path)
  return self
end

function zap.proto:nacitajDoplnenia(path)
  self.doplnene = presist.load(path, {prierezy = {}, default = true})
  return self
end

return zap
