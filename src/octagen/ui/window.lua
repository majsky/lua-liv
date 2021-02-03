local ac = require("ansicolors")

local canvas = require("octagen.ui.canvas")
local colors = require("octagen.ui.skin.4bit").window

local win = {
  proto={},
  colors = colors
}
local _win = {__index = win.proto}

local function clr(color, ...)
  return ac(string.format("%%{%s}%s", color, table.concat({...})))
end
function win.new(x, y, w, h)
  local o = setmetatable({
    area = canvas.new(x, y, w, h)
  }, _win)

  return o
end

function win.proto:settitle(title)
  self.title = title
  return self
end

function win.proto:clear()
  local ts = nil
  if self.title then
    local tits = self.title
    local tl = #tits
    local padn = math.floor((self.area.width - tl) / 2)
    local pad = string.rep(" ", padn)

    if 2 * padn + tl ~= self.area.width then
      tits = tits .. " "
    end

    ts = clr(colors.header, pad, tits, pad)
  else
    ts = clr(colors.header, string.rep(" ", self.area.width))
  end

  self.area:curpos(1,1)
  io.stdout:write(ts)

  local empty = clr(colors.body, string.rep(" ", self.area.width))
  for y = 2, self.area.height do
    self.area:curpos(1,y)
    io.stdout:write(empty)
  end

  self:curpos(1,1)
  return self
end

function win.proto:write(...)
  local str = table.concat({...})

  if #str > (self.area.width - 2) then
    str = str:sub(1, self.area.width - 2)
  end

  io.stdout:write(clr(colors.body, str))
end

function win.proto:curpos(x, y)
  self.area:curpos(x + 1, y + 1)
  return self
end

return win
