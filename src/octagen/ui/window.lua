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

local function bgcol(style)
  return style:match("([a-z]+)bg")
end

function win.proto:clear()
  local ts = nil
  if self.title then
    local tits = self.title
    local tl = #tits
    local padn = math.floor((self.area.width - tl) / 2) - 3
    local pad = string.rep("-", padn)

    local oneoff = 2 * padn + tl + 6 ~= self.area.width

    local titcol = bgcol(colors.header)
    local titstring = {
      clr(titcol .. "bg " .. titcol, "+" .. pad .. "[ "),
      clr(colors.header, tits),
      clr(titcol .. "bg " .. titcol, " ]" .. (oneoff and "-" or "") .. pad .. "+"),
    }
    ts = table.concat(titstring)
  else
    local titcol = bgcol(colors.header)
    local titstyle = titcol .. "bg " .. titcol
    ts = table.concat({
      clr(titstyle, "+"),
      clr(titstyle, string.rep("-", self.area.width - 2)),
      clr(titstyle, "+")
    })
  end

  self.area:curpos(1,1)
  io.stdout:write(ts)

  local bodyclr = bgcol(colors.body)

  local empty = table.concat({
    clr(bodyclr .. "bg " .. bodyclr, "|"),
    clr(colors.body, string.rep(" ", self.area.width - 2)),
    clr(bodyclr .. "bg " .. bodyclr, "|"),
  })

  for y = 2, self.area.height - 1 do
    self.area:curpos(1,y)
    io.stdout:write(empty)
  end

  self.area:curpos(1, self.area.height)
  io.stdout:write(
    clr(bodyclr .. "bg " .. bodyclr, "+"),
    clr(bodyclr .. "bg " .. bodyclr, string.rep("-", self.area.width - 2)),
    clr(bodyclr .. "bg " .. bodyclr, "+")
  )

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
