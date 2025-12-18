/**
 * # Lua.ahk
 * Extend *your* AHK program with Lua!
 *
 * ## Requirements
 * | Library | Tested Version | External Link |
 * | --- | --- | --- |
 * | AutoHotkey | 2.0.6 | https://www.autohotkey.com/download |
 * | Lua | 5.4.2 (Release 1) | https://luabinaries.sourceforge.net |
 *
 * # How To Install
 * 1. Download this script into your `/lib/` folder for your current project or into your AutoHotkey library directory.
 * Read more here: https://www.autohotkey.com/docs/v2/Scripts.htm#lib
 * 2. Use `#include` to include the library into your AHK program.
 * 3. Validate you have `lua54.dll` with your project. Make sure to use `#DllLoad` and set it to the path of the Lua DLL, for example: `#DllLoad %A_ScriptDir%\lua54.dll`
 * 4. Look up a tutorial for using Lua in C (with some minor adjustments to the syntax) and you're on your way.
 *
 * # Notes
 * - Lua does not have *all* of the functions defined publically for the Lua DLL.
 *   Therefore, translating the functions directly to a DllCall won't be easy.
 *   There are some functions that are just macros (read the Macros section below for more information),
 *   However some functions downright don't exist, such as `lua_call`, `lua_pcall`, and many others.
 *   So directly translating C code into AHK won't be a perfect solution.
 * - I have provided a list of functions that the lua54 DLL has and removed the functions that are currently present in this file.
 *   You may add them yourself if you so desire.
 * - I have not tested all functions (within this file) to see if they work.
 *   I only have used various examples strewn about within Lua's documentation to see if they work.
 *   A lot of the functions do in fact work :)
*/

#Requires AutoHotkey v2.0

; Attempt to load the lua DLL if present.
; It's recommended to use your own path in your project.
; IF the lua DLL does not exist within this folder, you must add this line yourself within your project, pointing to the lua DLL.
; Recommendation is lua 5.4+
#DllLoad *i lua54.dll


; =============================================================================
; # Global Variables

; This is not defined in Lua's source, this is a simple NULL variable added to AHK.
; In C, NULL is a null pointer with the position of 0.
; In AHK, I recommend to use a blank string.
global NULL                     := ""

global LUA_MULTRET              := -1

global LUA_OK                   := 0
global LUA_YIELD                := 1
global LUA_ERRRUN               := 2
global LUA_ERRSYNTAX            := 3
global LUA_ERRMEM               := 4
global LUA_ERRERR               := 5

/*
  LUAI_MAXSTACK limits the size of the Lua stack.
  Its only purpose is to stop Lua from consuming unlimited stack
  space (and to reserve some numbers for pseudo-indices).
  (It must fit into max(size_t)/32 and max(int)/2.)
  Regardless of AHK's bit size (32 or 64) Lua's stack size will always be 32 bit if this DLL is used. If compiled as 64-bit, the stack size will be limited to 15000.
*/
global LUAI_MAXSTACK            := unset
if FileExist("../bin/lua54.dll") {
  DllCall("GetBinaryType", "str", "../bin/lua54.dll", "uint*", &_lua_binary_type)
  ; 0 = 32-bit program
  LUAI_MAXSTACK                 := _lua_binary_type == 0 ? 1000000 : 15000
}
else
  ; We just have to assume the dll is 32-bit compiled
  LUAI_MAXSTACK                 := 1000000

; minimum Lua stack available to a AHK function
global LUA_MINSTACK             := 20

global LUA_REGISTRYINDEX        := (-LUAI_MAXSTACK - 1000)

global LUA_TNONE                := -1

global LUA_TNIL                 := 0
global LUA_TBOOLEAN             := 1
global LUA_TLIGHTUSERDATA       := 2
global LUA_TNUMBER              := 3
global LUA_TSTRING              := 4
global LUA_TTABLE               := 5
global LUA_TFUNCTION            := 6
global LUA_TUSERDATA            := 7
global LUA_TTHREAD              := 8
global LUA_NUMTYPES             := 9
global LUA_TUPVAL               := LUA_NUMTYPES
global LUA_TPROTO               := LUA_NUMTYPES + 1

global LUA_RIDX_MAINTHREAD      := 1
global LUA_RIDX_GLOBALS         := 2
global LUA_RIDX_LAST            := LUA_RIDX_GLOBALS

global LUA_NOREF                := -2
global LUA_REFNIL               := -1

global LUA_LOADED_TABLE         := "_LOADED"
global LUA_PRELOAD_TABLE        := "_PRELOAD"

; =============================================================================
; # Not used Functions
; Functions I will probably not implement, as they're either too niche, or don't do anything [useful] that I can think of (at least within ahk).

/*
; this is not defined in Lua's docs but is in the source code.
; it literally just returns the stack limit and doesn't change it
lua_setcstacklimit

; it's not defined in Lua's docs but is in the source code.
; it's supposed to check the lua version and throw an error if the version is not compatible
lual_checkversion_
*/


; =============================================================================
; # Functions

; Loads a file as a Lua chunk.
luaL_loadfilex(L, filename, mode) => DllCall("lua54.dll\luaL_loadfilex", "ptr", L, "astr", String(filename), mode == null ? "int" : "str", mode == null ? 0 : String(mode))

; Loads a string as a Lua chunk.
luaL_loadstring(L, s) => DllCall("lua54.dll\luaL_loadstring", "ptr", L, "astr", String(s))

; Creates a new Lua state.
luaL_newstate() => DllCall("lua54.dll\luaL_newstate", "ptr")

; Opens all standard Lua libraries into the given state.
luaL_openlibs(L) => DllCall("lua54.dll\luaL_openlibs", "ptr", L)

; Checks whether the function argument arg has type t.
luaL_checktype(L, arg, t) => DllCall("lua54.dll\luaL_checktype", "ptr", L, "int", Integer(arg), "int", Integer(t))

; Creates and returns a reference, in the table at index t, for the object on the top of the stack (and pops the object).
luaL_ref(L, t) => DllCall("lua54.dll\luaL_ref", "ptr", L, "int", t)

; Releases the reference ref from the table at index t (see luaL_ref).
luaL_unref(L, t, ref) => DllCall("lua54.dll\luaL_unref", "ptr", L, "int", t, "int", ref)

; Sets the metatable of the object on the top of the stack as the metatable associated with name tname in the registry (see luaL_newmetatable).
luaL_setmetatable(L, tname) => DllCall("lua54.dll\luaL_setmetatable", "ptr", L, "astr", String(tname))

; If the registry already has the key tname, returns 0. Otherwise, creates a new table to be used as a metatable for userdata, adds to this new table the pair __name = tname, adds to the registry the pair [tname] = new table, and returns 1.
luaL_newmetatable(L, tname) => DllCall("lua54.dll\luaL_newmetatable", "ptr", L, "astr", String(tname))

; This function creates and pushes on the stack a new full userdata, with nuvalue associated Lua values, called user values, plus an associated block of raw memory with size bytes.
lua_newuserdatauv(L, sz, nuv) => DllCall("lua54.dll\lua_newuserdatauv", "ptr", L, "int", Integer(sz), "int", Integer(nuv))

; Pushes onto the stack the n-th user value associated with the full userdata at the given index and returns the type of the pushed value.
; If the userdata does not have that value, pushes nil and returns LUA_TNONE.
lua_getiuservalue(L, idx, n) => DllCall("lua54.dll\lua_getiuservalue", "ptr", L, "int", Integer(idx), "int", Integer(n))

; Checks whether the function argument arg is a userdata of the type tname (see luaL_newmetatable) and returns the userdata's memory-block address (see lua_touserdata).
luaL_checkudata(L, ud, tname) => DllCall("lua54.dll\luaL_checkudata", "ptr", L, "ptr", ud, "astr", String(tname))

; If the value at the given index has a metatable, the function pushes that metatable onto the stack and returns 1. Otherwise, the function returns 0 and pushes nothing on the stack.
lua_getmetatable(L, objindex) => DllCall("lua54.dll\lua_getmetatable", "ptr", L, "int", Integer(objindex))

; Sets a new panic function and returns the old one.
lua_atpanic(L, panicf) => DllCall("lua54.dll\lua_atpanic", "ptr", L, "ptr", panicf)

; Converts the acceptable index idx into an equivalent absolute index (that is, one that does not depend on the stack size).
lua_absindex(L, idx) => DllCall("lua54.dll\lua_absindex", "ptr", L, "int", idx)

; Ensures that the stack has space for at least n extra elements, that is, that you can safely push up to n values into it.
lua_checkstack(L, n) => DllCall("lua54.dll\lua_checkstack", "ptr", L, "int", Integer(n))

; Close all active to-be-closed variables in the main thread, release all objects in the given Lua state (calling the corresponding garbage-collection metamethods, if any), and frees all dynamic memory used by this state.
lua_close(L) => DllCall("lua54.dll\lua_close", "ptr", L)

; Copies the element at index fromidx into the valid index toidx, replacing the value at that position. Values at other positions are not affected.
lua_copy(L, fromidx, toidx) => DllCall("lua54.dll\lua_copy", "ptr", L, "int", Integer(fromidx), "int", Integer(toidx))

; Creates a new empty table and pushes it onto the stack.
lua_createtable(L, narr, nrec) => DllCall("lua54.dll\lua_createtable", "ptr", L, "int", Integer(narr), "int", Integer(nrec))

; Pushes onto the stack the value of the global name. Returns the type of that value.
lua_getglobal(L, name) => DllCall("lua54.dll\lua_getglobal", "ptr", L, "astr", name)

; Gets information about the n-th upvalue of the closure at index funcindex. It pushes the upvalue's value onto the stack and returns its name. Returns NULL (and pushes nothing) when the index n is greater than the number of upvalues.
lua_getupvalue(L, funcindex, n) => DllCall("lua54.dll\lua_getupvalue", "ptr", L, "int", funcindex, "int", n)

; Pushes onto the stack the value t[k], where t is the value at the given index and k is the value on the top of the stack.
lua_gettable(L, index) => DllCall("lua54.dll\lua_gettable", "ptr", L, "int", Integer(index))

; Returns the index of the top element in the stack
lua_gettop(L) => DllCall("lua54.dll\lua_gettop", "ptr", L)

; Returns 1 if the value at the given index is a AHK function, and 0 otherwise.
lua_iscfunction(L, index) => DllCall("lua54.dll\lua_iscfunction", "ptr", L, "int", Integer(index))

; This function behaves exactly like lua_pcall, except that it allows the called function to yield.
lua_pcallk(L, nargs, nresults, msgh, ctx, k) => DllCall("lua54.dll\lua_pcallk", "ptr", L, "int", Integer(nargs), "int", Integer(nresults), "int", Integer(msgh), "int", ctx, k == null ? "int" : "ptr", k || 0)

; Pushes a new C closure onto the stack.
lua_pushcclosure(L, f, n) => DllCall("lua54.dll\lua_pushcclosure", "ptr", L, "ptr", f, "int", Integer(n))

; Pushes a float with value n onto the stack.
lua_pushnumber(L, n) => DllCall("lua54.dll\lua_pushnumber", "ptr", L, "double", Float(n))

; Pushes a boolean value with value b onto the stack.
lua_pushboolean(L, b) => DllCall("lua54.dll\lua_pushboolean", "ptr", L, "int", b ? true : false) ; Make sure that it's true or false (1 or 0), or there may be issues.

; Pushes an integer with value n onto the stack.
lua_pushinteger(L, n) => DllCall("lua54.dll\lua_pushinteger", "ptr", L, "int", Integer(n))

; Pushes a nil value onto the stack.
lua_pushnil(L) => DllCall("lua54.dll\lua_pushnil", "ptr", L)

; Pushes a copy of the element at the given index onto the stack.
lua_pushvalue(L, index) => DllCall("lua54.dll\lua_pushvalue", "ptr", L, "int", Integer(index))

; Pushes the zero-terminated string pointed to by s onto the stack. Lua will make or reuse an internal copy of the given string, so the memory at s can be freed or reused immediately after the function returns.
; Returns a pointer to the internal copy of the string.
; If s is NULL, pushes nil and returns NULL.
lua_pushstring(L, s) => DllCall("lua54.dll\lua_pushstring", "ptr", L, "astr", String(s))

; Similar to lua_gettable, but does a raw access (i.e., without metamethods). The value at index must be a table.
lua_rawget(L, index) => DllCall("lua54.dll\lua_rawget", "ptr", L, "int", Integer(index))

;  Pushes onto the stack the value t[n], where t is the table at the given index. The access is raw, that is, it does not use the __index metavalue.
; Returns the type of the pushed value.
lua_rawgeti(L, index, n) => DllCall("lua54.dll\lua_rawgeti", "ptr", L, "int", index, "int", n)

; Returns the raw "length" of the value at the given index: for strings, this is the string length; for tables, this is the result of the length operator ('#') with no metamethods; for userdata, this is the size of the block of memory allocated for the userdata. For other values, this call returns 0.
lua_rawlen(L, index) => DllCall("lua54.dll\lua_rawlen", "ptr", L, "int", index)

; Similar to lua_settable, but does a raw assignment (i.e., without metamethods). The value at index must be a table.
lua_rawset(L, index) => DllCall("lua54.dll\lua_rawset", "ptr", L, "int", Integer(index))

; Does the equivalent of t[i] = v, where t is the table at the given index and v is the value on the top of the stack.
; This function pops the value from the stack. The assignment is raw, that is, it does not use the __newindex metavalue.
lua_rawseti(L, index, i) => DllCall("lua54.dll\lua_rawseti", "ptr", L, "int", Integer(index), "int", Integer(i))

; Rotates the stack elements between the valid index idx and the top of the stack.
lua_rotate(L, idx, n) => DllCall("lua54.dll\lua_rotate", "ptr", L, "int", Integer(idx), "int", Integer(n))

; Does the equivalent to t[k] = v, where t is the value at the given index and v is the value on the top of the stack.
lua_setfield(L, index, k) => DllCall("lua54.dll\lua_setfield", "ptr", L, "int", Integer(index), "astr", String(k))

; Pushes onto the stack the value t[k], where t is the value at the given index.
lua_getfield(L, idx, k) => DllCall("lua54.dll\lua_getfield", "ptr", L, "int", Integer(idx), "astr", String(k))

; Pops a value from the stack and sets it as the new value of global name.
lua_setglobal(L, name) => DllCall("lua54.dll\lua_setglobal", "ptr", L, "astr", name)

; Sets the value of a closure's upvalue. It assigns the value on the top of the stack to the upvalue and returns its name. It also pops the value from the stack.
; Returns NULL (and pops nothing) when the index n is greater than the number of upvalues.
; Parameters funcindex and n are as in the function lua_getupvalue.
lua_setupvalue(L, funcindex, n) => DllCall("lua54.dll\lua_setupvalue", "ptr", L, "int", funcindex, "int", n)

; Does the equivalent to t[k] = v, where t is the value at the given index, v is the value on the top of the stack, and k is the value just below the top.
; This function pops both the key and the value from the stack
lua_settable(L, index) => DllCall("lua54.dll\lua_settable", "ptr", L, "int", Integer(index))

; Pops a table or nil from the stack and sets that value as the new metatable for the value at the given index. (nil means no metatable.)
; (For historical reasons, this function returns an int, which now is always 1.)
lua_setmetatable(L, index) => DllCall("lua54.dll\lua_setmetatable", "ptr", L, "int", Integer(index))

; Accepts any index, or 0, and sets the stack top to this index.
lua_settop(L, index) => DllCall("lua54.dll\lua_settop", "ptr", L, "int", Integer(index))

; Converts the Lua value at the given index to a C boolean value (0 or 1).
lua_toboolean(L, index) => DllCall("lua54.dll\lua_toboolean", "ptr", L, "int", Integer(index))

; Converts the Lua value at the given index to the signed integral type lua_Integer (which is just a renamed int).
lua_tointeger(L, index) => DllCall("lua54.dll\lua_tointegerx", "ptr", L, "int", Integer(index), "int", 0)

; If the value at the given index is a full userdata, returns its memory-block address. If the value is a light userdata, returns its value (a pointer). Otherwise, returns NULL.
lua_touserdata(L, index) => DllCall("lua54.dll\lua_touserdata", "ptr", L, "int", Integer(index))

; Pushes a light userdata onto the stack.
; Userdata represent C values in Lua. A light userdata represents a pointer, a void*. It is a value (like a number): you do not create it, it has no individual metatable, and it is not collected (as it was never created). A light userdata is equal to "any" light userdata with the same C address.
lua_pushlightuserdata(L, p) => DllCall("lua54.dll\lua_pushlightuserdata", "ptr", L, "ptr", p)

; Sets the value of a local variable of a given activation record. It assigns the value on the top of the stack to the variable and returns its name. It also pops the value from the stack.
; Returns NULL (and pops nothing) when the index is greater than the number of active local variables.
; Parameters ar and n are as in the function lua_getlocal.
lua_setlocal(L, ar, n) => DllCall("lua54.dll\lua_setlocal", "ptr", L, "ptr", ar, "int", Integer(n))

; Grows the stack size to top + sz elements, raising an error if the stack cannot grow to that size. msg is an additional text to go into the error message (or NULL for no additional text).
luaL_checkstack(L, space, msg) => DllCall("lua54.dll\luaL_checkstack", "ptr", L, "int", Integer(space), "astr", String(msg))

; Converts the value at the given index to a generic C pointer (void*). The value can be a userdata, a table, a thread, a string, or a function; otherwise, lua_topointer returns NULL. Different objects will give different pointers. There is no way to convert the pointer back to its original value.
; Typically this function is used only for hashing and debug information.
lua_topointer(L, index) => DllCall("lua54.dll\lua_topointer", "ptr", L, "int", Integer(index))

; Converts the value at the given index to a Lua thread (represented as lua_State*). This value must be a thread; otherwise, the function returns NULL.
lua_tothread(L, index) => DllCall("lua54.dll\lua_tothread", "ptr", L, "int", index)

; Returns the type of the value in the given valid index, or LUA_TNONE for a non-valid but acceptable index.
lua_type(L, index) => DllCall("lua54.dll\lua_type", "ptr", L, "int", Integer(index))

; This function behaves exactly like lua_call, but allows the called function to yield.
lua_callk(L, nargs, nresults, ctx, k) => DllCall("lua54.dll\lua_callk", "ptr", L, "int", Integer(nargs), "int", Integer(nresults), "int", ctx, k == null ? "int" : "ptr", k || 0)

; Used for luaL_requiref, it imports the base library.
luaopen_base(L) => DllCall("lua54.dll\luaopen_base", "ptr", L)

; Used for luaL_requiref, it imports the package library.
luaopen_package(L) => DllCall("lua54.dll\luaopen_package", "ptr", L)

; Used for luaL_requiref, it imports the coroutine library.
luaopen_coroutine(L) => DllCall("lua54.dll\luaopen_coroutine", "ptr", L)

; Used for luaL_requiref, it imports the table library.
luaopen_table(L) => DllCall("lua54.dll\luaopen_table", "ptr", L)

; Used for luaL_requiref, it imports the i/o library.
luaopen_io(L) => DllCall("lua54.dll\luaopen_io", "ptr", L)

; Used for luaL_requiref, it imports the os library.
luaopen_os(L) => DllCall("lua54.dll\luaopen_os", "ptr", L)

; Used for luaL_requiref, it imports the string library.
luaopen_string(L) => DllCall("lua54.dll\luaopen_string", "ptr", L)

; Used for luaL_requiref, it imports the math library.
luaopen_math(L) => DllCall("lua54.dll\luaopen_math", "ptr", L)

; Used for luaL_requiref, it imports the utf8 library.
luaopen_utf8(L) => DllCall("lua54.dll\luaopen_utf8", "ptr", L)

; Used for luaL_requiref, it imports the debug library.
luaopen_debug(L) => DllCall("lua54.dll\luaopen_debug", "ptr", L)

; If package.loaded[modname] is not true, calls the function openf with the string modname as an argument and sets the call result to package.loaded[modname], as if that function has been called through require.
; If glb is true, also stores the module into the global modname.
; Leaves a copy of the module on the stack.
luaL_requiref(L, modname, openf, glb) => DllCall("lua54.dll\luaL_requiref", "ptr", L, "astr", String(modname), "ptr", openf, "int", glb ? true : false)

; Pops a value from the stack and sets it as the new n-th user value associated to the full userdata at the given index. Returns 0 if the userdata does not have that value.
lua_setiuservalue(L, idx, n) => DllCall("lua54.dll\lua_setiuservalue", "ptr", L, "int", Integer(idx), "int", Integer(n))

/*
  Pops a key from the stack, and pushes a key-value pair from the table at the given index, the "next" pair after the given key. If there are no more elements in the table, then lua_next returns 0 and pushes nothing.
  Be aware, if you pop a value from the stack as to not re-pop again as this can cause an invalid memory access error for AHK itself.
  A typical table traversal looks like this:
  ```autohotkey
  printf := (fmt, args*) => FileAppend(Format(fmt, args*), "*")

  ; table is in the stack at index 't'
  lua_pushnil(L)  ; first key
  while lua_next(L, t) != 0 {
    ; uses 'key' (at index -2) and 'value' (at index -1)
    printf("{:s} - {:s}`n",
      lua_typename(L, lua_type(L, -2)),
      lua_typename(L, lua_type(L, -1))
    )
    ; removes 'value'; keeps 'key' for next iteration
    lua_pop(L, 1)
  }
  ```
  While traversing a table, avoid calling lua_tolstring directly on a key, unless you know that the key is actually a string. Recall that lua_tolstring may change the value at the given index; this confuses the next call to lua_next.
  This function may raise an error if the given key is neither nil nor present in the table. See function next for the caveats of modifying the table during its traversal.
*/
lua_next(L, index) => DllCall("lua54.dll\lua_next", "ptr", L, "int", Integer(index))

; Raises an error reporting a problem with argument arg of the AHK function that called it, using a standard message that includes extramsg as a comment:
;      bad argument #arg to 'funcname' (extramsg)
; This function never returns.
luaL_argerror(L, arg, extramsg) => DllCall("lua54.dll\luaL_argerror", "ptr", L, "int", Integer(arg), "astr", String(extramsg))

; Raises a Lua error, using the value on the top of the stack as the error object. This function does a long jump, and therefore never returns (see luaL_error).
lua_error(L) => DllCall("lua54.dll\lua_error", "ptr", L)

; Returns the length of the value at the given index. It is equivalent to the '#' operator in Lua. The result is pushed on the stack.
lua_len(L, index) => DllCall("lua54.dll\lua_len", "ptr", L, "int", Integer(index))

; Converts a value at the given index to a C function. That value must be a C function; otherwise, returns NULL.
lua_tocfunction(L, index) => DllCall("lua54.dll\lua_tocfunction", "ptr", L, "int", Integer(index))

; Performs an arithmetic or bitwise operation over the two values (or one, in the case of negations) at the top of the stack, with the value on the top being the second operand, pops these values, and pushes the result of the operation.
; The function follows the semantics of the corresponding Lua operator (that is, it may call metamethods).
lua_arith(L, op) => DllCall("lua54.dll\lua_arith", "ptr", L, "int", Integer(op))

; Compares two Lua values. Returns 1 if the value at index index1 satisfies op when compared with the value at index index2, following the semantics of the corresponding Lua operator (that is, it may call metamethods).
; Otherwise returns 0. Also returns 0 if any of the indices is not valid.
lua_compare(L, index1, index2, op) => DllCall("lua54.dll\lua_compare", "ptr", L, "int", Integer(index1), "int", Integer(index2), "int", Integer(op))

; Concatenates the n values at the top of the stack, pops them, and leaves the result on the top. If n is 1, the result is the single value on the stack (that is, the function does nothing);
; if n is 0, the result is the empty string. Concatenation is performed following the usual semantics of Lua
lua_concat(L, n) => DllCall("lua54.dll\lua_concat", "ptr", L, "int", Integer(n))

; Dumps a function as a binary chunk. Receives a Lua function on the top of the stack and produces a binary chunk that, if loaded again, results in a function equivalent to the one dumped. As it produces parts of the chunk, lua_dump calls function writer (see lua_Writer) with the given data to write them.
; If strip is true, the binary representation may not include all debug information about the function, to save space.
; The value returned is the error code returned by the last call to the writer; 0 means no errors.
; This function does not pop the Lua function from the stack.
lua_dump(L, writer, data, strip) => DllCall("lua54.dll\lua_dump", "ptr", L, "ptr", writer, "ptr", data, "int", Integer(strip))

; Controls the garbage collector.
; This function performs several tasks, according to the value of the parameter what. For options that need extra arguments, they are listed after the option.
; AHK: Pass the argument's type and value as args*:
; "str", "some thing", "int", 123, "float", 1.23
lua_gc(L, what, args*) => DllCall("lua54.dll\lua_gc", "ptr", L, "int", Integer(what), args*)

; Returns the memory-allocation function of a given state. If ud is not NULL, Lua stores in *ud the opaque pointer given when the memory-allocator function was set.
lua_getallocf(L, ud) => DllCall("lua54.dll\lua_getallocf", "ptr", L, "ptr", ud)

; Returns the current hook function.
lua_gethook(L) => DllCall("lua54.dll\lua_gethook", "ptr", L)

; Returns the current hook count.
lua_gethookcount(L) => DllCall("lua54.dll\lua_gethookcount", "ptr", L)

; Returns the current hook mask.
lua_gethookmask(L) => DllCall("lua54.dll\lua_gethook", "ptr", L)

; Pushes onto the stack the value t[i], where t is the value at the given index.
; As in Lua, this function may trigger a metamethod for the "index" event.
lua_geti(L, index, i) => DllCall("lua54.dll\lua_geti", "ptr", L, "int", Integer(index), "int", Integer(i))

; Gets information about a specific function or function invocation.
lua_getinfo(L, what, ar) => DllCall("lua54.dll\lua_getinfo", "ptr", L, "str", String(what), "ptr", ar)

; Gets information about a local variable or a temporary value of a given activation record or a given function.
; In the first case, the parameter ar must be a valid activation record that was filled by a previous call to lua_getstack or given as argument to a hook (see lua_Hook). The index n selects which local variable to inspect; see debug.getlocal for details about variable indices and names.
; lua_getlocal pushes the variable's value onto the stack and returns its name.
; In the second case, ar must be NULL and the function to be inspected must be on the top of the stack. In this case, only parameters of Lua functions are visible (as there is no information about what variables are active) and no values are pushed onto the stack.
; Returns NULL (and pushes nothing) when the index is greater than the number of active local variables.
lua_getlocal(L, ar, n) => DllCall("lua54.dll\lua_getlocal", "ptr", L, "ptr", ar, "int", Integer(n))

; Gets information about the interpreter runtime stack.
; This function fills parts of a lua_Debug structure with an identification of the activation record of the function executing at a given level. Level 0 is the current running function, whereas level n+1 is the function that has called level n (except for tail calls, which do not count in the stack).
; When called with a level greater than the stack depth, lua_getstack returns 0; otherwise it returns 1.
lua_getstack(L, level, ar) => DllCall("lua54.dll\lua_getstack", "ptr", L, "int", Integer(level), "ptr", ar)

; Returns 1 if the given coroutine can yield, and 0 otherwise.
lua_isyieldable(L) => DllCall("lua54.dll\lua_isyieldable", "ptr", L)

; Loads a Lua chunk without running it. If there are no errors, lua_load pushes the compiled chunk as a Lua function on top of the stack. Otherwise, it pushes an error message.
; The lua_load function uses a user-supplied reader function to read the chunk (see lua_Reader). The data argument is an opaque value passed to the reader function.
; The chunkname argument gives a name to the chunk, which is used for error messages and in debug information.
; lua_load automatically detects whether the chunk is text or binary and loads it accordingly (see program luac). The string mode works as in function load, with the addition that a NULL value is equivalent to the string "bt".
; lua_load uses the stack internally, so the reader function must always leave the stack unmodified when returning.
; lua_load can return LUA_OK, LUA_ERRSYNTAX, or LUA_ERRMEM. The function may also return other values corresponding to errors raised by the read function.
; If the resulting function has upvalues, its first upvalue is set to the value of the global environment stored at index LUA_RIDX_GLOBALS in the registry. Other upvalues are initialized with nil.
lua_load(L, reader, data, chunkname, mode) => DllCall("lua54.dll\lua_load", "ptr", L, "ptr", reader, "ptr", data, "astr", String(chunkname), "astr", String(mode), "int")

; Creates a new independent state and returns its main thread.
; Returns NULL if it cannot create the state (due to lack of memory).
; The argument f is the allocator function; Lua will do all memory allocation for this state through this function (see lua_Alloc). The second argument, ud, is an opaque pointer that Lua passes to the allocator in every call.
lua_newstate(f, ud) => DllCall("lua54.dll\lua_newstate", "ptr", f, "ptr", ud, "ptr")

; Creates a new thread, pushes it on the stack, and returns a pointer to a lua_State that represents this new thread. The new thread returned by this function shares with the original thread its global environment, but has an independent execution stack.
; Threads are subject to garbage collection, like any Lua object.
lua_newthread(L) => DllCall("lua54.dll\lua_newthread", "ptr", L, "ptr")

; Pushes onto the stack a formatted string and returns a pointer to this string (see §4.1.3).
; It is similar to the ISO C function sprintf, but has two important differences.
; First, you do not have to allocate space for the result; the result is a Lua string and Lua takes care of memory allocation (and deallocation, through garbage collection).
; Second, the conversion specifiers are quite restricted. There are no flags, widths, or precisions.
; The conversion specifiers can only be '%%' (inserts the character '%'), '%s' (inserts a zero-terminated string, with no size restrictions), '%f' (inserts a lua_Number), '%I' (inserts a lua_Integer), '%p' (inserts a pointer), '%d' (inserts an int), '%c' (inserts an int as a one-byte character), and '%U' (inserts a long int as a UTF-8 byte sequence).
; This function may raise errors due to memory overflow or an invalid conversion specifier.
lua_pushfstring(L, fmt, args*) => DllCall("lua54.dll\lua_pushfstring", "ptr", L, "astr", String(fmt), args*)

; Pushes the string pointed to by s with size len onto the stack. Lua will make or reuse an internal copy of the given string, so the memory at s can be freed or reused immediately after the function returns. The string can contain any binary data, including embedded zeros.
; Returns a pointer to the internal copy of the string
lua_pushlstring(L, s, len) => DllCall("lua54.dll\lua_pushlstring", "ptr", L, "astr", String(s), "int", Integer(len))

; Pushes the thread represented by L onto the stack. Returns 1 if this thread is the main thread of its state.
lua_pushthread(L) => DllCall("lua54.dll\lua_pushthread", "ptr", L, "int")

; Equivalent to lua_pushfstring, except that it receives a va_list instead of a variable number of arguments.
lua_pushvfstring(L, fmt, argp) => DllCall("lua54.dll\lua_pushvfstring", "ptr", L, "astr", String(fmt), "ptr", argp, "ptr")

; Returns 1 if the two values in indices index1 and index2 are primitively equal (that is, equal without calling the __eq metamethod). Otherwise returns 0. Also returns 0 if any of the indices are not valid.
lua_rawequal(L, index1, index2) => DllCall("lua54.dll\lua_rawequal", "ptr", L, "int", Integer(index1), "int", Integer(index2))

; Pushes onto the stack the value t[k], where t is the table at the given index and k is the pointer p represented as a light userdata. The access is raw; that is, it does not use the __index metavalue.
; Returns the type of the pushed value.
lua_rawgetp(L, index, p) => DllCall("lua54.dll\lua_rawgetp", "ptr", L, "int", Integer(index), "ptr", p, "int")

; Does the equivalent of t[p] = v, where t is the table at the given index, p is encoded as a light userdata, and v is the value on the top of the stack.
; This function pops the value from the stack. The assignment is raw, that is, it does not use the __newindex metavalue.
lua_rawsetp(L, index, p) => DllCall("lua54.dll\lua_rawsetp", "ptr", L, "int", Integer(index), "ptr", p, "int")

; This function is deprecated; it is equivalent to lua_closethread with from being NULL.
lua_resetthread(L) => DllCall("lua54.dll\lua_resetthread", "ptr", L, "ptr", 0)

; Starts and resumes a coroutine in the given thread L.
; To start a coroutine, you push the main function plus any arguments onto the empty stack of the thread. then you call lua_resume, with nargs being the number of arguments. This call returns when the coroutine suspends or finishes its execution. When it returns, *nresults is updated and the top of the stack contains the *nresults values passed to lua_yield or returned by the body function. lua_resume returns LUA_YIELD if the coroutine yields, LUA_OK if the coroutine finishes its execution without errors, or an error code in case of errors (see §4.4.1). In case of errors, the error object is on the top of the stack.
; To resume a coroutine, you remove the *nresults yielded values from its stack, push the values to be passed as results from yield, and then call lua_resume.
; The parameter from represents the coroutine that is resuming L. If there is no such coroutine, this parameter can be NULL.
lua_resume(L, from, nargs, nresults) => DllCall("lua54.dll\lua_resume", "ptr", L, "ptr", from, "int", Integer(nargs), "int*", nresults)

; Changes the allocator function of a given state to f with user data ud.
lua_setallocf(L, f, ud) => DllCall("lua54.dll\lua_setallocf", "ptr", L, "ptr", f, "ptr", ud)

; Sets the debugging hook function.
; Argument f is the hook function. mask specifies on which events the hook will be called: it is formed by a bitwise OR of the constants LUA_MASKCALL, LUA_MASKRET, LUA_MASKLINE, and LUA_MASKCOUNT. The count argument is only meaningful when the mask includes LUA_MASKCOUNT. For each event, the hook is called as explained below:
; - The call hook: is called when the interpreter calls a function. The hook is called just after Lua enters the new function.
; - The return hook: is called when the interpreter returns from a function. The hook is called just before Lua leaves the function.
; - The line hook: is called when the interpreter is about to start the execution of a new line of code, or when it jumps back in the code (even to the same line). This event only happens while Lua is executing a Lua function.
; - The count hook: is called after the interpreter executes every count instructions. This event only happens while Lua is executing a Lua function.
; Hooks are disabled by setting mask to zero.
lua_sethook(L, f, mask, count) => DllCall("lua54.dll\lua_sethook", "ptr", L, "ptr", f, "int", Integer(mask), "int", Integer(count))

; Does the equivalent to t[n] = v, where t is the value at the given index and v is the value on the top of the stack.
; This function pops the value from the stack. As in Lua, this function may trigger a metamethod for the "newindex" event
lua_seti(L, index, n) => DllCall("lua54.dll\lua_seti", "ptr", L, "int", Integer(index), "int", Integer(n))

; Sets the warning function to be used by Lua to emit warnings (see lua_WarnFunction). The ud parameter sets the value ud passed to the warning function.
lua_setwarnf(L, f, ud) => DllCall("lua54.dll\lua_setwarnf", "ptr", L, "ptr", f, "ptr", ud)

; Returns the status of the thread L.
; The status can be LUA_OK for a normal thread, an error code if the thread finished the execution of a lua_resume with an error, or LUA_YIELD if the thread is suspended.
; You can call functions only in threads with status LUA_OK. You can resume threads with status LUA_OK (to start a new coroutine) or LUA_YIELD (to resume a coroutine).
lua_status(L) => DllCall("lua54.dll\lua_status", "ptr", L)

; Converts the zero-terminated string s to a number, pushes that number into the stack, and returns the total size of the string, that is, its length plus one.
; The conversion can result in an integer or a float, according to the lexical conventions of Lua (see §3.1).
; The string may have leading and trailing whitespaces and a sign.
; If the string is not a valid numeral, returns 0 and pushes nothing.
; (Note that the result can be used as a boolean, true if the conversion succeeds.)
lua_stringtonumber(L, s) => DllCall("lua54.dll\lua_stringtonumber", "ptr", L, "str", s)

; Marks the given index in the stack as a to-be-closed slot (see §3.3.8). Like a to-be-closed variable in Lua, the value at that slot in the stack will be closed when it goes out of scope. Here, in the context of a C function, to go out of scope means that the running function returns to Lua, or there is an error, or the slot is removed from the stack through lua_settop or lua_pop, or there is a call to lua_closeslot. A slot marked as to-be-closed should not be removed from the stack by any other function in the API except lua_settop or lua_pop, unless previously deactivated by lua_closeslot.
; This function raises an error if the value at the given slot neither has a __close metamethod nor is a false value.
; This function should not be called for an index that is equal to or below an active to-be-closed slot.
; Note that, both in case of errors and of a regular return, by the time the __close metamethod runs, the C stack was already unwound, so that any automatic C variable declared in the calling function (e.g., a buffer) will be out of scope.
lua_toclose(L, index) => DllCall("lua54.dll\lua_toclose", "ptr", L, "int", Integer(index))

; Returns a unique identifier for the upvalue numbered n from the closure at index funcindex.
; These unique identifiers allow a program to check whether different closures share upvalues. Lua closures that share an upvalue (that is, that access a same external local variable) will return identical ids for those upvalue indices.
; Parameters funcindex and n are as in the function lua_getupvalue, but n cannot be greater than the number of upvalues.
lua_upvalueid(L, funcindex, n) => DllCall("lua54.dll\lua_upvalueid", "ptr", L, "int", Integer(funcindex), "int", Integer(n))

; Make the n1-th upvalue of the Lua closure at index funcindex1 refer to the n2-th upvalue of the Lua closure at index funcindex2.
lua_upvaluejoin(L, funcindex1, n1, funcindex2, n2) => DllCall("lua54.dll\lua_upvaluejoin", "ptr", L, "int", Integer(funcindex1), "int", Integer(n1), "int", Integer(funcindex2), "int", Integer(n2))

; Returns the version number of this core.
lua_version(L) => DllCall("lua54.dll\lua_version", "ptr", L)

; Emits a warning with the given message. A message in a call with tocont true should be continued in another call to this function.
lua_warning(L, msg, tocont) => DllCall("lua54.dll\lua_warning", "ptr", L, "str", msg, "int", Integer(tocont))

; Exchange values between different threads of the same state.
; This function pops n values from the stack from, and pushes them onto the stack to.
lua_xmove(from, to, n) => DllCall("lua54.dll\lua_xmove", "ptr", from, "ptr", to, "int", Integer(n))

; Yields a coroutine (thread).
; When a C function calls lua_yieldk, the running coroutine suspends its execution, and the call to lua_resume that started this coroutine returns. The parameter nresults is the number of values from the stack that will be passed as results to lua_resume.
; When the coroutine is resumed again, Lua calls the given continuation function k to continue the execution of the C function that yielded (see §4.5). This continuation function receives the same stack from the previous function, with the n results removed and replaced by the arguments passed to lua_resume. Moreover, the continuation function receives the value ctx that was passed to lua_yieldk.
; Usually, this function does not return; when the coroutine eventually resumes, it continues executing the continuation function. However, there is one special case, which is when this function is called from inside a line or a count hook (see §4.7). In that case, lua_yieldk should be called with no continuation (probably in the form of lua_yield) and no results, and the hook should return immediately after the call. Lua will yield and, when the coroutine resumes again, it will continue the normal execution of the (Lua) function that triggered the hook.
; This function can raise an error if it is called from a thread with a pending C call with no continuation function (what is called a C-call boundary), or it is called from a thread that is not running inside a resume (typically the main thread).
lua_yieldk(L, nresults, ctx, k) => DllCall("lua54.dll\lua_yieldk", "ptr", L, "int", Integer(nresults), "int", Integer(ctx), "ptr", k == null ? 0 : k, "int")

; Adds a copy of the string s to the buffer B (see luaL_Buffer), replacing any occurrence of the string p with the string r.
luaL_addgsub(B, s, p, r) => DllCall("lua54.dll\luaL_addgsub", "ptr", B, "str", s, "str", p, "str", r)

; Adds the string pointed to by s with length l to the buffer B (see luaL_Buffer). The string can contain embedded zeros.
luaL_addlstring(B, s, l) => DllCall("lua54.dll\luaL_addlstring", "ptr", B, "str", s, "int", Integer(l))

; Adds the zero-terminated string pointed to by s to the buffer B (see luaL_Buffer).
luaL_addstring(B, s) => DllCall("lua54.dll\luaL_addstring", "ptr", B, "str", s)

; Adds the value on the top of the stack to the buffer B (see luaL_Buffer). Pops the value.
; This is the only function on string buffers that can (and must) be called with an extra element on the stack, which is the value to be added to the buffer.
luaL_addvalue(B) => DllCall("lua54.dll\luaL_addvalue", "ptr", B)

; Initializes a buffer B (see luaL_Buffer). This function does not allocate any space; the buffer must be declared as a variable.
luaL_buffinit(L, B) => DllCall("lua54.dll\luaL_buffinit", "ptr", L, "ptr", B)

; Equivalent to the sequence luaL_buffinit, luaL_prepbuffsize.
luaL_buffinitsize(L, B, sz) => DllCall("lua54.dll\luaL_buffinitsize", "ptr", L, "ptr", B, "int", Integer(sz))

; Calls a metamethod.
; If the object at index obj has a metatable and this metatable has a field e, this function calls this field passing the object as its only argument. In this case this function returns true and pushes onto the stack the value returned by the call. If there is no metatable or no metamethod, this function returns false without pushing any value on the stack.
luaL_callmeta(L, obj, e) => DllCall("lua54.dll\luaL_callmeta", "ptr", L, "int", Integer(obj), "str", String(e), "int")

; Checks whether the function argument arg is a string and searches for this string in the array lst (which must be NULL-terminated). Returns the index in the array where the string was found. Raises an error if the argument is not a string or if the string cannot be found.
; If def is not NULL, the function uses def as a default value when there is no argument arg or when this argument is nil.
; This is a useful function for mapping strings to C enums. (The usual convention in Lua libraries is to use strings instead of numbers to select options.)
luaL_checkoption(L, arg, def, lst) => DllCall("lua54.dll\luaL_checkoption", "ptr", L, "int", Integer(arg), "str", String(def), "ptr", lst, "int")

; This function produces the return values for process-related functions in the standard library (os.execute and io.close).
luaL_execresult(L, stat) => DllCall("lua54.dll\luaL_execresult", "ptr", L, "int", Integer(stat), "int")

; This function produces the return values for file-related functions in the standard library (io.open, os.rename, file:seek, etc.).
luaL_fileresult(L, stat, fname) => DllCall("lua54.dll\luaL_fileresult", "ptr", L, "int", Integer(stat), "str", String(fname), "int")

; Pushes onto the stack the field e from the metatable of the object at index obj and returns the type of the pushed value. If the object does not have a metatable, or if the metatable does not have this field, pushes nothing and returns LUA_TNIL.
luaL_getmetafield(L, obj, e) => DllCall("lua54.dll\luaL_getmetafield", "ptr", L, "int", Integer(obj), "str", String(e), "int")

; Ensures that the value t[fname], where t is the value at index idx, is a table, and pushes that table onto the stack. Returns true if it finds a previous table there and false if it creates a new table.
luaL_getsubtable(L, idx, fname) => DllCall("lua54.dll\luaL_getsubtable", "ptr", L, "int", Integer(idx), "str", String(fname), "int")

; Creates a copy of string s, replacing any occurrence of the string p with the string r. Pushes the resulting string on the stack and returns it.
luaL_gsub(L, s, p, r) => DllCall("lua54.dll\luaL_gsub", "ptr", L, "str", String(s), "str", String(p), "str", String(r))

; Returns the "length" of the value at the given index as a number; it is equivalent to the '#' operator in Lua (see §3.4.7). Raises an error if the result of the operation is not an integer. (This case can only happen through metamethods.)
luaL_len(L, index) => DllCall("lua54.dll\luaL_len", "ptr", L, "int", Integer(index), "int")

; Loads a buffer as a Lua chunk. This function uses lua_load to load the chunk in the buffer pointed to by buff with size sz.
; This function returns the same results as lua_load. name is the chunk name, used for debug information and error messages. The string mode works as in the function lua_load.
luaL_loadbufferx(L, buff, sz, name, mode) => DllCall("lua54.dll\luaL_loadbufferx", "ptr", L, "ptr", buff, "int", Integer(sz), "astr", String(name), "astr", String(mode), "int")

; Returns an address to a space of size sz where you can copy a string to be added to buffer B (see luaL_Buffer). After copying the string into this space you must call luaL_addsize with the size of the string to actually add it to the buffer.
luaL_prepbuffsize(B, sz) => DllCall("lua54.dll\luaL_prepbuffsize", "ptr", B, "int", Integer(sz), "ptr")

; Finishes the use of buffer B leaving the final string on the top of the stack.
luaL_pushresult(B) => DllCall("lua54.dll\luaL_pushresult", "ptr", B)

; Equivalent to the sequence luaL_addsize, luaL_pushresult.
luaL_pushresultsize(B, sz) => DllCall("lua54.dll\luaL_pushresultsize", "ptr", B, "int", Integer(sz))

; This function works like luaL_checkudata, except that, when the test fails, it returns NULL instead of raising an error.
luaL_testudata(L, arg, tname) => DllCall("lua54.dll\luaL_testudata", "ptr", L, "int", Integer(arg), "str", String(tname), "ptr")

; Converts any Lua value at the given index to a C string in a reasonable format. The resulting string is pushed onto the stack and also returned by the function (see §4.1.3). If len is not NULL, the function also sets *len with the string length.
; If the value has a metatable with a __tostring field, then luaL_tolstring calls the corresponding metamethod with the value as argument, and uses the result of the call as its result.
luaL_tolstring(L, idx, len) => DllCall("lua54.dll\luaL_tolstring", "ptr", L, "int", Integer(idx), "int*", len ? len : 0, "ptr")

; Creates and pushes a traceback of the stack L1. If msg is not NULL, it is appended at the beginning of the traceback. The level parameter tells at which level to start the traceback.
luaL_traceback(L, L1, msg, level) => DllCall("lua54.dll\luaL_traceback", "ptr", L, "ptr", L1, "str", String(msg), "int", Integer(level))

; Raises a type error for the argument arg of the C function that called it, using a standard message; tname is a "name" for the expected type. This function never returns.
luaL_typeerror(L, arg, tname) => DllCall("lua54.dll\luaL_typeerror", "ptr", L, "int", Integer(arg), "str", String(tname), "int")

; Pushes onto the stack a string identifying the current position of the control at level lvl in the call stack. Typically this string has the following format:
;      chunkname:currentline:
; Level 0 is the running function, level 1 is the function that called the running function, etc.
; This function is used to build a prefix for error messages.
luaL_where(L, lvl) => DllCall("lua54.dll\luaL_where", "ptr", L, "int", Integer(lvl), "ptr")


; =============================================================================
; # Multi-line Functions
; These are functions that need multiple lines to define.
; The reasononing is usually because translating between C and AHK is not as simple as just calling a function.

; Registers all functions in the array l (see luaL_Reg) into the table on the top of the stack (below optional upvalues, see next).
; When nup is not zero, all functions are created with nup upvalues, initialized with copies of the nup values previously pushed on the stack on top of the library table. These values are popped from the stack after the registration.
; A function with a NULL value represents a placeholder, which is filled with false.
luaL_setfuncs(L, ls, nup) {
  luaL_checkstack(L, nup, "too many upvalues")

  ; Because we want to pass an AHK array to Lua but can't, we need to do the job ourselves by looping through the array manually.
  loop ls.length {
    obj := ls[A_Index]

    ; If it's a function we create a callback reference to it.
    if obj[2] is Func || obj[2] is BoundFunc || obj[2] is Closure {
      obj[2] := CallbackCreate(obj[2],, 1)
    }

    ; Otherwise it'll be a callback already and we don't need to do anything else.
    ; Probably should do a full check to see if it is a callback, but I don't care enough.
    else if obj[2] is Integer {
      ; ...
    }

    ; Array is at its end, break the loop.
    ; Ahk will break if it's at the end of the array anyway, but this is to make it easier for porting from C to AHK.
    else if obj[1] == null && obj[2] == null {
      break
    }

    lua_pushcfunction(L, obj[2])
    lua_setfield(L, -2, obj[1])
  }
  lua_pop(L, nup)
}

; NOTE:
; lua_tolstring returns 0 (or NULL) if it couldn't return it as a string.
; To make it easier for AHK to handle (and to not get an error thrown in StrGet())
; I've forced it to return a blank string if it could not get a string.
lua_tolstring(L, index, len) {
  result := DllCall("lua54.dll\lua_tolstring", "ptr", L, "int", Integer(index), len == null ? "int" : "int*", len == null ? 0 : Integer(len))
  ; We must check if the value returned was NULL, otherwise StrGet will silent crash AHK.
  return result == 0 ? "" : StrGet(result, "UTF-8")
}

; See lua_tolstring for more information.
luaL_checklstring(L, arg, len) {
  result := DllCall("lua54.dll\luaL_checklstring", "ptr", L, "int", Integer(arg), "int", len == null ? 0 : Integer(len))
  ; We must check if the value returned was NULL, otherwise StrGet will silent crash AHK.
  return result == 0 ? "" : StrGet(result, "UTF-8")
}

; See lua_tolstring for more information.
lua_typename(L, tp) {
  result := DllCall("lua54.dll\lua_typename", "ptr", L, "int", Integer(tp))
  ; We must check if the value returned was NULL, otherwise StrGet will silent crash AHK.
  return result == 0 ? "" : StrGet(result, "UTF-8")
}

; Raises an error. The error message format is given by fmt plus any extra arguments, following the same rules of lua_pushfstring. It also adds at the beginning of the message the file name and the line number where the error occurred, if this information is available.
luaL_error(L, fmt, args*) {
  str := Format(fmt, args*)
  lua_pushstring(L, str)
  lua_error(L)
  return 0
}

; Outputs the Lua stack as a string.
stack_dump(L, header?, indent?) {
  static call_count := 0

  str := header ?? "-- STACK [" . (call_count++) . "] --"

  loop {
    top := lua_gettop(L)
    if top == 0
      return str

    if IsSet(indent)
      str .= indent

    loop top {
      kind := lua_type(L, A_Index)
      str .= A_Index . ": "
      switch kind {
        case LUA_TSTRING:
          str .= Format("'{s}'", lua_tostring(L, A_Index))
        case LUA_TBOOLEAN:
          str .= lua_toboolean(L, A_Index) ? "true" : "false"
        case LUA_TNUMBER:
          str .= Format("{g}", lua_tonumber(L, A_Index))
        case LUA_TLIGHTUSERDATA:
          str .= Format("{p}", lua_topointer(L, A_Index))
        default:
          str .= Format("{s}", lua_typename(L, kind))
      }
      str .= " "
    }
    str .= "`n"
  }
  return str
}

; Converts the Lua value at the given index to the C type lua_Number (see lua_Number). The Lua value must be a number or a string convertible to a number; otherwise, lua_tonumberx returns 0.
; If isnum is not NULL, its referent is assigned a boolean value that indicates whether the operation succeeded.
lua_tonumberx(L, index, &isnum?) {
  if !IsSet(isnum) {
    kind := "int"
    val := 0
  }
  else {
    kind := "int*"
    val := &isnum
  }
  DllCall("lua54.dll\lua_tonumberx", "ptr", L, "int", Integer(index), kind, val, "double")
}



; =============================================================================
; # Macro Functions
; These functions are not defined publicly for use in the Lua DLL.
; However, they are macros in Lua's source code, available to read/use for yourself.
; Seeing as Lua has provided these for us, we can create them here.
; It's pretty darn easy to translate into AHK because they use #define,
; to which we don't have to worry about types too heavily.

; Checks whether cond is true. If it is not, raises an error with a standard message (see luaL_argerror).
luaL_argcheck(L, cond, arg, extramsg) => (cond || luaL_argerror(L, arg, extramsg))

; Checks whether the function has an argument of any type (including nil) at position arg.
luaL_checkany(L, n) => luaL_checktype(L, n, LUA_TNONE)

; Checks whether the function argument arg is an integer (or can be converted to an integer) and returns this integer.
luaL_checkinteger(L, n) => luaL_checktype(L, n, LUA_TNUMBER)

; Checks whether the function argument arg is a number and returns this number converted to a lua_Number.
luaL_checknumber(L, n) => luaL_checktype(L, n, LUA_TNUMBER)

; Checks whether the function argument arg is a string and returns this string.
; This function uses lua_tolstring to get its result, so all conversions and caveats of that function apply here.
luaL_checkstring(L, n) => luaL_checklstring(L, n, null)

; Loads and runs the given file.
luaL_dofile(L, filename) => (luaL_loadfile(L, filename), lua_pcall(L, 0, LUA_MULTRET, 0))

; Loads and runs the given string.
luaL_dostring(L, str) => (luaL_loadstring(L, str), lua_pcall(L, 0, LUA_MULTRET, 0))

; Pushes onto the stack the metatable associated with the name tname in the registry (see luaL_newmetatable), or nil if there is no metatable associated with that name. Returns the type of the pushed value.
luaL_getmetatable(L, n) => lua_getfield(L, LUA_REGISTRYINDEX, n)

; Equivalent to luaL_loadfilex with mode equal to NULL.
luaL_loadfile(L, filename) => luaL_loadfilex(L, filename, null)

; Creates a new table and registers there the functions in the list l.
luaL_newlib(L, ls) => (lua_newtable(L), luaL_setfuncs(L, ls, 0))

; if the argument arg is nil or absent, the macro results in the default dflt. Otherwise, it results in the result of calling func with the state L and the argument index arg as arguments.
luaL_opt(L, f, n, d) => (lua_isnoneornil(L, n) ? d : f(L, n))

; Checks whether the function argument arg is a boolean and returns it as a boolean.
luaL_optboolean(L, n, d) => luaL_opt(L, lua_toboolean, n, d)

; Checks whether the function argument arg is an integer (or can be converted to an integer) and returns it as an integer.
luaL_optinteger(L, n, d) => luaL_opt(L, lua_tointeger, n, d)

; Checks whether the function argument arg is a number and returns it as a number.
luaL_optnumber(L, n, d) => luaL_opt(L, lua_tonumber, n, d)

; Checks whether the function argument arg is a string and returns it as a string.
luaL_optlstring(L, n, d) => luaL_opt(L, lua_tostring, n, d)

; Checks whether the function argument arg is a string and returns it as a string.
luaL_optstring(L, n, d) => luaL_opt(L, lua_tostring, n, d)

; Calls a function. Like regular Lua calls, lua_call respects the __call metamethod. So, here the word "function" means any callable value.
lua_call(L, n, r) => lua_callk(L, n, r, 0, null)

; Moves the top element into the given valid index, shifting up the elements above this index to open space. This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position.
lua_insert(L, idx) => lua_rotate(L, idx, 1)

; Returns 1 if the value at the given index is a boolean, and 0 otherwise.
lua_isboolean(L, n) => (lua_type(L, n) == LUA_TBOOLEAN)

; Returns 1 if the value at the given index is a function (C or Lua), and 0 otherwise.
lua_isfunction(L, n) => (lua_type(L, n) == LUA_TFUNCTION)

; Returns 1 if the value at the given index is a light userdata, and 0 otherwise.
lua_islightuserdata(L, n) => (lua_type(L, n) == LUA_TLIGHTUSERDATA)

; Returns 1 if the value at the given index is nil, and 0 otherwise.
lua_isnil(L, n) => (lua_type(L, n) == LUA_TNIL)

; Returns 1 if the value at the given index is not valid, and 0 otherwise.
lua_isnone(L, n) => (lua_type(L, n) == LUA_TNONE)

; Returns 1 if the value at the given index is not valid or if the value is nil, and 0 otherwise.
lua_isnoneornil(L,  n) => (lua_type(L, n) <= 0)

; Returns 1 if the value at the given index is a number or a string convertible to a number, and 0 otherwise.
lua_isnumber(L, n) => (lua_type(L, n) == LUA_TNUMBER)

; Returns 1 if the value at the given index is a string or a number (which is always convertible to a string), and 0 otherwise.
lua_isstring(L, n) => (lua_type(L, n) == LUA_TSTRING)

; Returns 1 if the value at the given index is a table, and 0 otherwise.
lua_istable(L, n) => (lua_type(L, n) == LUA_TTABLE)

; Returns 1 if the value at the given index is a thread, and 0 otherwise.
lua_isthread(L, n) => (lua_type(L, n) == LUA_TTHREAD)

; Returns 1 if the value at the given index is a userdata (either full or light), and 0 otherwise.
lua_isuserdata(L, n) => (lua_type(L, n) == LUA_TUSERDATA)

; Creates a new empty table and pushes it onto the stack.
lua_newtable(L) => lua_createtable(L, 0, 0)

; This function creates and pushes on the stack a new full userdata, with nuvalue associated Lua values, called user values, plus an associated block of raw memory with size bytes.
; This is a macro for the standard library function luaL_newuserdatauv, however with the nuvalue parameter set to 1.
lua_newuserdata(L, s) => lua_newuserdatauv(L, s, 1)

; Pushes onto the stack the n-th user value associated with the full userdata at the given index and returns the type of the pushed value.
; If the userdata does not have that value, pushes nil and returns LUA_TNONE.
lua_getuservalue(L, idx) => lua_getiuservalue(L, idx, 1)

; Calls a function (or a callable object) in protected mode.
lua_pcall(L, nargs, nresults, msgh) => lua_pcallk(L, nargs, nresults, msgh, 0, null)

; Pops n elements from the stack.
lua_pop(L, n) => lua_settop(L, 0 - n - 1)

; Pushes an AHK function onto the stack.
; Use CallbackCreate() to pass a function to this macro.
lua_pushcfunction(L, f) => lua_pushcclosure(L, f, 0)

; Pushes an AHK function onto the stack.
; This automatically uses CallbackCreate() for you.
lua_pushahkfunction(L, f) => lua_pushcclosure(L, CallbackCreate(f,, 1), 0)

; Pushes the global environment onto the stack.
lua_pushglobaltable(L) => lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS)

; Sets the AHK function f as the new value of global name.
lua_register(L, n, f) => (lua_pushcfunction(L, f), lua_setglobal(L, n))

; Removes the element at the given valid index, shifting down the elements above this index to fill the gap.
lua_remove(L, idx) => (lua_rotate(L, idx, -1), lua_pop(L, 1))

; Moves the top element into the given valid index without shifting any element (therefore replacing the value at that given index), and then pops the top element.
lua_replace(L, idx) => (lua_copy(L, -1, idx), lua_pop(L, 1))

; Pops a value from the stack and sets it as the new n-th user value associated to the full userdata at the given index. Returns 0 if the userdata does not have that value.
; This is a macro for the standard library function lua_setiuservalue, however with the n parameter set to 1.
lua_setuservalue(L, idx) => lua_setiuservalue(L, idx, 1)

lua_tonumber(L, index) => lua_tonumberx(L, index)

; This macro is equivalent to lua_pushstring.
lua_pushliteral := lua_pushstring

; Converts the Lua value at the given index to an AHK string.
lua_tostring(L, idx) => lua_tolstring(L, idx, null)

; Returns the pseudo-index that represents the i-th upvalue of the running function. i must be in the range [1,256].
lua_upvalueindex(i) => (LUA_REGISTRYINDEX - (i))

; this doesn't exist in Lua, but when translating from C to AHK, it's useful to have a null value of some kind.
; in ahk, it's just an empty string.
; Converts the Lua value at the given index to a nil value.
lua_tonil(L, idx) => null

; Similar to lua_pushfstring however the format is done natively in AHK.
lua_pushstringf(L, frmt, args*) => lua_pushstring(L, Format(frmt, args*))

; The macro exists, so why not add it?
; This gets the type name of the value at the given index.
luaL_typename(L, index) => lua_typename(L, lua_type(L, index))
