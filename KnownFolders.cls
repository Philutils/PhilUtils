VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "KnownFolders"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'Todo #If VBA7 Then ... and implement the API calls correctly for VBA7 LongPtr etc
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'HEADER          Description;
'''''''''''''''''''''''''''''
'    -KeyWords?  #FOLDERID;#SHGetKnownFolderPath;#KnowFolder;#KnowFolders;#VBA;#VB6
'
'    -What?      Win API Call about KnownFolders (Desktop, Downloads etc...), Class for VBA - VB6 MsOffice Automation.
'                -Resolves a known by Windows folder GUID into the Path on current system and current user.
'                -(Could be called through .Net if we want, probably. Maybe someone will adapt and
'                 give the code in C# with the same interface?...)
'
'    -For Who?   For all VBA developers who want to use or know more about the 124 (May 2023) constants defined for this by Microsoft
'                (some are deprecated depending of which windows is run).
'                https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid
'                Private Const FOLDERID_Desktop = "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" 'Example of GUID
'
'    -When?      Right now. Working From Windows 97 to Windows 11 and future versions. Made and tested in May 2023.
'
'    -Where?     Into your code and own VBA project.
'
'    -What?      KnownFolders Resolves a known folder (Desktop, Downloads etc).
'
'    -How?       - By calling the only Public Method of KnownFolders (itself calling API shell32.dll, ole32.dll, kernel32.dll):
'                  Public Function PathOfGUID(ByVal GUID As String) As String
'                - See Code example (usage) at the end of this Header.
'                - With love.
'
'    -Remark:    - To get One or some resolved Folders, use Class KnownFolders as described in the Code example (usage) below.
'                - To get ALL resolved Folders, use Class KnownFoldersDocu as described in the Code example (usage) of that Class.
'
'    -GUID?      About GUID: A universally unique identifier (UUID) is a 128-bit label used for information
'                            in computer systems. The term Globally Unique Identifier (GUID) is also used. Wikipedia.
'
'-KnownFolders:  If you type "KnownFolders" in Google you find all. Also type FOLDERID_ in Google and you find more.
'                As this topic is discussed and developers need to know about the KnownFolder Desktop, Downloads etc,
'                I, Philippe Hollmuller decided to make this clean Class to API access at once all what is described here:
'                https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid
'
'                Must Work on computers that implement #SHGetKnownFolderPath in kernel32 AND
'                Must Work on old computers that do not implement #SHGetKnownFolderPath yet in kernel32.
'                For this I needed to be able to test the CurrentProcess type, see X64X32 in the code and
'                implement PathOfGuid with translation into the old Windows way: SpecialFolder and Registry reading ShellFolder
'                see PathOfRegShellFolderTranslateGUIDtoOldName
'                I tried to keep easy to read names, did my best for Perfomance and here the result:
'
'                - Resolve One or some most used KnownFolders, use this Class Properties.
'                - Resolve One or some less used KnownFolders, Look for the corresponding GUID, implement a constance like
'                  Private Const FOLDERID_Desktop = "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" 'Example of GUID
'                  Call Debug.Print ThisClass.PathOfGuid(FOLDERID_Desktop)
'                - Resolve ALL known folder(s) and get other informations can be called using KnownFoldersDocu Class.
'
'-Author:       Philippe Hollmuller, May 2023.
'-Tested:       Win 97, Win XP, Win 10 X64
'Private Function GetKnownFolders() As String
'    Dim s As String
'    With New KnownFolders
'        'Can be used with defined Const GUID and call of Function PathOfGUID:
'        Const FOLDERID_Desktop = "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" 'Example of GUID
'        Dim DesktopFld As String
'        DesktopFld = .PathOfGUID(FOLDERID_Desktop) 'Example of use KnownFolders.PathOfGUID(FOLDERID_Something)
'        'For all FOLDERID_  see 'https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid
'
'        'KnownFolders
'        'Can be used with the mostly used KnownFolders by Call on KnownFolders's Properties who themselve call PathOfDUID.
'        'This way is comfortable in most situations for the Developer who uses this Class because he does not have to define the Const FOLDERID_
'        'For less used FOLDERID_Something, go the first way shown here in test, look for the constant you need in Microsoft documentation.
'        s = "KnownFolders:"
'        s = s & vbCrLf & "Windows = " & .Windows
'        s = s & vbCrLf & "System = " & .System
'        s = s & vbCrLf & "SystemX86 = " & .SystemX86
'        s = s & vbCrLf & "ProgramFiles = " & .ProgramFiles
'        s = s & vbCrLf & "ProgramFilesX86 = " & .ProgramFilesX86
'        s = s & vbCrLf & "ProgramFilesX64 = " & .ProgramFilesX64
'        s = s & vbCrLf & "ProgramFilesCommon = " & .ProgramFilesCommon
'        s = s & vbCrLf & "ProgramFilesCommonX86 = " & .ProgramFilesCommonX86
'        s = s & vbCrLf & "ProgramFilesCommonX64 = " & .ProgramFilesCommonX64
'        s = s & vbCrLf
'        s = s & vbCrLf & "ProgramData = " & .ProgramData
'        s = s & vbCrLf & "PublicDesktop = " & .PublicDesktop
'        s = s & vbCrLf & "CommonStartup = " & .CommonStartup
'        s = s & vbCrLf
'        s = s & vbCrLf & "AdminTools = " & .AdminTools
'        s = s & vbCrLf & "CDBurning = " & .CDBurning
'        s = s & vbCrLf & "Cookies = " & .Cookies
'        s = s & vbCrLf & "Desktop = " & .Desktop      'Now .Desktop = DesktopFld that was set before using FOLDERID_Desktop. 'BreakPoint
'        s = s & vbCrLf & "Documents = " & .Documents
'        s = s & vbCrLf & "Downloads = " & .Downloads
'        s = s & vbCrLf & "Favorites = " & .Favorites
'        s = s & vbCrLf & "Fonts = " & .Fonts
'        s = s & vbCrLf & "History = " & .History
'        s = s & vbCrLf & "InternetCache = " & .InternetCache
'        s = s & vbCrLf & "LocalAppData = " & .LocalAppData
'        s = s & vbCrLf & "Music = " & .Music
'        s = s & vbCrLf & "NetHood = " & .NetHood
'        s = s & vbCrLf & "Pictures = " & .Pictures
'        s = s & vbCrLf & "PrintHood = " & .PrintHood
'        s = s & vbCrLf & "Programs = " & .Programs
'        s = s & vbCrLf & "Recent = " & .Recent
'        s = s & vbCrLf & "RoamingAppData = " & .RoamingAppData
'        s = s & vbCrLf & "SendTo = " & .SendTo
'        s = s & vbCrLf & "StartMenu = " & .StartMenu
'        s = s & vbCrLf & "Startup = " & .Startup
'        s = s & vbCrLf & "Templates = " & .Templates
'        s = s & vbCrLf & "TemporaryFolder = " & .TemporaryFolder
'        s = s & vbCrLf & "Videos = " & .Videos
'        Debug.Print s
'    End With
'    GetKnownFolders = s
'End Function
''End Code Example (usage)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''
'API:
'''''
'API Type and Functions declaration:
''''''''''''''''''''''''''''''''''''
'TGUID Type:
Private Type TGUID 'https://learn.microsoft.com/en-us/dynamics-nav/guid-data-type
   Data1 As Long
   Data2 As Integer
   Data3 As Integer
   Data4(7) As Byte
End Type

'API functions shell32, ole32 and kernel32
'shell32 SHGetKnownFolderPath is the main function we want to use for to resolve the Known Folder ID. See PathOfGUID
Private Declare Function SHGetKnownFolderPath Lib "shell32.dll" (ByVal rfID As Long, ByVal dwFlags As Long, _
                                                                 ByVal hToken As Long, ByRef pszPath As Long) As Long 'SHGetKnownFolderPath 'shlobj_core.h 'https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath
'ole32
Private Declare Function CLSIDFromString Lib "ole32.dll" (ByVal lpszGuid As Long, ByRef pGuid As TGUID) As Long 'combaseapi.h 'https://learn.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-clsidfromstring
Private Declare Function CoTaskMemFree Lib "ole32.dll" (ByVal pv As Long) As Long
'kernel32
Private Declare Function lstrlenA Lib "kernel32" (ByVal lpString As Long) As Long 'Ansi    'winbase.h 'https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-lstrlena
Private Declare Function lstrlenW Lib "kernel32" (ByVal lpString As Long) As Long 'Unicode 'winbase.h 'https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-lstrlenw
Private Declare Function lstrcpyA Lib "kernel32" (ByVal lpString1 As Long, ByVal lpString2 As Long) As Long 'Ansi    'winbase.h 'https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-lstrcpya
Private Declare Function lstrcpyW Lib "kernel32" (ByVal lpString1 As Long, ByVal lpString2 As Long) As Long 'Unicode 'winbase.h 'https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-lstrcpyw
'End API functions shell32, ole32 and kernel32

'API Const
Private Const S_OK As Long = &H0
'Private Const E_FAIL As Long = &H80004005       'Used during Developement, for to see what happens if uncorrect call to dll
'Private Const E_INVALIDARG As Long = &H80070057 'Used during Developement, for to see what happens if uncorrect call to dll
Private Const WIN32_NULL As Long = 0&
''''''''''''''''''''''''''''''''''''''''
'End API Type and Functions declaration:
''''''''''''''''''''''''''''''''''''''''

''''''''''''''''''''''''''''''''''''
'Const for use:
''''''''''''''''''''''''''''''''''''
Private Const URLdocuCONST As String = "https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid"

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'For Old Systems: Fso FileSystemObject from Microsoft Scripting Runtime (ScrRun.dll) will make the job.
'See https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getspecialfolder-method
'Private Enum FSOSpecialFolderConst 'Does not know the Downloads SpecialFolder.
'                                   'For Downloads, you have to be on a System where #SHGetKnownFolderPath answers correctly.
'   Should be Enum but Word 97 does not let make Enum.
Private Const FSOSpecialWindowsFolder As Long = 0     'The Windows folder contains files installed by the Windows operating system.
Private Const FSOSpecialSystemFolder As Long = 1      'The System folder contains libraries, fonts, and device drivers.
Private Const FSOSpecialTemporaryFolder As Long = 2   'The Temp folder is used to store temporary files. Its path is found in the TMP environment variable.
'End Enum

'ProgramFilesSpecial See Remark in the Code.
Private Const FOLDERID_Windows = "{F38BF404-1D43-42F2-9305-67DE0B28FC23}"
Private Const FOLDERID_System = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}" 'C:\WINDOWS\system32
Private Const FOLDERID_SystemX86 = "{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}" 'C:\WINDOWS\SysWOW64
Private Const FOLDERID_ProgramFiles = "{905E63B6-C1BF-494E-B29C-65B732D3D21A}"
Private Const FOLDERID_ProgramFilesX86 = "{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}"
Private Const FOLDERID_ProgramFilesX64 = "{6D809377-6AF0-444B-8957-A3773F02200E}"
Private Const FOLDERID_ProgramFilesCommon = "{F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}"
Private Const FOLDERID_ProgramFilesCommonX86 = "{DE974D24-D9C6-4D3E-BF91-F4455120B917}"
Private Const FOLDERID_ProgramFilesCommonX64 = "{6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}"
'End ProgramFilesSpecial See Remark in the Code.

'Values to be found in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
'And allready present in Windows 97, see match between FOLDERID_ and RegValueNAme in PathOfRegShellFolderTranslateGUIDtoOldName.
'On the modern Computers, better to pass through SHGetKnownFolderPath for resolving these Values
'But This Class may be run on old computers and SHGetKnownFolderPath will fail (even not exist)
'So in the case of fail of SHGetKnownFolderPath, we will search for these values in the Registry by old style,
'Reading HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders,
'See PathOfRegShellFolderTranslateGUIDtoOldName
Private Const FOLDERID_ProgramData = "{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}" 'Common AppData in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
Private Const FOLDERID_PublicDesktop = "{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}" 'Common Desktop in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
Private Const FOLDERID_CommonStartup = "{82A5EA35-D9CD-47C5-9629-E15D2F714E6E}" 'Common Startup in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders

'Values to be found in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
'And allready present in Windows 97.
'On the modern Computers, better to pass through SHGetKnownFolderPath for resolving these Values
'But This Class may be run on old computers and SHGetKnownFolderPath will fail (even not exist)
'So in the case of fail of SHGetKnownFolderPath, we will search for these values in the Registry by old style,
'Reading HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders,
'See PathOfRegShellFolderTranslateGUIDtoOldName
Private Const FOLDERID_AdminTools = "{724EF170-A42D-4FEF-9F26-B60E846FBA4F}"
Private Const FOLDERID_CDBurning = "{9E52AB10-F80D-49DF-ACB8-4330F5687855}"
Private Const FOLDERID_Cookies = "{2B0F765D-C0E9-4171-908E-08A611B84FF6}"
Private Const FOLDERID_Desktop = "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
Private Const FOLDERID_Documents = "{FDD39AD0-238F-46AF-ADB4-6C85480369C7}"
Private Const FOLDERID_Downloads = "{374DE290-123F-4565-9164-39C4925E467B}"
Private Const FOLDERID_Favorites = "{1777F761-68AD-4D8A-87BD-30B759FA33DD}"
Private Const FOLDERID_Fonts = "{FD228CB7-AE11-4AE3-864C-16F3910AB8FE}"
Private Const FOLDERID_History = "{D9DC8A3B-B784-432E-A781-5A1130A75963}"
Private Const FOLDERID_InternetCache = "{352481E8-33BE-4251-BA85-6007CAEDCF9D}"
Private Const FOLDERID_LocalAppData = "{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}"
Private Const FOLDERID_Music = "{4BD8D571-6D19-48D3-BE97-422220080E43}"
Private Const FOLDERID_NetHood = "{C5ABBF53-E17F-4121-8900-86626FC2C973}"
Private Const FOLDERID_Pictures = "{33E28130-4E1E-4676-835A-98395C3BC3BB}"
Private Const FOLDERID_PrintHood = "{9274BD8D-CFD1-41C3-B35E-B13F55A758F4}"
Private Const FOLDERID_Programs = "{A77F5D77-2E2B-44C3-A6A2-ABA601054A51}"
Private Const FOLDERID_Recent = "{AE50C081-EBD2-438A-8655-8A092E34987A}"
Private Const FOLDERID_RoamingAppData = "{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}"
Private Const FOLDERID_SendTo = "{8983036C-27C0-404B-8F08-102D10DCFD74}"
Private Const FOLDERID_StartMenu = "{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}"
Private Const FOLDERID_Startup = "{B97D20BB-F46A-4C97-BA10-5E3608430854}"
Private Const FOLDERID_Templates = "{A63293E8-664E-48DB-A079-DF759E0509F7}"
Private Const FOLDERID_TemporaryFolder = "{Temporar-yFol-derT-empo-raryFolderTe}" 'Added May 2012 FOLDERID_TemporaryFolder
'So FOLDERID_TemporaryFolder does not exist by Windows BUT exists here
'For to Select Case when to return Fso.GetSpecialFolder(FSOSpecialTemporaryFolder)
'See https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getspecialfolder-method
Private Const FOLDERID_Videos = "{18989B1D-99B5-455B-841C-AB7C74E4DDFC}"

Private myFso 'As FileSystemObject, scrrun.dll Microsoft Scripting Runtime, but we keep it as Variant for to have no Reference.
Private myRegistry As Registry
Private myDoSHGetKnownFolderPath As Boolean
Private myDoSearchInEnviron As Boolean
Private myDoFsoGetSpecialFolder As Boolean
Private myDoPathOfRegShellFolderTranslateGUIDtoOldName As Boolean
Private myDoPathOfRegShellFolderDirectFromGUID As Boolean

''''''''''''''''''''''''''''''''''''
'End Const for use:
''''''''''''''''''''''''''''''''''''

'URLdocu Public
Public Property Get URLdocu() As String
    URLdocu = URLdocuCONST
End Property

Public Property Get DoSHGetKnownFolderPath() As Boolean 'Should be True but give the possibility of Skip for Debug reason.
    DoSHGetKnownFolderPath = myDoSHGetKnownFolderPath
End Property
Public Property Let DoSHGetKnownFolderPath(ByVal Val As Boolean)
    myDoSHGetKnownFolderPath = Val
End Property

Public Property Get DoSearchInEnviron() As Boolean 'Should be True but give the possibility of Skip for Debug reason.
    DoSearchInEnviron = myDoSearchInEnviron
End Property
Public Property Let DoSearchInEnviron(ByVal Val As Boolean)
    myDoSearchInEnviron = Val
End Property

Public Property Get DoFsoGetSpecialFolder() As Boolean 'Should be True but give the possibility of Skip for Debug reason.
    DoFsoGetSpecialFolder = myDoFsoGetSpecialFolder
End Property
Public Property Let DoFsoGetSpecialFolder(ByVal Val As Boolean)
    myDoFsoGetSpecialFolder = Val
End Property

Public Property Get DoPathOfRegShellFolderTranslateGUIDtoOldName() As Boolean 'Should be True but give the possibility of Skip for Debug reason.
    DoPathOfRegShellFolderTranslateGUIDtoOldName = myDoPathOfRegShellFolderTranslateGUIDtoOldName
End Property
Public Property Let DoPathOfRegShellFolderTranslateGUIDtoOldName(ByVal Val As Boolean)
    myDoPathOfRegShellFolderTranslateGUIDtoOldName = Val
End Property

Public Property Get DoPathOfRegShellFolderDirectFromGUID() As Boolean 'Should be True but give the possibility of Skip for Debug reason.
    DoPathOfRegShellFolderDirectFromGUID = myDoPathOfRegShellFolderDirectFromGUID
End Property
Public Property Let DoPathOfRegShellFolderDirectFromGUID(ByVal Val As Boolean)
    myDoPathOfRegShellFolderDirectFromGUID = Val
End Property

Private Sub Class_Initialize()
    myDoSHGetKnownFolderPath = True 'Should be True but give the possibility of Skip for Debug reason.
    myDoSearchInEnviron = True 'Should be True but give the possibility of Skip for Debug reason.
    myDoFsoGetSpecialFolder = True 'Should be True but give the possibility of Skip for Debug reason.
    myDoPathOfRegShellFolderTranslateGUIDtoOldName = True 'Should be True but give the possibility of Skip for Debug reason.
    myDoPathOfRegShellFolderDirectFromGUID = True 'Should be True but give the possibility of Skip for Debug reason.
End Sub

Private Sub Class_Terminate()
    Set myFso = Nothing
    Set myRegistry = Nothing
End Sub

'''''''''''
'API Calls:
'''''''''''
'LstrlenUnicodeOrAnsi will call lstrlenW with Error management and call lstrlenA if Error (Error happens o old systems that do not manage Unicode, Win 97 and so on)
Private Function LstrlenUnicodeOrAnsi(lpString As Long, ByRef DidCallAnsi As Boolean) As Long
    DidCallAnsi = False
TryUnicode:
    On Error Resume Next
    LstrlenUnicodeOrAnsi = lstrlenW(lpString)
    If Err.Number <> 0 Or LstrlenUnicodeOrAnsi = 0 Then
         'Err, Try Ansi
        GoTo TryAnsi
    Else
        Exit Function 'Done
    End If
    On Error GoTo 0
TryAnsi:
    On Error Resume Next
    LstrlenUnicodeOrAnsi = lstrlenA(lpString)
    If Err.Number <> 0 Or LstrlenUnicodeOrAnsi = 0 Then
        LstrlenUnicodeOrAnsi = 0 'Err
    Else
        DidCallAnsi = True 'For Information and later call LstrcpyUnicodeOrAnsi direct to Ansi
    End If
    On Error GoTo 0
End Function

'LstrcpyUnicodeOrAnsi will call lstrlenW with Error management and call lstrlenA if Error (Error happens on old systems that do not manage Unicode, Win 97 and so on)
Private Function LstrcpyUnicodeOrAnsi(lpString1 As Long, lpString2 As Long, DoCallAnsi As Boolean) As Long
If DoCallAnsi Then GoTo TryAnsi
TryUnicode:
    On Error Resume Next
    LstrcpyUnicodeOrAnsi = lstrcpyW(lpString1, lpString2)
    If Err.Number <> 0 Or LstrcpyUnicodeOrAnsi = 0 Then
         'Err, Try Ansi
        GoTo TryAnsi
    Else
        Exit Function 'Done
    End If
    On Error GoTo 0
TryAnsi:
    On Error Resume Next
    LstrcpyUnicodeOrAnsi = lstrcpyA(lpString1, lpString2)
    If Err.Number <> 0 Or LstrcpyUnicodeOrAnsi = 0 Then
        LstrcpyUnicodeOrAnsi = 0 'Err
    End If
    On Error GoTo 0
End Function

'PathOfGUID needs as param the String GUID looking like "{374DE290-123F-4565-9164-39C4925E467B}"
'This is the Function that makes the API Call. It will return True only with Correct GUID in correct Format.
Public Function PathOfGUID(ByVal GUID As String) As String
    Dim KnownFolderPath As String 'Return Value wanted
    Dim pGuid As TGUID            'Pointer to GUID
    Dim pszPath As Long           'Pointer to Path
    Dim DidCallAnsi As Boolean    'For to know if did call Ansi method at LstrlenUnicodeOrAnsi call
                                  'and jump direct to Ansi method by call LstrcpyUnicodeOrAnsi later in case of True.
    
    On Error GoTo SHGetKnownFolderPath_End 'Be shure to not crash
    'Step 1, the modern way of looking at KnownFolders see URLdocu
    If DoSHGetKnownFolderPath Then 'Should be True but give the possibility of Skip for Debug reason.
        If CLSIDFromString(StrPtr(GUID), pGuid) = S_OK Then                             'Look for GUID for this GUID
            If SHGetKnownFolderPath(VarPtr(pGuid), 0&, WIN32_NULL, pszPath) = S_OK Then 'Look for FolderPath for this GUID
                KnownFolderPath = Space$(LstrlenUnicodeOrAnsi(pszPath, DidCallAnsi))    'Space ReturnValue with needed Length
                LstrcpyUnicodeOrAnsi StrPtr(KnownFolderPath), pszPath, DidCallAnsi      'Copy Pointer to Path value into ReturnValue String
                CoTaskMemFree pszPath                                                   'Free Memory of Pointer to Path
            End If
        End If
    End If 'of  if DoSHGetKnownFolderPath Then
SHGetKnownFolderPath_End: 'May do Error if SHGetKnownFolderPath not implemented yet in shell32.dll. Obviously this happens with Windows97 but also with Windows XP.
    On Error Resume Next 'The rest of the code of this Function should not anymore make Error, but better not crash in case.
    
    'Result
    PathOfGUID = KnownFolderPath 'Give back what has been found in the Registry,
                                 'or by whatever process Microsoft implements for this information
                                 'by direct API call to Shell32.dll SHGetKnownFolderPath.
                                 'This is the cleanest way to obtain this info.
                                 'Not testing if the Folder really exists on the hard drive is good,
                                 'because it may be an Exe or another Window process that Shell32 will delegate the job.
                                 'We never know. Hopefully Microsoft knows.
                                 'Application may Create theFolder when needed.
                                 '(Some of them, DocumentLibrary for example), are Files.
                                 'In that case, FileExists answer True and FolderExists answers False.
                                 'Microsoft is full of surprises...
    
    ''So, view to this last comment which is result of testing, these next commented lines were bad idea:
    'If FileOrFolderExists(knownFolderPath) Then 'This test was bad idea
    '    PathOfGUID = knownFolderPath
    'ElseIf knownFolderPath <> "" Then
    '    PathOfGUID = "" ' knownFolderPath
    'End If
    
    
    'SpecialProgramFiles Remarks: about
    '                    FOLDERID_ProgramFiles
    '                    FOLDERID_ProgramFilesX64
    '                    FOLDERID_ProgramFilesX86
    '                    FOLDERID_ProgramFilesCommon
    '                    FOLDERID_ProgramFilesCommonX64
    '                    FOLDERID_ProgramFilesCommonX86
    '                    FOLDERID_ProgramFiles
    '                    FOLDERID_ProgramFiles
    '                    FOLDERID_ProgramFiles
    '                    FOLDERID_ProgramFiles
    '... and implementation:
    If PathOfGUID = "" And DoSHGetKnownFolderPath And DoSearchInEnviron Then 'Result test 1 'Common and Program Files X84 X64 compare (see Remark at end of URLdocu
        'SHGetKnownFolderPath did answer "".
        
        'This may be a speciality of Windows: -If you call a X64 Folder from a Win32 Thread on a X64 Windows,  Win does not let you see it.
        Select Case GUID
           'Case FOLDERID_ProgramFiles      'OS     'APP     'OK . In Short: -On Win32, Allways "Program Files"
                                            '-on Win64, "Program Files" for 64 bit App and "Program Files (x86)" for 32 bit App
                                            
                                            '32 bit  32 bit  FOLDERID_ProgramFiles   %SystemDrive%\Program Files
                                            '64 bit  64 bit  FOLDERID_ProgramFiles   %SystemDrive%\Program Files
                                            '64 bit  32 bit  FOLDERID_ProgramFiles   %SystemDrive%\Program Files (x86)
                                            'So this case will never happen as long as
           'Case FOLDERID_ProgramFilesX86   'OS     'APP     'OK
                                            '32 bit  32 bit  FOLDERID_ProgramFilesX86    %SystemDrive%\Program Files
                                            '64 bit  64 bit  FOLDERID_ProgramFilesX86    %SystemDrive%\Program Files (x86)
                                            '64 bit  32 bit  FOLDERID_ProgramFilesX86    %SystemDrive%\Program Files (x86)
            
            Case FOLDERID_ProgramFilesX64   'OS     'APP     'OK 'Change if empty and OS 64 and App 32 (if OS 32, this Folder does not exist)
                                            '32 bit  32 bit  FOLDERID_ProgramFilesX64 (not supported under 32-bit operating systems) Not applicable
                                            '64 bit  64 bit  FOLDERID_ProgramFilesX64 %SystemDrive%\Program Files
                                            '64 bit  32 bit  FOLDERID_ProgramFilesX64 (not supported for 32-bit applications) Not applicable
                                            '  ... but should in my opinion give back %SystemDrive%\Program Files
                ' -If you call a X64 Folder from a Win32 Thread on a X64 Windows,  Win does not let you see it.
                Dim ProgramW6432 As String 'But Environ probably yes ! So let's take this: (Environ, the functionalities of VBA and VB6 about environment
                ProgramW6432 = EnvironByName("ProgramW6432")
                If StrComp(PathOfGUID, ProgramW6432, vbTextCompare) <> 0 Then
                    If FolderExists(ProgramW6432) Then
                        PathOfGUID = ProgramW6432 'OS 64 and App 32, we give it back and it will be %SystemDrive%\Program Files
                    End If
                End If
           'Case FOLDERID_ProgramFilesCommon    'OS     'APP     'OK
                                                '32 bit  32 bit  FOLDERID_ProgramFilesCommon %ProgramFiles%\Common Files
                                                '64 bit  64 bit  FOLDERID_ProgramFilesCommon %ProgramFiles%\Common Files
                                                '64 bit  32 bit  FOLDERID_ProgramFilesCommon %ProgramFiles(x86)%\Common Files
                
                
           
           'Case FOLDERID_ProgramFilesCommonX86 'OS     'APP     'OK
                                                '32 bit  32 bit  FOLDERID_ProgramFilesCommonX86  %ProgramFiles%\Common Files
                                                '64 bit  64 bit  FOLDERID_ProgramFilesCommonX86  %ProgramFiles(x86)%\Common Files
                                                '64 bit  32 bit  FOLDERID_ProgramFilesCommonX86  %ProgramFiles(x86)%\Common Files
                                                ' -If you call a X86 Folder from a Win64 Thread, %ProgramFiles(x86)%\Common Files
            
            Case FOLDERID_ProgramFilesCommonX64 'OS     'APP     'OK 'Change if empty and OS 64 and App 32 (if OS 32, this Folder does not exist)
                                                '32 bit  32 bit  FOLDERID_ProgramFilesCommonX64 (undefined)  Not applicable
                                                '64 bit  64 bit  FOLDERID_ProgramFilesCommonX64  %ProgramFiles%\Common Files
                                                '64 bit  32 bit  FOLDERID_ProgramFilesCommonX64  %ProgramFiles%\Common Files
                                          '  ... but STILL HAPPENS OS 64 App 32 should give back %ProgramFiles%\Common Files
                
                ' -If you call a X64 Folder from a Win32 Thread on a X64 Windows,  Win does not let you see it.
                Dim CommonProgramW6432 As String 'But Environ probably yes ! So let's take this: (Environ, the functionalities of VBA and VB6 about environment
                CommonProgramW6432 = EnvironByName("CommonProgramW6432")
                If StrComp(PathOfGUID, CommonProgramW6432, vbTextCompare) <> 0 Then
                    If FolderExists(CommonProgramW6432) Then
                        PathOfGUID = CommonProgramW6432 'OS 64 and App 32, we give it back and it will be %SystemDrive%\Program Files
                    End If
                End If
            
            'About System:
            'C:\WINDOWS\system:   This directory contains essential system files for the operation of Windows.
            '                     It includes DLL files (Dynamic Link Libraries), device drivers, and
                                  'other important system files.
            '
            'C:\WINDOWS\system32: This directory is also critical for the Windows operating system.
            '                     It houses the 32-bit system files required for the functioning of the system.
            '                     It contains executable files, Dynamic Link Libraries (DLLs), drivers, services, and
            '                     other system components.
            '
            'C:\WINDOWS\sysWOW64: This directory is specific to 64-bit Windows operating systems.
            '                     It contains the 32-bit system files (WOW64) needed for backward compatibility
            '                     of 32-bit applications on a 64-bit operating system.
            '                     32-bit applications run in a virtual environment
            '                     called Windows 32-bit on Windows 64-bit (WOW64).
            'Case FOLDERID_System    'OS     'APP     'OK 'C:\WINDOWS\system32
                                     '                    '(Except Win97 where it should be C:\WINDOWS\system
                                     '                    'but in this case the debug mode is not going through here
                                     '                    'and Fso will find it correctly).
                                     '32 bit  32 bit  FOLDERID_System  %windir%\system32
                                     '64 bit  64 bit  FOLDERID_System  %windir%\system32
                                     '64 bit  32 bit  FOLDERID_System  %windir%\system32
                                     ' So this is clear, this FOLDERID will allways return the same, and
                                     'houses the 32-bit system files required for the functioning of the system
                'No operation
            'Case FOLDERID_SystemX86 'OS     'APP     'OK 'C:\WINDOWS\SysWOW64
                                     '32 bit  32 bit  FOLDERID_SystemX86  %windir%\system32
                                     '64 bit  64 bit  FOLDERID_SystemX86  %windir%\syswow64
                                     '64 bit  32 bit  FOLDERID_SystemX86  %windir%\syswow64
                                     ' So this is clear, this FOLDERID will allways return:
                                     'On Win32 same as FOLDERID_System: C:\WINDOWS\system32
                                     'On Win64 it will return C:\WINDOWS\SysWOW64 which is
                                     'specific to 64-bit Windows operating systems and
                                     'contains the 32-bit system files (WOW64) needed for backward
                                     'compatibility of 32-bit applications on a 64-bitsystem.
                'No operation
            Case Else
                'No operation
        End Select 'End Select Case GUID
    End If 'of If PathOfGUID = "" And DoSHGetKnownFolderPath And DoSearchInEnviron Then 'Result test 1 'Common and Program Files X84 X64 compare (see Remark at end of URLdocu
    
    'PathOfGUID is now recognizable Folder or "" if not existing.
    '
    'BUT!!!!! And here is the experience of the Senior developer:
    '
    'This class may be run on an Old System where SHGetKnownFolderPath does not exist yet, for example Word 97, 98, 2000 on an old Windows.
    'or it's implementation is not yet perfect on Windows and in one of these cases,
    If PathOfGUID = "" And DoFsoGetSpecialFolder Then 'Result test 2, Resolve using FileSystemObject Fso.GetSpecialFolder
        'so let's do it with the FileSystemObject. This one runs allready in Win97 if the Win dll ScrRun.dll is present in System(32)
        'Only 3 Values to be found here, see https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getspecialfolder-method
        If Not Fso Is Nothing Then 'Fso through Private Property Get Fso...
            'We have Access to FileSystemObject:
            Select Case GUID
                'Fso.GetSpecialFolder(i) returns only 3 values:
                '0 C:\Windows                           'FSOSpecialWindowsFolder
                '1 C:\Windows\System32                  'FSOSpecialSystemFolder
                '2 C:\Users\UserName\AppData\Local\Temp 'FSOSpecialTemporaryFolder
                'See https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getspecialfolder-method
                'Comparing this with KnownFolders 'See https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid
                'We can conclude:
                'FSOSpecialWindowsFolder corresponds to FOLDERID_Windows
                'FSOSpecialSystemFolder corresponds to FOLDERID_System  '(X32, but in this part of the code of PathOfGuid,
                '                            and to FOLDERID_SystemX86  ' we are in old windows that means no X64,
                '                                                       ' because on new Windows, the First part of this procedure
                '                                                       ' has answered already).
                'FSOSpecialTemporaryFolder corresponds to nothing described in FOLDERID_Something see https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid.
                'So I made one and here now FSOSpecialTemporaryFolder
                'corresponds to FOLDERID_TemporaryFolder, TemporaryFolder for correspondance with FSOSpecialTemporaryFolder see See https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getspecialfolder-method
                'FOLDERID_TemporaryFolder is now Added to the Class KnownFolders.cls as FOLDERID_TemporaryFolder
                'for comparing and returning Fso.GetSpecialFolder(FSOSpecialTemporaryFolder)
                'and we can compare here the three possible Values for Fso.GetSpecialFolder with our values of FOLDERID_KnownFolders:
                Case FOLDERID_Windows 'FOLDERID_Windows
                    PathOfGUID = Fso.GetSpecialFolder(FSOSpecialWindowsFolder) 'Ok Tested 'Windows SpecialFolderConst.WindowsFolder, already working on Win97 ok
                    'See https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getspecialfolder-method
                Case FOLDERID_System 'FOLDERID_System 'Answer same in both Cases: We are here in a part of code that is called
                                     'from a old system. Win XP or earlier no yet SystemX86 or X64
                                                         
                    PathOfGUID = Fso.GetSpecialFolder(FSOSpecialSystemFolder) 'Ok Tested ' 'Windows SpecialFolderConst.SystemFolder 'System32, System on old computers, already working on Win97 ok
                    'See https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getspecialfolder-method
                Case FOLDERID_SystemX86 'OS     'APP     'OK 'C:\WINDOWS\SysWOW64               'FOLDERID_SystemX86
                                         '32 bit  32 bit  FOLDERID_SystemX86  %windir%\system32
                                         '64 bit  64 bit  FOLDERID_SystemX86  %windir%\syswow64
                                         '64 bit  32 bit  FOLDERID_SystemX86  %windir%\syswow64
                                         ' So this is clear, this FOLDERID will allways return:
                                         'On Win32 same as FOLDERID_System: C:\WINDOWS\system32
                                         'On Win64 it will return C:\WINDOWS\SysWOW64 which is
                                         'specific to 64-bit Windows operating systems and
                                         'contains the 32-bit system files (WOW64) needed for backward
                                         'compatibility of 32-bit applications on a 64-bitsystem.
                    If X64X32.IsThisWindowsX64 Then
                        'We expect are in Win64 Windows and expect %windir%\SysWOW64 in all casees if DoSearchInEnviron
                        'There is no this information about WOW64 in EnvironByName, so even If DoSearchInEnviron, this will not help
                        'So Let's try to take Windows folder, add "SysWOW64", see if it Exists and if so, return this.
                        'I remind you here that this part of code will only happen If Not DoSHGetKnownFolderPath, becasue with DoSHGetKnownFolderPath, we already have this information.
                        If FolderExists(PathOfGUID(FOLDERID_Windows) & "\SysWOW64") Then
                            PathOfGUID = PathOfGUID(FOLDERID_Windows) & "\SysWOW64"
                        End If

                    Else 'of X64X32.IsThisWindowsX64
                        'We are in Win32 Windows and expect %windir%\system32
                        PathOfGUID = Fso.GetSpecialFolder(FSOSpecialSystemFolder) 'Ok Tested ' 'Windows SpecialFolderConst.SystemFolder 'System32, System on old computers, already working on Win97 ok
                                    'Fso.GetSpecialFolder(FSOSpecialSystemFolder) answers %windir%\system32
                    End If
                Case FOLDERID_TemporaryFolder           'does not exist by Windows BUT exists here: 'FOLDERID_TemporaryFolder
                                                        'And we give back Fso.GetSpecialFolder(2) which works since years

                    PathOfGUID = Fso.GetSpecialFolder(FSOSpecialTemporaryFolder) 'Ok Tested 'System32, System on old computers, already working on Win97 ok
                    'See https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/getspecialfolder-method
            End Select
        End If
    End If 'of If PathOfGUID = "" And DoFsoGetSpecialFolder Then 'Result test 2, Resolve using FileSystemObject Fso.GetSpecialFolder
    'PathOfGUID is now recognizable Folder or "" if not existing.
    '
    'BUT!!!!! And here is the experience of the Senior developer once more time:
    '
    'When called on old computers with modern code, it is nice to have access still access some KnownFolders
    'That where known through Registry HKCU or HKLM \ "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell
    'at the time of these old systems. I am speaking about Windows 97, 98, NT, 2000, XP... I think things began to change really from Windows Vista
    'This last section of PathOfGuid does not concern computers more modern than Windows Vista.
    'But it can be tested on moderne computers by changing the Values of
    'DoSHGetKnownFolderPath, DoSearchInEnviron, DoFsoGetSpecialFolder to False.

    'So and so, for these modern Computers, our first part of PathOfGuid did the job already.
    'So here: Imagine you are running an old 32 bit Computer that did not know about Program Files(X86). Program Files was enough.
    'So now we translate these FOLDERID_Something, the main ones, to a possible use of this class on old machines,
    'Win 97 Word 97 , WinXP etc for example.
    If PathOfGUID = "" And DoPathOfRegShellFolderTranslateGUIDtoOldName Then 'Result test 4, Resolve "manually" for old systems:
        'This function replaces the old and tested GetSpecialFolder used for some years in PhilUtils.
        'It allows to be shure to return something ok with some specific Folders, even if we are on old systems like XP, Win NT Win97.
        'On new computer, this function will not even be called because the first parts of PathOfGUID did answer already.
        PathOfGUID = PathOfRegShellFolderTranslateGUIDtoOldName(GUID)
    End If 'of If PathOfGUID = "" And DoPathOfRegShellFolderTranslateGUIDtoOldName Then 'Result test 4, Resolve "manually" for old systems:
    'PathOfGUID is now recognizable Folder or "" if not existing.
    '
    'BUT: If SHGetFolderPath failed, some of the values are readable in the Registry: (This should almost never happen but for safe reason, let's do it.
    If PathOfGUID = "" And DoPathOfRegShellFolderDirectFromGUID Then 'Result test 4, Resolve "manually" for old systems:
        Const LookInCurrentUser As Boolean = True
        PathOfGUID = PathOfRegShellFolder(LookInCurrentUser, GUID) '8 found like this on Win10. They are entries in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders having names corresponding to Exact GUID.
                                                                   'Note: In the same Key, there is one value saying: Use the SHGetFolderPath or SHGetKnownFolderPath function instead
                                                                   'Which means it is really better to resolve at the fists step of this Function.
                                                                   'This part of code will be run only if the first part of code SHGetFolderPath did fail.
    End If
    
    'Last tests:
    'So, After all this, some Values need really to be given Back:
    If PathOfGUID = "" Then 'This will never happen for our tested here ProgFile, System and Windows,
                            'if we are on X64 Windows and DoSHGetKnownFolderPath and DoSearchInEnviron
        Select Case GUID
            Case FOLDERID_Windows 'Windows
                'Windows
                If DoSearchInEnviron Then
                    PathOfGUID = EnvironByName("windir") 'This answer OK Win97, OK WinXP, OK Win10
                    If PathOfGUID = "" Then
                        PathOfGUID = EnvironByName("winbootdir") 'This answer OK Win97, Not XP, Not Win10
                    End If
                    If PathOfGUID = "" Then
                        PathOfGUID = EnvironByName("SystemRoot") 'This answer NOT Win97, OK WinXP, Ok Win10
                    End If
                    If PathOfGUID = "" Then
                        PathOfGUID = EnvironByName("SystemDrive") 'This answer NOT Win97, OK WinXP, Ok Win10
                        If FolderExists(PathOfGUID & "\Windows") Then
                            PathOfGUID = PathOfGUID & "\Windows"
                        Else
                            PathOfGUID = ""
                        End If
                    End If
                End If
                If PathOfGUID = "" Then
                    'If after all this we still did not find it, oh what to do, try this and else let it be. But this should actually never happen.
                    If FolderExists("C:\Windows") Then
                        PathOfGUID = "C:\Windows"
                    End If
                End If
            Case FOLDERID_System 'System
                'FOLDERID_System should answer on Win97: C:\Windows\system, even system32 exists (Fso answer)
                'on WinXP and later, as soon as Exists System32: C:\WINDOWS\system32
                'Search for the value through Fso even if not DoFsoGetSpecialFolder
                If Not Fso Is Nothing Then
                    PathOfGUID = Fso.GetSpecialFolder(FSOSpecialSystemFolder) 'Ok Tested ' 'Windows SpecialFolderConst.SystemFolder 'System32, System on Win97, already working on Win97 ok
                End If
                If PathOfGUID = "" Then
                    'Fso did not answer, which is very uncommon because Fso is long tested and may answer already on Win97
                    'This should never happen if Fso did answer. On Win97, Fso answers System, not 32. And 32 exists allready. On windows lateer than 97 Fso answers System32.
                    If FolderExists(PathOfGUID(FOLDERID_Windows) & "\System32") Then
                        PathOfGUID = PathOfGUID(FOLDERID_Windows) & "\System32" 'Going through the Windows Folder
                        'Here it may be a mistake if Win97 and System32 exists. Normally Fso did answer correctly though so this described mistake will not happen.
                    ElseIf (Not X64X32.IsThisWindowsX64) And FolderExists(PathOfGUID(FOLDERID_Windows) & "\System") Then
                        PathOfGUID = PathOfGUID(FOLDERID_Windows) & "\System" 'Going through the Windows Folder
                    End If
                End If
                'If PathOfGUID = "" Then 'Hmm, there we are lost, no more something really good to give back.
                'End If                  'Should never happen.
            Case FOLDERID_SystemX86  'FOLDERID_SystemX86
                                     'OS     'APP     'OK 'C:\WINDOWS\SysWOW64
                                     '32 bit  32 bit  FOLDERID_SystemX86  %windir%\system32
                                     '64 bit  64 bit  FOLDERID_SystemX86  %windir%\syswow64
                                     '64 bit  32 bit  FOLDERID_SystemX86  %windir%\syswow64
                                     ' So this is clear, this FOLDERID will allways return:
                                     'On Win32 same as FOLDERID_System: C:\WINDOWS\system32
                                     'On Win64 it will return C:\WINDOWS\SysWOW64 which is
                                     'specific to 64-bit Windows operating systems and
                                     'contains the 32-bit system files (WOW64) needed for backward
                                     'compatibility of 32-bit applications on a 64-bitsystem.
                    If X64X32.IsThisWindowsX64 Then
                        'We expect are in Win64 Windows and expect %windir%\SysWOW64 in all casees if DoSearchInEnviron
                        'There is no this information about WOW64 in EnvironByName, so even If DoSearchInEnviron, this will not help
                        'So Let's try to take Windows folder, add "SysWOW64", see if it Exists and if so, return this.
                        'I remind you here that this part of code will only happen If Not DoSHGetKnownFolderPath, becasue with DoSHGetKnownFolderPath, we already have this information.
                        If FolderExists(PathOfGUID(FOLDERID_Windows) & "\SysWOW64") Then
                            PathOfGUID = PathOfGUID(FOLDERID_Windows) & "\SysWOW64"
                        End If
                        'If PathOfGUID = "" Then 'Hmm, there we are lost, no more something really good to give back.
                        'End If                  'Should never happen.
                    Else 'of X64X32.IsThisWindowsX64
                        'We are in Win32 Windows and expect %windir%\system32
                        If Not Fso Is Nothing Then
                            PathOfGUID = Fso.GetSpecialFolder(FSOSpecialSystemFolder) 'Ok Tested ' 'Windows SpecialFolderConst.SystemFolder 'System32, System on old computers, already working on Win97 ok
                        End If
                        If PathOfGUID = "" Then
                            'Fso did not answer, which is very uncommon because Fso is long tested and may answer already on Win97
                            'This should never happen if Fso did answer. On Win97, Fso answers System, not 32. And 32 exists allready. On windows lateer than 97 Fso answers System32.
                            If FolderExists(PathOfGUID(FOLDERID_Windows) & "\System32") Then
                                PathOfGUID = PathOfGUID(FOLDERID_Windows) & "\System32" 'Going through the Windows Folder
                                'Here it may be a mistake if Win97 and System32 exists. Normally Fso did answer correctly though so this described mistake will not happen.
                            ElseIf (Not X64X32.IsThisWindowsX64) And FolderExists(PathOfGUID(FOLDERID_Windows) & "\System") Then
                                PathOfGUID = PathOfGUID(FOLDERID_Windows) & "\System" 'Going through the Windows Folder
                            End If
                        End If
                    End If
            Case FOLDERID_ProgramFiles 'FOLDERID_ProgramFiles
                                       'OS     'APP     'OK . In Short: -On Win32, Allways "Program Files"
                                       '-on Win64, "Program Files" for 64 bit App and "Program Files (x86)" for 32 bit App
                                       '32 bit  32 bit  FOLDERID_ProgramFiles   %SystemDrive%\Program Files
                                       '64 bit  64 bit  FOLDERID_ProgramFiles   %SystemDrive%\Program Files
                                       '64 bit  32 bit  FOLDERID_ProgramFiles   %SystemDrive%\Program Files (x86)
                                       
                'see Remark in URLdocu, This changes answer depending if Process  is 32 or 64 bit
                'So test it and return what is needed
                If X64X32.IsThisWindowsX64 Then
                    If X64X32.IsThisProcessX64 Then 'This line of code does tests on windows architecture and the running proces
                                                        'to get the right Path.
                        'Os 64 bit App 64 bit
                        'Expected %SystemDrive%\Program Files
                        PathOfGUID = PathOfGUID(FOLDERID_ProgramFilesX64) '64 This does the job correctly
                    Else
                        'Os 64 bit App 32 bit
                        'Expected %SystemDrive%\Program Files (x86)
                        PathOfGUID = PathOfGUID(FOLDERID_ProgramFilesX86) '86 This does the job correctly
                    End If
                Else
                    'Os 32 bit App 32 bit
                    'Expected %SystemDrive%\Program Files
                    PathOfGUID = PathOfGUID(FOLDERID_ProgramFilesX86) '86 This does the job correctly
                End If
            Case FOLDERID_ProgramFilesX86 'FOLDERID_ProgramFilesX86
                                          'OS     'APP     'OK
                                          '32 bit  32 bit  FOLDERID_ProgramFilesX86    %SystemDrive%\Program Files
                                          '64 bit  64 bit  FOLDERID_ProgramFilesX86    %SystemDrive%\Program Files (x86)
                                          '64 bit  32 bit  FOLDERID_ProgramFilesX86    %SystemDrive%\Program Files (x86)
                If X64X32.IsThisWindowsX64 Then
                    'Expected %SystemDrive%\Program Files (x86)
                    PathOfGUID = EnvironByName("ProgramFiles(x86)") 'Look in Environ
                    If PathOfGUID = "" Then
                        'Should never happen, but we never know with microsoft...
                        PathOfGUID = PathOfGUID(FOLDERID_Windows) 'Go through Windows and replace
                        PathOfGUID = Replace(PathOfGUID, "\Windows", "\Program Files (x86)", , , vbTextCompare)
                        If Not FolderExists(PathOfGUID) Then
                            'Hmm, did not work
                            PathOfGUID = "" 'Should not happen
                        End If
                    End If
                Else
                    'Expected %SystemDrive%\Program Files
                    PathOfGUID = EnvironByName("ProgramFiles") 'Look in Environ
                    If PathOfGUID = "" Then
                        'Should never happen, but on old systems.... happens with Win97
                        PathOfGUID = PathOfGUID(FOLDERID_Windows) 'Go through Windows and replace
                        PathOfGUID = Replace(PathOfGUID, "\Windows", "\Program Files", , , vbTextCompare)
                        If Not FolderExists(PathOfGUID) Then
                            'Hmm, did not work
                            PathOfGUID = "" 'Should not happen
                        End If
                    End If
                End If
            Case FOLDERID_ProgramFilesX64 'FOLDERID_ProgramFilesX64
                'If X64X32.IsThisWindowsX64, FOLDERID_ProgramFilesX64 should answer C:\Program Files (or its set Value found through Environ
                'Else, it means we are on a 32 bit Windows and this FOLDERID_ProgramFilesX64 should stay Empty ""
                If X64X32.IsThisWindowsX64 Then
                    'It was not found yet, take it from EnvironByName("ProgramW6432") even if not DoSearchInEnviron.
                    PathOfGUID = EnvironByName("ProgramW6432")
                'Else it stays Empty
                End If
            Case FOLDERID_ProgramFilesCommon 'FOLDERID_ProgramFilesCommon
            'Case FOLDERID_ProgramFilesCommon    'OS     'APP     'OK
                                                 '32 bit  32 bit  FOLDERID_ProgramFilesCommon %ProgramFiles%\Common Files
                                                 '64 bit  64 bit  FOLDERID_ProgramFilesCommon %ProgramFiles%\Common Files
                                                 '64 bit  32 bit  FOLDERID_ProgramFilesCommon %ProgramFiles(x86)%\Common Files
                'see Remark in URLdocu, This changes answer depending if Process  is 32 or 64 bit
                'So test it and return what is needed
                If X64X32.IsThisWindowsX64 Then
                    If X64X32.IsThisProcessX64 Then 'This line of code does tests on windows architecture and the running proces
                                                        'to get the right Path.
                        'Os 64 bit App 64 bit
                        'Expected %SystemDrive%\Program Files
                        PathOfGUID = PathOfGUID(FOLDERID_ProgramFilesCommonX64) '64 This does the job correctly
                    Else
                        'Os 64 bit App 32 bit
                        'Expected %SystemDrive%\Program Files (x86)
                        PathOfGUID = PathOfGUID(FOLDERID_ProgramFilesCommonX86) '86 This does the job correctly
                    End If
                Else
                    'Os 32 bit App 32 bit
                    'Expected %SystemDrive%\Program Files
                    PathOfGUID = PathOfGUID(FOLDERID_ProgramFilesCommonX86) '86 This does the job correctly
                End If
            Case FOLDERID_ProgramFilesCommonX86 'FOLDERID_ProgramFilesCommonX86
                                                'OS     'APP     'OK
                                                '32 bit  32 bit  FOLDERID_ProgramFilesCommonX86  %ProgramFiles%\Common Files
                                                '64 bit  64 bit  FOLDERID_ProgramFilesCommonX86  %ProgramFiles(x86)%\Common Files
                                                '64 bit  32 bit  FOLDERID_ProgramFilesCommonX86  %ProgramFiles(x86)%\Common Files
                                                ' -If you call a X86 Folder from a Win64 Thread, %ProgramFiles(x86)%\Common Files
                If X64X32.IsThisWindowsX64 Then
                    'Expected %SystemDrive%\Program Files (x86)
                    PathOfGUID = EnvironByName("CommonProgramFiles(x86)") 'Look in Environ
                    If PathOfGUID = "" Then
                        'Should never happen, but we never know with microsoft...
                        PathOfGUID = PathOfGUID(FOLDERID_Windows) 'Go through Windows and replace
                        PathOfGUID = Replace(PathOfGUID, "\Windows", "\Program Files (x86)\Common Files", , , vbTextCompare)
                        If Not FolderExists(PathOfGUID) Then
                            'Hmm, did not work
                            PathOfGUID = "" 'Should not happen
                        End If
                    End If
                Else
                    'Expected %SystemDrive%\Program Files
                    PathOfGUID = EnvironByName("CommonProgramFiles") 'Look in Environ
                    If PathOfGUID = "" Then
                        'Should never happen, but on old systems.... happens with Win97
                        PathOfGUID = PathOfGUID(FOLDERID_Windows) 'Go through Windows and replace
                        PathOfGUID = Replace(PathOfGUID, "\Windows", "\Program Files\Common Files", , , vbTextCompare)
                        If Not FolderExists(PathOfGUID) Then
                            'Hmm, did not work
                            PathOfGUID = "" 'Should not happen
                        End If
                    End If
                End If
            Case FOLDERID_ProgramFilesCommonX64 'FOLDERID_ProgramFilesCommonX64
                ' -If you call a X64 Folder from a Win32 Thread on a X64 Windows,  Win does not let you see it.
                'Second time, should have been solved if DoSHGetKnownFolderPath but here: Dim CommonProgramW6432 As String 'But Environ probably yes ! So let's take this: (Environ, the functionalities of VBA and VB6 about environment
                CommonProgramW6432 = EnvironByName("CommonProgramW6432")
                If StrComp(PathOfGUID, CommonProgramW6432, vbTextCompare) <> 0 Then
                    If FolderExists(CommonProgramW6432) Then
                        PathOfGUID = CommonProgramW6432 'OS 64 and App 32, we give it back and it will be %SystemDrive%\Program Files
                    End If
                End If
        End Select
    End If
    'End of PathOfGUID
End Function

Private Function EnvironByName(Name As String) As String
    On Error Resume Next 'Because Key could be empty or other errors could happen, we return "" if Error
    EnvironByName = Environ(Name)
    On Error GoTo 0
End Function

'This function replaces the old and tested GetSpecialFolder used for some years in PhilUtils.
'It allows to be shure to return something ok with some specific KNOWNFOLDERID_, even if we are on old systems like XP, Win NT Win97.
'On new computer, this function will not even be called because the first parts of PathOfGUID did answer already.
'This is the function that will give the correct Answer on Windows 97, XP, maybe 7 not shure is 7 allready answers to SHGetKnownFolderPath.
'This function translates the new GUID used by Windows modern to ValueName in registry used by old Windows but still present in Win 10
'see HKEY_LOCAL_MACHINE and HKEY_CURRENT_USER \SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
Private Function PathOfRegShellFolderTranslateGUIDtoOldName(GUID As String) As String
    Const LookInCurrentUser As Boolean = True
    Const LookInLocalMachine As Boolean = False 'Not LookInCurrentUser
    Dim rv As String
    Select Case GUID
        
        'Values to be found in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
        'Private Const FOLDERID_ProgramData = "{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}" 'Common AppData in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
        'Private Const FOLDERID_PublicDesktop = "{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}" 'Common Desktop in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
        'Private Const FOLDERID_CommonStartup = "{82A5EA35-D9CD-47C5-9629-E15D2F714E6E}" 'Common Startup in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
        'Here a list Case FOLDERID_ that can be read in Registry 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\
        Case FOLDERID_ProgramData: rv = PathOfRegShellFolder(LookInLocalMachine, "Common AppData")
        Case FOLDERID_PublicDesktop: rv = PathOfRegShellFolder(LookInLocalMachine, "Common Desktop")
        Case FOLDERID_CommonStartup: rv = PathOfRegShellFolder(LookInLocalMachine, "Common Startup")
        
        'Values to be found in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
        'Here a list Case FOLDERID_ that can be read in Registry 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\
        'The names corresponding are to be found direct in the Registry with using Regedit.
        'This is how my code was working before to use SHGetKnownFolderPath and I had no bad surprise.
        'The numbers 0 to 21 corresponds to my old Enum in PhilUtils for GetSpecialFolder.
        Case FOLDERID_RoamingAppData: rv = PathOfRegShellFolder(LookInCurrentUser, "AppData")  ' 0
        Case FOLDERID_LocalAppData: rv = PathOfRegShellFolder(LookInCurrentUser, "Local AppData")  ' 1
        Case FOLDERID_Videos: rv = PathOfRegShellFolder(LookInCurrentUser, "My Video")  ' 2
        Case FOLDERID_Pictures: rv = PathOfRegShellFolder(LookInCurrentUser, "My Pictures")  ' 3
        Case FOLDERID_Desktop: rv = PathOfRegShellFolder(LookInCurrentUser, "Desktop")  ' 4
        Case FOLDERID_History: rv = PathOfRegShellFolder(LookInCurrentUser, "History")  ' 5
        Case FOLDERID_NetHood: rv = PathOfRegShellFolder(LookInCurrentUser, "NetHood")  ' 6
        Case FOLDERID_Cookies: rv = PathOfRegShellFolder(LookInCurrentUser, "Cookies")  ' 7
        Case FOLDERID_Favorites: rv = PathOfRegShellFolder(LookInCurrentUser, "Favorites")  ' 8
        Case FOLDERID_SendTo: rv = PathOfRegShellFolder(LookInCurrentUser, "SendTo")  ' 9
        Case FOLDERID_StartMenu: rv = PathOfRegShellFolder(LookInCurrentUser, "Start Menu")  ' 10
        Case FOLDERID_Music: rv = PathOfRegShellFolder(LookInCurrentUser, "My Music")  ' 11
        Case FOLDERID_Programs: rv = PathOfRegShellFolder(LookInCurrentUser, "Programs")  ' 12
        Case FOLDERID_Recent: rv = PathOfRegShellFolder(LookInCurrentUser, "Recent")  ' 13
        Case FOLDERID_CDBurning: rv = PathOfRegShellFolder(LookInCurrentUser, "CD Burning")  ' 14
        Case FOLDERID_PrintHood: rv = PathOfRegShellFolder(LookInCurrentUser, "PrintHood")  ' 15
        Case FOLDERID_Startup: rv = PathOfRegShellFolder(LookInCurrentUser, "Startup")  ' 16
        Case FOLDERID_AdminTools: rv = PathOfRegShellFolder(LookInCurrentUser, "Administrative Tools")  ' 17
        Case FOLDERID_Documents: rv = PathOfRegShellFolder(LookInCurrentUser, "Personal")  ' 18
        Case FOLDERID_InternetCache: rv = PathOfRegShellFolder(LookInCurrentUser, "Cache")  ' 19
        Case FOLDERID_Templates: rv = PathOfRegShellFolder(LookInCurrentUser, "Templates")  ' 20
        Case FOLDERID_Fonts: rv = PathOfRegShellFolder(LookInCurrentUser, "Fonts")  ' 21
        Case FOLDERID_Downloads: rv = PathOfRegShellFolder(LookInCurrentUser, FOLDERID_Downloads) 'new, this will answer on new computers and stay empty on old ones. It is actually not Translated because New and contains the GUID in the Registry of new Computers.
    End Select
    
    PathOfRegShellFolderTranslateGUIDtoOldName = rv
End Function

Private Function PathOfRegShellFolder(LookInCurrentUser As Boolean, ValueName As String) As String
    Dim KeyRoot As Long
    If LookInCurrentUser Then
        KeyRoot = Registry.HKEY_CURRENT_USER
    Else
        KeyRoot = Registry.HKEY_LOCAL_MACHINE
    End If
    PathOfRegShellFolder = Registry.GetRegValue("", KeyRoot, "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\", ValueName)
End Function

Private Property Get Fso()
    On Error Resume Next
    If myFso Is Nothing Then
        Set myFso = CreateObject("Scripting.FileSystemObject")
    End If
    If Err.Number <> 0 Then
        Set Fso = Nothing 'Be shure it does not stay as Empty
    End If
    On Error GoTo 0
    Set Fso = myFso
End Property

Private Function FolderExists(Path As String)
    On Error Resume Next
    FolderExists = Fso.FolderExists(Path)
End Function

Private Property Get Registry() As Registry
    If myRegistry Is Nothing Then Set myRegistry = New Registry
    Set Registry = myRegistry
End Property
'''''''''''''''
'End API Calls:
'''''''''''''''
'''''''''
'End API:
'''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'And now for easiness in call from the Applications using this Class,
'for they do not have to define every Const that is already defined here:
'Properties on the most used Know Folders:
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Windows() As String
    Windows = PathOfGUID(FOLDERID_Windows)
End Property

Public Property Get System() As String
    System = PathOfGUID(FOLDERID_System)
End Property

Public Property Get SystemX86() As String
    SystemX86 = PathOfGUID(FOLDERID_SystemX86)
End Property

Public Property Get ProgramFiles() As String
    ProgramFiles = PathOfGUID(FOLDERID_ProgramFiles)
End Property

Public Property Get ProgramFilesX86() As String
    ProgramFilesX86 = PathOfGUID(FOLDERID_ProgramFilesX86)
End Property

Public Property Get ProgramFilesX64() As String
    ProgramFilesX64 = PathOfGUID(FOLDERID_ProgramFilesX64)
End Property

Public Property Get ProgramFilesCommon() As String
    ProgramFilesCommon = PathOfGUID(FOLDERID_ProgramFilesCommon)
End Property

Public Property Get ProgramFilesCommonX86() As String
    ProgramFilesCommonX86 = PathOfGUID(FOLDERID_ProgramFilesCommonX86)
End Property

Public Property Get ProgramFilesCommonX64() As String
    ProgramFilesCommonX64 = PathOfGUID(FOLDERID_ProgramFilesCommonX64)
End Property

Public Property Get ProgramData() As String
    ProgramData = PathOfGUID(FOLDERID_ProgramData)
End Property

Public Property Get PublicDesktop() As String
    PublicDesktop = PathOfGUID(FOLDERID_PublicDesktop)
End Property

Public Property Get CommonStartup() As String
    CommonStartup = PathOfGUID(FOLDERID_CommonStartup)
End Property

Public Property Get AdminTools() As String
    AdminTools = PathOfGUID(FOLDERID_AdminTools)
End Property

Public Property Get CDBurning() As String
    CDBurning = PathOfGUID(FOLDERID_CDBurning)
End Property

Public Property Get Cookies() As String
    Cookies = PathOfGUID(FOLDERID_Cookies)
End Property

Public Property Get Desktop() As String
    Desktop = PathOfGUID(FOLDERID_Desktop)
End Property

Public Property Get Documents() As String
    Documents = PathOfGUID(FOLDERID_Documents)
End Property

Public Property Get Downloads() As String
    Downloads = PathOfGUID(FOLDERID_Downloads)
End Property

Public Property Get Favorites() As String
    Favorites = PathOfGUID(FOLDERID_Favorites)
End Property

Public Property Get Fonts() As String
    Fonts = PathOfGUID(FOLDERID_Fonts)
End Property

Public Property Get History() As String
    History = PathOfGUID(FOLDERID_History)
End Property

Public Property Get InternetCache() As String
    InternetCache = PathOfGUID(FOLDERID_InternetCache)
End Property

Public Property Get LocalAppData() As String
    LocalAppData = PathOfGUID(FOLDERID_LocalAppData)
End Property

Public Property Get Music() As String
    Music = PathOfGUID(FOLDERID_Music)
End Property

Public Property Get NetHood() As String
    NetHood = PathOfGUID(FOLDERID_NetHood)
End Property

Public Property Get Pictures() As String
    Pictures = PathOfGUID(FOLDERID_Pictures)
End Property

Public Property Get PrintHood() As String
    PrintHood = PathOfGUID(FOLDERID_PrintHood)
End Property

Public Property Get Programs() As String
    Programs = PathOfGUID(FOLDERID_Programs)
End Property

Public Property Get Recent() As String
    Recent = PathOfGUID(FOLDERID_Recent)
End Property

Public Property Get RoamingAppData() As String
    RoamingAppData = PathOfGUID(FOLDERID_RoamingAppData)
End Property

Public Property Get SendTo() As String
    SendTo = PathOfGUID(FOLDERID_SendTo)
End Property

Public Property Get StartMenu() As String
    StartMenu = PathOfGUID(FOLDERID_StartMenu)
End Property

Public Property Get Startup() As String
    Startup = PathOfGUID(FOLDERID_Startup)
End Property

Public Property Get Templates() As String
    Templates = PathOfGUID(FOLDERID_Templates)
End Property

Public Property Get TemporaryFolder() As String
    TemporaryFolder = PathOfGUID(FOLDERID_TemporaryFolder)
End Property

Public Property Get Videos() As String
    Videos = PathOfGUID(FOLDERID_Videos)
End Property

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'End Properties on the most used Know Folders:
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
