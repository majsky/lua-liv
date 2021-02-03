local charset = {
  charsets = {
    CP1250 = require("liv.import.charset.cp1250")
  }
}


function charset.convert(what, from)
  if not what then
    return nil
  end
  local cp = charset.charsets[from]

  local done = {}
  for i=1, #what do
    local char = cp[what:byte(i, i)]
    table.insert(done, char)
  end

  return table.concat(done)
end

function charset.wrap(stream, charset)

end

return charset
