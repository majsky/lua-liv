local term = require("octagen.platform").term

---@field proto Canvas
local canvas = {proto={}}
local _canvas = {__index=canvas.proto}

---@param x number Pozicia x
---@param y number Pozicia y
---@param w number Sirka
---@param h number Vyska
---@return Canvas
function canvas.new(x, y, w, h)
  if not x then x = 0 end
  if not y then y = 0 end

  local tw, th = term.getsize()
  if not w then w = tw end
  if not h then h = th end

  ---@class Canvas
  local o = setmetatable({
    x = x,
    y = y,
    width = w,
    height = h
  }, _canvas)

  return o
end

function canvas.proto:clear()
  local empty = string.rep(" ", self.width)
  for y = self.y, self.y + self.height do
    term.curpos(self.x, y)
    io.stdout:write(empty)
  end
end

function canvas.proto:curpos(x, y)
  term.curpos(self.x + x, self.y + y)
end

return canvas
