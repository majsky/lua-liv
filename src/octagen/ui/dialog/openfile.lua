--TODO naportovať na nový systém dialógov
local lfs = require("lfs")
local ansicolors = require("ansicolors")

local colors = require("octagen.ui.skin.4bit")
local window = require("octagen.ui.window")
local icoload = require("octagen.ui.icoload")
local plpath = require("octagen.ui.plpath")
local stringbuilder = require("octagen.utils.stringbuilder")
local platform = require("octagen.platform")
local term = platform.term

local icons = {
  dir = icoload(0xf413, "D"),
  file = icoload(0xf15b, " "),
  up = icoload(0xf148, "^"),
  csv = icoload(0xf0ce, " "),
}

local function dir()
  local dirs = {}
  local files = {}

  for d in lfs.dir(".") do
    local attr, err = lfs.attributes(d)

    if not attr then

    else
      if attr.mode == "directory" then
        if d ~= "." then
          table.insert(dirs, d)
        end
      else
        table.insert(files, d)
      end
    end
  end

  for k,v in pairs(files) do
    table.insert(dirs, v)
  end

  return dirs
end

local function isdir(path)
  local attr = lfs.attributes(path)

  if attr then
    return (attr.mode == "directory")
  end

  return false
end

local function ext(path)
  local rev = path:reverse()
  local i = rev:find("%.")
  if not i then
    return ""
  end
  return rev:sub(1,i-1):lower():reverse()
end

local function tagged(tags, what)
  for _, path in pairs(tags) do
    if path == lfs.currentdir() .. platform.fs.separator .. what then
      return true
    end
  end

  return false
end

return function()
  local popd = lfs.currentdir()
  local w, h = term.getsize()
  local ww, wh = w - 8, h - 4

  local win = window.new(4, 2, ww, wh):settitle("Vyber subor")
  local sel = 1
  local tags = {}
  local cd = dir()

  term.curvisible(false)
  while true do
    win:clear()

    win:curpos(1, 1)
    win:write(plpath(lfs.currentdir(), "white"))
    for ln, fname in ipairs(cd) do
      if ln + 1>= wh then
        break
      end

      win:curpos(1, ln + 1)
      local icon = isdir(fname) and icons.dir or icons.file

      if fname == ".." then
        icon = icons.up
      elseif ext(fname) == "csv" then
        icon = icons.csv
      end

      if ln == sel then
        if tagged(tags, fname) then
          fname = ansicolors("%{" .. colors.chooser.select .. "bg " .. colors.chooser.tag .. "}" .. fname)
        else
          fname = ansicolors("%{" .. colors.chooser.select .. "bg}" .. fname)
        end
      else
        if tagged(tags, fname) then
          fname = ansicolors("%{" .. colors.chooser.tag .. "bg black}" .. fname)
        end
      end

      win:write(icon, " ", fname)
    end

    local key = term.getkey()

    if key == "down" then
      local max = #cd

      if sel < max then
        sel = sel + 1
      end

    elseif key == "up" then
      if sel > 1 then
        sel = sel - 1
      end

    elseif key == "right" then
      if isdir(cd[sel]) then
        lfs.chdir(cd[sel])
        cd = dir()
        sel = 1
      end

    elseif key == "left" then
      lfs.chdir("..")
      cd = dir()
      sel = 1

    elseif key == "space" then
      local abspath = lfs.currentdir() .. platform.fs.separator .. cd[sel]

      local key = nil
      for k, file in pairs(tags) do
        if file == abspath then
          key = k
          break
        end
      end

      if key then
        table.remove(tags, key)
      else
        table.insert(tags, abspath)
      end

    elseif key == "enter" then
      break
    end
  end

  lfs.chdir(popd)
  return tags
end
