#include %A_ScriptDir%\..\lib\misc.ahk

#include %A_ScriptDir%\..\include\lua.ahk

#NoEnv
#SingleInstance Force
SetBatchLines -1
SetWorkingDir % A_ScriptDir . "\.."

main(argc, argv)
{
	; Load the DLL file.
	lua := new LuaLib(A_WorkingDir . "\assets\lua54.dll")
	; Create a new state for Lua.
	L := luaL_newstate()

	; Open the libs.
	luaL_openlibs(L)

	; Execute the script file.
	luaL_dofile(L, A_ScriptDir . "\scripts\test_1.lua")

	; Attempt to call the function that resides inside the Lua file.
	x := 10
	y := 2
	z := luaAdd(L, x, y)

	; Print the info.
	printf("{1} + {2} = {3}`n", x, y, z)

	; Close the library.
	lua_close(L)
	return 0
}

luaAdd(byref L, a, b)
{
	; Push the add function on the top of the lua stack
	lua_getglobal(L, "add")

	; Push the first argument on the top of the lua stack
	lua_pushnumber(L, a)

	; Push the second argument on the top of the lua stack
	lua_pushnumber(L, b)

	; Call the function with 2 arguments, returning 1 result
	lua_call(L, 2, 1)

	; Get the result
	sum := lua_tointeger(L, -1)
	lua_pop(L, 1)
	return sum
}

; Create the entry point.
ExitApp, % main(A_Args.Count(), A_Args)
