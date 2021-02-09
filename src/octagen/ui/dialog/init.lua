local term = require("octagen.platform").term
local class = require("octagen.utils.class")

local dialog = class.new()

function dialog:show()
  self.show = true
  while self.show do
    self:draw()
    self:update(term.getkey())
  end

  if self.value then
    return table.unpack(self.value)
  end
end

function dialog:hide(...)
  self.show = false
  self.value = {...}
end

function dialog:draw()

end

function dialog:update(key)
  if key == "esc" then
    self:hide()
  end
end

return dialog
