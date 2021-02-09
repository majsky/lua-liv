local import = require("liv.import")

local dopen = require("octagen.ui.dialog.openfile")
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
  klo = badge.new("KLO", colors.main.csv.klo):string()
}

local paths = {}
local m = menu.new(term.height() - 2, {
  {
    txt = "Import...",
    action = function()
      for i, p in pairs(dopen()) do
        local d, t = import(p)
        table.insert(udaje.data, {
          path = p,
          type = t,
          data = d
        })
      end
    end
  },
  {
    txt = "Odstran...",
    action = os.exit
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
    io.stdout:write(badges[d.type], " ", plpath(d.path))
  end
end


function udaje.update(key)
  m:update(key)
end



return udaje
