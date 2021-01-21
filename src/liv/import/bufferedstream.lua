local _bs = {}
local bs = {
    __BUFFER_SIZE = 8 * 1024
}

function _bs.__index(t, k)
    return bs[k] or t.base[k]
end

function bs.new(stream, buffer)
    local s = {
        base = stream,
        buffer = {},
        bstr = "",
        bsize = buffer or bs.__BUFFER_SIZE
    }
    return setmetatable(s, _bs)
end

function bs:fillbuffer()
    local buf = self.base:read(self.__BUFFER_SIZE)
    if not buf then
        return false
    end
    table.insert(self.buffer, buf)
    self.bstr = self.bstr .. buf
    return true
end

function bs:read(mode)
    local tmode = type(mode)

    
    if tmode == "nil" then
        
    elseif tmode == "number" then

    elseif tmode == "string" then
        if mode == "*l" then
            local i = string.find(self.bstr, "\n")
            if not i then
                if not self:fillbuffer() then return nil end
                i = string.find(self.bstr, "\n")
                
            end
            local txt = self.bstr:sub(1,i)
            self.bstr = self.bstr:sub(i+1, #self.bstr)

            return txt
        end
    end
end


return bs