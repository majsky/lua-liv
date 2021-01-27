local aclr = require("ansicolors")
local tcolor = {
  shortstand = {
    r = "red",
    g = "green",
    y = "yellow",
    m = "magenta",
    b = "blue",
    w = "white"
  }
}

function tcolor.printf(fmt, ...)
  for tkn in fmt:gmatch("@([rgymbw])") do
    fmt = fmt:gsub("@" .. tkn, "%%%%{"..tcolor.shortstand[tkn] .. "}")
  end

  io.stdout:write(aclr(string.format(fmt:gsub("@c", "%%%%{%%s}"), ...)))
  io.stdout:write("\n")
  io.stdout:flush()
end

return tcolor
