local lgetchar = require("lgetchar")
local windcon = require("windcon")

local console = {}

function console.getsize()
  local ansicon = os.getenv("ANSICON")

  if ansicon then
    local w, h = ansicon:match("%((%d+)x(%d+)%)")
    return w, h
  end

  return windcon.size()
end

function console.getkey()
  while true do
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
      end

    elseif (c >= 65 and c <= 90) or (c >= 97 and c <= 122) then
      return string.char(c)
    end
  end
end

return console
