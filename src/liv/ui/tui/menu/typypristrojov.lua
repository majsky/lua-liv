local vyber = require("liv.ui.tui.menu.vyber")
local typypris = require("liv.gen.pristroje.typy")

local menu = {}

local function draw_zoznam(db)
  for i, pr in pairs(db) do
  end
end

local function gen_pristroje(zoznamPristrojov)
  local pristroje = {}
  for nazov, typ in pairs(zoznamPristrojov.db) do
    table.insert(pristroje, string.format("%s\t%s", nazov,typ))
  end
  table.sort(pristroje)
  return pristroje
end


function menu.zobraz(zoznamPristrojov)
  local definicie = {}

  for k, v in pairs(typypris) do
    local d = {v.definuje()}

    for _, typ in pairs(d) do
      table.insert(definicie, typ)

    end
  end

  table.sort(definicie)

  local pristroje = gen_pristroje(zoznamPristrojov)

  while true do
    local p = vyber(pristroje)

    if p[0] then
      break
    end

    local d = nil
    for idpr in pairs(p) do
      if not d then
        d = vyber(definicie, true, "yellow")
      end
      local pid = pristroje[idpr]:match("(%S+)")
      zoznamPristrojov.db[pid] = definicie[d]
    end
    pristroje = gen_pristroje(zoznamPristrojov)
    --break
  end
end

return menu
