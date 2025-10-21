local lfs = require("lfs")

local import = require("liv.import")

local alert = require("octagen.ui.dialog.alert")
local dopen = require("octagen.ui.dialog.openfile")
local ddel = require("octagen.ui.dialog.delete")
local term = require("octagen.platform").term
local menu = require("octagen.ui.menu")
local icoload = require("octagen.ui.icoload")
local badge = require("octagen.ui.badge")
local colors = require("octagen.ui.skin.4bit")
local plpath = require("octagen.ui.plpath")

local udaje = {
  name = "ÚDAJE",
  icon = icoload(0xf0ce),
  data = {}
}

local badges = {
  gan = badge.new("GAN", colors.main.csv.gan):string(),
  klo = badge.new("KLO", colors.main.csv.klo):string(),
  lua = badge.new("LUA", colors.main.script):string()
}

local _PRESIST_PATH = ".lastimport"

local function isdir(path)
  local atr = lfs.attributes(path)
  if not atr then
    return false
  end

  return atr.mode == "directory"
end

local function importAll(filelist)
  for i, p in pairs(filelist) do
    local d, t = import(p)
    table.insert(udaje.data, {
      path = p,
      type = t,
      data = d
    })
  end
end

local m = menu.new(term.height() - 2, {
  {
    txt = "Import...",
    action = function()
      local paths = dopen()

      if #paths > 0 then
        local fh = io.open(_PRESIST_PATH, "w")
        if fh then
          for _, pth in ipairs(paths) do
            fh:write(pth, "\n")
          end
          fh:close()
        end

      importAll(paths)
      end
    end
  }, {
    txt = "Posledne zadanie",
    action = function()
      local pths = {}
      for pth in io.lines(_PRESIST_PATH) do
        table.insert(pths, pth)
      end

      if #pths == 0 then
        alert:new(err, "Chyba importu"):show()
        return
      end

      importAll(pths)
    end
  }, {
    txt = "Odstran...",
    action = function()
      local d = {}
      for k, v in pairs(udaje.data) do
        table.insert(d, string.format("%s", v.path))
      end

      local diag = ddel:new(d)
      local todel = diag:show()

      for _, dlt in pairs(todel) do
        local k = 0
        for _k, v in pairs(udaje.data) do
          if v.path == dlt then
            k = _k
            break
          end
        end

        if k > 0 then
          udaje.data[k] = nil
        end
      end

    end
  }
})

function udaje.draw()
  m:draw(1, 2)

  local w, h = term.getsize()
  local tw = math.floor(w/3)
  term.curpos(tw, 2)
  io.stdout:write("Aktualne sa pouziva:")
  for i, d in pairs(udaje.data) do
    term.curpos(tw, 2 + i)

    local _, e = d.path:find("WTEMP\\vcs\\")
    io.stdout:write(badges[d.type], " ", plpath(d.path:sub(e + 1), "black", true))
  end
end


function udaje.update(key)
  m:update(key)
end



return udaje
