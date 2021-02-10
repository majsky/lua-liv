local lgetchar = require("lgetchar")
local windcon = require("windcon")

local console = {
  keys = {
    [13] = "enter",
    [9] = "tab",
    [8] = "bckspc",
    [32] = "space",
    [27] = "esc",
    [44] = ",",
    [46] = "."
  }
}

function console.getsize()
  local ansicon = os.getenv("ANSICON")

  if ansicon then
    local w, h = ansicon:match("%((%d+)x(%d+)%)")
    return tonumber(w), tonumber(h)
  end

  return windcon.size()
end

function console.width()
  local w, h = console.getsize()
  return w
end

function console.height()
  local w, h = console.getsize()
  return h
end
function console.curpos(x, y)
  windcon.movecursor(x-1, y-1)
end

function console.curvisible(visible)
  windcon.showcursor(visible)
end

function console.clear()
  windcon.clear()
end

function console.getkey()
    local c = lgetchar.getChar()

    if c == 224 then
      c = lgetchar.getChar()
      if c == 72 then
        return "up"
      elseif c == 75 then
        return "left"
      elseif c == 77 then
        return "right"
      elseif c == 80 then
        return "down"
      elseif c == 133 or c == 134 then
        return string.format("F%d", c - 122)
      end

    elseif c == 0 then
      c = lgetchar.getChar()
      return string.format("F%d", c - 58)

    elseif console.keys[c] then
      return console.keys[c]

    elseif (c >= 65 and c <= 90) or (c >= 97 and c <= 122) then
      return string.char(c)

    elseif c >= 48 and c <= 57 then
      return string.format("%d", c - 48)
    end

    return c
end

function console.iscolor()
  return os.getenv("ANSICON_DEF") ~= nil
end

function console.isicon()
  return os.getenv("ConEmuBuild") ~= nil
end

return console
