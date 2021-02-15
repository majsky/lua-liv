local class = require("liv.util.class")
local icoload = require("octagen.ui.icoload")

---@class ToggleMenuItem : MenuItem
local tmi = class.new("octagen.ui.menuitem.basic")

tmi.icons = {
  [true] = icoload(0xf631, "A"),
  [false] = icoload(0xf630, "N")
}

function tmi:init(txt, value)
  self.txt = txt
  self.value = value or false
end

function tmi:action()
  self.value = not self.value
end

function tmi:gettext()
  return string.format(" %s %s", self.icons[self.value], self.txt)
end

return tmi
