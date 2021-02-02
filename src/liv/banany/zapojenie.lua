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
---@return Zapojenie
function zap.new(adresa, gan, klo)
  ---@class Zapojenie
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

  if not gan[o.pole] then
    error("GAN neobsahuje pole " .. o.pole)
  end
  if not gan[o.pole][o.skrina] then
    error("Gan neobsahuje skrinu " .. o.skrina)
  end

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

        local tu = addr.new(nil, nil, pristroj, svorka.pristroj2, svorka.pristroj3, svorka.svorka)
        local tam = addr.new(nil, nil, svorka.cpristroj, svorka.cpristroj2, svorka.cpristroj3, svorka.csvorka)

        local smer1 = svorka.smer

        if not smer1 and pristroje then
          smer1 = pristroje:nasmeruj(pristroj, svorka)
        end

        if not smer1 then
          smer1 = ui.actual:prompt("Smer pre ", tu:text(), " chýba, zadaj ho prosím\nsmer [L|P]: ")
        end

        if not smer1 then
          smer1 = bnn.LAVY
        end

        local smer2 = pristroje:nasmeruj(pristroj, svorka)
        if not smer2 then
          smer2 = bnn.LAVY
        end

        if not smer2 then
          smer2 = ui.actual:prompt("Smer pre ", tam:text(), " chýba, zadaj ho prosím\nsmer [L|P]: ")
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

          if not prierez and ui.actual then
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

          table.insert(banany[prierez], bnn.sprav(smer1, k2, k1))
          table.insert(banany[prierez], bnn.sprav(smer2, k1, k2))
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
  for tu, sv in self:prejdi(function(a, s) return s.obsadena and not s.vygenerovana and s.cpole == self.pole and s.cskrina == self.skrina end) do
    local tam = addr.new(tu.pole, tu.skrina, sv.cpristroj, sv.cpristroj2, sv.cpristroj3, sv.csvorka)
    local stam = self:dajsvorku(tam, tu)

    if not stam then
      print("Svorka " .. tam:text() .. " sa nenasla. (Chcem pripojit " .. tu:text() .. ")")
    end

    local smtu = sv.smer

    if not smtu then
      smtu = pristroje:nasmeruj(tu.pristroj, sv)
    end

    if not smtu then
      print(tu:text() .. " nema nasmerovanie, davam lave...")
      smtu = "L"
    end

    local smtam = stam.smer

    if not smtam then
      smtam = pristroje:nasmeruj(tam.pristroj, stam)
    end

    if not smtam then
      print(tam:text() .. " nema nasmerovanie, davam lave...")
      smtam = "L"
    end

    local prierez = sv.prierez or stam.prierez
    if not prierez then
      print(tu:text() .. "=>" .. tam:text() .. " nema prierez, davam 1,5...")
      prierez = "1,5mm"
    end

    if not banany[prierez] then
      banany[prierez] = {}
    end

    table.insert(banany[prierez], bnn.sprav(smtam, tam, tu))
    table.insert(banany[prierez], bnn.sprav(smtu, tu, tam))

    sv.vygenerovana = true
    stam.vygenerovana = true
  end

  pristroje:ulozLog(self.pole .. "/" .. self.skrina .. "/banany.log")
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

  for k, v in pairs(self.doplnene.prierezy) do
    local p, sv = k:match("-(.+):(.+)")
    self:dajsvorku(p, sv).prierez = v
  end

  return self
end

function zap.proto:dajsvorku(pristroj, svorka, cpristroj, csvorka)
  if type(pristroj) == "table" then
    if type(svorka) == "table" then
      cpristroj = svorka.pristroj
      csvorka = svorka.svorka
    end

    svorka = pristroj.svorka
    pristroj = pristroj.pristroj
  end

  local prs = self.data[pristroj]
  if not prs then return end
  for _, s in pairs(prs) do
    if s.svorka == svorka then
      if cpristroj and csvorka then
        if s.cpristroj == cpristroj and s.csvorka == csvorka then
          return s
        end
      end
      return s
    end
  end
end

function zap.proto:jevyplnene()
    for npr, pr in pairs(self.data) do
      for _, sv in pairs(pr) do
        if sv.obsadena then
          if not sv.prierez then
            local opacnykonec = self:dajsvorku(sv.cpristroj, sv.csvorka).prierez
            local tu = addr.new(nil, nil, npr, sv.svorka)
            local tam = addr.new(nil, nil, sv.cpristroj, sv.csvorka)
            local doplneny = self.doplnene.prierezy[tam:text()] or self.doplnene.prierezy[tu:text()]

            if doplneny then
              sv.prierez = doplneny
              break
            elseif opacnykonec then
              sv.prierez = opacnykonec
              break
            else
              return false, {pr = npr, sv = sv, tu=tu, tam=tam}
            end
          end
        end
      end
end

  return true
end

function zap.proto:nevyplnene()
  local co = coroutine.create(function()
    for npr, pr in pairs(self.data) do
      for _, sv in pairs(pr) do
        if sv.obsadena and (not sv.prierez or sv.prierez == "-") then
          coroutine.yield(npr, sv)
        end
      end
    end
  end)

  return function()
    local code, pr, sv = coroutine.resume(co)
    return pr, sv
  end
end

function zap.proto:prejdi(filter)
  local co = coroutine.create(function(filter)
    table.sort(self.pristroje)
    for _, npr in ipairs(self.pristroje) do
      local pr = self.data[npr]
      for _, sv in pairs(pr) do
        local a = addr.new(self.pole, self.skrina, npr, sv.pristroj2, sv.pristroj3, sv.svorka)
        if not filter or filter(a, sv) then
          coroutine.yield(a, sv)
        end
      end
    end

    table.sort(self.svorkovnice)
    for _, npr in ipairs(self.svorkovnice) do
      local pr = self.data[npr]
      for _, sv in pairs(pr) do
        local a = addr.new(self.pole, self.skrina, npr, sv.pristroj2, sv.pristroj3, sv.svorka)
        if not filter or filter(a, sv) then
          coroutine.yield(a, sv)
        end
      end
    end
  end)

  return function()
    local status, ad, sv = coroutine.resume(co, filter)

    if not status then
      error(ad)
    end

    return ad, sv
  end
end

return zap
