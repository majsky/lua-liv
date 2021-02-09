local ansicolors = require("ansicolors")

local stringbuilder = require("octagen.utils.stringbuilder")
local window = require("octagen.ui.window")
local colors = require("octagen.ui.skin.4bit")
local icoload = require("octagen.ui.icoload")
local platform = require("octagen.platform")
local term = platform.term

local main = {}

local icons = {
  tab = {
    l = icoload(0xe0bc, "/"),
    r = icoload(0xe0be, " \\")
  }
}

main.tabs = {
  require("octagen.ui.tabs.domov"),
  require("octagen.ui.tabs.udaje"),
  require("octagen.ui.tabs.gen")
}
main.currenttab = 1

local function gentabline()
  local tl = stringbuilder.new()
  for i, tab in ipairs(main.tabs) do
    local selected = i == main.currenttab
    tl:add("%{")
    local tc = colors.main.tab.bg

    if selected then
      tc = colors.main.tab.active
    end

    tl:add(tc, "bg ", colors.main.tab.fg, "}", icons.tab.l, " %{", tc, "bg ", tc, "}")

    if selected then
      tl:add(">")
    else
      tl:add(" ")
    end

    tl:add("%{", tc, "bg ", colors.main.tab.fg, "}")
    if tab.icon then
      tl:add(tab.icon, " ")
    end
    tl:add(tab.name, "%{", tc, "bg ", tc, "}")

    if selected then
      tl:add("<")
    else
      tl:add(" ")
    end

    tl:add("%{", tc, "bg ", colors.main.tab.fg, "}", icons.tab.r, " ")
  end

  return ansicolors(tl:string())
end

local function draw()
  local function w(...)
    io.stdout:write(...)
  end

  term.clear()
  term.curpos(1, 1)
  w(gentabline())

  main.tabs[main.currenttab].draw()
end

local function update()
  local k = term.getkey()

  local propagate = true
  if type(k) == "string" then
    local ntab = k:match("F(%d+)")
    if ntab then
      propagate = false
      ntab = tonumber(ntab)
      if ntab <= #main.tabs then
        main.currenttab = ntab
      end
    end
  end

  if propagate then
    main.tabs[main.currenttab].update(k)
  end

  return k ~= "q"
end

local function run()
  term.clear()
  repeat
    term.curvisible(false)
    draw()
  until not update()

  term.curvisible(true)
  term.clear()
end

return setmetatable(main, {__call = run})
