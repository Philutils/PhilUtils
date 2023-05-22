Attribute VB_Name = "X64X32"
Option Explicit
'Please Help: I need someone who uses Word X64 and VBA7 to go in debug through the IF VBA7 API calls and looks if working and informs...
'             see the only todo in the code.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'HEADER          Description: IsThisWindowsX64? IsThisProcessX64?  300 lines of Code and Comment, 150 without comments. Working tested made with attention.
'''''''''''''''''''''''''''''
'    -KeyWords?  #X64;#X32;#WindowsArchitecture;#VBA;#VB6
'
'    -What?      Win API Call about Windows architecture and Process for to
'                detect if Win64 and if someProcess running in Win64 or Win32
'
'    -For Who?   For all VBA / VB6 / VB.NET developers who need to detect on runtime if their code is
'                running in a Win32 or Win64 Process
'                (For VB.Net, it needs to be adapted but will be easy, if someone wants to do it, welcome to share.)
'
'    -When?      Right now. Working From Windows 97 to Windows 11 and future versions. Made and tested in May 2023.
'
'    -Where?     Into your code and own VBA project. (Should be easy to translate into VB .NET, if someone does,
'                thank you to publish and inform).
'
'    -What?      Know in runtime if your code is running on a Win64 or Win32 OS and if your process is Win64 or Win32.
'
'    -How?       - By calling the two Public Properties of X64X32 Module: IsThisWindowsX64 and IsThisProcessX64
'                - With love.
'
'    -Use        - For use in VBA: Save this file as "X64X32.bas" (With the header containing Attribute VB_Name = "X64X32";
'                  in your VBA environment, Right clik your project, Import File "X64X32.bas", You're done
'                  use it by calling the two Public Properties IsThisWindowsX64 and IsThisProcessX64.
'                  Test it, in ThisDocument Module in VBA copy this code:
'                  'Option Explicit
'                  '
'                  'Private Sub Document_Open()
'                  '    Dim Doc As Document
'                  '    Set Doc = ActiveDocument
'                  '    Doc.Paragraphs.Add
'                  '    Doc.Paragraphs.Last.Range.Text = IIf(X64X32, "Windows 64 bit", "Windows 32 bit") & ",  " & _
'                  '                                     IIf(IsThisProcessX64, "Process 64 bit", "Process 32 bit")
'                  'End Sub
'
'    -Remarks    - I made this Module for My Class KnownFolders that has to answer some differently for ProgramFiles
'                  depending on the System X64 X32.
'                  (Class KnownFolders will be pulished Soon)
'
'                - This Module should work on all Windows from Win97 to now Windows 11. It has been made with big
'                  attention. I think it may become a reference for testing X64 X32.
'                  As this Module is new (May 2023) it has been tested yet on few systems.
'                  I am open to the Developer's community comments and suggestions.
'
'                - For to see which approach to have for to detect if Win64 or Win32, there were a lot of exchange with ChatGPT.
'                  ChatGPT can generate code for you but mostly with mistakes (VBA may 2023), but ChatGPT is good for to give
'                  informations about which way to go and for to read the code you do and tell you what to be carefull about.
'
'                - 'MsgBox "Debug" ... has been commented but stays in the code for further Debug if needed.
'                  It may be usefull for debugging different Systems with compiled code.
'
'                - There is in this code one procedure that is not absolutely needed for the good working of the functionalities but important for life.
'                  The Procedure is called Love. It implements nothing so it is no problem for debugging and so on. Feel free to keep or remove as you wish.
'                  I personnaly have the intention to keep this Procedure and even to write it in all my Modules and Classes.
'
'                - There is this wish of clean working useful code. I wish this module may stay useful until 2030 and still work.
'                  7 years for a module would be nice. Let's see what Microsoft will still invent...
'                  that brings developers to go back through their code and adapt.
'
'-Author:        Philippe Hollmuller, swiss quality, May 2023.
'-Tested:        Win97 Word VBA and compiled VB6, XP CompiledVB6, Windows10 VBA and compiled VB6, May 2023.
'

'todo VBA7 test API Call and see if ProgramFiles come for the X64 version C:\Program Files
#If VBA7 Then
    ' API about process
    ' Retrieves a pseudo handle for the calling thread.
    Private Declare PtrSafe Function GetCurrentProcess Lib "kernel32.dll" () As LongPtr

    ' Opens an existing local process object.
    Private Declare PtrSafe Function OpenProcess Lib "kernel32.dll" (ByVal dwDesiredAccess As LongPtr, ByVal bInheritHandle As Boolean, ByVal dwProcessId As LongPtr) As LongPtr

    ' Closes an open object handle.
    Private Declare PtrSafe Function CloseHandle Lib "kernel32.dll" (ByVal hObject As LongPtr) As LongPtr

    ' Retrieves the identifier of the thread that created the specified window and, optionally, the identifier of the process that created the window.
    Private Declare PtrSafe Function GetWindowThreadProcessId Lib "user32.dll" (ByVal hwnd As LongPtr, lpdwProcessId As LongPtr) As LongPtr

    ' Retrieves the handle to the desktop window.
    Private Declare PtrSafe Function GetDesktopWindow Lib "user32.dll" () As LongPtr

    ' Determines whether the specified process is running under WOW64 or an Intel64 of x64 processor.
    Private Declare PtrSafe Function IsWow64Process Lib "kernel32.dll" (ByVal hProcess As LongPtr, ByRef Wow64Process As Boolean) As LongPtr
    
    Private Const PROCESS_QUERY_LIMITED_INFORMATION As LongPtr = &H1000
    Private Const PROCESS_QUERY_INFORMATION As LongPtr = &H400
    
    'End API about process
#Else
    ' API about process
    ' Retrieves a pseudo handle for the calling thread.
    Private Declare Function GetCurrentProcess Lib "kernel32.dll" () As Long

    ' Opens an existing local process object.
    Private Declare Function OpenProcess Lib "kernel32.dll" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Boolean, ByVal dwProcessId As Long) As Long

    ' Closes an open object handle.
    Private Declare Function CloseHandle Lib "kernel32.dll" (ByVal hObject As Long) As Long

    ' Retrieves the identifier of the thread that created the specified window and, optionally, the identifier of the process that created the window.
    Private Declare Function GetWindowThreadProcessId Lib "user32.dll" (ByVal hwnd As Long, lpdwProcessId As Long) As Long

    ' Retrieves the handle to the desktop window.
    Private Declare Function GetDesktopWindow Lib "user32.dll" () As Long

    ' Determines whether the specified process is running under WOW64 or an Intel64 of x64 processor.
    Private Declare Function IsWow64Process Lib "kernel32.dll" (ByVal hProcess As Long, ByRef Wow64Process As Boolean) As Long
    
    Private Const PROCESS_QUERY_LIMITED_INFORMATION As Long = &H1000
    Private Const PROCESS_QUERY_INFORMATION As Long = &H400
    
    'End API about process
#End If

'Test or tested Variables for Properties
Private myIsThisWindowsX64Byte As Byte '0 Not Tested, 1 Win32, 2 Win64, 255 Testing Now
Private myIsThisProcessX64Byte As Byte '0 Not Tested, 1 Win32, 2 Win64

'Public Properties
Public Property Get IsThisWindowsX64() As Boolean
    If myIsThisWindowsX64Byte = 0 Then '0 Not Tested
        TestIsThisWindowsX64
    End If
    IsThisWindowsX64 = CBool(myIsThisWindowsX64Byte = 2)
End Property

Public Property Get IsThisProcessX64() As Boolean
    If myIsThisProcessX64Byte = 0 Then '0 Not Tested
        TestIsThisProcessX64
    End If
    IsThisProcessX64 = CBool(myIsThisProcessX64Byte = 2)
End Property

'Private procedures
Private Sub TestIsThisWindowsX64()
    If myIsThisWindowsX64Byte = 0 Then  '0 Not Tested, 1 Win32, 2 Win64, 255 Testing Now 'Only Test once
        Love 'Call to empty function, just once, for the intention and good on this planet earth. You may remove this if you want and this really does not take a lot of Processor :)
        myIsThisWindowsX64Byte = 255 'Testing. This Value is used in IsWin64Process
        Dim test1 As Boolean, test2 As Boolean
        test1 = isDesktopWindowWin64Process 'Important at Test1
        test2 = isWindowsX64ViewToPROCESSORARCHITEW6432
        If test1 = test2 Then
            If test1 Then
                myIsThisWindowsX64Byte = 2 '2 Win64
            Else
                myIsThisWindowsX64Byte = 1 '1 Win32
            End If
        Else
            'Hmmm, should never happen, but we never know with Microsoft...
            If FolderExists(EnvironByName("windir") & "\SysWOW64") Then
                myIsThisWindowsX64Byte = 2 '2 Win64
            Else
                myIsThisWindowsX64Byte = 1 '1 Win32
            End If
            'MsgBox "Debug: Two different Answers for TestIsThisWindowsX64", vbCritical
        End If
    End If
End Sub

Private Sub TestIsThisProcessX64()
    If myIsThisProcessX64Byte = 0 Then  '0 Not Tested, 1 Win32, 2 Win64 'Only Test once
        If IsWin64Process(GetCurrentProcess) Then 'GetCurrentProcess returns -1 which is commonly used to define the CurrentProcess in this kind of test.
            myIsThisProcessX64Byte = 2 '2 Win64
        Else
            myIsThisProcessX64Byte = 1 '1 Win32
        End If
    End If
End Sub

Private Function isWindowsX64ViewToPROCESSORARCHITEW6432() As Boolean
    'On a 64-bit Windows system, when you call Environ("PROCESSOR_ARCHITEW6432") from either a 32-bit or 64-bit process,
    'you should receive the same non-empty answer indicating the architecture of the system. The value of the
    'PROCESSOR_ARCHITEW6432 environment variable will be fixed and consistent on a given 64-bit Windows system.
    '
    'The possible values for PROCESSOR_ARCHITEW6432 on a 64-bit Windows system are:
    '
    '"AMD64" (x64 architecture)
    '"IA64" (Itanium architecture)
    '"ARM64" (ARM 64-bit architecture)
    'In most cases, the value will be "AMD64" indicating an x64 architecture.
    'However, it's worth noting that older systems or specialized versions may have different
    'values if they are running on Itanium or ARM 64-bit architectures.
    isWindowsX64ViewToPROCESSORARCHITEW6432 = CBool(InStr(1, EnvironByName("PROCESSOR_ARCHITEW6432"), "64") > 0)
End Function

Private Function isDesktopWindowWin64Process() As Boolean
    
    #If VBA7 Then
        Dim prc As LongPtr, hProcess As LongPtr
    #Else
        Dim prc As Long, hProcess As Long
    #End If

    
    On Error GoTo isDesktopWindowWin64Process_End
    GetWindowThreadProcessId GetDesktopWindow, prc
    If prc <> 0 Then
        hProcess = OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_QUERY_LIMITED_INFORMATION, 0, prc)
        isDesktopWindowWin64Process = IsWin64Process(hProcess) 'Answers True on Win64, even hProcess = 0 because here, hProcess = 0 represents the System Idle Process of Windows.
                                                               'On Win32, IsWin64Process(0) will fail and answer False
        CloseHandle hProcess
    End If
isDesktopWindowWin64Process_End:
End Function

                                                                                 'see Microsoft documentation about GetCurrentProcess
#If VBA7 Then
Private Function IsWin64Process(Optional ByVal hProcess As LongPtr = -1) As Boolean '-1 is a current way of calling CurrentProcess,
#Else
Private Function IsWin64Process(Optional ByVal hProcess As Long = -1) As Boolean '-1 is a current way of calling CurrentProcess,
#End If

    #If VBA7 Then
        Dim IsWow64ProcessRetVal As LongPtr
    #Else
        Dim IsWow64ProcessRetVal As Long
    #End If
    
    Dim Wow64Process As Boolean
    
IsWin64Process_Begin:
    If myIsThisWindowsX64Byte = 0 Then '0 Not Tested, 1 Win32, 2 Win64, 255 Testing Now
        'MsgBox "Debug: will TestIsThisWindowsX64: IsWin64Process myIsThisWindowsX64Byte = " & myIsThisWindowsX64Byte & " hProcess " & hProcess
        TestIsThisWindowsX64 'We need to know if this Windows is X64. If not, IsWin64Process should allways return False.
        'MsgBox "Debug: will restart IsWin64Process from beginning now that IsThisWindowsX64 has been set. myIsThisWindowsX64Byte = " & myIsThisWindowsX64Byte & " hProcess " & hProcess
        GoTo IsWin64Process_Begin 'Re begin now that myIsThisWindowsX64Byte is set to 1 or 2
    ElseIf myIsThisWindowsX64Byte <> 255 Then 'Not TestingNow '0 Not Tested, 1 Win32, 2 Win64, 255 Testing Now
        If Not IsThisWindowsX64 Then 'Enshure to test IsThisWindowsX64 because if not there may be no X64 process running and
                                     'IsWow64Process still may answer True for the CurrentProcess (Happens on WinXP
            'MsgBox "Debug: IsWin64Process Exit because IsThisWindowsX64 = False and not X64 Thread may run on Win32."
            Exit Function
        Else
            'MsgBox "Debug: IsWin64Process Continue because IsThisWindowsX64 = True, so X64 Thread may run on Win64."
        End If
    Else
        'MsgBox "Debug: Let IsWin64Process run for TestIsThisWindowsX64, hProcess = " & CStr(hProcess)
'       'myIsThisWindowsX64Byte = 255
'       'Let the code do this function IsWin64Process for TestIsThisWindowsX64() through isDesktopWindowWin64Process = 0
'       'But after that, once myIsThisWindowsX64Byte has been tested and set to 1 or 2
'       'We want to Exit this Function if not IsThisWindowsX64Byte
'       'because calling it with hProcess = -1 (CurrentProcess) could answer True even on Win32 System (happens on XP)
    End If
    
    'The purpose of the IsWow64Process function is to determine if a specific process is running under the WoW64
    '(Windows 32-bit on Windows 64-bit) emulation layer.
    'This function is specifically designed to check if a process is a 32-bit process
    'running on a 64-bit version of Windows.
    
    'Therefore, you can safely use the IsWow64Process function to determine if a process is 32-bit or 64-bit
    'on all 64-bit versions of Windows.
    'The function will return True for 32-bit processes running under the WoW64 emulation layer and False for 64-bit processes.
    
    On Error Resume Next 'We catch Error for if this code is called on a System where IsWow64Process does not exist yet in kernel32
    IsWow64ProcessRetVal = IsWow64Process(hProcess, Wow64Process)
    If Err.Number = 0 Then
        'No Error, IsWow64Process entry point was found in kernel32.dll
        If IsWow64ProcessRetVal <> 0 Then
            'The function IsWow64Process did succeed
            If Wow64Process Then 'Wow64Process contains True if Win32 Process runnign in Win64
                'The function IsWow64Process did return True for 32-bit processes running under the WoW64 emulation layer
                IsWin64Process = False '(First I was writing: IsWin64Process = not Wow64Process, but this gave strange results, Wow64Process was True and (Not Wow64Process) was True.
            Else
                'The function IsWow64Process did return False for 64-bit process
                IsWin64Process = True '(First I was writing: IsWin64Process = not Wow64Process, but this gave strange results, Wow64Process was True and (Not Wow64Process) was True.
                                       'Because CLng(WowProcess64) = 1 and CLng(Treu) = -1
            End If
            'MsgBox "Debug: IsWow64Process answered, IsWin64Process(" & CStr(hProcess) & ") = " & CStr(IsWin64Process)
        Else
            'MsgBox "Debug: IsWow64Process Call ok no Error but answer failed , IsWin64Process(" & CStr(hProcess) & ") = " & CStr(IsWin64Process)
        End If
    Else
        'MsgBox "Debug: IsWow64Process Call Error:  " & Err.Description & vbCrLf & "IsWin64Process(" & CStr(hProcess) & ") = " & CStr(IsWin64Process)
    End If
End Function

Private Function EnvironByName(Name As String) As String
    On Error Resume Next 'Because Key could be empty or other errors could happen, we return "" if Error
    EnvironByName = Environ(Name)
    On Error GoTo 0
End Function

Private Function FolderExists(Path As String)
'    FolderExists = Uf.FolderExists(Path)  'In PhilNetFiles
    On Error Resume Next
    Dim Fso
    On Error Resume Next
    Set Fso = CreateObject("Scripting.FileSystemObject")
    If Err.Number <> 0 Then
        Set Fso = Nothing 'Be shure it does not stay as Empty
    End If
    On Error GoTo 0
    If Not Fso Is Nothing Then
        FolderExists = Fso.FolderExists(Path)
    End If
End Function

Public Sub Love()
    'Keep in heart :)   This is the best method: no debug, no bugfix, everybody may interpret as he/she likes.
End Sub
