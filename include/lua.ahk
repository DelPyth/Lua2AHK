global LUA_MULTRET := -1

global LUA_DLL := null

; This is called before creating a new state as to load the library.
class LuaLib
{
	__new(dll_path)
	{
		global LUA_DLL

		if (!FileExist(dll_path))
		{
			throw new Error("Cannot find the file specified", -1, dll_path)
		}

		LUA_DLL := dll_path

		this.dll := DllCall("LoadLibrary", "str", dll_path)
		if (!this.dll)
		{
			throw Exception("Could not load library", -1, dll_path)
		}
		return this
	}

	; This is executed automatically after the class has been closed.
	__delete()
	{
		DllCall("FreeLibrary", "uint", this.dll)
	}
}

; lua_State *luaL_newstate (void);
luaL_newstate()
{
	return DllCall(LUA_DLL . "\luaL_newstate", "cdecl")
}

; void luaL_openlibs (lua_State *L);
luaL_openlibs(byref L)
{
	return DllCall(LUA_DLL . "\luaL_openlibs", "uint", L)
}

; void lua_close (lua_State *L);
lua_close(byref L)
{
	return DllCall(LUA_DLL . "\lua_close", "uint", L)
}

; int luaL_loadfile (lua_State *L, const char *filename);
luaL_loadfile(byref L, filename)
{
	return DllCall(LUA_DLL . "\luaL_loadfile", "uint", L, "str", filename)
}

; int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);
lua_pcall(byref L, nargs, nresults, msgh)
{
	return DllCall(LUA_DLL . "\lua_pcall", "uint", L, "int", nargs, "int", nresults, "int", msgh)
}

; int lua_getglobal (lua_State *L, const char *name);
lua_getglobal(byref L, name)
{
	return DllCall(LUA_DLL . "\lua_getglobal", "uint", L, "str", name)
}

; void lua_pushnumber (lua_State *L, lua_Number n);
lua_pushnumber(byref L, n)
{
	return DllCall(LUA_DLL . "\lua_pushnumber", "uint", L, "int", n)
}

; void lua_call (lua_State *L, int nargs, int nresults);
lua_call(byref L, nargs, nresults)
{
	return DllCall(LUA_DLL . "\lua_call", "uint", L, "int", nargs, "int", nresults)
}

; lua_Integer lua_tointeger (lua_State *L, int index);
lua_tointeger(byref L, index)
{
	return DllCall(LUA_DLL . "\lua_tointeger", "uint", L, "int", index)
}

; void lua_pop (lua_State *L, int n);
lua_pop(byref L, n)
{
	return DllCall(LUA_DLL . "\lua_pop", "uint", L, "int", n)
}

; int luaL_dofile (lua_State *L, const char *filename);
luaL_dofile(byref L, filename)
{
	return (luaL_loadfile(L, filename) || lua_pcall(L, 0, LUA_MULTRET, 0))
}
