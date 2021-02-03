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
  local index = {}
  local function filter(a, s)
    local tam = addr.new(s.cpole, s.cskrina, s.cpristroj, s.cpristroj2, s.cpristroj3, s.csvorka)

    local tak = a:text() .. ">" .. tam:text()
    local onak = tam:text() .. ">" .. a:text()
    if index[tak] or index[onak] then
      print(s.vygenerovana)
      return false
    end

    return s.obsadena and (not s.vygenerovana) and (s.cpole == self.pole) and (s.cskrina == self.skrina)
  end

  local banany = {}
  for tu, sv in self:prejdi(filter) do
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

    index[tu:text() .. ">" .. tam:text()] = true
    index[tam:text() .. ">" .. tu:text()] = true
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
  local co = coroutine.create(function(flt)
    table.sort(self.pristroje)
    for _, npr in ipairs(self.pristroje) do
      local pr = self.data[npr]
      for _, sv in pairs(pr) do
        local a = addr.new(self.pole, self.skrina, npr, sv.pristroj2, sv.pristroj3, sv.svorka)
        if flt then
          if flt(a, sv) then
            coroutine.yield(a, sv)
          end
        else
          coroutine.yield(a, sv)
        end
      end
    end

    table.sort(self.svorkovnice)
    for _, npr in ipairs(self.svorkovnice) do
      local pr = self.data[npr]
      for _, sv in pairs(pr) do
        local a = addr.new(self.pole, self.skrina, npr, sv.pristroj2, sv.pristroj3, sv.svorka)
        if flt then
          if flt(a, sv) then
            coroutine.yield(a, sv)
          end
        else
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
