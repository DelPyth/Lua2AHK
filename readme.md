# Lua2AHK
My half-assed attempt at using Lua in AHK.

## Note
To learn about the current functions that are in the Lua DLL, go [here](functions_list.md).

## Info
- **AHK Version**: 2.0.2
- **AHK Bit Size**: 64
- **Lua DLL Version**: 5.4.4

## Installation
Simply take all files within the `include` directory into your personal or global `lib` folder.

## Usage
1. `#include` the Lua library into your project.
2. Run the library as if it was like the C examples.
3. Do your thing!

## To Do List
- [x] Get `lua.dll` to actually work.
	- Expectation: `lua.dll` will be run and able to execute internal functions within the DLL file.
	- Reality: It works great! Just needed to move to AHK v2 with more consistent parameters and it works.
- [x] Execute external Lua script with custom variables and functions taken from AHK itself.
	- Expectation: Variables and Functions can be called and used within the external script.
	- Reality: It works.
- [ ] Add all of Lua54's external DLL functions as AHK code with documentation.
- [ ] Add AHK class wrapper.
