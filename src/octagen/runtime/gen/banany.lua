
local banany = {}

function banany.over(data)
  if data.zapojenie == nil and data.zozPrist == nil then
    error("Chyba mi" .. not zapojenie and " zapojenie" .. not data.zozPrist and " zozonam pristrojov.")
  end

  return true
end

function banany.generuj(data)
  if not data.zapojenie:jevyplnene() then
    error("Zapojenie nieje vyplnene!")
  end

  return data.zapojenie:generuj(data.zozPrist)
end

return banany
