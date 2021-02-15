local ansicolors = require("ansicolors")

local class = require("liv.util.class")
---@type ToggleMenuItem
local tglmitm = require("octagen.ui.menuitem.toggle")
local window = require("octagen.ui.window")
local icoload = require("octagen.ui.icoload")
local menu = require("octagen.ui.menu")
local colors = require("octagen.ui.skin.4bit")
local term = require("octagen.platform").term

local delete = class.new("octagen.ui.dialog")

delete.icons = {
  all = icoload(0xf985, " "),
  inv = icoload(0xf986, " ")
}

delete.buttons = {
  "OK",
  "VSETKO",
  "INVERTOVAT",
  "ZRUS"
}

function delete:init(items, title)
  self.title = title or "Zmazať"
  self.items = {}

  for i, item in ipairs(items) do
    table.insert(self.items, tglmitm:new(item))
  end


  local w, h = term.getsize()
  local hw, hh = w / 2, h / 2
  self.menu = menu.new(h-4, self.items)

  self.win = window.new(4, 2, w - 8, h - 8)
  self.win:settitle(self.title)
  self.menu:setcanvas(self.win.area)
  self.menu:setinwindow()
  self.focus = "menu"
  self.bf = 1
end

function delete:draw()
  self.win:clear()
  self.win:curpos(1,2)
  self.menu:draw(2,3, self.focus ~= "menu")

  local w, h = term.getsize()

  local cw = math.floor(w / (#delete.buttons + 1))

  for i, btxt in pairs(delete.buttons) do
    self.win:curpos(cw * i, self.win.area.height - 2)
    if self.focus == "btns" and i == self.bf then
      self.win:write(ansicolors("%{bluebg black}" .. btxt))
    else
      self.win:write(btxt)
    end
  end
end

function delete:update(key)
  if key == "tab" then
    if self.focus == "menu" then
      self.focus = "btns"
    else
      self.focus = "menu"
    end
  end

  if self.focus == "menu" then
    self.menu:update(key)
  else
    if key == "right" then
      if self.bf < #delete.buttons then
        self.bf = self.bf + 1
      end
    elseif key == "left" then
      if self.bf > 0 then
        self.bf = self.bf - 1
      end
    elseif key == "enter" then
      local btn = delete.buttons[self.bf]

      if btn == "VSETKO" then
        for i, itm in pairs(self.items) do
          itm.value = true
        end
      elseif btn == "INVERTOVAT" then
        for i, itm in pairs(self.items) do
          itm.value = not itm.value
        end
      elseif btn == "OK" then
        local s = {}

        for k, v in pairs(self.items) do
          if v.value then
            table.insert(s, v.txt)
          end
        end

        self:hide(s)
      elseif btn == "ZRUS" then
        self:hide({})
      end
    end
  end
end

return delete
