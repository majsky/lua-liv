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

local _tabmt = {
  __index = vodice.proto
}

local function gensvtxt(svorka)
  local tw = math.floor(platform.term.width() / 6)
  local thw = math.floor(tw / 4)
  local ciel = stringbuilder.new(svorka.cpristroj, ":")

  if #svorka.cpristroj2 > 0 then
    ciel:add(svorka.cpristroj2, "/")
  end

  if #svorka.cpristroj3 > 0 then
    ciel:add(svorka.cpristroj3, "/")
  end

  ciel:add(svorka.csvorka)

  local txt = stringbuilder.new(svorka.svorka, string.rep(" ", thw - #svorka.svorka), ciel:string())
  txt:add(string.rep(" ", tw - #svorka.prierez - ciel:len() - thw), svorka.prierez)

  return txt:string()
end

local function gensvmenu(svorky)
  local svopts = {}
  local sv = {}

  for i = 1, #svorky do
    local prp = svorky[i]
    if prp.obsadena then
      table.insert(svopts, {
        txt = gensvtxt(prp),
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
          self.txt = gensvtxt(prp)
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

        for k, v in pairs(svky) do
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
              txt = nkarta .. string.rep(" ", math.floor(platform.term.width() / 8) - #nkarta),
              action = function()
                local svopts = {}

                for ns, sv in pairs(karta) do
                  table.insert(svopts, {
                    txt = ns .. string.rep(" ", math.floor(platform.term.width() / 8) - #ns),
                    action = function()
                      table.insert(menus, gensvmenu(sv))
                      focus = 4
                    end
                  })
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
          table.insert(menus, gensvmenu(svorky))
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
