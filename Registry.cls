VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Registry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'Todo #If VBA7 Then ... and implement the API calls correctly for VBA7 LongPtr etc
'byVal Public params done 20171014 Bir Himachal Pradesh India
'24.05.2010 Philippe Hollmuller (philippe.hollmuller@gmail.com) retravaillé le 22.08.2018 pour Ansi Unicode
'Class for reading writing windows registry with error managment.
'You are free to use this Class in your applications but not to sell the source code
'Use:
'Dim regRW As Registry
'Set regRW = New Registry
'Dim Val As String
'Dim ComputerName As String
'ComputerName = "" 'Local machine
''ComputerName = "TheRemoteComputerName" 'Works only for systems bigger than Win98 and if User has right on the remote computer
''Computername can be "" for local machine or a name of a computer on the network
'Val = regRW.GetRegValue("Computername", HKEY_CURRENT_USER, "Test1\test2\haha", "KeyName")
'if regRW.ErrorNumber <> 0 then
'    MsgBox regRW.ErrorDescription
'End If
'see http://www.vbaexpress.com/forum/archive/index.php/t-6557.html

'Types Definition
Private Type SECURITY_ATTRIBUTES
    nLength As Long
    lpSecurityDescriptor As Long
    bInheritHandle As Long
End Type

'API Declarations
'pour fermer la connection à la base de registre distante
Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long

'declare AW ansi unicode ok
'Ansi
Private Declare Function RegQueryValueExA Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, ByRef lpType As Long, ByVal lpData As String, ByRef lpcbData As Long) As Long ' equalsBinaryTestAok
Private Declare Function RegSetValueExA Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, ByVal lpData As String, ByVal cbData As Long) As Long ' equalsBinaryTestAok
Private Declare Function RegDeleteValueA Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpValueName As String) As Long ' equalsBinaryTestAok
Private Declare Function RegCreateKeyExA Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal Reserved As Long, ByVal lpClass As String, ByVal dwOptions As Long, ByVal samDesired As Long, lpSecurityAttributes As SECURITY_ATTRIBUTES, phkResult As Long, lpdwDisposition As Long) As Long ' equalsBinaryTestAok
Private Declare Function RegDeleteKeyA Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpSubKey As String) As Long ' equalsBinaryTestAok
'pour se connecter à une base de regitre distante
Private Declare Function RegConnectRegistryA Lib "advapi32.dll" (ByVal lpMachineName As String, ByVal hKey As Long, phkResult As Long) As Long ' equalsBinaryTestAok
'pour lister les sous-clé d'une ruche
Private Declare Function RegEnumKeyExA Lib "advapi32.dll" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, lpcbName As Long, ByVal lpReserved As Long, ByVal lpClass As String, lpcbClass As Long, lpftLastWriteTime As Any) As Long ' equalsBinaryTestAok no need cause received memory
'pour lister les valeurs ruche
Private Declare Function RegEnumValueA Lib "advapi32.dll" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpValueName As String, lpcbValueName As Long, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long ' equalsBinaryTestAok no need cause received memory
'ouvre une clé pour savoir si elle est valide
Private Declare Function RegOpenKeyA Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpSubKey As String, phkResult As Long) As Long ' equalsBinaryTestAok

'Unicode
Private Declare Function RegQueryValueExW Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, ByRef lpType As Long, ByVal lpData As String, ByRef lpcbData As Long) As Long
Private Declare Function RegSetValueExW Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, ByVal lpData As String, ByVal cbData As Long) As Long
Private Declare Function RegDeleteValueW Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpValueName As String) As Long
Private Declare Function RegCreateKeyExW Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal Reserved As Long, ByVal lpClass As String, ByVal dwOptions As Long, ByVal samDesired As Long, lpSecurityAttributes As SECURITY_ATTRIBUTES, phkResult As Long, lpdwDisposition As Long) As Long
Private Declare Function RegDeleteKeyW Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpSubKey As String) As Long
'pour se connecter à une base de regitre distante
Private Declare Function RegConnectRegistryW Lib "advapi32.dll" (ByVal lpMachineName As String, ByVal hKey As Long, phkResult As Long) As Long
'pour lister les sous-clé d'une ruche
Private Declare Function RegEnumKeyExW Lib "advapi32.dll" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, lpcbName As Long, ByVal lpReserved As Long, ByVal lpClass As String, lpcbClass As Long, lpftLastWriteTime As Any) As Long
'pour lister les valeurs ruche
Private Declare Function RegEnumValueW Lib "advapi32.dll" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpValueName As String, lpcbValueName As Long, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long
'ouvre une clé pour savoir si elle est valide
Private Declare Function RegOpenKeyW Lib "advapi32.dll" (ByVal hKey As Long, ByVal lpSubKey As String, phkResult As Long) As Long
'declare AW ansi unicode ok
   

'Constants Definition
Private Const SYNCHRONIZE As Long = &H100000
Private Const STANDARD_RIGHTS_ALL As Long = &H1F0000
Private Const KEY_QUERY_VALUE As Long = &H1&
Private Const KEY_SET_VALUE As Long = &H2&
Private Const KEY_CREATE_LINK As Long = &H20&
Private Const KEY_CREATE_SUB_KEY As Long = &H4&
Private Const KEY_ENUMERATE_SUB_KEYS As Long = &H8&
Private Const KEY_EVENT As Long = &H1&
Private Const KEY_NOTIFY As Long = &H10&
Private Const READ_CONTROL As Long = &H20000
Private Const STANDARD_RIGHTS_READ As Long = (READ_CONTROL)
Private Const STANDARD_RIGHTS_WRITE As Long = (READ_CONTROL)
Private Const KEY_ALL_ACCESS As Long = ((STANDARD_RIGHTS_ALL Or KEY_QUERY_VALUE Or KEY_SET_VALUE Or KEY_CREATE_SUB_KEY Or KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY Or KEY_CREATE_LINK) And (Not SYNCHRONIZE))
Private Const KEY_READ As Long = ((STANDARD_RIGHTS_READ Or KEY_QUERY_VALUE Or KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY) And (Not SYNCHRONIZE))
Private Const KEY_EXECUTE As Long = (KEY_READ)
Private Const KEY_WRITE As Long = ((STANDARD_RIGHTS_WRITE Or KEY_SET_VALUE Or KEY_CREATE_SUB_KEY) And (Not SYNCHRONIZE))
Private Const REG_CREATED_NEW_KEY As Long = &H1&
Private Const REG_DWORD_BIG_ENDIAN As Long = 5
Private Const REG_DWORD_LITTLE_ENDIAN As Long = 4
Private Const REG_FULL_RESOURCE_DESCRIPTOR As Long = 9
Private Const REG_LINK As Long = 6
Private Const REG_NONE As Long = 0
Private Const REG_NOTIFY_CHANGE_ATTRIBUTES As Long = &H2&
Private Const REG_NOTIFY_CHANGE_LAST_SET As Long = &H4&
Private Const REG_NOTIFY_CHANGE_NAME As Long = &H1&
Private Const REG_NOTIFY_CHANGE_SECURITY As Long = &H8&
Private Const REG_OPTION_BACKUP_RESTORE As Long = 4
Private Const REG_OPTION_CREATE_LINK As Long = 2
Private Const REG_OPTION_NON_VOLATILE As Long = 0
Private Const REG_OPTION_RESERVED As Long = 0
Private Const REG_OPTION_VOLATILE As Long = 1
Private Const REG_LEGAL_CHANGE_FILTER As Long = (REG_NOTIFY_CHANGE_NAME Or REG_NOTIFY_CHANGE_ATTRIBUTES Or REG_NOTIFY_CHANGE_LAST_SET Or REG_NOTIFY_CHANGE_SECURITY)
Private Const REG_LEGAL_OPTION As Long = (REG_OPTION_RESERVED Or REG_OPTION_NON_VOLATILE Or REG_OPTION_VOLATILE Or REG_OPTION_CREATE_LINK Or REG_OPTION_BACKUP_RESTORE)
Private Const BUFFER_Size As Long = 255
Private Const ERROR_NO_MORE_ITEMS As Long = 259&

Private Const MILLION_1 As Double = 1000000 'To split big String numbers DWORD OR QWORD and make double buffering

'Private attributes:
Private myErrorNumber As Long
Private myErrorDescription As String

'Properties

Public Property Get HKEY_CLASSES_ROOT() As Long
    HKEY_CLASSES_ROOT = &H80000000
End Property
Public Property Get HKEY_CURRENT_USER() As Long
    HKEY_CURRENT_USER = &H80000001
End Property
Public Property Get HKEY_LOCAL_MACHINE() As Long
    HKEY_LOCAL_MACHINE = &H80000002
End Property
Public Property Get HKEY_USERS() As Long
    HKEY_USERS = &H80000003
End Property
Public Property Get HKEY_CURRENT_CONFIG() As Long
    HKEY_CURRENT_CONFIG = &H80000005
End Property

Public Property Get REG_BINARY() As Long
    REG_BINARY = 3
End Property
Public Property Get REG_DWORD() As Long
    REG_DWORD = 4 'A DWORD is a 32-bit unsigned integer (range: 0 through 4294967295 decimal). Because a DWORD is unsigned, its first bit (Most Significant Bit (MSB)) is not reserved for signing.
End Property
Public Property Get REG_QWORD() As Long
    REG_QWORD = 11 'A QWORD is a 64-bit unsigned integer (range: 0 through 18446744073709551615. Because a QWORD is unsigned, its first bit (Most Significant Bit (MSB)) is not reserved for signing.
End Property
Public Property Get REG_SZ() As Long
    REG_SZ = 1
End Property
Public Property Get REG_MULTI_SZ() As Long
    REG_MULTI_SZ = 7
End Property
Public Property Get REG_EXPAND_SZ() As Long
    REG_EXPAND_SZ = 2
End Property

Public Property Get CALL_UNICODE() As Long
    CALL_UNICODE = 1
End Property
Public Property Get CALL_ANSI() As Long
    CALL_ANSI = 2
End Property

Public Property Get ErrorNumber() As Long
    ErrorNumber = myErrorNumber
End Property 'ok 22.05.2010

Public Property Get ErrorDescription() As String
    ErrorDescription = myErrorDescription
End Property 'ok 22.05.2010

'Functions
Public Function KeyRootAsString(ByVal KeyRoot As Long) As String
    Select Case KeyRoot
        Case HKEY_CLASSES_ROOT
            KeyRootAsString = "HKEY_CLASSES_ROOT"
        Case HKEY_CURRENT_CONFIG
            KeyRootAsString = "HKEY_CURRENT_CONFIG"
        Case HKEY_CURRENT_USER
            KeyRootAsString = "HKEY_CURRENT_USER"
        Case HKEY_LOCAL_MACHINE
            KeyRootAsString = "HKEY_LOCAL_MACHINE"
        Case HKEY_USERS
            KeyRootAsString = "HKEY_USERS"
        Case Else
            KeyRootAsString = CStrNotNull(KeyRoot)
    End Select
End Function 'ok 19.05.2010

Public Function KeyRootFromString(ByVal keyRootStr As String) As Long
    Select Case Trim(keyRootStr)
        Case "HKEY_CLASSES_ROOT"
            KeyRootFromString = HKEY_CLASSES_ROOT
        Case "HKEY_CURRENT_CONFIG"
            KeyRootFromString = HKEY_CURRENT_CONFIG
        Case "HKEY_CURRENT_USER"
            KeyRootFromString = HKEY_CURRENT_USER
        Case "HKEY_LOCAL_MACHINE"
            KeyRootFromString = HKEY_LOCAL_MACHINE
        Case "HKEY_USERS"
            KeyRootFromString = HKEY_USERS
        Case Else
            KeyRootFromString = 0
    End Select
End Function 'ok 19.05.2010

Public Function ValTypeAsString(ByVal valType As Long) As String
    Select Case valType
        Case REG_BINARY
            ValTypeAsString = "REG_BINARY"
        Case REG_DWORD
            ValTypeAsString = "REG_DWORD"
        Case REG_QWORD
            ValTypeAsString = "REG_QWORD"
        Case REG_SZ
            ValTypeAsString = "REG_SZ"
        Case REG_MULTI_SZ
            ValTypeAsString = "REG_MULTI_SZ"
        Case REG_EXPAND_SZ
            ValTypeAsString = "REG_EXPAND_SZ"
        Case Else
            ValTypeAsString = CStrNotNull(valType)
    End Select
End Function 'ok 23.05.2010

Public Function ValTypeFromString(ByVal valTypeStr As String) As Long
    Select Case Trim(valTypeStr)
        Case "REG_BINARY"
            ValTypeFromString = REG_BINARY
        Case "REG_DWORD"
            ValTypeFromString = REG_DWORD
        Case "REG_QWORD"
            ValTypeFromString = REG_QWORD
        Case "REG_SZ"
            ValTypeFromString = REG_SZ
        Case "REG_MULTI_SZ"
            ValTypeFromString = REG_MULTI_SZ
        Case "REG_EXPAND_SZ"
            ValTypeFromString = REG_EXPAND_SZ
        Case Else
            ValTypeFromString = 0
    End Select
End Function 'ok 19.05.2010

'Private use to Connect to a computer's registry, local computer if name is empty ""
Private Function ConnectRegistry(ComputerName As String, ByVal KeyRoot As Long, _
                                 ByRef hKeyResult As Long, FunctionName As String, Path As String, ByRef callUnicodeAnsi As Long) As Boolean
    On Error Resume Next
    
    myErrorNumber = 0
    myErrorDescription = ""
    Dim errSuffix As String
    Dim rv As Long
    rv = 1
    callUnicodeAnsi = CALL_UNICODE
    rv = RegConnectRegistryW(ByVal StrConv(ComputerName, vbUnicode), ByVal CLng(KeyRoot), hKeyResult)
    If (Not (rv = 0)) Or hKeyResult = 0 Then
        callUnicodeAnsi = CALL_ANSI
        rv = 1
        Dim sComputerName As String
        sComputerName = ComputerName 'keep for eventually UnicodeLoss
        rv = RegConnectRegistryA(ByVal ComputerName, ByVal CLng(KeyRoot), hKeyResult)
        If StrComp(ComputerName, sComputerName, vbBinaryCompare) <> 0 Then
            errSuffix = " (trying to access unicode Path using Ansi System function RegConnectRegistryA)"
            ComputerName = sComputerName ' equalsBinaryTestAok 'fix UnicodeLoss
            If rv = 0 Then
                rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
            End If
        End If
    End If
   
    'l'api renvoie 0 si la connexion a pu être établi (cela évite de faire un ping)
    If rv = 0 And (hKeyResult <> 0) Then
        ConnectRegistry = True
    Else
        ConnectRegistry = False
        If hKeyResult = 0 And rv = 0 Then
            myErrorNumber = 101
            myErrorDescription = "Registry." & FunctionName & ": Registry ConnectRegistry \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: RegConnectRegistry returned no Key" & errSuffix
        Else
            myErrorNumber = rv
            myErrorDescription = "Registry." & FunctionName & ": Registry ConnectRegistry \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & WinErrorAsString(rv) & errSuffix
        End If
    End If
    
    If Err.Number <> 0 Then
        ConnectRegistry = False
        myErrorNumber = Err.Number
        myErrorDescription = "Registry." & FunctionName & ": ConnectRegistry \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & Err.Description & errSuffix
    End If
End Function 'ok 19.05.2010


Private Function OpenKey(hKeyResult As Long, Path As String, hKeyTmp As Long, KeyRoot As Long, _
                         ComputerName As String, FunctionName As String, callUnicodeAnsi As Long) As Boolean
    On Error Resume Next
    Dim rv As Long
    rv = 1
    Dim errSuffix As String
    If callUnicodeAnsi = CALL_UNICODE Then
        rv = RegOpenKeyW(ByVal hKeyResult, ByVal StrConv(Path, vbUnicode), hKeyTmp)
    Else ' callUnicodeAnsi = CALL_ANSI
        Dim sPath As String
        sPath = Path
        rv = RegOpenKeyA(ByVal hKeyResult, ByVal Path, hKeyTmp)
        If StrComp(Path, sPath, vbBinaryCompare) <> 0 Then
            errSuffix = " (trying to access unicode Path using Ansi System function RegConnectRegistryA)"
            Path = sPath ' equalsBinaryTestAok
            If rv = 0 Then
                rv = 2 'Path not found 'sould not appen
            End If
            If Not hKeyTmp = 0 Then
                RegCloseKey hKeyTmp
                hKeyTmp = 0
            End If
        End If
    End If
    'l'api renvoie 0 si la connexion a pu être établi (cela évite de faire un ping)
    If rv = 0 And (hKeyTmp <> 0) Then
        OpenKey = True
    Else
        OpenKey = False
        If hKeyTmp = 0 Then
            myErrorDescription = "Registry." & FunctionName & ": Registry OpenKey \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: RegOpenKey returned no Key" & errSuffix
            myErrorNumber = 102
        Else
            myErrorDescription = "Registry." & FunctionName & ": Registry OpenKey \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & WinErrorAsString(rv) & errSuffix
            myErrorNumber = rv
        End If
    End If
    
    If Err.Number <> 0 Then
        OpenKey = False
        myErrorNumber = Err.Number
        myErrorDescription = "Registry." & FunctionName & ": Registry OpenKey \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & Err.Description & errSuffix
    End If
End Function 'ok 19.05.2010

'Fonctions
'Delete e Registry Key with all his contained Values
Public Function DeleteRegistryKey(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                                  ByVal Path As String) As Boolean
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    Dim errSuffix As String
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "DeleteRegistryKey", Path, callUnicodeAnsi) Then
        
        Dim hKeyTmp As Long
        If OpenKey(hKeyResult, Path, hKeyTmp, KeyRoot, ComputerName, "DeleteRegistryKey", callUnicodeAnsi) Then
            On Error Resume Next
            RegCloseKey hKeyTmp 'close the key Open by OpenKey
            
            Dim rv As Long
            If callUnicodeAnsi = CALL_UNICODE Then
                rv = RegDeleteKeyW(hKeyResult, StrConv(Path, vbUnicode))
            Else ' callUnicodeAnsi = CALL_ANSI
                If Not IsAnsi(Path) Then
                    'Want to delete a key on a Unicode Path on an Ansi Registry. Not possible, risk of deleting a key named ????
                    rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
                    errSuffix = " (trying to access unicode Path using Ansi System function RegDeleteKeyA)"
                Else
'                    Dim sPath As String
'                    sPath = Path
                    rv = RegDeleteKeyA(hKeyResult, Path)
'                    If Not Us.EqualsBinary(Path, sPath) Then
'                        errSuffix = " (trying to access unicode Path using Ansi System function RegConnectRegistryA)"
'                        Path = sPath ' equalsBinaryTestAok
'                        If rv = 0 Then
'                            rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
'                        End If
'                    End If
                End If
            End If
            
            If rv = 0 Then
                DeleteRegistryKey = True
            Else
                DeleteRegistryKey = False
                myErrorNumber = rv
                myErrorDescription = "Registry.DeleteRegistryKey \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & WinErrorAsString(myErrorNumber) & errSuffix
            End If
            
            If Err.Number <> 0 Then
                DeleteRegistryKey = False
                myErrorNumber = Err.Number
                myErrorDescription = "Registry.DeleteRegistryKey \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & Err.Description & errSuffix
            End If
        End If
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
End Function 'ok 19.05.2010

'Delete a Value from the Registry
Public Function DeleteValue(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                            ByVal Path As String, ByVal ValueName As String) As Boolean
    'le lien avec l'ordi distant ce fait grâce au hKeyResult qui est un paramettre de résultat
    'hKeyResult est le dernier paramettre de RegConnectRegistry et le premier de RegOpenKey
    
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    Dim errSuffix As String
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "DeleteValue", Path, callUnicodeAnsi) Then
        
        Dim hKeyTmp As Long
        If OpenKey(hKeyResult, Path, hKeyTmp, KeyRoot, ComputerName, "DeleteValue", callUnicodeAnsi) Then
            On Error Resume Next
            Dim rv As Long
            If callUnicodeAnsi = CALL_UNICODE Then
                rv = RegDeleteValueW(hKeyTmp, StrConv(ValueName, vbUnicode))
            Else ' callUnicodeAnsi = CALL_ANSI
                If Not IsAnsi(ValueName) Then
                    'Want to delete a Value on a Unicode Path on an Ansi Registry. Not possible, risk of deleting a key named ????
                    rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
                    errSuffix = " (trying to access unicode Path using Ansi System function RegDeleteValueA)"
                Else
'                    Dim sValueName As String
'                    sValueName = ValueName
                    rv = RegDeleteValueA(hKeyTmp, ValueName)
'                    If Not Us.EqualsBinary(ValueName, sValueName) Then
'                        errSuffix = " (trying to access unicode Path using Ansi System function RegConnectRegistryA)"
'                        ValueName = sValueName ' equalsBinaryTestAok
'                        If rv = 0 Then 'sould not happen
'                            rv = 2 'Path not found
'                        End If
'                    End If
                End If
            End If
            If rv = 0 Then
                DeleteValue = True
            Else
                DeleteValue = False
                myErrorNumber = rv
                myErrorDescription = "Registry.DeleteValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & WinErrorAsString(myErrorNumber) & errSuffix
            End If
            
            If Err.Number <> 0 Then
                DeleteValue = False
                myErrorNumber = Err.Number
                myErrorDescription = "Registry.DeleteValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & Err.Description & errSuffix
            End If
            RegCloseKey hKeyTmp 'close the key Open by OpenKey
        End If
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
End Function 'ok 19.05.2010

'Creates a New Registry Key
Public Function CreateRegistryKey(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                                  ByVal Path As String) As Boolean
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "CreateRegistryKey", Path, callUnicodeAnsi) Then
        On Error Resume Next
        Dim hKeyTmp As Long
        Dim y As SECURITY_ATTRIBUTES
        Dim Operation As Long
        Dim rv As Long
        Dim errSuffix As Long
        If callUnicodeAnsi = CALL_UNICODE Then
            rv = RegCreateKeyExW(hKeyResult, StrConv(Path, vbUnicode), 0, StrConv("", vbUnicode), 0, KEY_ALL_ACCESS, y, hKeyTmp, Operation)
        Else ' callUnicodeAnsi = CALL_ANSI
            If Not IsAnsi(ComputerName) Or Not IsAnsi(Path) Then
                'Want to delete a Value on a Unicode Path on an Ansi Registry. Not possible, risk of deleting a key named ????
                rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
                myErrorNumber = 2 'File  not found
                errSuffix = " (trying to access unicode Path using Ansi System function RegCreateKeyExA)"
            Else
'                Dim sPath As String
'                sPath = Path
                rv = RegCreateKeyExA(hKeyResult, Path, 0, "", 0, KEY_ALL_ACCESS, y, hKeyTmp, Operation)
'                If Not Us.EqualsBinary(Path, sPath) Then
'                    errSuffix = " (trying to access unicode Path using Ansi System function RegConnectRegistryA)"
'                    Path = sPath ' equalsBinaryTestAok
'                    If rv = 0 Then
'                        rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
'                        DeleteRegistryKey ComputerName, keyRoot, Path
'                        myErrorNumber = 2 'File  not found
'                        myErrorDescription = WinApiError.WinErrorAsString(myErrorNumber)
'                    End If
'                End If
            End If
        End If
        If rv = 0 Then
            CreateRegistryKey = True
        Else
            CreateRegistryKey = False
            myErrorNumber = rv
            myErrorDescription = "Registry.CreateRegistryKey \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & WinErrorAsString(rv) & errSuffix
        End If
        
        If Err.Number <> 0 Then
            CreateRegistryKey = False
            myErrorNumber = Err.Number
            myErrorDescription = "Registry.CreateRegistryKey \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & Err.Description & errSuffix
        End If
        
        RegCloseKey hKeyTmp 'close the key Open by RegCreateKeyEx
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
End Function 'ok 19.05.2010

'Get a specific Registry Value (to access the Default Registry Key Value set ValueName parameter as "")
Public Function GetRegValType(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                              ByVal Path As String, ByVal ValueName As String) As Long
    Dim rv As Long
    GetRegValue ComputerName, KeyRoot, Path, ValueName, rv
    GetRegValType = rv
End Function 'ok 23.05.2010

'Get a specific Registry Value (to access the Default Registry Key Value set ValueName parameter as "")
Public Function GetRegValue(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                            ByVal Path As String, ByVal ValueName As String, Optional ByRef valType As Long = 1) As String '1  REG_SZ
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "GetRegValue", Path, callUnicodeAnsi) Then
        
        Dim hKeyTmp As Long
        If OpenKey(hKeyResult, Path, hKeyTmp, KeyRoot, ComputerName, "GetRegValue", callUnicodeAnsi) Then
            On Error Resume Next
            Dim keyValType As Long
            Dim KeyValSize As Long
            Dim KeyVal As String
            Dim tmpVal As String
            Dim i As Integer
            Dim rv As Long
            Dim errSuffix As String
            tmpVal = String(1024, 0)
            KeyValSize = 1024
            
            If callUnicodeAnsi = CALL_UNICODE Then
                rv = RegQueryValueExW(hKeyTmp, StrConv(ValueName, vbUnicode), 0, keyValType, tmpVal, KeyValSize)
            Else ' callUnicodeAnsi = CALL_ANSI
                Dim sValueName As String
                sValueName = ValueName
                Dim sTmpVal As String
                sTmpVal = tmpVal
                rv = RegQueryValueExA(hKeyTmp, ValueName, 0, keyValType, tmpVal, KeyValSize)
                If StrComp(ValueName, sValueName, vbBinaryCompare) <> 0 Then
                    errSuffix = " (trying to access unicode Path using Ansi System function RegConnectRegistryA)"
                    ValueName = sValueName ' equalsBinaryTestAok
                    If rv = 0 Then
                        rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
                        myErrorNumber = 2 'File  not found
                    End If
                    If StrComp(tmpVal, sTmpVal, vbBinaryCompare) <> 0 Then
                        tmpVal = sTmpVal ' equalsBinaryTestAok
                    End If
                End If
            End If
            If rv = 0 Then
                If KeyValSize > 0 Then
                    If (callUnicodeAnsi = CALL_UNICODE) And ((keyValType = REG_SZ) Or (keyValType = REG_MULTI_SZ) Or (keyValType = REG_EXPAND_SZ)) Then
                        tmpVal = Left(tmpVal, KeyValSize)
                        tmpVal = StrConv(tmpVal, vbFromUnicode)
                        If (Asc(Mid(tmpVal, Len(tmpVal), 1)) = 0) Then
                            tmpVal = Left(tmpVal, Len(tmpVal) - 1)
                        Else
                            tmpVal = Left(tmpVal, KeyValSize)
                        End If
                        
                    Else ' callUnicodeAnsi = CALL_ANSI
                        If (Asc(Mid(tmpVal, KeyValSize, 1)) = 0) Then
                            tmpVal = Left(tmpVal, KeyValSize - 1)
                        Else
                            tmpVal = Left(tmpVal, KeyValSize)
                        End If
                    End If
                Else
                    tmpVal = ""
                End If
                
                Select Case keyValType
                    Case REG_DWORD, REG_QWORD
                        Dim valMillionCount As Double 'pour double buffering valeur en cas de QWord et DWORD, non signés de 32 et 64 bits
                        Dim valLow As Double          'pour double buffering valeur en cas de QWord et DWORD, non signés de 32 et 64 bits
                        valLow = 0
                        For i = Len(tmpVal) To 1 Step -1
                            If valLow * 256 > 99999999# Then
                                Dim milc As Double
                                milc = Fix(valLow / MILLION_1)
                                valLow = valLow - (milc * MILLION_1)
                                valMillionCount = valMillionCount + milc
                            End If
                            valMillionCount = valMillionCount * 256
                            valLow = valLow * 256
                            valLow = valLow + Asc(Mid(tmpVal, i, 1))
                        Next i
                        
                        milc = Fix(valLow / MILLION_1)
                        valLow = valLow - (milc * MILLION_1)
                        valMillionCount = valMillionCount + milc
                                
                        Dim ErrMsg As String
                        'set KeyVal:
                        If Not DblToString(valLow, valMillionCount, KeyVal, ErrMsg) Then
                            myErrorNumber = 1
                            myErrorDescription = "Registry.GetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: Error by transforming Values to string."
                        Else
                            valType = keyValType
                        End If
                    Case REG_BINARY
                        Dim valMillionCount1 As Double 'pour double buffering valeur en cas de QWord et DWORD, non signés de 32 et 64 bits
                        Dim valLow1 As Double          'pour double buffering valeur en cas de QWord et DWORD, non signés de 32 et 64 bits
                        valLow1 = 0
                        For i = Len(tmpVal) To 1 Step -1
                            If valLow1 * 16 > 99999999# Then
                                Dim milc1 As Double
                                milc1 = Fix(valLow1 / MILLION_1)
                                valLow1 = valLow1 - (milc1 * MILLION_1)
                                valMillionCount1 = valMillionCount1 + milc1
                            End If
                            valMillionCount1 = valMillionCount1 * 16
                            valLow1 = valLow1 * 16
                            valLow1 = valLow1 + Asc(Mid(tmpVal, i, 1))
                        Next i
                        
                        milc1 = Fix(valLow1 / MILLION_1)
                        valLow1 = valLow1 - (milc1 * MILLION_1)
                        valMillionCount1 = valMillionCount1 + milc1
                                
                        Dim ErrMsg1 As String
                        'set KeyVal:
                        If Not DblToString(valLow1, valMillionCount1, KeyVal, ErrMsg1) Then
                            myErrorNumber = 1
                            myErrorDescription = "Registry.GetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: Error by transforming Values to string." & errSuffix
                        Else
                            valType = keyValType
                        End If
                    Case Else
                        KeyVal = tmpVal
                        valType = keyValType
                End Select
            Else
                KeyVal = ""
                myErrorNumber = rv
                myErrorDescription = "Registry.GetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & WinErrorAsString(myErrorNumber) & errSuffix
            End If
            
            If Err.Number <> 0 Then
                KeyVal = ""
                myErrorNumber = Err.Number
                myErrorDescription = "Registry.GetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & Err.Description & errSuffix
            End If
            
            GetRegValue = KeyVal 'return Value
            
            RegCloseKey hKeyTmp 'close the key Open by OpenKey
        End If
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
End Function 'ok 22.05.2010

'Tests if a key exists by key Path
Public Function ExistsKey(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                          ByVal Path As String) As Boolean
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "ExistsKey", Path, callUnicodeAnsi) Then
        Dim hKeyTmp As Long
        If OpenKey(hKeyResult, Path, hKeyTmp, KeyRoot, ComputerName, "ExistsKey", callUnicodeAnsi) Then
            ExistsKey = True
            RegCloseKey hKeyTmp 'close the key Open by OpenKey
        End If
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
End Function 'ok 24.05.2010

'Tests if a Value name exists in the key Path
Public Function ExistsValue(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                            ByVal Path As String, ByVal ValueName As String) As Boolean
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "ExistsValue", Path, callUnicodeAnsi) Then
        
        Dim hKeyTmp As Long
        If OpenKey(hKeyResult, Path, hKeyTmp, KeyRoot, ComputerName, "ExistsValue", callUnicodeAnsi) Then
            On Error Resume Next
            Dim keyValType As Long
            Dim KeyValSize As Long
            Dim tmpVal As String
            
            tmpVal = String(1024, 0)
            KeyValSize = 1024
            
            If callUnicodeAnsi = CALL_UNICODE Then
                If RegQueryValueExW(hKeyTmp, StrConv(ValueName, vbUnicode), 0, keyValType, tmpVal, KeyValSize) = 0 Then
                    ExistsValue = True
                End If
            Else ' callUnicodeAnsi = CALL_ANSI
                Dim sValueName As String
                sValueName = ValueName
                Dim sTmpVal As String
                sTmpVal = tmpVal
                Dim Ret As Long
                Ret = RegQueryValueExA(hKeyTmp, ValueName, 0, keyValType, tmpVal, KeyValSize)
                If Not StrComp(ValueName, sValueName, vbBinaryCompare) <> 0 Then
                    'errSuffix = " (trying to access unicode Path using Ansi System function RegQueryValueExA)"
                    ValueName = sValueName ' equalsBinaryTestAok
                    If Ret = 0 Then
                        Ret = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
                    End If
                End If
                If Ret = 0 Then
                    ExistsValue = True
                End If
            End If
            
            RegCloseKey hKeyTmp 'close the key Open by OpenKey
        End If
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
End Function 'ok 24.05.2010

'Create or Modify a Registry Value (to access the Default Registry Key Value set ValueName parameter as "")
Public Function SetRegValue(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                            ByVal Path As String, ByVal ValueName As String, ByVal NewValue As String, _
                            Optional ByVal RegValType As Long = 1, _
                            Optional ByVal overwriteExixtingRegValType As Boolean = True) As Boolean '1  REG_SZ
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    Dim sValueName As String
    Dim sTmpVal As String
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "SetRegValue", Path, callUnicodeAnsi) Then
        
        Dim hKeyTmp As Long
        If OpenKey(hKeyResult, Path, hKeyTmp, KeyRoot, ComputerName, "SetRegValue", callUnicodeAnsi) Then
            On Error Resume Next
            Dim rv As Long
            Dim i As Integer
            Dim valMillionCount As Double 'pour double buffering valeur en cas de QWord et DWORD, non signés de 32 et 64 bits
            Dim valLow As Double          'pour double buffering valeur en cas de QWord et DWORD, non signés de 32 et 64 bits
            Dim keyValType As Long
            Dim KeyValSize As Long
            Dim oldRegValType As Long
            Dim tmpVal As String
            tmpVal = String(1024, 0)
            KeyValSize = 1024
            Dim existingVal As Boolean
            Dim errSuffix
            If callUnicodeAnsi = CALL_UNICODE Then
                rv = RegQueryValueExW(hKeyTmp, StrConv(ValueName, vbUnicode), 0, keyValType, tmpVal, KeyValSize)
            Else ' callUnicodeAnsi = CALL_ANSI
                If Not IsAnsi(ValueName) Then
                    'Want to set a key on a Unicode Path on an Ansi Registry. Not possible, risk of deleting a key named ????
                    rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
                    errSuffix = " (trying to access unicode Path using Ansi System function RegQueryValueExA)"
                Else
'                    sValueName = ValueName
'                    sTmpVal = tmpVal
                    rv = RegQueryValueExA(hKeyTmp, ValueName, 0, keyValType, tmpVal, KeyValSize)
'                    If Not Us.EqualsBinary(ValueName, sValueName) Then
'                       'errSuffix = " (trying to access unicode Path using Ansi System function RegQueryValueExA)"
'                        ValueName = sValueName ' equalsBinaryTestAok
'                        If rv = 0 Then
'                            rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
'                            errSuffix = " (trying to access unicode Path using Ansi System function RegQueryValueExA)"
'                        End If
'                        If Not Us.EqualsBinary(tmpVal, sTmpVal) Then
'                            tmpVal = sTmpVal ' equalsBinaryTestAok
'                        End If
'                    End If
                End If
            End If
                        
            oldRegValType = keyValType 'pour pouvoir récrire l'ancienne valeur en cas d'échec dépassement de capacité
            Select Case rv
                Case 0
                    existingVal = True
                Case 2
                    existingVal = False
                    keyValType = RegValType 'la valeur n'existe pas encore dans la registry
                Case Else 'Error
                    SetRegValue = False
                    myErrorNumber = rv
                    myErrorDescription = "Registry.SetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & WinErrorAsString(rv)
                    RegCloseKey hKeyTmp 'close the key Open by OpenKey
                    RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
                    Exit Function       'EXIT
            End Select
            
            If keyValType <> RegValType Then 'Différence entre existante dans la registry et
                                             'voulue par la fonction
                If overwriteExixtingRegValType Then
                    keyValType = RegValType
                Else
                    SetRegValue = False
                    myErrorNumber = rv
                    myErrorDescription = "Registry.SetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: RegistryValue already existing with a different type."
                    RegCloseKey hKeyTmp 'close the key Open by OpenKey
                    RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
                    Exit Function       'EXIT
                End If
            End If
            
            
            'Now do the writing depending on keyValType:
            
            Select Case keyValType
                Case REG_SZ, REG_MULTI_SZ, REG_EXPAND_SZ
                    tmpVal = NewValue
                Case REG_BINARY, REG_DWORD, REG_QWORD
                    Dim oldVal As String  'lire Valeur existante, err et errDesc  pour pouvoir revenir en arrière en cas de dépassement de capacité.?
                    Dim oldErrorDescription As String
                    Dim oldErrNr As Long
                    If existingVal Then
                        oldErrNr = ErrorNumber
                        oldErrorDescription = ErrorDescription
                        oldVal = Me.GetRegValue(ComputerName, KeyRoot, Path, ValueName) 'lire valeur avant d'écrire pour pouvoir revenir en arrière en cas de dépassement de capacité
                        If Me.ErrorNumber <> 0 Then
                            existingVal = False
                        End If
                        myErrorNumber = oldErrNr
                        myErrorDescription = oldErrorDescription
                    End If
                    
                    'préparation valeurs écriture
                    
                    Dim ErrMsg As String
                    If Not SetDWordQWordValueFromString(NewValue, valLow, valMillionCount, ErrMsg) Then
                        SetRegValue = False
                        myErrorNumber = 1
                        myErrorDescription = "Registry.SetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & NewValue & " is not " & IIf(keyValType = REG_DWORD, "DWORD", "QWORD") & ". " & ErrMsg
                        RegCloseKey hKeyTmp 'close the key Open by OpenKey
                        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
                        Exit Function       'EXIT
                    End If
                    tmpVal = ""
                    Dim loopLimit As Integer
                    Select Case keyValType
                        Case REG_DWORD
                            loopLimit = 3
                        Case REG_QWORD
                            loopLimit = 7
                        Case REG_BINARY
                            loopLimit = 7
                    End Select
                    
                    'Construct the string for RegSetValueEx DWORD or QWORD
                    For i = 0 To loopLimit
                        If keyValType = REG_BINARY Then
                            valLow = valLow + ((valMillionCount - (Fix(valMillionCount / 16) * 16)) * MILLION_1)
                            valMillionCount = Fix(valMillionCount / 16)
                            tmpVal = tmpVal & Chr(valLow - (Fix(valLow / 16) * 16))
                            valLow = Fix(valLow / 16)
                        Else
                            valLow = valLow + ((valMillionCount - (Fix(valMillionCount / 256) * 256)) * MILLION_1)
                            valMillionCount = Fix(valMillionCount / 256)
                            tmpVal = tmpVal & Chr(valLow - (Fix(valLow / 256) * 256))
                            valLow = Fix(valLow / 256)
                        End If
                    Next
                    If valLow > 0 Or valMillionCount > 0 Then
                        SetRegValue = False
                        myErrorNumber = 1
                        myErrorDescription = "Registry.SetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & NewValue & " is not " & IIf(keyValType = REG_DWORD, "DWORD", "QWORD") & ", overflow." & ErrMsg
                        RegCloseKey hKeyTmp 'close the key opened by OpenKey  'https://www.myenglishteacher.eu/blog/what-is-the-difference-between-open-and-is-opened/     see We can say ‘is opened’ when it’s done by someone. The shop is opened by the owner.
                        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
                        Exit Function       'EXIT
                    End If
                Case Else 'keyValType not implemented for write
                    SetRegValue = False
                    myErrorNumber = 1
                    myErrorDescription = "Registry.SetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: keyValType " & CStr(keyValType) & " not implemented existing in registry. To be implemented in Registry."
                    RegCloseKey hKeyTmp 'close the key Open by OpenKey
                    RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
                    Exit Function 'EXIT
            End Select
            
            'Ecriture
            If (callUnicodeAnsi = CALL_UNICODE) Then
                If ((keyValType = REG_SZ) Or (keyValType = REG_MULTI_SZ) Or (keyValType = REG_EXPAND_SZ)) Then
                    If (keyValType = REG_MULTI_SZ) Then
                        If Not (Right(tmpVal, Len(vbCrLf)) = vbCrLf) Then
                            tmpVal = tmpVal & vbCrLf
                        End If
                    End If
                    KeyValSize = Len(StrConv(tmpVal, vbUnicode))
                    rv = RegSetValueExW(hKeyTmp, StrConv(ValueName, vbUnicode), 0, keyValType, StrConv(tmpVal, vbUnicode), KeyValSize)
                Else
                
                
                
                    KeyValSize = Len(tmpVal)
                    rv = RegSetValueExW(hKeyTmp, StrConv(ValueName, vbUnicode), 0, keyValType, tmpVal, KeyValSize)
                End If
            Else ' callUnicodeAnsi = CALL_ANSI
                If (keyValType = REG_MULTI_SZ) Then
                    If Not (Right(tmpVal, Len(vbCrLf)) = vbCrLf) Then
                        tmpVal = tmpVal & vbCrLf
                    End If
                End If
                KeyValSize = Len(tmpVal)
                
                If Not IsAnsi(ValueName) Then
                    'Want to set a key on a Unicode Path on an Ansi Registry. Not possible, risk of deleting a key named ????
                    rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
                    errSuffix = " (trying to access unicode Path using Ansi System function RegQueryValueExA)"
                ElseIf Not IsAnsi(tmpVal) Then
                    'Want to set a key on a Unicode Path on an Ansi Registry. Not possible, risk of deleting a key named ????
                    rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
                    errSuffix = " (trying to set unicode Value using Ansi System function RegSetValueExA)"
                Else
'                    sValueName = ValueName
'                    sTmpVal = tmpVal
                    rv = RegSetValueExA(hKeyTmp, ValueName, 0, keyValType, tmpVal, KeyValSize)
'                    If Not Us.EqualsBinary(ValueName, sValueName) Then
'                        errSuffix = " (trying to set unicode Value using Ansi System function RegSetValueExA)"
'                        ValueName = sValueName ' equalsBinaryTestAok
'                        If rv = 0 Then
'                            rv = 2 'Path not found 'should not happen. If yes, it means anoter pat exists in registry including ???? caracters exactly at same place of our Path and functionA returned tis key
'                            DeleteValue ComputerName, keyRoot, Path, ValueName
'                        End If
'                        If Not Us.EqualsBinary(tmpVal, sTmpVal) Then
'                            tmpVal = sTmpVal ' equalsBinaryTestAok
'                        End If
'                    End If
                End If
            End If
            If rv = 0 Then
                Select Case keyValType                      'Relecture pour contrôle
                    Case REG_BINARY, REG_DWORD, REG_QWORD
                                                            'dépassement de capacité, valeur écrite correspond à valeur voulue??
                        Dim valInRegEqualsWantedVal As Boolean
                        oldErrNr = ErrorNumber
                        oldErrorDescription = ErrorDescription
                        Dim valLow1 As Double, valMillionCount1 As Double
                        Dim val1 As String
                        val1 = Me.GetRegValue(ComputerName, KeyRoot, Path, ValueName) 'Lire la valeur écrite auparavant
                        If Me.ErrorNumber <> 0 Then
                            SetRegValue = False
                            myErrorDescription = "Registry.SetRegValue read again: " & myErrorDescription
                            RegCloseKey hKeyTmp 'close the key Open by OpenKey
                            RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
                            Exit Function 'EXIT
                        End If
                        myErrorNumber = oldErrNr
                        myErrorDescription = oldErrorDescription
                        
                        If SetDWordQWordValueFromString(NewValue, valLow, valMillionCount, ErrMsg) Then
                            If SetDWordQWordValueFromString(val1, valLow1, valMillionCount1, ErrMsg) Then
                                valInRegEqualsWantedVal = ((valLow = valLow1) And _
                                                           (valMillionCount = valMillionCount1))
                            End If
                        End If
                        
                        If valInRegEqualsWantedVal Then
                            SetRegValue = True
                        Else
                            SetRegValue = False
                            If existingVal Then 'remettre l'ancienne valeur
                                Me.SetRegValue ComputerName, KeyRoot, Path, ValueName, oldVal, oldRegValType, overwriteExixtingRegValType
                            Else                'effacer la valeur faussement enregistrée
                                Me.DeleteValue ComputerName, KeyRoot, Path, ValueName
                            End If
                            myErrorNumber = 1
                            myErrorDescription = "Registry.SetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: overflow."
                            RegCloseKey hKeyTmp 'close the key Open by OpenKey
                            RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
                            Exit Function 'EXIT
                        End If
                        
                    Case Else 'setting a string Value, no control necessary
                        SetRegValue = True
                End Select
            Else
                SetRegValue = False
                myErrorNumber = rv
                myErrorDescription = "Registry.SetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & WinErrorAsString(rv) & errSuffix
            End If
            
            If Err.Number <> 0 Then
                SetRegValue = False
                myErrorNumber = Err.Number
                myErrorDescription = "Registry.SetRegValue \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & "\" & ValueName & " failed: " & Err.Description & errSuffix
            End If
                     
            RegCloseKey hKeyTmp 'close the key Open by OpenKey
        End If
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
End Function 'ok 22.05.2010

Public Function ListKeysIn(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                           ByVal Path As String) As Collection
    Dim rv As Collection
    Set rv = New Collection
    
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "ListKeysIn", Path, callUnicodeAnsi) Then
        
        Dim hKeyTmp As Long, cnt As Long, sName As String, Ret As Long
        
        cnt = 0
        If OpenKey(hKeyResult, Path, hKeyTmp, KeyRoot, ComputerName, "ListKeysIn", callUnicodeAnsi) Then
            On Error Resume Next
            
            If callUnicodeAnsi = CALL_UNICODE Then

                'crer un buffer
                Ret = 2 * BUFFER_Size
                sName = Space(Ret)
                
                'énumaire les sous-clé
                While RegEnumKeyExW(hKeyTmp, cnt, sName, Ret, ByVal 0&, vbNullString, ByVal 0&, ByVal 0&) <> ERROR_NO_MORE_ITEMS

                    'ajoute les sous clés
                    rv.Add (Left$(StrConv(sName, vbFromUnicode), Ret))
                    'prepare pour la clé suivante
                    Ret = 2 * BUFFER_Size
                    sName = Space(Ret)
                    cnt = cnt + 1
                Wend
            
            Else ' callUnicodeAnsi = CALL_ANSI

                'crer un buffer
                Ret = BUFFER_Size
                sName = Space(Ret)
                'énumaire les sous-clé
                While RegEnumKeyExA(hKeyTmp, cnt, sName, Ret, ByVal 0&, vbNullString, ByVal 0&, ByVal 0&) <> ERROR_NO_MORE_ITEMS
                    'ajoute les sous clés ' equalsBinaryTestAok no need cause received memory
                    rv.Add (Left$(sName, Ret))

                    'prepare pour la clé suivante
                    Ret = BUFFER_Size
                    sName = Space(Ret)
                    cnt = cnt + 1
                Wend
            End If
    
    
            RegCloseKey hKeyTmp 'close the key Open by OpenKey
        End If
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
    
    Set ListKeysIn = rv

    If Err.Number <> 0 Then
        myErrorNumber = Err.Number
        myErrorDescription = "Registry.ListKeysIn \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & Err.Description
    End If
End Function 'ok 22.05.2010

Public Function ListValuesIn(ByVal ComputerName As String, ByVal KeyRoot As Long, _
                             ByVal Path As String) As Collection
    Dim rv As Collection
    Set rv = New Collection
    
    Dim callUnicodeAnsi As Long
    Dim hKeyResult As Long
    If ConnectRegistry(ComputerName, KeyRoot, hKeyResult, "ListValuesIn", Path, callUnicodeAnsi) Then
        
        Dim hKeyTmp As Long, cnt As Long, sName As String, sData As String, Ret As Long, RetData As Long
            
        If OpenKey(hKeyResult, Path, hKeyTmp, KeyRoot, ComputerName, "ListValuesIn", callUnicodeAnsi) Then
            On Error Resume Next
            
            cnt = 0
            
            If callUnicodeAnsi = CALL_UNICODE Then
                'crer un buffer
                Ret = 2 * BUFFER_Size
                RetData = Ret
                sName = Space(Ret)
                sData = Space(RetData)
                
                'enumerate the values
                While RegEnumValueW(hKeyTmp, cnt, sName, Ret, 0, ByVal 0&, ByVal sData, RetData) <> ERROR_NO_MORE_ITEMS
                                                    
                    If Ret > 0 Then
                        sName = Left$(StrConv(sName, vbFromUnicode), Ret)
                    Else
                        sName = ""
                    End If
                    If RetData > 1 Then
                        sData = StrConv(Left$(sData, RetData - 1), vbFromUnicode)
                    Else
                        sData = ""
                    End If
                    
                    If sName <> "" Then
                        rv.Add sName
                    End If
                    
                    'prepare for next Value
                    Ret = 2 * BUFFER_Size
                    RetData = Ret
                    sName = Space(Ret)
                    sData = Space(RetData)
                    cnt = cnt + 1
                Wend
                
            Else ' callUnicodeAnsi = CALL_ANSI
                'crer un buffer
                Ret = BUFFER_Size
                RetData = Ret
                sName = Space(Ret)
                sData = Space(RetData)
                
                'enumerate the values
                While RegEnumValueA(hKeyTmp, cnt, sName, Ret, 0, ByVal 0&, ByVal sData, RetData) <> ERROR_NO_MORE_ITEMS
                     ' equalsBinaryTestAok no need cause received memory
                    If Ret > 0 Then
                        sName = Left$(sName, Ret)
                    Else
                        sName = ""
                    End If
                    If RetData > 1 Then
                        sData = Left$(sData, RetData - 1)
                    Else
                        sData = ""
                    End If
                    
                    If sName <> "" Then
                        rv.Add sName
                    End If
                    
                    'prepare for next Value
                    Ret = BUFFER_Size
                    RetData = Ret
                    sName = Space(Ret)
                    sData = Space(RetData)
                    cnt = cnt + 1
                Wend
            End If
            
            'Close the registry key
            RegCloseKey hKeyTmp 'close the key Open by OpenKey
        End If
        RegCloseKey hKeyResult 'close the key Open by ConnectRegistry
    End If
    
    Set ListValuesIn = rv

    If Err.Number <> 0 Then
        myErrorNumber = Err.Number
        myErrorDescription = "Registry.ListValuesIn \\" & ComputerName & "\" & KeyRootAsString(KeyRoot) & "\" & Path & " failed: " & Err.Description
    End If
End Function

'set les valeurs valLow et valMillionCount en fonction de la string d'entrée
Private Function SetDWordQWordValueFromString(s As String, _
                                              valLow As Double, valMillionCount As Double, _
                                              ErrMsg As String) As Boolean
On Error Resume Next
    'Test si cast en Cdbl possible:
    Dim d As Double
    d = CDbl(Trim(s))
    If Err.Number <> 0 Then
        ErrMsg = "PhilNetFiles.Registry.SetDWordQWordValueFromString Error: " & Err.Description
        SetDWordQWordValueFromString = False
        Exit Function 'EXIT ERROR
    End If
    If d < 0 Or Fix(d) <> d Then 'négatif ou contenand virgule
        ErrMsg = "PhilNetFiles.Registry.SetDWordQWordValueFromString Error: " & "Value < 0 is not a WORD, Word is unsigned Value."
        SetDWordQWordValueFromString = False
        Exit Function 'EXIT ERROR
    End If
    valLow = d  'd can be set from a big string like 1.2E+15
    valMillionCount = Fix(valLow / MILLION_1) 'split in buffers
    valLow = valLow - (valMillionCount * MILLION_1)
    
    SetDWordQWordValueFromString = True
    'si pas d'erreur, valLow contient la valeur s sous forme de double, ok si 1.7E17,
    'mais arrondi en virgule flottante si grand nombre en string passé en paramètre
    'dépassant 15 caractères formattés pour calculs sur dbl
    'limite sans double buffering sans perdre de précision: 999999999999999
    
    'RECHERCHE DE PRECISION:
    'peut être que la string passée contient un grand nombre pour un QWord 64 bits, calculer
    If WordStrToLowAndHighDbl(Trim(s), valLow, valMillionCount) Then
        SetDWordQWordValueFromString = True
    End If
    Err.Clear
End Function 'ok 22.05.2010

'Transformer un string en double
Private Function WordStrToLowAndHighDbl(s As String, valLow As Double, valMillionCount As Double) As Boolean
On Error Resume Next
    Dim v As Integer
    Dim i As Long
    
    Dim sLow As String, sMillionCount As String
    Dim numberMillion As Integer
    numberMillion = Len(CStr(MILLION_1)) - 1
    If Len(s) <= numberMillion Then
        sLow = s
    Else
        sLow = Right(s, numberMillion)
        sMillionCount = Left(s, Len(s) - Len(sLow))
    End If
    
    Dim sTmp As String
    Dim rv As Double
    Dim dLow As Double
    Dim dMillionCount As Double
    Dim lowIsSet As Boolean
    Dim MillionCountIsSet As Boolean
    
    'Calcule valLow:
    sTmp = sLow
    rv = 0
    For i = 1 To Len(sTmp)
        v = CInt(Mid(sTmp, i, 1)) 'can make error if 1.7E17 passed as parameter
        rv = 10 * rv
        rv = rv + CDbl(Mid(sTmp, i, 1))
        
        If Err.Number <> 0 Then
            Err.Clear
            Exit Function 'EXIT ERROR
        End If
    Next i
    If Len(sTmp) > 0 Then
        dLow = rv
        lowIsSet = True
    End If
    
    'Calcule valMillionCount:
    sTmp = sMillionCount
    rv = 0
    For i = 1 To Len(sTmp)
        v = CInt(Mid(sTmp, i, 1)) 'can make error if 1.7E17 passed as parameter
        rv = 10 * rv
        rv = rv + CDbl(Mid(sTmp, i, 1))
        
        If Err.Number <> 0 Then
            Err.Clear
            Exit Function 'EXIT ERROR
        End If
    Next i
    If Len(sTmp) > 0 Then
        dMillionCount = rv
        MillionCountIsSet = True
    End If
    
    If lowIsSet Then
        valLow = dLow
        
        If MillionCountIsSet Then
            valMillionCount = dMillionCount
        Else
            valMillionCount = 0
        End If
        
        WordStrToLowAndHighDbl = True
    End If
    Err.Clear
End Function  'ok 22.05.2010

'transforme deux doubles représentant un nombre en un string de sortie
Private Function DblToString(valLow, valMillionCount, _
                             ByRef StringToSet As String, ByRef ErrMsg As String) As Boolean
    On Error GoTo DblToString_Err
    Dim d As Double
    Dim deci As Double
    Dim rv As String
    
    d = valLow
    While d >= 1
        d = d / 10
        deci = d - Fix(d)
        d = Fix(d)
        rv = Left(CStr(CDbl(deci * 10)), 1) & rv
    Wend
    If valMillionCount > 0 Then
        Dim numberMillion As Integer
        numberMillion = Len(CStr(MILLION_1)) - 1
        While Len(rv) < numberMillion
            rv = "0" & rv
        Wend
    End If
    d = valMillionCount
    While d >= 1
        d = d / 10
        deci = d - Fix(d)
        d = Fix(d)
        rv = Left(CStr(CDbl(deci * 10)), 1) & rv
    Wend
    
    If rv = "" Then
        rv = 0
    End If
    
    StringToSet = rv
    DblToString = True
    Exit Function
    
DblToString_Err:
    StringToSet = ""
    ErrMsg = "PhilNetFiles.Registry.DblToString Error: " & Err.Description
    DblToString = False
    Err.Clear
End Function  'ok 19.05.2010

Private Function CStrNotNull(Val As Variant)
    CStrNotNull = ""
    On Error Resume Next
    CStrNotNull = CStr(Val)
    If Err.Number <> 0 Then
        CStrNotNull = ""
    End If
End Function

Public Function ListPrinters(ByVal ComputerName As String) As Collection
    Set ListPrinters = ListKeysIn(ComputerName, HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Print\Printers")
End Function 'ok 19.05.2010

'Called BEFORE calling WinKernelUser32 declare aFunctionA instead of aFunctionW,
'in order to NOT call aFunctionA with Unicode parameters
'This function can be time consuming if long strings.
'I preferr to try Way 1 than Way 2 (see explanation in comments down here) if nothing will be written or deleted on disk or in registry.
'if aFunctionA can write or delete something, I first Test te entry parameter string wit tis function:
'tis function returns True if not Unicode Character found in the passed string, returns False if some Unicode character found in the string
Public Function IsAnsi(ByVal aString As String) As Boolean
    IsAnsi = True
    Dim sLength As Long
    Const BLOCK_Size As Integer = 1024 '1024 characters Max will be tested at once
    Dim beginPos As Long
    beginPos = 1
    sLength = Len(aString)
    Dim block As String 'meilleur de garder Mid(aString, beginPos, BLOCK_Size) en mémoire et de l'utiliser comme variable. Plus rapide que de répéter l'expression Mid plusieurs fois dans la fonction. Testé 20180815 Philippe
    While beginPos <= sLength
        block = Mid(aString, beginPos, BLOCK_Size)
        If StrComp(block, StrConv(StrConv(block, vbFromUnicode), vbUnicode), vbBinaryCompare) <> 0 Then
            IsAnsi = False
            beginPos = sLength + 1 'to come out of while loop
        Else
            beginPos = beginPos + BLOCK_Size
        End If
    Wend
End Function
Public Function IsUnicode(ByVal aString As String) As Boolean
    IsUnicode = Not IsAnsi(aString)
End Function
