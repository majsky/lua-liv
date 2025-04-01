local lfs       = require("lfs")

local zapojenie = require("liv.banany.zapojenie")
local adresa    = require("liv.banany.adresa")
local pristroje = require("liv.gen.pristroje")

local tpris     = require("octagen.ui.tabs.typpristrojov")
local tvodice   = require("octagen.ui.tabs.vodice")
local icoload   = require("octagen.ui.icoload")
local menu      = require("octagen.ui.menu")
local udaje     = require("octagen.ui.tabs.udaje")
local platform  = require("octagen.platform")
local stringbuilder = require("octagen.utils.stringbuilder")

local gen = {
  name = "GENEROVAŤ",
  icon = icoload(0xf0674)
}

local function _exists(what, where)
  for item in lfs.dir(where) do
    if item == what then
      return true
    end
  end

  return false
end

local function mkdirs(...)
  local path = stringbuilder.new(".")
  for _, dir in ipairs({...}) do
    if not _exists(dir, path:string()) then
      lfs.mkdir(path:string() .. platform.fs.separator .. dir)
    end

    path:add(platform.fs.separator, dir)
  end
  return path:string()
end

local function madata(ake, pocet)
  local n = 0
  for k, v in pairs(udaje.data) do
    if v.type == ake then
      if pocet then
        n = n + 1
      else
        return true
      end
    end
  end

  if pocet then
    return n == pocet
  end

  return false
end

local function scandirs(pole, skrina)
  for d in lfs.dir(".") do
    if d == pole then
      for sd in lfs.dir(d) do
        if sd == skrina then
          local accum = {}
          for ss in lfs.dir(d .. platform.fs.separator .. sd) do
            accum[ss] = d .. platform.fs.separator .. sd .. platform.fs.separator .. ss
          end
          return accum
        end
      end
    end
  end
end


local focus = 1
local menus = {}
local menuh = platform.term.height() - 2

local banany = {}

function banany.vyber(self)
  if madata("gan", 1) and madata("klo", 1) then
    local mpole = menu.new(menuh, {})

    for i, d in pairs(udaje.data) do
      if d.type == "gan" then
        for npole, pole in pairs(d.data) do
          table.insert(mpole.options, {
            txt = npole,
            action = function ()
              if #menus == 2 then
                local mskrine = menu.new(menuh, {})
                for nskrina, skrina in pairs(pole) do
                  table.insert(mskrine.options, {
                    txt = nskrina,
                    action = function()
                      local klo = nil

                      for i, dat in pairs(udaje.data) do
                        if dat.type == "klo" then
                          klo = dat.data
                          break
                        end
                      end

                      local zap = zapojenie.new(adresa.new(npole, nskrina), d.data, klo)
                      local files = scandirs(npole, nskrina)

                      if files and files["doplnenie.txt"] then
                        zap:nacitajDoplnenia(files["doplnenie.txt"])
                      end

                      local lspr = pristroje.new(zap)

                      if files and files["pristroje.txt"] then
                        lspr:nacitaj(files["pristroje.txt"])
                      end

                      mkdirs(npole, nskrina, "banany")
                      tpris(zap, lspr)
                      tvodice(zap)
                      banany.zap = zap
                      banany.pristroje = lspr
                      self.action = banany.menu
                      menus[3] = nil
                      menus[2] = nil
                      focus = 1
                    end
                  })
                end
              table.sort(mskrine.options, function(a, b) return a.txt < b.txt end)
              table.insert(menus, mskrine)
              focus = 3
            end
          end
        })
      end
    end
  end

  table.insert(menus, mpole)
  focus = 2
  end
end


function banany.reset(bme)
  return function(self)
  local main = require("octagen.ui.main")

    for i = 1, #main.tabs do
      local tab = main.tabs[i]
      if tab and tab.name:find("PRISTROJE:") or tab.name:find("PRIEREZY:") then
        main.tabs[i] = nil
      end
    end

    banany.zap = nil
    banany.pristorje = nil
    bme.action = banany.vyber
    menus[focus] = nil
    focus = 1
  end
end

function banany.menu(hme)
  local bmenu = menu.new(menuh, {
    {
      txt = "Vygeneruj",
      action = function(self)
        local dir = mkdirs(banany.zap.pole, banany.zap.skrina, "banany")
        for pr, lst in pairs(banany.zap:generuj(banany.pristroje)) do
          local path = string.format("%s%s%s.csv", dir, platform.fs.separator, pr)
          local handle = assert(io.open(path, "w"))
          for ln, l in ipairs(lst) do
            handle:write(l, "\n")
          end
          handle:close()
        end

        local hnd = io.open(string.format("%s%spristroje.csv", dir, platform.fs.separator), "w")
        for i = 1, #banany.zap.pristroje, 4 do
          for j = i, math.min(#banany.zap.pristroje, i + 3) do
            hnd:write(banany.zap.pristroje[j], ";")
          end
          hnd:write("\n")
        end
        hnd:close()

        hnd = io.open(string.format("%s%ssvorkovnice.csv", dir, platform.fs.separator), "w")
        for i = 1, #banany.zap.svorkovnice do
          hnd:write(banany.zap.svorkovnice[i], "\n")
        end
        hnd:close()

        banany.reset(hme)()
      end
    },
    {
      txt = "Reset",
      action = banany.reset(hme)
    }
  })

  table.insert(menus, bmenu)
  focus = 2
end

table.insert(menus, menu.new(menuh, {
  {
    txt = "Banany...",
    action = banany.vyber
  }
}))

function gen.draw()
  local w, h = platform.term.getsize()
  local tw = math.floor(w / 3)

  for i, menu in pairs(menus) do
    menu:draw(((i - 1) * tw ) + 1, 2, (i ~= focus))
  end
end

function gen.update(key)
  if key == "right" then
    key = "enter"
  end

  if key == "up" or key == "down" or key == "enter" then
    menus[focus]:update(key)
  elseif key == "left" then
    if focus > 1 then
      table.remove(menus, focus)
      focus = focus - 1
    end
  end
end

return gen
