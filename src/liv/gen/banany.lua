local bnn = {
  LAVY = "L",
  PRAVY = "P"
}

function bnn.sprav(smer, k1, k2)
  if smer == bnn.LAVY then
    return bnn.spravLavy(k1, k2)
  elseif smer == bnn.PRAVY then
    return bnn.spravPravy(k1, k2)
  end
  error("Neznamy smer: " .. smer)
end

function bnn.spravLavy(k1, k2)
  return string.format("%s:%s:%s", k2.svorka, k2.pristroj, k1.svorka)
end

function bnn.spravPravy(k1, k2)
  return string.format("%s:%s:%s", k1.svorka, k2.pristroj, k2.svorka)
end

return bnn
