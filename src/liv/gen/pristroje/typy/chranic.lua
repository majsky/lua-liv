local chranic = {
  _NAZOV = "bezny-chranic"
}

function chranic.otypuj(nazov, svorky)
  if nazov:sub(1, 1) ~= "F" then
    return nil
  end

  local jeChranic = false
  for _, s in pairs(svorky) do
    local ns = s.svorka

    if ns == "N" then
      jeChranic = true
      break
    end
  end

  return jeChranic and chranic._NAZOV or nil
end

function chranic.nasmeruj(nazov, svorka, typ)
  if svorka.svorka == "N" then
    if svorka.potencial:find(nazov) then
      return "L"
    end
    return "R"
  else
    local cs = tonumber(svorka.svorka)
    if cs then
      return cs % 2 == 0 and "L" or "P"
    end
  end
end

function chranic.jetyp(typ)
    return typ == chranic._NAZOV
end

return chranic
