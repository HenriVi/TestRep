'WINDOWS PROCESS API

Strict

Const INFINITE:Int = $FFFFFFFF

Extern "Win32"
	Function CloseHandle:Int(handle:Byte Ptr)
	Function WaitForSingleObject(hHandle:Byte Ptr, dwMilliseconds:Int)
	Function WaitForInputIdle(hHandle:Byte Ptr, dwMilliseconds:Int)
	Function GetProcessId:Int(handle:Byte Ptr)
	Function GetThreadId:Int(handle:Byte Ptr)
	Function GetWindowThreadProcessId(hwnd:Byte Ptr, pid:Byte Ptr)
	Function GetTopWindow:Byte Ptr(handle:Byte Ptr = Null)
	Function GetWindow:Byte Ptr(hwnd:Byte Ptr, direction:Int = 2) ' 2 = next, 3 = previous
	Function GetWindowText(hwnd:Byte Ptr, lpString:Short Ptr, MaxCount:Int = 255) = "GetWindowTextW@12"
	Function IsWindowVisible:Int(hwnd:Byte Ptr)
	Function OpenProcess:Byte Ptr(dwDesiredAccess:Int, bInheritHandle:Int, pid:Int)
	Function CreateProcess( lpApplicationName:Short Ptr,..
							lpCommandLine:Short Ptr,..
							lpProcessAttributes:Byte Ptr,..
							lpThreadAttributes:Byte Ptr,..
							bInheritHandles:Int,..
							dwCreationFlags:Int,..
							lpEnvironment:Byte Ptr,..
							lpCurrentDirectory:Byte Ptr,..
							lpStartupInfo:Byte Ptr,..
							lpProcessInformation:Byte Ptr ) = "CreateProcessW@40"
	
End Extern


'EXAMPLE
Local proc:TWinProcess = TWinProcess.Create("notepad.exe")
If proc

	DebugLog proc.GetProcId() + " | " + proc.GetThreadId()

	Local list:TList = proc.GetWinProcs()
	
	For Local pw:TProcessWindow = EachIn list
		
		If pw.visible Then DebugLog pw.title + " | " + pw.threadId
	Next
	
	proc.Close()
EndIf

End



Type TWinProcess

	Global _sysProcs:TList = New TList 
	
	Field _pi:PROCESS_INFORMATION = New PROCESS_INFORMATION
	Field _si:STARTUPINFO = New STARTUPINFO

	Function Create:TWinProcess(cmd:String, waitForIdle:Int = True)
		
		If Not cmd Then Return Null
		Local proc:TWinProcess = New TWinProcess
			'proc._si.cb = SizeOf(STARTUPINFO)
			Local s:String = "Hello World"
			proc._si.title = s.ToWString()
			
		Local sp:Short Ptr = cmd.ToWString()

		If CreateProcess(Null,..
						sp,..
						Null,..
						Null,..
						False,..
						0,..
						Null,..
						Null,..
						proc._si, proc._pi)
			
			'DebugLog Hex(p.dwProcessId) + " : " + Hex(p.dwThreadId)
			
			Local start:Int = MilliSecs()
			'WaitForSingleObject(p.hProcess, INFINITE)
			If waitForIdle Then WaitForInputIdle(proc._pi.hProcess, INFINITE)
			
			DebugLog "Closing after " + (MilliSecs()-start) + " millisecs."
			
			MemFree(sp)
			Return proc
		Else
			DebugLog("The process could not be started..."); Return Null
		EndIf

	EndFunction
	
	Method Close()
		
		CloseHandle(_pi.hThread)
		CloseHandle(_pi.hProcess)
		
		_pi = Null
		_si = Null		
	EndMethod
	
	Function EnumWindows:TList()
		
		_sysProcs.Clear()
		
		Local hwnd:Byte Ptr = GetTopWindow()
		If hwnd Then DebugLog "Found top window.."
		
		Local buffer:Short[255]
		Local pid:Int
		Local pHandle:Byte Ptr
		Local pw:TProcessWindow
		
		While hwnd
			
			pw = New TProcessWindow
			
			'If IsWindowVisible(hwnd) Then
			GetWindowThreadProcessId(hwnd, Varptr pw.threadId)
			GetWindowText(hwnd, buffer)
			pw.title = String.FromWString( buffer )
			pw.visible = IsWindowVisible(hwnd)
			
			'DebugLog pw.title + " | " + pw.visible
			
			'pHandle = OpenProcess(PROCESS_QUERY_INFORMATION, 0, pid)
				
			'DebugLog Int(pHandle) + " : " + String.FromCString( buffer ) + " : " + Int(ShExecInfo.hProcess)
			'EndIf	
			'If ShExecInfo.hProcess = pHandle Then DebugLog "MATCH!! = " + pid; Exit
			
			_sysProcs.addlast(pw)
			
			hwnd = GetWindow(hwnd)
		Wend
		
		DebugLog "Closing.."
			
	EndFunction
	
	Method GetProcId:Int()
		Return _pi.processId
	EndMethod
	
	Method GetThreadId:Int()
		Return _pi.threadId
	EndMethod
	
	Function GetWinProcs:TList()
		
		EnumWindows()
		
		Return _sysProcs
	EndFunction
	
	Method GetProcHandle:Byte Ptr()
		Return _pi.hProcess
	EndMethod

EndType

Type TProcessWindow
	Field hwnd:Byte Ptr
	Field title:String
	Field visible:Int
	Field threadId:Int
EndType

Type PROCESS_INFORMATION
	Field hProcess:Byte Ptr
	Field hThread:Byte Ptr
	Field processId:Int
	Field threadId:Int
EndType

Type STARTUPINFO
	Field cb:Int = SizeOf(Self)
	Field reserved:Byte Ptr
	Field lpDesktop:Byte Ptr
	Field title:Short Ptr
	Field x:Int
	Field y:Int
	Field xSize:Int
	Field ySize:Int
	Field xCountChars:Int
	Field yCountChars:Int
	Field fillAttribute:Int
	Field flags:Int
	Field showWindow:Int
	Field cbReserved2:Int
	Field lpReserved2:Byte Ptr
	Field stdInput:Byte Ptr
	Field stdOutput:Byte Ptr
	Field stdError:Byte Ptr
End Type