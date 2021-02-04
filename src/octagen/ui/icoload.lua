local term = require("octagen.platform").term

return function(code, fallback)
  if term.isicon() then
    return utf8.char(code)
  end

  return fallback
end
