local ansicolors = require("ansicolors")

local stringbuilder = require("octagen.utils.stringbuilder")
local colors = require("octagen.ui.skin.4bit")
local icoload = require("octagen.ui.icoload")

local icons = {
  sep = icoload(0xe0b1, ">"),
  pathend = icoload(0xe0b0, ""),
  drive = icoload(0xf7c9, "")
}

return function (path, bg)
  bg = bg or "black"
  local baseclr = colors.chooser.path
  local basefmt = "%{" .. baseclr .. "bg black}"
  local p = stringbuilder.new(basefmt, " ")
  p:add(icons.drive, " ", path:sub(1,1))
  path = path:sub(3,#path)

  if path:find("\\") < #path  then
    path = path:gsub("\\", string.format(" %s%s%s ", "%%{" .. baseclr  .. "bg " .. bg .. "}", icons.sep, "%"..basefmt))
    p:add(path)
  end

  p:add(" %{", bg, "bg ", baseclr, "}", icons.pathend)

  return ansicolors(p:string())
end
