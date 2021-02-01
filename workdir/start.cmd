@echo off
set "LUA_PATH=..\\src\\?.lua;..\\src\\?\\init.lua;..\\lua_modules\\share\\lua\\5.1\\?.lua;..\\lua_modules\\luarocks\\share\\lua\\5.1\\?\\init.lua;"
set "LUA_CPATH=..\\lua_modules\\lib\\lua\\5.1\\?.dll"
"C:\tools\share\luajit\luajit.exe" ..\\src\\octagen\\main.lua
exit /b %ERRORLEVEL%
