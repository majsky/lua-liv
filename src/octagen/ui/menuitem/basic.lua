local class = require("liv.util.class")

---@class MenuItem
local mi = class.new()

function mi:init(text, action)
  self.txt = text
  self.action = action
end

function mi:action()

end

return mi
