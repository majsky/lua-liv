package.cpath = package.cpath .. ";c:/Users/oresany/.vscode/extensions/tangzx.emmylua-0.3.49/debugger/emmy/windows/x86/?.dll"
local dbg = require("emmy_core")
dbg.tcpListen("localhost", 9966)
rawset(_G, "dbg", dbg)


local og = require("octagen")

og.main(...)
