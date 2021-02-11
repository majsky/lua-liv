local bnn = require("liv.gen.banany")
local klo = {}

klo.map = {
  ["EXTERNÍ ="]       = "lpole",
  ["EXTERNÍ +"]       = "lskrina",
  ["EXTERNÍ -"]       = "lpristroj",
  ["EXTERNÍ -1"]      = "lpristroj1",
  ["EXTERNÍ -AN"]     = "lpristroj2",
  ["EXTERNÍ :1"]      = "lsvorka",
  ["SVORKOVNICE ="]   = "pole",
  ["SVORKOVNICE +"]   = "skrina",
  ["SVORKOVNICE -KL"] = "svorkovnica",
  ["SVORKOVNICE -1"]  = "svorkovnica1",
  ["SVORKOVNICE -AN"] = "svorkovnica2",
  ["SVORKA :1"]       = "svorka",
  ["INTERNÍ ="]       = "rpole",
  ["INTERNÍ +"]       = "rskrina",
  ["INTERNÍ -"]       = "rpristroj",
  ["INTERNÍ -1"]      = "rpristroj1",
  ["INTERNÍ -AN"]     = "rpristroj2",
  ["INTERNÍ :1"]      = "rsvorka",
}

local skipp = {
  ["STENA SKRINE"] = true,
  ["DVERE"] = true,
  ["RÁM"] = true
}
local function odstranBordel(str)
  str = str:match("[=%+-%.]*(.+)") or ""
  if skipp[str] then
    return ""
  end
  return str
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

function klo.process(lines)
  local data = {}
  for ln = 1, #lines do
    local l = lines[ln]

    if #l.svorka > 0 then
      if l.pole == l.lpole and l.skrina == l.lskrina then
        local ld = {
          pristroj = l.svorkovnica,
          pristroj2 = l.svorkovnica1,
          pristroj3 = l.svorkovnica2,
          svorka = l.svorka,
          cpristroj = l.lpristroj,
          cpristroj2 = l.lpristroj1,
          cpristroj3 = l.lpristroj2,
          csvorka = l.lsvorka,
          cpole = l.lpole,
          cskrina = l.lskrina,
          smer = bnn.LAVY,
          obsadena = true
        }
        if ld.cpristroj == "" then
          ld.obsadena = false
        end
        store(data, ld, l.pole, l.skrina, l.svorkovnica)
      end

      if l.pole == l.rpole and l.skrina == l.rskrina then
        local ld = {
          pristroj = l.svorkovnica,
          pristroj2 = l.svorkovnica1,
          pristroj3 = l.svorkovnica2,
          svorka = l.svorka,
          cpristroj = l.rpristroj,
          cpristroj2 = l.rpristroj1,
          cpristroj3 = l.rpristroj2,
          csvorka = l.rsvorka,
          cpole = l.rpole,
          cskrina = l.rskrina,
          smer = bnn.PRAVY,
          obsadena = true
        }
        if ld.cpristroj == "" then
          ld.obsadena = false
        end
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
