local gens = {
  pristroje = {}
}

function gens.pristroje.over(data)
  return data.zozPrist ~= nil
end
function gens.pristroje.generuj(data)
  local pristroje = {}

  for k in pairs(data.zozPrist.db) do
    table.insert(pristroje, k)
  end

  table.sort(pristroje)

  return pristroje
end

local function registruj(generator)
  gens[generator] = require("octagen.runtime.gen." .. generator)
end

local function init()
  registruj("banany")
  registruj("stitky")

  return gens
end

return init()
