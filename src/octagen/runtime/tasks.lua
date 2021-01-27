local rawterm = require("rawterm")
local clr = require("ansicolors")
local windcon = require('windcon')
local lfs = require("lfs")

local zapojenie = require("liv.banany.zapojenie")
local pristroje = require("liv.gen.pristroje")
local import = require("liv.import")
local addr = require("liv.banany.adresa")
local presist = require("liv.util.presist")

local generator = require("octagen.runtime.gen")
local tc = require("octagen.utils.tcolor")
local multicolumn = require("octagen.ui.multicolumn")

local printf = tc.printf
local tasks = {}

local function getbasedir(self, fn)
  return string.format("%s/%s/%s/%s", lfs.currentdir(), self.zapojenie.pole, self.zapojenie.skrina, fn)
end

local function gen_pristroje(zoznamPristrojov)
  local pristroje = {}
  for nazov, typ in pairs(zoznamPristrojov.db) do
    table.insert(pristroje, string.format("%s\t%s", nazov,typ))
  end
  table.sort(pristroje)
  return pristroje
end

local function vyber(zoznam, farba)
  windcon.clear()
  if not farba then
    farba = "blue"
  end

  --multicolumn(zoznam, 30)
  --print("p")
  for ln, txt in ipairs(zoznam) do
    if type(txt) == "table" then
      txt = table.concat(txt, "\t")
    end

    local fb = farba or "yellow"
    if ln % 2 == 0 then
      fb =  (farba .."bg black")
    end
    io.stdout:write(clr("%{" .. fb .. "}" .. string.format("%d:\t%s", ln, txt)), "\n")
  end

  io.stdout:write(clr("%{red}Vyber viacero %{white}(napr 1, 5;20;25, 1-15, 1-20;^4, ^15, 0 - pokračuj)"), "\n")
  local i = io.stdin:read("*l")

  local vyber = {}
    local block = {}
    for tkn in i:gmatch("(%^?[%d-]+),?") do
      local data = nil
      local target = vyber

      if tkn:sub(1,1) == "^" then
        target = block
        tkn = tkn:sub(2, #tkn)
      end

      local dash = tkn:find("-")
      if dash then
        local zac = tonumber(tkn:sub(1, dash-1))
        local kon = tonumber(tkn:sub(dash+1, #tkn))
        --("((%d+)-(%d+))")

        if kon < zac then
          local tmp = zac
          zac = kon
          kon = zac
        end

        data = {}

        for i = zac, kon do
          table.insert(data, i)
        end
      elseif tonumber(tkn) then
        data = tonumber(tkn)
      end

      if type(data) == "table" then
        for _, v in pairs(data) do
          target[v] = true
        end
      else
        target[data] = true
      end
    end

    for k in pairs(block) do
      vyber[k] = nil
    end

    return vyber

end

function tasks:help()
  print("help1111s")
  print(windcon.size())

end

function tasks:peak()
  for k, v in pairs(self) do
    print("peak", k, v)
  end
end

local function merge(t1, t2)
  for k2, v2 in pairs(t2) do
    if type(t1[k2]) == "table" then
      merge(t1[k2], v2)
    elseif not t1[k2] then
      t1[k2] = v2
    else
      error("Neviem spojit tabulky!")
    end
  end
end
function tasks:zober(...)
  local d = {}
  for _, p in pairs({...}) do
    if p:sub(#p, #p) == "/" then
      for f in lfs.dir(p) do
        if f == "." or f == ".." then
          print("Preskakujem", f)
        else
          print("citam", p .. f)
          local data, typ = import(p .. f)
          if d[typ] then
            merge(d[typ], data)
          else
            rawset(d, typ, data)
          end
        end
      end
    else
      print("citam", p)
      local data, typ = import(p)
      rawset(d, typ, data)
    end
  end

  return d
end

function tasks:generuj(co)
  local g = generator[co]
  if not g then
    error("Neviem generovat " .. co)
  end

  if not g.over(self) then
    error("Nemozno generovat: Overovanie zlyhalo.")
  end

  print("Generujem " .. co)

  local out = {}

  out[co] = g.generuj(self)

  return out
end

function tasks:vydratuj(pole, skrina)
  self.zapojenie = zapojenie.new(addr.new(pole, skrina), self.gan, self.klo)
  self.zapojenie:nacitajDoplnenia(getbasedir(self, "doplnenie.txt"))
  local ppath = getbasedir(self, "pristroje.txt")
  self.zozPrist = presist.exists(ppath) and pristroje.nacitaj(ppath) or pristroje.new()
  self.zozPrist:analyzuj(self.zapojenie)
end

function tasks:overzapojenie()
  if not self.zapojenie then
    error("Nemam co doplnat!")
  end

  for pr, sv in self.zapojenie:nevyplnene() do

    local pri = "@"
    local stam = self.zapojenie:dajsvorku(sv.cpristroj, sv.csvorka)
    if stam and stam.prierez then
      pri = stam.prierez
    else
      printf("\nZadaj @rprierez@w pre @g%s@w:@m%s @w=> @g%s@w:@m%s", pr, sv.svorka, sv.cpristroj, sv.csvorka)
      pri = io.stdin:read("*l")
    end

    self.zapojenie.doplnene.prierezy[string.format("-%s:%s", pr, sv.svorka)] = pri
    sv.prierez = pri
    if stam and not stam.prierez then
      self.zapojenie.doplnene.prierezy[string.format("-%s:%s", sv.cpristroj, sv.csvorka)] = pri
    end

    if stam then
      stam.prierez = pri
    end
  end

  self.zapojenie:ulozDoplnene(getbasedir(self, "doplnenie.txt"))
end

function tasks:overpristroje()
  windcon.clear()
  local w, h = windcon.size()
  local maxl = 0

  local definicie = {}

  for k, v in pairs(require("liv.gen.pristroje.typy")) do
    local d = {v.definuje()}

    for _, typ in pairs(d) do
      table.insert(definicie, typ)
    end
  end

  table.sort(definicie)

  while true do
    while true do
      local zoradene = {}
      for n, typ in pairs(self.zozPrist.db) do
        table.insert(zoradene, {n, typ})
        maxl = math.max(#n, #typ, maxl)
      end

      table.sort(zoradene,function(a, b)
        return a[1] < b[1]
      end)

      local p = vyber(zoradene, "blue")

      if p[0] then
        break
      end

      local d = nil
      for idpr in pairs(p) do
        if not d then
          local dt = vyber(definicie, "yellow")
          for k in pairs(dt) do
            d = k
            break
          end
        end
        local pid = zoradene[idpr][1]
        rawset(self.zozPrist.db, pid, definicie[d])
      end
    end

    local chyba = {}
    for n, typ in pairs(self.zozPrist.db) do
      table.insert(chyba, n)
    end

    if #chyba > 0 then
      local cht = #chyba

      if cht < 10 then
        cht = table.concat(chyba, " ")
      end

      printf("@bNiektore priestroje (@r%s@b) stale nemaju typ.", cht)
      printf("@mNaozaj pokracovat? @w[@ga@w/@rN@w] ")
      local a = string.lower(io.stdin:read(1))
      if a == "a" then
        break
      end
    end
  end

  self.zozPrist:uloz(getbasedir(self, "pristroje.txt"))
end

function tasks:export(...)
  local function s(p, t)
    local fh = io.open(p, "w")
    for ln, l in ipairs(t) do
      fh:write(l)
      fh:write("\n")
    end
    fh:close()
  end
  for i, v in pairs({...}) do
    local o = self[v]

    if type(o) == "table" then
      lfs.mkdir(getbasedir(self, v))
      for k, t in pairs(o) do
        s(getbasedir(self, v .. "/" .. k .. ".csv"), t)
      end
    end
  end
end

return tasks
