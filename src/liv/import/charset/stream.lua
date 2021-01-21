local charset = require("liv.import.charset")
local st = {}
local _st = {}

function _st.__index(t, k)
    return st[k] or t.base[k]
end

function st.new(stream, cp)
    local o = {
        base = stream,
        codepage = cp
    }

    return setmetatable(o, _st)
end

function st:read(...)
    local data = self.base:read(...)
    data = charset.convert(data, self.codepage)
    return data
end

return st