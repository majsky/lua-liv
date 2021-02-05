local ansicolors = require("ansicolors")
local icoload = require("octagen.ui.icoload")
local stringbuilder = require("octagen.utils.stringbuilder")

local badge = {proto={}}
local _badge = {__index = badge.proto}

local icons = {
  le = icoload(0xe0b6, "("),
  re = icoload(0xe0b4, ")")
}

function badge.new(txt, bg, fg)
  local o = setmetatable({
    txt = txt,
    fg = fg,
    bg = bg
  }, _badge)

  return o
end

function badge.proto:string(bg)
  if not bg then
    bg = "black"
  end
  local sb = stringbuilder.new()

  if self.bg then
    sb:add("%{", bg, "bg ", self.bg, "}", icons.le)
  end

  if self.fg or self.bg then
    sb:add("%{")

    if self.bg then
      sb:add(self.bg, "bg ")
    end

    if self.fg then
      sb:add(self.fg)
    else
      sb:add("black")
    end

    sb:add("}")
  end

  sb:add(self.txt)

  if self.bg then
    sb:add("%{", bg, "bg ", self.bg, "}", icons.re)
  end

  return ansicolors(tostring(sb))
end

return badge
