local log = {
  proto={},
  levels = {
    "DEBG", "INFO", "WARN", "ERRO"
  }
}
local _log = {__index=log.proto}

function log.new(nazov)
  local o = setmetatable({
    nazov = nazov,
    entrys = {}
  }, _log)

  return o
end

function log.proto:log(level, msg)
  if type(msg) == "table" then
    msg = table.concat(msg, " ")
  end
  table.insert(self.entrys, self:format(level, msg))
end

function log.proto:format(level, msg)
  if type(level) == "number" then
    level = log.level[level]
  end

  return string.format("%s[%s]<%s>: %s", os.date(), self.nazov, level, msg)
end

function log.proto:debug(...)
  self:log(log.levels[1], {...})
end

function log.proto:info(...)
  self:log(log.levels[2], {...})
end

function log.proto:warn(...)
  self:log(log.levels[3], {...})
end

function log.proto:error(...)
  self:log(log.levels[4], {...})
end

function log.proto:uloz(cesta)
  local fh = io.open(cesta, "w")

  for _, e in ipairs(self.entrys) do
    fh:write(e)
    fh:write("\n")
  end

  fh:close()
end

return log
