print(package.path)
print(package.cpath)

local lcls = require("libl.class.simple")

local c = lcls.new()

function c:init(n)
  self.name = n
end

function c:greet(text)
    print(string.format("%s says: %s", self.name, text))
end

local d = lcls.new(c)

function d:greet(text)
    print(string.format("superior %s says: %s", self.name, text))
end

local o = c:new("o")
local i = d:new("i")

--o:test("hellp")


i:greet("heyy")
o:greet("sup")

print(i:getclass())
