local term = require("octagen.platform").term
local icoload = require("octagen.ui.icoload")
local menu = require("octagen.ui.menu")
local stringbuilder = require("octagen.utils.stringbuilder")

local pristroje = {
  proto = {
    name = "PRISTROJE",
    icon = icoload(0xf2db) -- fb19
  }
}

local tabmt = {
  __index = pristroje.proto
}

local function gentabtit(skrina)
  return "PRISTROJE: " .. skrina
end

local function gentab(zapojenie, zpri)
  local tab = {
    name = gentabtit(zapojenie.skrina)
  }
  local w, h = term.getsize()
  local focus = 1

  local function _focus2()
    focus = 2
  end
  
  local function genmenu()
    local m = menu.new(term.height() - 2, {})
    local devs = {}
    for k in pairs(zpri.db) do
      table.insert(devs, k)
    end
    table.sort(devs)

    for i, d in ipairs(devs) do
      local txt = stringbuilder.new(d, string.rep(" ", math.floor(w / 4) - #d), zpri.db[d])
      txt:add(string.rep(" ", math.floor(2 * (w / 4) - txt:len())))
      table.insert(m.options, {
        txt = txt:string(),
        action = _focus2
      })
    end

    return m
  end

  local definicie = {}
  for k, v in pairs(require("liv.gen.pristroje.typy")) do
    local d = {v.definuje()}

    for _, typ in pairs(d) do
      table.insert(definicie, typ)
    end
  end

  table.sort(definicie)
  local mdev = genmenu()
  local mdef = menu.new(h-2, {})

  for i, def in ipairs(definicie) do
    table.insert(mdef.options, {
      txt = def,
      action = function()
        local cur = mdev.current
        local opt = mdev.options[cur]
        local npr = string.match(opt.txt, "(%S+)%s+.+%s*")

        zpri.db[npr] = def
        mdev = genmenu()
        mdev.current = cur
        focus = 1
      end
    })
  end

  function tab.draw()
    mdev:draw(1, 2)
    mdef:draw(3 * math.ceil(w/4), 2, focus ~= 2)
  end

  function tab.update(keys)
    if focus == 1 then
      mdev:update(keys)
    else
      mdef:update(keys)
    end
  end

  return setmetatable(tab, tabmt)
end

return function(zapojenie, pris)
  local main = require("octagen.ui.main")

  for i, tab in pairs(main.tabs) do
    if tab.name == gentabtit(zapojenie.skrina) then
      error("Nemozno generovat!")
    end
  end

  local tab = gentab(zapojenie, pris)

  table.insert(main.tabs, tab)
  main.currenttab = #main.tabs
end
