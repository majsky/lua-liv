local class = require("liv.util.class")
local icoload = require("octagen.ui.icoload")

---@class RadioMenuItem : ToggleMenuItem
local rmi = class.new("octagen.ui.menuitem.toggle")

rmi.icons = {
  [true] = icoload(0xf93d, "X"),
  [false] = icoload(0xf93c, " ")
}

function rmi:init(group, txt, isdefault)
  self.txt = txt
  self.value = isdefault or #group == 0
  table.insert(group, self)
  self.group = group
end

function rmi:action()
  for i, mi in pairs(self.group) do
    mi.value = false
  end
  self.value = true
end

return rmi
