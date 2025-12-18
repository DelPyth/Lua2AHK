#SingleInstance Force

#include ..\include\lua.ahk

#include ..\lib\
#include io.ahk
#include misc.ahk

global TEST_PATH := A_ScriptDir . "\scripts"

main(args)
{
	; Initialize lua
	L := luaL_newstate()

	; Open the libraries for what we're about to do.
	luaL_openlibs(L)

	; Ask for user input.
	printf("This is a test to see if objects work smoothly within Lua.\n")

	; Overwrite the print function as Lua prints (supposedly) to something else.
	setPrint(L, lua_print)

	luaL_dofile(L, TEST_PATH . "\test02.lua")
	return 0
}

setPrint(L, fn)
{
	; Lua functions only push 1 parameter so setting the parameter count to 1 is only necessary.
	lua_pushcclosure(L, CallbackCreate(fn,, 1), 0)

	; Set the new value from the top of the stack as the "print" function.
	lua_setglobal(L, "print")
}

lua_print(L)
{
	msg := lua_tolstring(L, 1, 0)
	printf(msg)
}

if (A_LineFile == A_ScriptFullPath)
{
	ExitApp(main(A_Args) || 0)
}


