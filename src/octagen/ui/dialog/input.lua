local ansicolors = require("ansicolors")

local window = require("octagen.ui.window")
local platform = require("octagen.platform")

local class = require("octagen.utils.class")

local input = class.new("octagen.ui.dialog")

function input:init(title, txt, filter)
  local w, h = platform.term.getsize()
  local cx, ch = math.floor(w / 2), math.floor(h / 2)

  self.win = window.new(cx - 20, ch - 2, 40, 4):settitle(title)
  self.txt = txt or ""
  self.filter = filter
end

function input:draw()
  self.win:clear()
  self.win:curpos(1, 2)
  self.win:write("%{white blackbg}", self.txt, string.rep(" ", 38 - #self.txt))
  self.win:curpos(#self.txt + 1, 2)
  platform.term.curvisible(true)
end

function input:update(key)
  if type(key) == "string" and #key == 1 then
    self.txt = self.txt .. key

  elseif key == "enter" then
    if self.filter then
      if self.filter(self.txt) then
        self:hide(self.txt)
      end
    else
      self:hide(self.txt)
    end

  elseif key == "bckspc" then
    if #self.txt >= 1 then
      self.txt = self.txt:sub(1, #self.txt - 1)
    end
  end
end

return input
