local istic = {
  typy = {
    ["bezny-chranic"] = {svorky = {"N"}},
    ["@I_Moeller_PL7-IHK-NHK"] = {svorky = {".13", ".14", ".21", ".22"}}
  }
}

local function containsall(t, what)
  for _, k in pairs(what) do
    local found = false
    for __, v in pairs(t) do
      if k == v then
        found = true
        break
      end
    end

    if not found then
      return false
    end
  end
  return true
end

function istic.nasmeruj(typ, svorka, nazov)
  if not istic.typy[typ] then
    error("Neviem nasmerovat " .. typ)
  end

  local t = istic.typy[typ]

  if t.nasmeruj then
    t.nasmeruj(typ, svorka, nazov)
  end
end

function istic.otypuj(nazov, svorky)
    local sub = string.match(nazov, "FA[A-Z0-9]+")
    if not sub then
      return nil
    end

    local ns = {}
    for _, sk in pairs(svorky) do
      if #sk.svorka > 0 then
        ns[sk.svorka] = true
      end
    end

    for typ, is in pairs(istic.typy) do
      local match = true

      for _, cs in pairs(is.svorky) do
        if not ns[cs] then
          match = false
          break
        end
      end

      if match then
        return typ
      end
  end
end

function istic.najdi(meno, svorky)
  local s = {}

  for _, v in pairs(svorky) do
    s[v.svorka] = true
  end

  local typ = nil
  for _typ, is in pairs(istic.typy) do
    local match = true

    for _, cs in pairs(is.svorky) do
      if not s[cs] then
        match = false
        break
      end
    end

    if match then
      typ = _typ
      break
    end
  end

  for _, svorka in pairs(svorky) do
    istic.nasmeruj(typ, svorka, meno)
  end

  return typ
end

return istic
