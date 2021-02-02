local stitky = {}

function stitky.over(data)
  if not data.kab then
    error("Chyba mi KAB")
  end

  return true
end

function stitky.generuj(data)
  local st = {}

  for cislo, d in pairs(data.kab) do
    local len = d.dlzka1
    if not len or #len == 0 then
      len = d.dlzka2
    end

    if len:reverse():sub(1,1) ~= "m" then
      len = len .. "m"
    end

    table.insert(st, table.concat({cislo, d.skrina, d.cskrina, d.typ, len}, ";"))
    table.insert(st, table.concat({cislo, d.cskrina, d.skrina, d.typ, len}, ";"))
  end

  return st
end

return stitky
