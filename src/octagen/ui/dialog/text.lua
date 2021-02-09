local ansicolors = require("ansicolors")

local window = require("octagen.ui.window")
local platform = require("octagen.platform")

return function(title, txt, filter)
  local w, h = platform.term.getsize()
  local cx, ch = math.floor(w / 2), math.floor(h / 2)

  local win = window.new(cx - 20, ch - 2, 40, 4):settitle(title)
  local txt = txt or ""

  while true do
    win:clear()
    win:curpos(1, 2)
    io.stdout:write(ansicolors("%{white blackbg}"..txt..string.rep(" ", 38 - #txt)))
    win:curpos(#txt + 1, 2)

    platform.term.curvisible(true)
    local key = platform.term.getkey()
    platform.term.curvisible(false)

    if type(key) == "string" and #key == 1 then
      txt = txt .. key

    elseif key == "enter" then
      if filter then
        if filter(txt) then
          break
        end
      else
        break
      end

    elseif key == "bckspc" then
      if #txt >= 1 then
        txt = txt:sub(1, #txt - 1)
      end
    end
  end

  return txt
end
