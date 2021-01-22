local bnn = require("liv.gen.banany")
local klo = {}

local map = {
  ["lpole"] = "EXTERNÍ =",
  ["lskrina"] = "EXTERNÍ +",
  ["lpristroj"] = "EXTERNÍ -",
  ["lpristroj1"] = "EXTERNÍ -1",
  ["lpristroj2"] = "EXTERNÍ -AN",
  ["lsvorka"] = "EXTERNÍ :1",
  ["pole"] = "SVORKOVNICE =",
  ["skrina"] = "SVORKOVNICE +",
  ["svorkovnica"] = "SVORKOVNICE -KL",
  ["svorkovnica1"] = "SVORKOVNICE -1",
  ["svorkovnica2"] = "SVORKOVNICE -AN",
  ["svorka"] = "SVORKA :1",
  ["rpole"] = "INTERNÍ =",
  ["rskrina"] = "INTERNÍ +",
  ["rpristroj"] = "INTERNÍ -",
  ["rpristroj1"] = "INTERNÍ -1",
  ["rpristroj2"] = "INTERNÍ -AN",
  ["rsvorka"] = "INTERNÍ :1",
}

local function odstranBordel(str)
  return str:match("[=%+-]?(.+)")
end

local function store(t, v, ...)
  local ctx = t
  local path = {...}
  for i=1, #path do
    local k = odstranBordel(path[i])
    if not ctx[k] then
      ctx[k] = {}
    end
    ctx = ctx[k]
  end

  table.insert(ctx, v)
end

function klo.process(head, lines)
  local lmap = {}

  for k, v in pairs(map) do
    for _k, _v in pairs(head) do
      if _v == v then
        lmap[k] = _k
        break
      end
    end
  end

  local __linemeta = {
    __index = function(t, k)
      local uk = lmap[k]
      if uk then
        return rawget(t, uk)
      end
    end
  }

  local data = {}
  for ln = 1, #lines do
    local l = setmetatable(lines[ln], __linemeta)

    if #l.svorka > 0 then
      if l.pole == l.lpole and l.skrina == l.lskrina then
        local ld = {
          pristroj = odstranBordel(l.svorkovnica),
          pristroj2 = odstranBordel(l.svorkovnica1),
          pristroj3 = odstranBordel(l.svorkovnica2),
          svorka = l.svorka,
          cpristroj = odstranBordel(l.lpristroj),
          cpristroj2 = odstranBordel(l.lpristroj1),
          cpristroj3 = odstranBordel(l.lpristroj2),
          csvorka = l.lsvorka,
          cpole = odstranBordel(l.lpole),
          cskrina = odstranBordel(l.lskrina),
          smer = bnn.LAVY
        }
        store(data, ld, l.pole, l.skrina, l.svorkovnica)
      end

      if l.pole == l.rpole and l.skrina == l.rskrina then
        local ld = {
          pristroj = odstranBordel(l.svorkovnica),
          pristroj2 = odstranBordel(l.svorkovnica1),
          pristroj3 = odstranBordel(l.svorkovnica2),
          svorka = l.svorka,
          cpristroj = odstranBordel(l.rpristroj),
          cpristroj2 = odstranBordel(l.rpristroj1),
          cpristroj3 = odstranBordel(l.rpristroj2),
          csvorka = l.rsvorka,
          cpole = odstranBordel(l.rpole),
          cskrina = odstranBordel(l.rskrina),
          smer = bnn.PRAVY
        }
        store(data, ld, l.pole, l.skrina, l.svorkovnica)
      end
    end
  end

  return data
end

klo.headers = {
  "EXTERNÍ =", "EXTERNÍ +", "EXTERNÍ -", "EXTERNÍ -1", "EXTERNÍ -AN", "EXTERNÍ :1",
  "SVORKOVNICE =", "SVORKOVNICE +", "SVORKOVNICE -KL", "SVORKOVNICE -1", "SVORKOVNICE -AN", "SVORKA :1",
  "INTERNÍ =", "INTERNÍ +", "INTERNÍ -", "INTERNÍ -1", "INTERNÍ -AN", "INTERNÍ :1"
}

return klo
