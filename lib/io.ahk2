#Requires AutoHotkey v2

global IO := StdIO()

printf(frmt, args*)
{
	frmt := StrReplace(frmt, "\n", "`n")
	frmt := StrReplace(frmt, "\r", "`r")
	frmt := StrReplace(frmt, "\t", "`t")

	IO.write(Format(frmt, args*))
	return IO.flush()  ; Flush the write buffer.
}

class StdIO
{
	static stdin := -1
	static stdout := -1
	static stderr := -1

	__new(pid?)
	{
		if (!IsSet(pid) && (WinGetProcessName("A") == "explorer.exe"))
		{
			DllCall("AllocConsole")
		}
		else
		{
			DllCall("AttachConsole", "uint", pid ?? -1, "Cdecl int")
		}

		this.stdin := FileOpen('*', 'r')
		this.stdout := FileOpen('*', 'w')
		this.stderr := FileOpen("**", 'w')
		return this
	}

	write(txt) => this.stdout.Write(txt)
	writeln(txt) => this.stdout.WriteLine(txt)

	input()
	{
		return RTrim(this.stdin.ReadLine(), "`n")
	}

	flush() => this.stdout.Read(0)
}

; Example:
if (A_LineFile == A_ScriptFullPath)
{
	printf("Enter a noun: ")
	subject := IO.input() || "world"
	printf("Hello, {1}\n", subject)
	ExitApp(0)
}
