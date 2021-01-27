local arch = {
    AMD64 = "x64",
    x86 = "x86"
}

local osenv = {
    home = os.getenv("USERPROFILE"),
    arch = arch[os.getenv("PROCESSOR_ARCHITECTURE")]
}

local pathf = ";@home/.vscode/extensions/tangzx.emmylua-0.3.49/debugger/emmy/windows/@arch/?.dll"

local function makecpath()
    local p = pathf
    for k, v in pairs(osenv) do
        p = p:gsub("@" .. k, v)
    end
    return p
end

package.cpath = package.cpath .. makecpath()
local dbg = require("emmy_core")
dbg.tcpListen("localhost", 9966)

return dbg
