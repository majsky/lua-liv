local gens = {}

local function registruj(generator)
  gens[generator] = require("octagen.runtime.gen." .. generator)
end

local function init()
  registruj("banany")


  return gens
end

return init()
