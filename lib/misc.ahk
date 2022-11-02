global null := ""

printf(frmt, args*)
{
	FileAppend, % Format(frmt, args*), *
	return null
}
