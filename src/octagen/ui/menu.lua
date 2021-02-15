local ansicolors = require("ansicolors")

local stringbuilder = require("octagen.utils.stringbuilder")
local colors = require("octagen.ui.skin.4bit")
local canvas = require("octagen.ui.canvas")
local term = require("octagen.platform").term
---@type Menu
local menu = {proto={}}
local _menu = {__index=menu.proto}

local function cptbl(t)
  local n = {}

  for k, v in pairs(t) do
    if type(v) == "table" then
      n[k] = cptbl(v)
    else
      n[k] = v
    end
  end

  return n
end

---@param menuitems MenuItem[]
---@return Menu
function menu.new(lines, menuitems)
  ---@class Menu
  ---@field options MenuItem[]
  ---@field current integer
  ---@field style table
  ---@field height integer
  ---@field scroll integer
  local o = setmetatable({
    options = menuitems or {},
    current = 1,
    style = cptbl(colors.menu),
    height = lines,
    scroll = 1
  }, _menu)


  return o
end

---@param x integer
---@param y integer
---@param nofocus boolean
function menu.proto:draw(x, y, nofocus)
  local w, h = term.getsize()
  local canvas = self.canvas or canvas.full
  local showing = 0
  for i = self.scroll, #self.options do
    local opt = self.options[i]
    canvas:curpos(x, y + i - self.scroll)
    local sb = stringbuilder.new("%{")
    if self.current == i and not nofocus then
      sb:add(self.style.active.bg, "bg ", self.style.active.fg)
    else
      sb:add(self.style.bg, "bg ", self.style.fg)
    end

    sb:add("}")

    if opt.gettext then
      sb:add(opt:gettext())
    else
      sb:add(opt.txt)
    end

    canvas:write(ansicolors(sb:string()))
    showing = 1 + showing

    if showing == self.height then
      break
    end
  end

  canvas:flush()
end

---@param canvas Canvas
function menu.proto:setcanvas(canvas)
  self.canvas = canvas
end

---@param key string
function menu.proto:update(key)
  if key == "up" then
    if self.current > 1 then
      self.current = self.current - 1
      if self.current >= self.height then
        self.scroll = self.scroll - 1
      else
        self.scroll = 1
      end
    end

  elseif key == "down" then
    if self.current < #self.options then
      self.current = self.current + 1
      if self.current >= self.height then
        self.scroll = self.scroll + 1
      end
    end

  elseif key == "enter" then
    self.options[self.current]:action()

  end
end

---@param item MenuItem
function menu.proto:add(item)
  table.insert(self.options, item)
end

return menu
