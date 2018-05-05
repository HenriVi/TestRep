Strict

Const INPUT_MOUSE:Int = 0
Const INPUT_KEYBOARD:Int = 1
Const INPUT_HARDWARE:Int = 2

Const KEYEVENTF_KEYUP:Int = 2
Const KEYEVENTF_UNICODE:Int = 4

Extern "Win32"
	Function SendInput:Int(nInputs:Int, pInputs:Byte Ptr, cbSize:Int)
EndExtern


'EXAMPLE
For Local i:Int = 49 Until 91
	SendChar(i)
Next

End


Function SendChar(char:Int)
	Local in:TInput = New TInput
	in.key = char
	
	'Send key press
	SendInput(1, in, SizeOf(in) )
	
	'Signal key up
	in.dwFlags = KEYEVENTF_KEYUP
	SendInput(1, in, SizeOf(in) )
EndFunction

Type TInput
	Field iType:Int = INPUT_KEYBOARD
	
	'Keyboard structure
	Field key:Short
	Field wScan:Short
	Field dwFlags:Int
	Field time:Int
	Field dwExtraInfo:Int
	Field _extra1:Int
	Field _extra2:Int
EndType