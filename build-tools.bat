@echo off
setlocal

if exist tools (
    echo TOOLS READY
    goto EOF
)

mkdir tools
pushd tools
set "LUAV=5.3"
set "LUAR=6"

if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    call "C:\Program Files\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat"
) else (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
)
@echo off

mkdir lua
pushd lua

bitsadmin /transfer "lua-%LUAV%" /priority high "http://www.lua.org/ftp/lua-%LUAV%.%LUAR%.tar.gz" "%cd%\lua-%LUAV%.%LUAR%.tar.gz"
7z x -o%cd% "%cd%\lua-%LUAV%.%LUAR%.tar.gz"
7z x -o%cd% "%cd%\lua-%LUAV%.%LUAR%.tar"

mkdir lua-%LUAV%.%LUAR%\build
pushd lua-%LUAV%.%LUAR%\build
cl /MD /O2 /c /DLUA_BUILD_AS_DLL ..\src\*.c
if exist lua.o del lua.o
ren lua.obj lua.o
if exist luac.o del luac.o
ren luac.obj luac.o
link /DLL /IMPLIB:lua%LUAV%.lib /OUT:lua%LUAV%.dll *.obj
lib /OUT:lua%LUAV%-static.lib *.obj
link /OUT:lua%LUAV%.exe lua.o lua-%LUAV%.lib
link /OUT:luac%LUAV%.exe luac.o lua-%LUAV%-static.lib
popd
popd

robocopy lua\lua-%LUAV%.%LUAR%\src include lua.h luaconf.h lualib.h lauxlib.h lua.hpp
robocopy lua\lua-%LUAV%.%LUAR%\build %cd% lua%LUAV%.exe luac%LUAV%.exe lua%LUAV%.dll"
robocopy lua\lua-%LUAV%.%LUAR%\build lib lua%LUAV%.lib lua%LUAV%-static.lib

rd /S /Q lua


mkdir srlua
pushd srlua
bitsadmin /transfer "srlua-102" /priority high "http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/ar/srlua-102.tar.gz" "%cd%\srlua-102.tar.gz"
7z x -o%cd% "%cd%\srlua-102.tar.gz"
7z x -o%cd% "%cd%\srlua-102.tar"

cl srlua-102\srglue.c
cl /I ..\include ..\lib\lua5.3.lib srlua-102\srlua.c
popd

move /Y srlua\srglue.exe srglue.exe
move /Y srlua\srlua.exe srlua.exe
rd /S /Q srlua
popd 

:EOF