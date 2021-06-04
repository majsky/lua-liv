local platform = require("octagen.platform")
local icoload = require("octagen.ui.icoload")
local menu = require("octagen.ui.menu")
local input = require("octagen.ui.dialog.input")
local stringbuilder = require("octagen.utils.stringbuilder")

local vodice = {
  proto={
    icon = icoload(0xfac8)
  }
}

local _BEZNE_PRIEREZY = {"0", "1", "1,5", "2,5", "4", "6"}

local _tabmt = {
  __index = vodice.proto
}

local function gensvtxt(svorka, zapojenie)
  local tw = math.floor(platform.term.width() / 6)
  local thw = math.floor(tw / 4)

  local pr = svorka.prierez

  if not pr then
    for k, sv in pairs(zapojenie.data[svorka.cpristroj]) do
      if sv.csvorka == svorka.svorka then
        if sv.cpristroj == svorka.pristroj and sv.csvorka == svorka.svorka then
          pr = sv.prierez
          break
        end
      end
    end
  end

  local ciel = stringbuilder.new(pr and "" or "%{red}", svorka.cpristroj, ":")

  if #svorka.cpristroj2 > 0 then
    ciel:add(svorka.cpristroj2, "/")
  end

  if #svorka.cpristroj3 > 0 then
    ciel:add(svorka.cpristroj3, "/")
  end

  ciel:add(svorka.csvorka)

  local txt = stringbuilder.new(svorka.svorka, string.rep(" ", thw - #svorka.svorka), ciel:string())
  txt:add(string.rep(" ", tw - (svorka.prierez and #svorka.prierez or 0) - ciel:len() - thw), pr)

  return txt:string()
end

local function remember(s)
  local new = string.format("%s:%s-%s:%s-%s",
    s.pristroj,
    s.svorka,
    s.cpristroj,
    s.csvorka,
    s.prierez
  )

  local replace = false

  local lns = {}
  local fh = io.open(s.pole .. "/" .. s.skrina .. "/prierezy.txt", "r")
  if fh then
    while true do
      local line = fh:read("*l")
      if not line then
        break
      end

      local pris, sv, cpris, csv, pr = line:match("([^:]+):([^%-]+)%-([^:]+):([^%-]+)%-(.+)")

      if s.pristroj == pris and s.svorka == sv and s.cpristroj == cpris and s.csvorka == csv then
        table.insert(lns, new)
        replace = true
      else
        table.insert(lns, line)
      end
    end
    fh:close()
  end

  if not replace then
    table.insert(lns, new)
  end

  fh = io.open(s.pole .. "/" .. s.skrina .. "/prierezy.txt", "w")
  fh:write(table.concat(lns, "\n"))
  fh:close()
end

local function gensvmenu(svorky, zapojenie)
  local svopts = {}
  local sv = {}

  for i = 1, #svorky do
    local prp = svorky[i]
    if prp.obsadena then
      table.insert(svopts, {
        txt = gensvtxt(prp, zapojenie),
        svtxt = prp.svorka,
        action = function(self)
          local npr = prp.prierez:match("(.+)mm")
          local i = input:new("Zadaj prierez", npr)
          local np = i:show()
          if np:sub(#np - 1, #np) ~= "mm" then
            if np:sub(#np) == "m" then
              np = np .. "m"
            else
              np = np .. "mm"
            end
          end

          prp.prierez = np
          self.txt = gensvtxt(prp, zapojenie)
          remember(prp)
        end,

        onKey = function(self, key)
          local prindex = 0
          for k, v in ipairs(_BEZNE_PRIEREZY) do
            if prp.prierez == v .. "mm" then
              prindex = k
              break
            end
          end

          if key == 43 then -- +
            prindex = prindex + 1

            if prindex <= #_BEZNE_PRIEREZY then
              prp.prierez = _BEZNE_PRIEREZY[prindex] .. "mm"
              self.txt = gensvtxt(prp,zapojenie)
              remember(prp)
            end

          elseif key == 45 then -- -
            prindex = prindex - 1

            if prindex > 0 then
              prp.prierez = _BEZNE_PRIEREZY[prindex] .. "mm"
              self.txt = gensvtxt(prp, zapojenie)
              remember(prp)
            end
          end
        end
      })
    end
  end

  table.sort(svopts, function(a, b)
    local na, nb = tonumber(a.svtxt), tonumber(b.svtxt)
    if na and nb then
      return na < nb
    elseif na then
      return true
    elseif nb then
      return false
    end

    return a.svtxt < b.svtxt
  end)
  return menu.new(platform.term.height() - 2, svopts)
end

local function gentab(zapojenie)
  local tab = setmetatable({}, _tabmt)
  tab.name = "PRIEREZY: " .. zapojenie.skrina
  local menus = {}
  local focus = 1
  local devs = {}
  for k, svky in pairs(zapojenie.data) do
    table.insert(devs, {
      txt = k .. string.rep(" ", math.floor(platform.term.width() / 8) - #k),
      action = function()
        local karty = {}
        local svorky = {}

        for _k, v in pairs(svky) do
          v.pristroj = k
          v.pole = zapojenie.pole
          v.skrina = zapojenie.skrina
          if #v.pristroj2 > 0 then
            if not karty[v.pristroj2] then
              karty[v.pristroj2] = {}
            end

            local karta = karty[v.pristroj2]

            if #v.pristroj3 > 0 then
              if not karta[v.pristroj3] then
                karta[v.pristroj3] = {}
              end

              local svorkovnica = karta[v.pristroj3]

              table.insert(svorkovnica, v)
            else
              karta["@null"] = karta["@null"] or {}
              table.insert(karta["@null"], v)
            end
          else
            table.insert(svorky, v)
          end
        end

        if next(karty) then
          table.sort(karty)

          local kopts = {}
          for nkarta, karta in pairs(karty) do
            table.insert(kopts,{
              txt = "%{underline}" .. nkarta .. "%{reset}" .. string.rep(" ", math.floor(platform.term.width() / 8) - #nkarta),
              action = function()
                local svopts = {}

                for ns, sv in pairs(karta) do
                  if ns ~= "@null" then
                    table.insert(svopts, {
                      txt = "%{underline}" .. ns .. "%{reset}" .. string.rep(" ", math.floor(platform.term.width() / 8) - #ns),
                      action = function()
                        table.insert(menus, gensvmenu(sv, zapojenie))
                        focus = 4
                      end
                    })
                  else
                    local nsv = gensvmenu(sv, zapojenie)

                    for k, v in pairs(nsv.options) do
                      table.insert(svopts, v)
                    end
                  end
                end

                table.insert(menus, menu.new(platform.term.height() - 2, svopts))
                focus = 3
              end
            })
          end

          table.sort(kopts, function(a,b) return a.txt < b.txt end )
          table.insert(menus, menu.new(platform.term.height() - 2, kopts))
          focus = 2
        else
          table.insert(menus, gensvmenu(svorky, zapojenie))
          focus = 2
        end
      end
    })
  end
  table.sort(devs, function(a, b) return a.txt < b.txt end)
  table.insert(menus, menu.new(platform.term.height() - 2, devs))

  function tab.draw()
    local w, h = platform.term.getsize()
    for i, menu in ipairs(menus) do
      menu:draw((i - 1) * math.floor(w / #menus) + 1, 2)
    end
  end

  function tab.update(key)
    if key == "right" then
      key = "enter"
    end

    if key == "left" then
      if focus > 1 then
        table.remove(menus, #menus)
        focus = focus - 1
      end
    else
      menus[focus]:update(key)
    end
  end

  return tab
end

return function(zapojenie)
  local main = require("octagen.ui.main")

  local tab = gentab(zapojenie)
  table.insert(main.tabs, tab)
end
