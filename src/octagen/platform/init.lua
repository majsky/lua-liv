local platform = {}

local function getlib(lib)
  if not platform[lib] then
    platform[lib] = require(string.format("octagen.platform.%s.%s", platform.current, lib))
  end

  return platform[lib]
end

function platform.iswindows()
  return platform.current == "win32"
end

function platform.isunix()
  return platform.current == "unix"
end

return (function()
  platform.current = (package.config:sub(1,1) == "\\") and "win32" or "unix"

  getlib("term")
  getlib("fs")

  return platform
end)()
