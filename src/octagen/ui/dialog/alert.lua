local window = require("octagen.ui.window")
local colors = require("octagen.ui.skin.4bit")
local term = require("octagen.platform").term
local class = require("octagen.utils.class")

local alert = class.new("octagen.ui.dialog")

function alert:init(txt, title)
  self.txt = txt
  self.title = title or "Oznam"

  local w, h = term.getsize()
  local hw, hh = math.floor(w/2), math.floor(h/2)
  self.win = window.new(hw - 20, hh - 3, 40, 6)
  self.win:settitle(self.title)
end

function alert:draw()
  term.curvisible(false)
  self.win:clear()
  self.win:curpos(20-math.floor(#self.txt/2),2)
  self.win:write("%{",colors.window.body,"}", self.txt)
  self.win:curpos(19,4)
  self.win:write("%{bluebg black}OK")
end

function alert:update(key)
  if key == "enter" then
    self:hide()
  end
end

return alert

